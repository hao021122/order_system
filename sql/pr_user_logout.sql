IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_user_logout')
BEGIN DROP PROC pr_user_logout END
GO

create proc [dbo].[pr_user_logout] (
	@sess_uid uniqueidentifier 

	-- result
	, @result nvarchar(255) output
	
	, @is_debug int = 0
)
as
begin

/*#1000_0260
15-aug-15,lhw
- user is logging on to the system

	-- login ok
	declare @s nvarchar(255)
	exec pr_user_logout
			@sess_uid = '9ADBBD82-D3F8-44B5-98DD-5CE7AAC117F7'
			, @result		= @s output, @is_debug		= 1	
	select @s '@result'

	-- invalid sess uid
	declare @s nvarchar(255)
	exec pr_user_logout
			@sess_uid = '349a631f-5cf5-491d-ba33-e9a75a6ddaa4'
			, @result		= @s output, @is_debug		= 1	
	select @s '@result'

	

*/

	-- ==========================================================
	-- init
	-- ==========================================================
	set nocount on

	declare
		@module_id int
		, @audit_log nvarchar(255)
		, @audit_log_id uniqueidentifier
		, @uid nvarchar(255)
		, @user_id uniqueidentifier

	set @result = ''	

	-- ==========================================================
	-- process
	-- ==========================================================
	
	if not exists(
		select *
		from tb_user_access_log
		where
			sess_uid = @sess_uid
	)
	begin

		--27-feb-16,lhw-we don't need to handle anything
		--set @module_id = -2								-- alert
		--set @audit_log = 'Logout failed because the session ID is invalid: ' + isnull(cast(@sess_uid as nvarchar(36)), '?')
		--set @result = 'Invalid session ID'
		--set @uid = '?'

		if @is_debug = 1 print 'Logout failed because the session ID is invalid'
		return 

	end
	else 
	begin
	
		-- update to the access log
		update tb_user_access_log 
		set 
			logout_on = getdate()
		where
			sess_uid = @sess_uid

		-- get the login_id
		select
			@uid = login_id
			, @user_id = user_id
		from tb_user_access_log 
		where
			sess_uid = @sess_uid

		set @module_id = -4								--logout
		set @audit_log = '"' + @uid + '" has logged out from the system'
		set @result = 'OK'

	end

	if @is_debug = 1
		print @audit_log

	-- --------------------------------------------
	-- create audit log 
	-- --------------------------------------------
	
	exec pr_sys_append_task_inbox 
			@uid
			, ''					--@task_inbox_url 
			, @audit_log			--@task 
			, @user_id				--@task_fk_value
			, @module_id
			, null					--@co_row_guid
			, @audit_log_id output	--@task_inbox_id 
			, 'pr_user_logout'		--@proc_name

	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	set nocount off

end
GO
