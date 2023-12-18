IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_user_list')
BEGIN DROP PROC pr_user_list END
GO

create proc [dbo].[pr_user_list] (	
	@startRowIndex int				-- for pagination
	, @maximumRows int				-- for pagination

	, @current_uid nvarchar(255)	-- for access control

	-- search fields
	, @login_id nvarchar(255)
	, @user_name nvarchar(255)
	, @user_type_id int
	, @user_status_id int
	, @co_row_guid uniqueidentifier

	, @is_debug int = 0
)
as
begin

/*#1000_0190-secu-pr_user_list
16-aug-15,lhw
- returns the user list

	
	exec pr_user_list
			@startRowIndex			= 0
			, @maximumRows			= 1000

			, @current_uid			='admin'

			-- search fields
			, @login_id				= ''
			, @user_name			= ''
			, @user_type_id			= -1
			, @user_status_id		= -1
			, @co_row_guid			= null--'6dcb70d0-dc84-4e7f-a069-44050182ddb7'
			, @is_debug				= 1
	
*/

	-- ==========================================================
	-- init
	-- ==========================================================

	set nocount on

	declare
		@current_user_type_id int

	if len(isnull(@login_id, '')) > 0
		set @login_id = '%' + @login_id + '%'

	if len(isnull(@user_name, '')) > 0
		set @user_name = '%' + @user_name + '%'

	select
		@current_user_type_id = user_type_id
	from tb_users
	where login_id = @current_uid

	if @current_uid = 'admin'
	and @current_user_type_id is null
	begin
		set @current_user_type_id = 10			--superuser
	end	

	if @is_debug = 1
		print '@current_user_type_id=' + cast(isnull(@current_user_type_id, 0) as nvarchar)

	-- ==========================================================
	-- process
	-- ==========================================================

	if dbo.fn_to_uid(@co_row_guid) <> dbo.fn_empty_guid()
	begin

		-- -------------------------------------
		-- show the user for a client.
		-- -------------------------------------
		
		if @is_debug = 1 print 'show the user for a client => ' + cast(@co_row_guid as nvarchar(36))

		select 
			u.user_id as id
			
			-- stop overload the user.
			--, u.modified_on
			--, u.modified_by
			--, u.created_on
			--, u.created_by

			, u.login_id
			, u.user_name as name
			, user_type = u.user_type_id
			, user_status = u.user_status_id
			, u.last_access_on
			, u.pwd_expiry_on						--9-feb-19,lhw
			, us.user_status_desc
			, ut.user_type_desc
			, us.user_status_desc
			, u1.user_group_desc
			, rowidx
			, co_count = (
				select count(*)
				from tb_users_co uc
				where uc.user_id = u.user_id
			)

			-- if the caller specified the co_row_guid, include the user group.
			, user_group = (
								select uc2.user_group_id
								from tb_users_co uc2
								where 
									uc2.co_row_guid = @co_row_guid
									and uc2.user_id = u.user_id
							)

			--14-may-20,lhw-whitelist
			, wl = (
				select
					f5						-- device ip address (IP pattern)
				from tb_obj_ext oe
				where
					oe.ext_group = 'users'
					and oe.ext_code = 'tx_permission'
					and oe.id1 = cast(u1.user_id as nvarchar(36))		
			)

		from (
			select 
				rowidx = row_number() over (order by u0.login_id)
				, u0.user_id
				, ug.user_group_desc
			from tb_users u0		
			inner join tb_users_co uc0 on uc0.user_id = u0.user_id
			inner join tb_user_group ug on ug.user_group_id = uc0.user_group_id

			where
				(
					len(isnull(@login_id, '')) = 0
					or u0.login_id like @login_id
				)
				and (
					len(isnull(@user_name, '')) = 0
					or u0.user_name like @user_name
				)
				and (
					isnull(@user_type_id, '-1') <= 0
					or u0.user_type_id = @user_type_id
				)
				
				and (
					@current_user_type_id = 10											--superuser
					or u0.user_type_id > @current_user_type_id							--18-sep-15,lhw-accessible to the lower rank record.
				)
				and (
					isnull(@user_status_id, '-1') <= 0
					or u0.user_status_id = @user_status_id
				)
				and (
					dbo.fn_to_uid(@co_row_guid) = dbo.fn_empty_guid()
					or uc0.co_row_guid = @co_row_guid
				)


		) as u1
		inner join tb_users u on u.user_id = u1.user_id
		inner join tb_user_type ut on ut.user_type_id = u.user_type_id 
		inner join tb_user_status us on us.user_status_id = u.user_status_id

		where
			u1.rowidx between @startRowIndex + 1 and @startRowIndex + @maximumRows
		
		order by 
			u.login_id

		
		

	end
	else
	begin
		
		-- -------------------------------------
		-- for sys admin
		-- -------------------------------------

		if @is_debug = 1 print 'show the user  - sys admin'

		select 
			u.user_id as id
			--, u.modified_on
			--, u.modified_by
			--, u.created_on
			--, u.created_by
			, u.login_id
			, u.user_name as name
			, user_type = u.user_type_id
			, user_type_desc
			, u1.user_group_desc
			, user_status = u.user_status_id
			, u.last_access_on

			, u.pwd_expiry_on						--9-feb-19,lhw

			--, ut.user_type_desc
			, us.user_status_desc

			, rowidx

			, co_count = (
							select count(*)
							from tb_users_co uc
							where uc.user_id = u.user_id
						)

		from (
			select 
				rowidx = row_number() over (order by u0.login_id)
				, u0.user_id
				, ug.user_group_desc
			from tb_users u0		
			inner join tb_users_co uc0 on uc0.user_id = u0.user_id
			inner join tb_user_group ug on ug.user_group_id = uc0.user_group_id
			where
				(
					len(isnull(@login_id, '')) = 0
					or u0.login_id like @login_id
				)
				and (
					len(isnull(@user_name, '')) = 0
					or u0.user_name like @user_name
				)
				and (
					isnull(@user_type_id, '-1') <= 0
					or u0.user_type_id = @user_type_id
				)	
				and (
					@current_user_type_id = 10											--superuser
					or u0.user_type_id > @current_user_type_id							--18-sep-15,lhw-accessible to the lower rank record.
				)
				and (
					isnull(@user_status_id, '-1') <= 0
					or u0.user_status_id = @user_status_id
				)

		) as u1
		inner join tb_users u on u.user_id = u1.user_id
		inner join tb_user_type ut on ut.user_type_id = u.user_type_id
		inner join tb_user_status us on us.user_status_id = u.user_status_id

		where
			u1.rowidx between @startRowIndex + 1 and @startRowIndex + @maximumRows
		
		order by 
			u.login_id

		
		
					
	end

	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	set nocount off

end
GO
