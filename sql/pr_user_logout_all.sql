IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_user_logout_all')
BEGIN DROP PROC pr_user_logout_all END
GO

create proc [dbo].[pr_user_logout_all] (
	@current_uid nvarchar(255)
	, @result nvarchar(255) output
	
	, @user_id uniqueidentifier				--logout all connections for this user id.

	, @is_debug int = 0
)
as
begin

/*#1000_0261
15-aug-15,lhw
- closed all connections for the given user id.


	declare @s nvarchar(255)
	exec pr_user_logout_all
			@current_uid = 'tester'
			, @result = @s output
			, @user_id = '00000000-0000-0000-0000-000000000001'
			, @is_debug = 1
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

	set @result = ''	

	-- ==========================================================
	-- process
	-- ==========================================================
	
	
	-- update to the access log
	update tb_user_access_log 
	set 
		logout_on = getdate()
	where
		user_id = @user_id
		and logout_on is null


	-- get the login_id
	select
		@uid = login_id
	from tb_users
	where
		user_id = @user_id

	-- -----------------
	set @module_id = -4								--logout
	set @audit_log = 'Closed all connections made by ' + @uid
	set @result = 'OK'


	if @is_debug = 1
		print @audit_log

	-- --------------------------------------------
	-- create audit log 
	-- --------------------------------------------
	
	exec pr_sys_append_task_inbox 
			@current_uid
			, ''					--@task_inbox_url 
			, @audit_log			--@task 
			, @user_id				--@task_fk_value
			, @module_id
			, null					--@co_row_guid
			, @audit_log_id output	--@task_inbox_id 
			, 'pr_user_logout_all'		--@proc_name

	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	set nocount off

end
GO
