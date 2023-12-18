if exists (select * from sys.objects where name = 'pr_addon_delete')
begin drop proc pr_addon_delete end
go

CREATE PROCEDURE pr_addon_delete (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output
	, @addon_id uniqueidentifier
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
		EXEC pr_addon_delete
			@current_uid = 'tester'
			, @result = @s output
			, @addon_id = null
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
		, @addon_code_old nvarchar(50)

	SET @result = NULL
	SET @module_id = 1101001

	-- ---------------------------------------------
	-- validation
	-- ---------------------------------------------

	IF NOT EXISTS (
		SELECT *
		FROM tb_addon
		WHERE 
			addon_id = @addon_id
	)
	BEGIN
		SET @result = 'The Record Does Not Exists!!'
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
		@addon_code_old = a.addon_code
	FROM tb_addon a
	WHERE 
		a.addon_id = @addon_id

	-- ----------------------------
	DELETE FROM tb_addon
	WHERE 
		addon_id = @addon_id

	-- ---------------------------
	-- prepare the audit log

	SET @audit_log = 'Deleted Add-ons: ' + @addon_code_old

	SET @result = 'OK'

	-- ---------------------------------
	-- create audit log
	-- ---------------------------------
	IF LEN(ISNULL(@audit_log, '')) > 0 
	BEGIN 
		exec pr_sys_append_task_inbox
			@current_uid
			, @url								-- @task_inbox_url
			, @audit_log						-- @task
			, @addon_id							-- @task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output
			, 'pr_addon_delete'					-- @proc_name
			, null								-- @task_fk_value2
	END

	-- ================================================================
	-- cleanup
	-- ================================================================

	SET NOCOUNT OFF
END
GO
