IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_settings_server_save')
BEGIN DROP PROC pr_settings_server_save END
GO

CREATE PROCEDURE pr_settings_server_save (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @co_row_guid uniqueidentifier
	, @smtp_server nvarchar(255)
	, @smtp_port int
	, @smtp_mailbox_uid nvarchar(255)
	, @smtp_mailbox_pwd nvarchar(255)
	, @smtp_use_ssl int
	, @smtp_disable_service int

	, @is_debug int = 0
)
AS
BEGIN
/*
-- save the smtp settings
	declare @s nvarchar(max)
	exec pr_settings_server_save 
		@current_uid = 'tester'
		, @result = @s output

		, @co_row_guid = null
		, @smtp_server = ''
		, @smtp_port = 587
		, @smtp_mailbox_uid = ''
		, @smtp_mailbox_pwd = ''
		, @smtp_use_ssl = 1
		, @smtp_disable_service = 1

		, @is_debug = 1
	select @s 'result'
*/
	-- =====================================================================================
	-- init
	-- =====================================================================================

	SET NOCOUNT ON;

	IF @is_debug = 1
		PRINT 'pr_settings_server_save - start'

	DECLARE 
		@co_id int
		, @url nvarchar(255)
		, @module_id int
		, @smtp_server_old nvarchar(255)
		, @smtp_port_old int
		, @smtp_mailbox_uid_old nvarchar(255)
		, @smtp_mailbox_pwd_old nvarchar(255)
		, @smtp_use_ssl_old int
		, @smtp_disable_service_old int

		, @audit_log nvarchar(max)
		, @audit_log_id uniqueidentifier

	SET @result = ''
	--SET @url = ''
	SET @module_id = 1101004

	-- ----------------------------------
	-- validation 
	-- ----------------------------------

	SET @co_id = 0

	SELECT @smtp_server_old = prop_value
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_server'
	AND co_id = @co_id

	SELECT @smtp_port_old = CAST(ISNULL(prop_value, '0') AS INT)
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_port'
	AND co_id = @co_id

	SELECT @smtp_mailbox_uid_old = prop_value
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_mailbox_uid'
	AND co_id = @co_id

	SELECT @smtp_mailbox_pwd_old = prop_value
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_mailbox_pwd'
	AND co_id = @co_id

	SELECT @smtp_use_ssl_old = CAST(ISNULL(prop_value, '0') AS INT)
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_use_ssl'
	AND co_id = @co_id

	SELECT @smtp_disable_service_old = CAST(ISNULL(prop_value, '0') AS INT)
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_disable_service'
	AND co_id = @co_id

	-- =====================================================================================
	-- process
	-- =====================================================================================

	EXEC pr_update_prop_value 
		'smtp_server'
		, @smtp_server
		, @current_uid
		, @co_id

	EXEC pr_update_prop_value 
		'smtp_port'
		, @smtp_port
		, @current_uid
		, @co_id

	EXEC pr_update_prop_value 
		'smtp_mailbox_uid'
		, @smtp_mailbox_uid
		, @current_uid
		, @co_id

	EXEC pr_update_prop_value 
		'smtp_mailbox_pwd'
		, @smtp_mailbox_pwd
		, @current_uid
		, @co_id

	EXEC pr_update_prop_value 
		'smtp_use_ssl'
		, @smtp_use_ssl
		, @current_uid
		, @co_id

		
	EXEC pr_update_prop_value 
		'smtp_disable_service'
		, @smtp_disable_service
		, @current_uid
		, @co_id

	SET @result = 'OK'

	-- prepare the audit log
	SET @audit_log = ''
	SET @audit_log = @audit_log + dbo.fn_has_changes('Server', @smtp_server_old, @smtp_server)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Port', @smtp_port_old, @smtp_port)
	SET @audit_log = @audit_log + dbo.fn_has_changes('mailbox ID', @smtp_mailbox_uid_old, @smtp_mailbox_uid)
	
	IF @smtp_mailbox_pwd_old <> @smtp_mailbox_pwd 
	BEGIN
		SET @audit_log = @audit_log + ', Password has Changed'
	END

	SET @audit_log = @audit_log + dbo.fn_has_changes('Use SSL', dbo.fn_fmt_yesno(@smtp_use_ssl_old), dbo.fn_fmt_yesno(@smtp_use_ssl))
	SET @audit_log = @audit_log + dbo.fn_has_changes('Disabled SMTP Service', dbo.fn_fmt_yesno(@smtp_disable_service_old), dbo.fn_fmt_yesno(@smtp_disable_service))

	-- remove the first comma symbol
	IF LEN(@audit_log) > 0
		SET @audit_log = RIGHT(@audit_log, LEN(@audit_log) - 1)
	ELSE
		SET @audit_log = '(No Changes)'

	SET @audit_log = 'Updated SMTP Mailbox Settings: '
						+ @audit_log

	-- ------------------------------------
	-- append audit log	
	-- ------------------------------------

	EXEC pr_sys_append_task_inbox 
			@current_uid
			, @url							--@task_inbox_url 
			, @audit_log					--@task 
			, null							--@task_fk_value
			, @module_id					--@module_id
			, @co_row_guid			
			, @audit_log_id output			--@task_inbox_id 
			, 'pr_settings_server_save'		--@proc_name
			
	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	IF @is_debug = 1 PRINT 'pr_settings_server_save - exit'

	SET NOCOUNT OFF

END
GO
