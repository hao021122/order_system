IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_prod_group_delete')
BEGIN DROP PROC pr_prod_group_delete END
GO

CREATE PROCEDURE [dbo].[pr_prod_group_delete] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @prod_group_id uniqueidentifier

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_prod_group_delete

sample code:

	declare @s nvarchar(max) 
	exec pr_prod_group_delete
		@current_uid = 'tester'
		, @result = @s output

		, @prod_group_id = null

		, @url = '~/q'
		, @is_debug = 0

	select @s'@result' 

*/

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON

	DECLARE

		@module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)

		, @prod_group_desc_old nvarchar(255)


	SET @result = NULL
	SET @module_id = 1101003

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF NOT EXISTS (
		SELECT * 
		FROM tb_prod_group
		WHERE 
			prod_group_id = @prod_group_id
	)
	BEGIN
		SET @result = 'The Record Does Not Exist!!'
		SET NOCOUNT OFF
		RETURN
	END

	IF EXISTS (
		SELECT * 
		FROM tb_prod_code
		WHERE
			prod_group_id = @prod_group_id
	)
	BEGIN
		SET @result = 'Deletion Is Not Allowed Because The Record Is In Use!!'
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
		@prod_group_desc_old = a.prod_group_desc
	FROM tb_prod_group a
	WHERE
		a.prod_group_id = @prod_group_id

	-- ------------------
	DELETE FROM tb_prod_group
	WHERE
		prod_group_id = @prod_group_id

	-- ------------------
	-- prepare the audit log

	SET @audit_log = 'Deleted Product Group: '
						+ @prod_group_desc_old

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
			, @prod_group_id									--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_prod_group_delete'						--@remarks 
			, null										--@task_fk_value2 

	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
