IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_request_delete')
BEGIN DROP PROC pr_request_delete END
GO

CREATE PROCEDURE [dbo].[pr_request_delete] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @request_id uniqueidentifier

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_request_delete

sample code:

	declare @s nvarchar(max) 
	exec pr_request_delete
		@current_uid = 'tester'
		, @result = @s output

		, @request_id = null

		, @url = '~/q'
		, @is_debug = 0

	SELECT @s'@result' 

*/

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON

	DECLARE

		@module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)

		, @request_code_old nvarchar(50)

	SET @result = null
	SET @module_id = 1101009

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF NOT EXISTS (
		SELECT * 
		FROM tb_request
		WHERE 
			request_id = @request_id
	)
	BEGIN
		SET @result = 'The Record Does not Exist!!'
		SET NOCOUNT OFF
		RETURN
	END

	--if exists (
	--	SELECT * 
	--	FROM tb_prod_addon
	--	WHERE 
	--		request_id = @request_id
	--)
	--BEGIN
	--	SET @result = 'Deletion is not allowed because the record is in use'
	--	SET nocount off
	--	return 
	--end

	-- ================================================================
	-- process 
	-- ================================================================

	-- ------------------------------------
	-- delete record
	-- ------------------------------------

	SELECT 
		@request_code_old = a.request_code
	FROM tb_request a
	WHERE
		a.request_id = @request_id

	-- ------------------
	DELETE FROM tb_request
	WHERE
		request_id = @request_id

	-- ------------------
	-- prepare the audit log

	SET @audit_log = 'Deleted Request'
					+ ', Request Code: ' + @request_code_old

	SET @result = 'OK'

	-- --------------------------------------------
	-- create audit log 
	-- --------------------------------------------

	IF LEN(ISNULL(@audit_log, '')) > 0
	BEGIN

		EXEC pr_sys_append_task_inbox 
			@current_uid
			, @url										--@task_inbox_url
			, @audit_log								--@task
			, @request_id								--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_request_delete'						--@remarks 
			, null										--@task_fk_value2 

	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET nocount off

END
GO
