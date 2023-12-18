IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_prod_group_save')
BEGIN DROP PROC pr_prod_group_save END
GO

CREATE PROCEDURE [dbo].[pr_prod_group_save] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @prod_group_id uniqueidentifier output
	, @prod_group_desc nvarchar(50)
	, @is_in_use int
	, @display_seq int
	, @is_global int

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*#2100-0310-pos-pr_prod_group_save
2019.12.20,lhw
-

sample code:

	declare @s nvarchar(max), @id uniqueidentifier 
	exec pr_prod_group_save
		@current_uid = 'tester'
		, @result = @s output

		, @prod_group_id = @id output
		, @prod_group_desc = ''
		, @is_in_use = 0
		, @display_seq = 0
		, @is_global = 0

		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = '~/q'
		, @is_debug = 0

	select @s'@result', @id'@id' 

*/

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON

	DECLARE
		@now datetime

		, @module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)

		, @prod_group_desc_old nvarchar(50)
		, @is_in_use_old int
		, @display_seq_old int
		, @is_global_old int

	SET @now = GETDATE()
	SET @result = NULL
	SET @module_id = 1101003

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF LEN(ISNULL(@prod_group_desc, '')) = 0
	BEGIN
		SET @result = 'Product Group Description Cannot Be Blank!!'
		SET NOCOUNT OFF
		RETURN
	END

	--ensure that the code is unique
	IF EXISTS(
		SELECT *
		FROM tb_prod_group
		WHERE
			prod_group_desc = @prod_group_desc
			AND prod_group_id <> dbo.fn_to_uid(@prod_group_id)
	)
	BEGIN
		SET @result = 'Product Group Already Exists!!'
		SET NOCOUNT OFF
		RETURN
	END


	-- ================================================================
	-- process 
	-- ================================================================

	IF dbo.fn_to_uid(@prod_group_id) = dbo.fn_empty_guid()
	BEGIN

		-- ------------------------------------
		-- insert record
		-- ------------------------------------

		SET @prod_group_id = NEWID()

		INSERT INTO tb_prod_group(
			prod_group_id,created_on,created_by,modified_on,modified_by,prod_group_desc,is_in_use,display_seq,is_global
		) VALUES (
			@prod_group_id,@now,@current_uid,@now,@current_uid,@prod_group_desc
			,isnull(@is_in_use, 0)
			,@display_seq,@is_global
		)

		SET @audit_log = 'Added Product Group - '
							+ 'Product Group: ' + @prod_group_desc

	END
	ELSE
	BEGIN

		-- ------------------------------------
		-- update record
		-- ------------------------------------

		SELECT
			@prod_group_desc_old = a.prod_group_desc
			, @is_in_use_old = a.is_in_use
			, @display_seq_old = a.display_seq
			, @is_global_old = a.is_global
		FROM tb_prod_group a
		WHERE
			a.prod_group_id = @prod_group_id

		-- ------------------
		UPDATE tb_prod_group
		SET
			modified_on = @now
			,modified_by = @current_uid
			,prod_group_desc = @prod_group_desc
			,is_in_use = isnull(@is_in_use, 0)
			,display_seq = @display_seq
			,is_global = @is_global
		WHERE
			prod_group_id = @prod_group_id

		-- ------------------
		-- prepare the audit log
		SET @audit_log = ''
		SET @audit_log = @audit_log + dbo.fn_has_changes('product group', @prod_group_desc_old, @prod_group_desc)
		SET @audit_log = @audit_log + dbo.fn_has_changes('is active', dbo.fn_fmt_yesno(@is_in_use_old), dbo.fn_fmt_yesno(@is_in_use))
		SET @audit_log = @audit_log + dbo.fn_has_changes('display sequence', dbo.fn_int_to_str(@display_seq_old), dbo.fn_int_to_str(@display_seq))
		SET @audit_log = @audit_log + dbo.fn_has_changes('is global', dbo.fn_fmt_yesno(@is_global_old), dbo.fn_fmt_yesno(@is_global))

		-- remove the first comma symbol
		IF LEN(@audit_log) > 0
		BEGIN
			SET @audit_log = right(@audit_log, len(@audit_log) - 1)

			SET @audit_log = 'Updated Product Group - '
							+ 'Product Group: ' + @prod_group_desc_old
							 + '=>' 
							 + @audit_log
		END

	END

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
			, 'pr_prod_group_save'						--@proc_name
			, null										--@task_fk_value2 

	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
