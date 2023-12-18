IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_quotation_setting_load')
BEGIN DROP PROC pr_quotation_setting_load END
GO

CREATE PROCEDURE pr_quotation_setting_load (
	@current_uid nvarchar(255)
	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)	
AS
BEGIN

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON;

	-- ================================================================
	-- process
	-- ================================================================

	SELECT 
		receipt_header = (
							SELECT prop_value
							FROM tb_sys_prop
							WHERE prop_name = 'quotation-header'
						)
		, receipt_footer = (
							SELECT prop_value
							FROM tb_sys_prop
							WHERE prop_name = 'quotation-footer'
						)
		, no_of_blank_line = (
							SELECT prop_value
							FROM tb_sys_prop
							WHERE prop_name = 'quotation-footer-no-of-blank-line'
						)

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
