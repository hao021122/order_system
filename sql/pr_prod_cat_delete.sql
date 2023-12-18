IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_prod_cat_delete')
BEGIN DROP PROC pr_prod_cat_delete END
GO

CREATE PROCEDURE [dbo].[pr_prod_cat_delete] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @prod_cat_id uniqueidentifier

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_prod_cat_delete

sample code:

	declare @s nvarchar(max) 
	exec pr_prod_cat_delete
		@current_uid = 'tester'
		, @result = @s output

		, @prod_cat_id = null

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

		, @prod_cat_desc_old nvarchar(50)

	SET @result = NULL
	SET @module_id = 1101002

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF NOT EXISTS (
		SELECT * 
		FROM tb_prod_cat
		WHERE 
			prod_cat_id = @prod_cat_id
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
			prod_cat_id = @prod_cat_id
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
		@prod_cat_desc_old = a.prod_cat_desc
	FROM tb_prod_cat a
	WHERE
		a.prod_cat_id = @prod_cat_id

	-- ------------------
	DELETE FROM tb_prod_cat
	WHERE
		prod_cat_id = @prod_cat_id


	-- ------------------
	-- prepare the audit log

	SET @audit_log = 'Deleted product category:' + @prod_cat_desc_old

	SET @result = 'OK'

	-- --------------------------------------------
	-- create audit log 
	-- --------------------------------------------

	IF LEN(ISNULL(@audit_log, '')) > 0
	BEGIN

		EXEC pr_sys_appEND_task_inbox 
			@current_uid
			, @url										--@task_inbox_url
			, @audit_log								--@task
			, @prod_cat_id								--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_prod_cat_delete'						--@remarks 
			, null										--@task_fk_value2 

	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF
END
GO
