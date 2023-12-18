IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_quotation_setting_save')
BEGIN DROP PROC pr_quotation_setting_save END
GO

CREATE PROCEDURE [dbo].[pr_quotation_setting_save] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @receipt_header nvarchar(max)
	, @receipt_footer nvarchar(max)
	, @no_of_blank_line int

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_quotation_setting_save

sample code:

	EXEC pr_quotation_setting_save
		@current_uid = 'tester'

		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = '~/q'
		, @is_debug = 0
		 

*/

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON
	

	DECLARE
		@module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)
		
		, @smtp_server_old nvarchar(255)
		, @smtp_port_old int
		, @smtp_mailbox_uid_old nvarchar(255)
		, @smtp_mailbox_pwd_old nvarchar(255)
		, @smtp_use_ssl_old int
		, @smtp_disable_service_old int


		, @receipt_header_old nvarchar(max)
		, @receipt_footer_old nvarchar(max)
		, @no_of_blank_line_old int

		, @co_id2 int
	
	SET @result = NULL
	SET @module_id = 1101008
	
	EXEC pr_sys_get_map_id
			@current_uid	= @current_uid
			, @guid_id		= @co_id
			, @id			= @co_id2 output
			, @is_debug		= @is_debug


	-- ================================================================
	-- process 
	-- ================================================================

	SELECT @receipt_header_old = prop_value
	FROM tb_sys_prop
	WHERE prop_name = 'quotation-header'
		
	SELECT @receipt_footer_old = prop_value
	FROM tb_sys_prop
	WHERE prop_name = 'quotation-footer'
	
	SELECT @no_of_blank_line_old = ISNULL(CAST(prop_value AS INT), 0)
	FROM tb_sys_prop
	WHERE prop_name = 'quotation-footer-no-of-blank-line'

	
	EXEC pr_update_prop_value 
		'quotation-header'
		, @receipt_header
		, @current_uid
		, @co_id2

	EXEC pr_update_prop_value 
		'quotation-footer'
		, @receipt_footer
		, @current_uid
		, @co_id2

	EXEC pr_update_prop_value 
		'quotation-footer-no-of-blank-line'
		, @no_of_blank_line
		, @current_uid
		, @co_id2
		
	SET @result = 'OK'

	
	-- ------------------
	-- prepare the audit log

	SET @audit_log = ''
	SET @audit_log = @audit_log + dbo.fn_has_changes('Receipt Header', @receipt_header_old, @receipt_header)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Receipt Footer', @receipt_footer_old, @receipt_footer)
	SET @audit_log = @audit_log + dbo.fn_has_changes('# of Blank Line at Footer', dbo.fn_int_to_str(@no_of_blank_line_old), dbo.fn_int_to_str(@no_of_blank_line))

	-- remove the first comma symbol
	IF LEN(@audit_log) > 0
	BEGIN
		SET @audit_log = RIGHT(@audit_log, LEN(@audit_log) - 1)

		SET @audit_log = 'Updated Receipt Setting - '
							+ '=>' 
							+ @audit_log
	END


	-- --------------------------------------------
	-- create audit log 
	-- --------------------------------------------

	IF LEN(ISNULL(@audit_log, '')) > 0
	BEGIN
	
		EXEC pr_sys_append_task_inbox 
			@current_uid
			, @url										--@task_inbox_url
			, @audit_log								--@task
			, null									--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_quotation_SET ting_save'						--@remarks 
			, null										--@task_fk_value2 

	END



	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
