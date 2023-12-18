IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_admin_create_user_save')
BEGIN DROP PROC pr_admin_create_user_save END
GO

CREATE PROCEDURE [dbo].[pr_admin_create_user_save] (
	@current_uid nvarchar(255)
	, @result nvarchar(255) output

	, @user_id uniqueidentifier output
	, @login_id nvarchar(255)
	, @user_name nvarchar(255)
	, @user_status_id int
	, @user_type_id int
	, @pwd nvarchar(255)
	--, @login_validity_start datetime
	--, @login_validity_end datetime
	
	, @url nvarchar(255)		-- FROM which URL the record was called
	, @module_id int			-- which module 

	--, @wl nvarchar(255)			--14-may-20,lhw

	, @is_debug int = 0
)
AS
BEGIN
/* pr_admin_create_user_save

- save the user record.

	declare
		@id uniqueidentifier, @s nvarchar(255)
	exec pr_admin_create_user_save
			@current_uid		= 'tester'
			, @result			= @s output
			, @user_id			= @id output
			, @login_id			= 'd@test.com'
			, @user_name		='dd d'
			, @pwd = 'a'
			, @user_status_id	= 1
			, @user_type_id		= 10
			--, @login_validity_start = '2016-02-27'
			--, @login_validity_end	= '2016-12-31'
			, @url				= '~/modules/test.aspx'
			, @module_id		= 110016
			, @wl = null
			, @is_debug	= 1
	SELECT @s 'result', @id 'user id'

*/

	-- ==========================================================
	-- init
	-- ==========================================================

	SET NOCOUNT ON

	IF @is_debug = 1
		PRINT 'pr_user_save - start'

	DECLARE
		@login_id_old nvarchar(255)
		, @user_name_old nvarchar(255)
		, @user_status_desc_old nvarchar(255)
		, @user_status_desc nvarchar(255)
		, @user_type_desc_old nvarchar(255)
		, @user_type_desc nvarchar(255)
		, @user_status_id_old int
		, @pwd_old nvarchar(255)
		--, @login_validity_start_old datetime
		--, @login_validity_end_old datetime
		, @continue int
		--, @wl_old nvarchar(255)					--14-may-20,lhw

		, @audit_log nvarchar(max)
		, @audit_log_id uniqueidentifier

	SET @result = ''

	IF ISNULL(@module_id, 0) = 0 SET @module_id = 1101012

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF LEN(ISNULL(@login_id, '')) = 0
	BEGIN
		SET @result = 'Email Cannot Be Blank!!'
		SET NOCOUNT OFF
		RETURN
	END

	IF dbo.fn_is_valid_email(@login_id) = 0
	BEGIN
		SET @result = 'Invalid Email Address!!'
		SET NOCOUNT OFF
		RETURN
	END

	-- login id is unique
	IF dbo.fn_to_uid(@user_id) = dbo.fn_empty_guid()
	AND EXISTS(
		SELECT *
		FROM tb_users
		WHERE 
			login_id = @login_id							--unique value
			AND user_id <> dbo.fn_to_uid(@user_id)			--PK value
	)
	BEGIN
		SET @result = 'The ID Has Already Been Registered!!'

		SET @audit_log = 'Failed to Register New User, User Record Already Exist: ' + @login_id
		SET @user_id = dbo.fn_empty_guid()

		EXEC pr_sys_append_task_inbox 
				@current_uid
				, @url					--@task_inbox_url 
				, @audit_log			--@task 
				, @user_id				--@task_fk_value
				, @module_id			--@module_id
				, null					--@co_row_guid
				, @audit_log_id output	--@task_inbox_id 
				, 'pr_user_save'		--@proc_name

		SET NOCOUNT OFF
		RETURN
	END

	IF LEN(ISNULL(@user_name, '')) = 0
	BEGIN		
		SET @result = 'Username Cannot Be Blank!!'
		SET NOCOUNT OFF
		RETURN

		--SET @user_name = LEFT(@login_id, charindex('@', @login_id) - 1)
	END

	IF ISNULL(@user_type_id, 0) <= 0
	BEGIN
		SET @result = 'User Type Cannot Be Blank!!'
		SET NOCOUNT OFF
		RETURN
	END

	IF LEN(ISNULL(@pwd, '')) = 0
	BEGIN
		SET @result = 'Password Cannot Be Blank!!'
		SET NOCOUNT OFF 
		RETURN
	END
	
	-- ------------------------------------
	-- get the display text.
	-- ------------------------------------
	IF ISNULL(@user_status_id , 0) = 0
	BEGIN
		SET @user_status_id = 1	--active
	END

	SELECT @user_status_desc = isnull(user_status_desc, '')
	FROM tb_user_status us 
	WHERE us.user_status_id = @user_status_id

	SELECT @user_type_desc = isnull(user_type_desc, '')
	FROM tb_user_type ut 
	WHERE ut.user_type_id = @user_type_id
	 		
	-- ==========================================================
	-- process
	-- ==========================================================

	IF dbo.fn_to_uid(@user_id) = dbo.fn_empty_guid()
	BEGIN

		-- ------------------------------------
		-- insert record
		-- ------------------------------------
		
		SET @user_id = NEWID()		-- must be random value

		INSERT INTO tb_users (
			user_id,modified_on,modified_by,created_on,created_by,login_id,user_name,user_status_id,user_type_id, pwd
			--,login_validity_start, login_validity_end			
		) VALUES (
			@user_id,GETDATE(),@current_uid,GETDATE(),@current_uid,@login_id,ISNULL(@user_name, ''),@user_status_id,@user_type_id, @pwd
			--,@login_validity_start, @login_validity_end
		);
				
		SET @audit_log = 'Added User Record: '
							+ @login_id
							+ ' => '
							+ ' User Status=' + @user_status_desc
							+ ', User Type=' + @user_type_desc

		IF @is_debug = 1
			PRINT 'added new user => audit log msg=>' + isnull(@audit_log, '???')

		SET @result = 'OK'
	END
	ELSE
	BEGIN

		-- ------------------------------------
		-- update record
		-- ------------------------------------

		SELECT
			@login_id_old = a.login_id
			,@user_name_old = a.user_name
			,@user_status_desc_old = user_status_desc
			,@user_type_desc_old = user_type_desc
			,@user_status_id_old = a.user_status_id
			,@pwd_old = pwd
			--,@login_validity_start_old = login_validity_start
			--,@login_validity_end_old = login_validity_end
		FROM tb_users a
		INNER JOIN tb_user_status us on us.user_status_id = a.user_status_id
		INNER JOIN tb_user_type ut on ut.user_type_id = a.user_type_id
		WHERE
			a.user_id = @user_id

		UPDATE tb_users
		SET
			modified_on			= GETDATE()
			, modified_by		= @current_uid
			
			, login_id			= @login_id
			, user_name			= @user_name
			--, user_status_id	= @user_status_id		--16-aug-15,lhw-the 'status' field will be updated by other stored proc.
			, user_type_id		= @user_type_id
			, pwd				= @pwd
			
			--, login_validity_start = @login_validity_start
			--, login_validity_end = @login_validity_end
		WHERE 
			user_id = @user_id

		-- prepare the audit log
		SET @audit_log = ''
		SET @audit_log = @audit_log + dbo.fn_has_changes('login ID', @login_id_old, @login_id)
		SET @audit_log = @audit_log + dbo.fn_has_changes('user name', @user_name_old, @user_name)	
		--SET @audit_log = @audit_log + dbo.fn_has_changes('user status', @user_status_desc_old, @user_status_desc)
		SET @audit_log = @audit_log + dbo.fn_has_changes('user type', @user_type_desc_old, @user_type_desc)
		--SET @audit_log = @audit_log + dbo.fn_has_changes('validity FROM', dbo.fn_fmt_date(@login_validity_start_old), dbo.fn_fmt_date(@login_validity_start))
		--SET @audit_log = @audit_log + dbo.fn_has_changes('validity to', dbo.fn_fmt_date(@login_validity_end_old), dbo.fn_fmt_date(@login_validity_end))

		
		-- remove the first comma symbol
		if len(@audit_log) > 0
			SET @audit_log = right(@audit_log, len(@audit_log) - 1)
		else
			----SET @audit_log = '(no changes)'
			SET @audit_log = null

		SET @audit_log = 'Updated user record: '
						+ @login_id
						+ ' => '
						+ @audit_log 

		if @is_debug = 1
			print 'updated user'

		SET @result = 'User Updated Successfully!!!'
	end

	-- -----------------------------
	-- 14-may-20,lhw
	-- -----------------------------

	--if not exists(
	--	SELECT *
	--	FROM tb_obj_ext
	--	WHERE
	--		ext_group = 'users'
	--		and ext_code = 'tx_permission'
	--		and id1 = cast(@user_id as nvarchar(36))
	--)
	--BEGIN
		
	--	insert into tb_obj_ext (
	--		created_by, created_on
	--		, modified_by, modified_on
	--		, ext_id
	--		, ext_group
	--		, ext_code
	--		, ext_seq
	--		, id1
	--	)
	--	values (
	--		@current_uid, getdate()
	--		, @current_uid, getdate()
	--		, newid()
	--		, 'users'
	--		, 'tx_permission'
	--		, 1
	--		, cast(@user_id as nvarchar(36))
	--	)
		
	--end
	--else
	--BEGIN

	--	SELECT
	--		@wl_old = f5
	--	FROM tb_obj_ext
	--	WHERE
	--		ext_group = 'users'
	--		and ext_code = 'tx_permission'
	--		and id1 = cast(@user_id as nvarchar(36))

	--end

	--update tb_obj_ext
	--SET
	--	f5 = @wl
	--WHERE
	--	ext_group = 'users'
	--	and ext_code = 'tx_permission'
	--	and id1 = cast(@user_id as nvarchar(36))	


	--if isnull(@wl_old, '') <> isnull(@wl, '')
	--BEGIN
	--	SET @audit_log = @audit_log
	--					+ ', device access control has been changed FROM "'
	--					+ @wl_old
	--					+ '" to "'
	--					+ @wl
	--					+ '"'

	--end


	-- ------------------------------------
	-- append audit log	
	-- ------------------------------------
	
	if @audit_log <> null	
	BEGIN

		exec pr_sys_append_task_inbox 
				@current_uid
				, @url					--@task_inbox_url 
				, @audit_log			--@task 
				, @user_id				--@task_fk_value
				, @module_id			--@module_id
				, null					--@co_row_guid
				, @audit_log_id output	--@task_inbox_id 
				, 'pr_user_save'		--@proc_name

	end
			
	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	IF @is_debug = 1
		PRINT 'pr_user_save - exit'

	SET NOCOUNT OFF

END
GO
