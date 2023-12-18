IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_uom_save')
BEGIN DROP PROC pr_uom_save END
GO

CREATE PROCEDURE pr_uom_save (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output
	, @uom_id uniqueidentifier output
	, @uom_desc nvarchar(50)
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
/*
sample code:

	declare @s nvarchar(max), @id uniqueidentifier 
	exec pr_uom_save
		@current_uid = 'tester'
		, @result = @s output

		, @uom_id = @id output
		, @uom_desc = ''
		, @is_in_use = 0
		, @display_seq = 0
		, @is_global = 0

		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = '~/q'
		, @is_debug = 0

	SELECT @s'@result', @id'@id' 

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

		, @uom_desc_old nvarchar(50)
		, @is_in_use_old int
		, @display_seq_old int
		, @is_global_old int

	SET @now = GETDATE()
	SET @result = NULL
	SET @module_id = 1101011

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF LEN(ISNULL(@uom_desc, '')) = 0
	BEGIN
		SET @result = 'Description Cannot Be Blank!!'
		SET NOCOUNT OFF
		RETURN
	END

	--ensure that the code is unique
	IF EXISTS(
		SELECT *
		FROM tb_uom
		WHERE
			uom_desc = @uom_desc
			AND uom_id <> dbo.fn_to_uid(@uom_id)
	)
	BEGIN
		SET @result = 'UOM Already Exists!!'
		SET NOCOUNT OFF
		RETURN
	END


	-- ================================================================
	-- process 
	-- ================================================================

	IF dbo.fn_to_uid(@uom_id) = dbo.fn_empty_guid()
	BEGIN

	-- ------------------------------------
	-- insert record
	-- ------------------------------------

		SET @uom_id = NEWID()

		INSERT INTO tb_uom(
			uom_id,created_on,created_by,modified_on,modified_by,uom_desc,is_in_use,display_seq,is_global
		) VALUES (
			@uom_id,@now,@current_uid,@now,@current_uid,@uom_desc

			,ISNULL(@is_in_use, 0)
			,@display_seq,@is_global
		)

		SET @audit_log = 'Added Unit of Measure - '
							+ 'Unit of Measure:' + @uom_desc

	END
	ELSE
	BEGIN

		-- ------------------------------------
		-- update record
		-- ------------------------------------

		SELECT 
			@uom_desc_old = a.uom_desc
			, @is_in_use_old = a.is_in_use
			, @display_seq_old = a.display_seq
			, @is_global_old = a.is_global
		FROM tb_uom a
		WHERE
			a.uom_id = @uom_id

		-- ------------------
		UPDATE tb_uom
		SET
			modified_on = @now
			, modified_by = @current_uid
			, uom_desc = @uom_desc
			, is_in_use = ISNULL(@is_in_use, 0)
			, display_seq = @display_seq
			, is_global = @is_global
		WHERE
			uom_id = @uom_id

		-- ------------------
		-- prepare the audit log
		SET @audit_log = ''

		SET @audit_log = @audit_log + dbo.fn_has_changes('Unit of Measure', @uom_desc_old, @uom_desc)
		SET @audit_log = @audit_log + dbo.fn_has_changes('Is Active', dbo.fn_fmt_yesno(@is_in_use_old), dbo.fn_fmt_yesno(@is_in_use))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Display Sequence', dbo.fn_int_to_str(@display_seq_old), dbo.fn_int_to_str(@display_seq))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Is Global', dbo.fn_fmt_yesno(@is_global_old), dbo.fn_fmt_yesno(@is_global))

		-- remove the first comma symbol		
		IF LEN(@audit_log) > 0
		BEGIN
			SET @audit_log = right(@audit_log, len(@audit_log) - 1)

			SET @audit_log = 'Updated Unit of Measure --> '
							+ 'Unit of Measure: ' + @uom_desc_old
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
			, @uom_id									--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_uom_save'								--@proc_name
			, null										--@task_fk_value2 

	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
