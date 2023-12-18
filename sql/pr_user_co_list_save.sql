IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_user_co_list_save')
BEGIN DROP PROC pr_user_co_list_save END
GO

create proc [dbo].[pr_user_co_list_save] (
	@current_uid nvarchar(255) 
	, @result nvarchar(max) output

	, @user_id uniqueidentifier 
	, @ids nvarchar(max)		--the comma separated of 'co id + user group id'
	
	, @url nvarchar(255)
	, @is_debug int = 0
)
as
begin

/*#1070_0120
23-feb-16,lhw
- update the accessible co or the given user.

	declare @s nvarchar(max), @id uniqueidentifier
	set @id = 'bcb4303d-c171-4468-b453-b5f8cbeb4f95'
	exec pr_user_co_list_save
			@current_uid			= 'tester'
			, @result				=@s output
			
			, @user_id				= '07701905-9E8A-4F9D-8619-EEC1FB248BDE'
			, @ids					= '8FDF41BB-0285-462E-8FD6-E5D4EB64A808+E264CF57-05C5-4F11-9799-9DCA56C68012'
			, @url					= '~/testing.aspx'
			, @is_debug				= 1
	select @s 'result', @id 'id'
	

*/

	-- ==========================================================
	-- init
	-- ==========================================================
	
	if @is_debug = 1 print 'pr_user_co_list_save - start'

	set nocount on

	declare
		@audit_log nvarchar(max)
		, @audit_log_id uniqueidentifier
		, @module_id int
		, @rowid int
		, @login_id nvarchar(255)
		, @user_group nvarchar(255)
		, @user_group_old nvarchar(255)
		, @co_name nvarchar(255)
		

	declare @tb1 table (
		rowid int identity(1,1)
		, col nvarchar(255)
		, co_row_guid uniqueidentifier
		, user_group_id uniqueidentifier
		, user_group_id_old uniqueidentifier
		, audit_log nvarchar(max)
	)

	set @result = ''

	-- ==========================================================
	-- process
	-- ==========================================================

	if len(isnull(@ids, '')) = 0
	begin
		
		if @is_debug = 1 print 'not accessible to any company'

		delete from tb_users_co
		where user_id = @user_id

		set @result = 'OK'

	end
	else
	begin

		begin try

			insert into @tb1 (col)
			select col
			from dbo.fn_str_to_table(@ids)

			update @tb1
			set 
				co_row_guid = cast(left(col, charindex('+', col) -1) as uniqueidentifier)
				, user_group_id = cast(substring(col, charindex('+', col) + 1, len(col) - charindex('+', col)) as uniqueidentifier)

			-- ----------------------------------------
			-- delete the inaccessible company
			-- ----------------------------------------

			-- generate the audit log
			update @tb1
			set audit_log = 'disallow'
			where 
				co_row_guid in (
					select [@tb1].co_row_guid
					from @tb1 
					inner join tb_users_co uc on uc.co_row_guid = [@tb1].co_row_guid and uc.user_id = @user_id
					where 
						dbo.fn_to_uid(uc.user_group_id) <> dbo.fn_empty_guid()
						and [@tb1].user_group_id = dbo.fn_empty_guid()
				)
				
			-- delete the settings
			delete from tb_users_co
			where 
				user_id = @user_id
				and co_row_guid in (
					select co_row_guid
					from @tb1
					where user_group_id = dbo.fn_empty_guid()
				)


			--<<======
			--17-dec-18,lhw-bug fixed- the 'disallow' rec might not be included in @ids!!
			insert into @tb1 (co_row_guid, user_group_id, audit_log)
			select 
				co_row_guid, user_group_id, 'disallow'
			from tb_users_co uc0
			where
				user_id = @user_id
				and co_row_guid not in (
					select co_row_guid
					from @tb1
				)
				
			delete from tb_users_co
			where 
				user_id = @user_id
				and co_row_guid in (
					select co_row_guid
					from @tb1
					where audit_log = 'disallow'
				)

			--<<======


			-- ----------------------------------------
			-- update the settings
			-- ----------------------------------------

			-- generate the audit log
			update @tb1
			set 
				audit_log = 'change'
				, user_group_id_old = (
										select user_group_id
										from tb_users_co uc0
										where 
											uc0.user_id = @user_id
											and uc0.co_row_guid = [@tb1].co_row_guid
									)
			where 
				co_row_guid in (
					select [@tb1].co_row_guid
					from @tb1 
					inner join tb_users_co uc on uc.co_row_guid = [@tb1].co_row_guid and uc.user_id = @user_id
					where 
						dbo.fn_to_uid(uc.user_group_id) <> [@tb1].user_group_id
						and dbo.fn_to_uid(uc.user_group_id) <> dbo.fn_empty_guid()
						and [@tb1].user_group_id <> dbo.fn_empty_guid()
				)
				and audit_log is null				--17-dec-18,lhw-bug fixed

			-- update the settings
			update tb_users_co
			set user_group_id = [@tb1].user_group_id 
			from @tb1
			where 
				user_id = @user_id
				and tb_users_co.co_row_guid = [@tb1].co_row_guid			
				and [@tb1].user_group_id <> dbo.fn_empty_guid()
	
			-- ----------------------------------------
			-- append the new settings
			-- ----------------------------------------

			-- generate the audit log
			update @tb1
			set audit_log = 'allow'
			where 
				co_row_guid in (
					select [@tb1].co_row_guid
					from @tb1 
					left outer join tb_users_co uc on uc.co_row_guid = [@tb1].co_row_guid and uc.user_id = @user_id
					where 
						uc.user_group_id is null
						and [@tb1].user_group_id <> dbo.fn_empty_guid()
						and [@tb1].audit_log is null				--17-dec-18,lhw-bug fixed
				)
				and audit_log is null								--17-dec-18,lhw-bug fixed

			-- append the settings
			insert into tb_users_co (
				users_co_id,user_id,user_status_id,user_group_id,activate_on,co_row_guid
			) 
			select
				newid()
				, @user_id
				, 1	--active
				, [@tb1].user_group_id
				, null
				, [@tb1].co_row_guid
			from @tb1 
			left outer join tb_users_co uc on uc.co_row_guid = [@tb1].co_row_guid and uc.user_id = @user_id
			where 
				uc.user_group_id is null
				and [@tb1].user_group_id <> dbo.fn_empty_guid()
				and audit_log <> 'disallow'							--17-dec-18,lhw-bug fixed

						
			----if @is_debug =	1
			----	select * from @tb1
				
			-- ----------------------------------------
			-- append the audit log
			-- ----------------------------------------

			-- delete the record that does not have changes
			delete from @tb1 
			where audit_log is null

			set @module_id = 130001	--users

			select @login_id = login_id
			from tb_users
			where user_id = @user_id

			if len(isnull(@login_id, '')) = 0
				set @login_id = '?'
						
			set @rowid = 0

			while exists(
				select * 
				from @tb1
				where rowid > @rowid
			)
			begin

				
				select top 1
					@rowid = rowid
					, @audit_log = case audit_log
									when 'disallow' then '"' + @login_id + '" - disallow accessing to this company: "' + isnull(c.co_name, '?') + '"'

									when 'change ' then '"' + @login_id 
														+ '" - change the user group in this company: "' + isnull(c.co_name, '?') 
														+ '", user group: from "' + ug_old.user_group_desc + '" to "' + ug.user_group_desc + '"'

									when 'allow ' then '"' + @login_id 
														+ '" - allow access to this company: "' + isnull(c.co_name, '?') 
														+ '", user group: "' + ug.user_group_desc + '"'
									else ''
									end

				from @tb1
				inner join tb_co_profile c on c.co_row_guid = [@tb1].co_row_guid
				left outer join tb_user_group ug on ug.user_group_id = [@tb1].user_group_id
				left outer join tb_user_group ug_old on ug_old.user_group_id = [@tb1].user_group_id_old
				where
					rowid > @rowid

				order by rowid 

				----delete from @tb1
				----where rowid = @rowid

				exec pr_sys_append_task_inbox 
						@current_uid
						, @url					--@task_inbox_url 
						, @audit_log			--@task 
						, @user_id				--@task_fk_value
						, @module_id			--@module_id
						, null					--@co_row_guid
						, @audit_log_id output	--@task_inbox_id 
						, 'pr_user_co_list_save'			--@proc_name

			end

			set @result = 'OK'
			
		end try
		begin catch

			if @is_debug = 1 print error_message()
			set @result = 'Failed to update the accessible company'

		end catch

	end

	if @is_debug = 1 
		select * from @tb1


	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	if @is_debug = 1 print 'pr_user_co_list_save - exit'
	
	set nocount off

end
GO
