IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_pymt_type_delete')
BEGIN DROP PROC pr_pymt_type_delete END
GO

CREATE PROCEDURE [dbo].[pr_pymt_type_delete] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @pymt_type_id uniqueidentifier

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*#2100-1130-pos-pr_pymt_type_delete
2019.12.20,lhw
-

sample code:

	declare @s nvarchar(max) 
	exec pr_pymt_type_delete
		@current_uid = 'tester'
		, @result = @s output

		, @pymt_type_id = 'AD1CC3A6-2754-4C3E-8995-51101F13FC72'

		, @url = '~/q'
		, @co_id = null
		, @axn = null
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

		, @pymt_type_desc_old nvarchar(50)

	SET @result = NULL
	SET @module_id = 1101007

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF NOT EXISTS (
		SELECT * 
		FROM tb_pymt_type
		WHERE 
			pymt_type_id = @pymt_type_id
	)
	BEGIN
		SET @result = 'The Record Does Not Exist!!'
		SET NOCOUNT OFF
		RETURN 
	END

	-- ================================================================
	-- process 
	-- ================================================================

	-- ------------------------------------
	-- delete record
	-- ------------------------------------

	SELECT 
		@pymt_type_desc_old = a.pymt_type_desc
	FROM tb_pymt_type a
	WHERE
		a.pymt_type_id = @pymt_type_id

	-- ------------------
	DELETE FROM tb_pymt_type
	WHERE
		pymt_type_id = @pymt_type_id

	-- ------------------
	-- prepare the audit log

	SET @audit_log = 'Deleted Payment Type: ' + @pymt_type_desc_old

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
			, @pymt_type_id								--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_pymt_type_delete'						--@remarks 
			, null										--@task_fk_value2 

	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END 
GO
