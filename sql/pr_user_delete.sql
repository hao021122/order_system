IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_user_delete')
BEGIN DROP PROC pr_user_delete END
GO

create proc [dbo].[pr_user_delete] (	
	@current_uid nvarchar(255)	-- for access control
	, @delete_user_id uniqueidentifier

	, @co_row_guid uniqueidentifier

	, @url nvarchar(255)
	, @module_id int

	, @result nvarchar(255) output
	, @is_debug int = 0
)
as
begin

/*#1000_0210
16-aug-15,lhw
- delete the user.

	declare @s nvarchar(255)
	exec pr_user_delete
			@current_uid			='admin'
			, @delete_user_id		= '35b0f02f-7b4f-45a9-9000-4a2e212f115a'
			, @co_row_guid			= null
			, @url					='..aspx'
			, @module_id			= -1
			, @result				= @s output
			, @is_debug				= 1
	select @s 'result'

*/

	-- ==========================================================
	-- init
	-- ==========================================================

	set nocount on

	declare
		@delete_login_id nvarchar(255)
		, @delete_user_type_desc nvarchar(255)
		, @audit_log nvarchar(255)
		, @audit_log_id uniqueidentifier
		, @co_user_count int
		, @msg nvarchar(255)
		

	set @result = ''
	if isnull(@module_id, 0) = 0 set @module_id = 130001

	select 
		@delete_login_id = u.login_id
		,  @delete_user_type_desc = isnull(user_type_desc, '')
	from tb_users u
	inner join tb_user_type ut on ut.user_type_id = u.user_type_id
	where
		u.user_id = @delete_user_id
			
	-- ==========================================================
	-- process
	-- ==========================================================

	if exists(
		select *
		from tb_users
		where
			user_id = @delete_user_id
	)
	begin

		if @is_debug = 1
			print 'user record exists. continue to work to deletion...'

		-- if co_row_guid is null, delete all access in the client database.
		-- this condition will be meet if the system admin deleting the user record.
		if dbo.fn_to_uid(@co_row_guid) = dbo.fn_empty_guid()	
		begin

			if @is_debug = 1
				print 'force deleting user record'

			delete from tb_users
			where user_id = @delete_user_id

			delete from tb_users_co
			where user_id = @delete_user_id

			set @audit_log = 'Deleted user record "'
							+ @delete_login_id
							+ '", type: "'
							+ @delete_user_type_desc
							+ '"'
							+ isnull(@msg, '')

		end
		else
		begin

			-- delete the user from the client database.
			if dbo.fn_to_uid(@co_row_guid) <> dbo.fn_empty_guid()	
			begin

				if @is_debug = 1
					print 'delete the user from the client database'

				delete from tb_users_co
				where 
					user_id = @delete_user_id
					and dbo.fn_to_uid(co_row_guid) = @co_row_guid

				--select 
				--	@msg = ', client: "' + co_name + '"'
				--from tb_co
				--where dbo.fn_to_uid(row_guid) = @co_row_guid
			end

			-- ------------------------------------
			-- delete the user record if it is there is no referencing from tb_users_co 
		
			select @co_user_count = count(*)
			from tb_users_co
			where user_id = @delete_user_id
		
			if @co_user_count = 0 
			and exists(
				select *
				from tb_users
				where 
					user_id = @delete_user_id
					and user_type_id > 20		-- it's user, allow deletion.
			)
			begin

				if @is_debug = 1
					print 'delete the user from the database'

				delete from tb_users
				where user_id = @delete_user_id

			end
			else
			begin

				if @is_debug = 1
					print 'user record still in use. abort deletion'

			end

			-- ------------------------------------

		end

		set @result = 'OK'
		set @audit_log = 'Deleted user record "'
						+ @delete_login_id
						+ '", type: "'
						+ @delete_user_type_desc
						+ '"'
						+ isnull(@msg, '')

	end
	else
	begin

		set @result = 'Deletion to this user record "'
						+ isnull(@delete_login_id, '?')
						+ '", type: "'
						+ isnull(@delete_user_type_desc, '?')
						+ '" - is not allowed'

		set @audit_log = @result

		if @is_debug = 1
			print @result

	end

	-- ------------------------------------
	-- append audit log	
	-- ------------------------------------

	exec pr_sys_append_task_inbox 
			@current_uid
			, @url					--@task_inbox_url 
			, @audit_log 			--@task 
			, @delete_user_id		--@task_fk_value
			, @module_id
			, @co_row_guid
			, @audit_log_id output	--@task_inbox_id 
			, 'pr_user_delete'		--@proc_name
	
	if @is_debug = 1
		print '@audit_log=' + isnull(@audit_log, '?')

	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	set nocount off

end
GO
