IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_uom_delete')
BEGIN DROP PROC pr_uom_delete END
GO

CREATE PROCEDURE pr_uom_delete (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output
	, @uom_id uniqueidentifier
	, @co_id uniqueidentifier
	, @axn nvarchar(255)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*
	SAMPLE CODE:
	
	DECLARE @s nvarchar(max)
	EXEC pr_uom_delete
		@current_uid = 'tester'
		, @result = @s output
		, @uom_id uniqueidentifier
		, @co_id uniqueidentifier
		, @axn nvarchar(255)
		, @my_role_id int = 0
		, @url nvarchar(255)
		, @is_debug int = 0
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
		, @uom_desc_old nvarchar(50)

	SET @result = NULL
	SET @module_id = 1101011 

	-- ---------------------------------------------
	-- validation
	-- ---------------------------------------------

	IF NOT EXISTS (
		SELECT *
		FROM tb_uom
		WHERE 
			uom_id = @uom_id
	)
	BEGIN
		SET @result = 'The Record Does Not Exists!!'
		SET NOCOUNT OFF
		RETURN
	END

	IF EXISTS (
		SELECT *
		FROM tb_prod_code
		WHERE 
			uom_id = @uom_id
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

	SELECT 
		@uom_desc_old = a.uom_desc
	FROM tb_uom a
	WHERE 
		a.uom_id = @uom_id

	-- ----------------------------
	DELETE FROM tb_uom
	WHERE 
		uom_id = @uom_id

	-- ---------------------------
	-- prepare the audit log

	SET @audit_log = 'Deleted UOM: ' + @uom_desc_old

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
			, @uom_id							-- @task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output
			, 'pr_uom_delete'					-- @proc_name
			, null								-- @task_fk_value2
	END

	-- ================================================================
	-- cleanup
	-- ================================================================

	SET NOCOUNT OFF
END
GO