IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_settings_server_load')
BEGIN DROP PROC pr_settings_server_load END
GO

CREATE PROCEDURE pr_settings_server_load (
	@current_uid nvarchar(255)
	, @co_row_guid uniqueidentifier			-- OPTIONAL
	, @is_debug int = 0
)
AS
BEGIN
/*
- load the smtp settings
	
	exec pr_settings_server_load
		@current_uid = 'tester'
		, @co_row_guid = null
		, @is_debug = 1

*/
	-- =====================================================================================
	-- init
	-- =====================================================================================

	SET NOCOUNT ON;

	IF @is_debug = 1 
		PRINT 'pr_settings_smtp_load - start' 

    DECLARE
		@co_id int
		, @smtp_server nvarchar(255)
		, @smtp_port int
		, @smtp_mailbox_uid nvarchar(255)
		, @smtp_mailbox_pwd nvarchar(255)
		, @smtp_use_ssl int
		, @smtp_disable_service int

	-- ----------------------------------
	-- validation 
	-- ----------------------------------


	-- =====================================================================================
	-- process
	-- =====================================================================================

	SET @co_id = 50

	SELECT @smtp_server= prop_value
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_server'
	AND co_id = @co_id

	SELECT @smtp_port = CAST(ISNULL(prop_value, '0') AS INT)
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_port'
	AND co_id = @co_id

	SELECT @smtp_mailbox_uid= prop_value
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_mailbox_uid'
	AND co_id = @co_id

	SELECT @smtp_mailbox_pwd= prop_value
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_mailbox_pwd'
	AND co_id = @co_id

	SELECT @smtp_use_ssl= CAST(ISNULL(prop_value, '0') AS INT)
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_use_ssl'
	AND co_id = @co_id

	SELECT @smtp_disable_service= CAST(ISNULL(prop_value, '0') AS INT)
	FROM tb_sys_prop
	WHERE prop_name = 'smtp_disable_service'
	AND co_id = @co_id

	-- returns the values 

	SELECT 
		@smtp_server 'smtp_server'
		, @smtp_port 'smtp_port'
		, @smtp_mailbox_uid 'smtp_mailbox_uid'
		, @smtp_mailbox_pwd 'smtp_mailbox_pwd'
		, @smtp_use_ssl 'smtp_use_ssl'
		, @smtp_disable_service 'smtp_disable_service'

	-- =====================================================================================
	-- cleanup
	-- =====================================================================================

	IF @is_debug = 1
		PRINT 'pr_settings_smtp_load - end'

	SET NOCOUNT OFF

END
GO
