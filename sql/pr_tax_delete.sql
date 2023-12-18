IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_tax_delete')
BEGIN DROP PROC pr_tax_delete END
GO

CREATE PROCEDURE pr_tax_delete (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output
	, @tax_id uniqueidentifier
	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)	
AS
BEGIN
/*
	SAMPLE CODE:
	
	DECLARE @s nvarchar(max)
	EXEC pr_tax_delete
		@current_uid = 'tester'
		, @result = @s output
		, @tax_id  = ''
		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = null
		, @is_debug = 0

	SELECT @s'result'
*/
	-- ================================================================
	-- int
	-- ================================================================

	SET NOCOUNT ON;

	DECLARE 
		@module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)
		, @tax_code_old nvarchar(50)

	SET @result = NULL
	SET @module_id = 1101010

	-- ---------------------------------------------
	-- validation
	-- ---------------------------------------------

	IF NOT EXISTS (
		SELECT *
		FROM tb_tax
		WHERE 
			tax_id = @tax_id
	)
	BEGIN
		SET @result = 'The Record Does Not Exists!!'
		SET NOCOUNT OFF
		RETURN
	END

	SELECT 
		@tax_code_old = a.tax_code
	FROM tb_tax a
	WHERE
		a.tax_id = @tax_id

	IF EXISTS (
		SELECT *
		FROM tb_prod_code
		WHERE
			tax_code1 = @tax_code_old
			OR tax_code2 = @tax_code_old
	)
	BEGIN
		SET @result = 'Deletion Is Not Allowed Because The Record Is In Use!!'
		SET NOCOUNT OFF
		RETURN
	END

	-- ================================================================
	-- process
	-- ================================================================
    
	-- ---------------------------------
	-- delete record
	-- ---------------------------------

	-- ----------------------------
	DELETE FROM tb_tax
	WHERE 
		tax_id = @tax_id

	-- ---------------------------
	-- prepare the audit log

	SET @audit_log = 'Deleted Tax: ' +', Tax: ' + @tax_code_old

	SET @result = 'OK'

	-- ---------------------------------
	-- create audit log
	-- ---------------------------------
	IF LEN(ISNULL(@audit_log, '')) > 0 
	BEGIN 
		EXEC pr_sys_append_task_inbox
			@current_uid
			, @url								-- @task_inbox_url
			, @audit_log						-- @task
			, @tax_id							-- @task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output
			, 'pr_tax_delete'					-- @proc_name
			, null								-- @task_fk_value2
	END

	-- ================================================================
	-- cleanup
	-- ================================================================

	SET NOCOUNT OFF

END
GO
