IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_request_save')
BEGIN DROP PROC pr_request_save END
GO

CREATE PROCEDURE [dbo].[pr_request_save] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @request_id uniqueidentifier output	
	, @request_code nvarchar(50)
	, @request_desc nvarchar(255)
	, @remarks nvarchar(255)
	, @group_code nvarchar(50)
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
/*pr_request_save

sample code:

	declare @s nvarchar(max), @id uniqueidentifier 
	EXEC pr_request_save
		@current_uid = 'tester'
		, @result = @s output

		, @request_id = @id output
		, @request_code = ''
		, @request_desc = ''
		, @remarks = ''
		, @group_code= null
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

		, @request_code_old nvarchar(50)
		, @request_desc_old nvarchar(255)
		, @remarks_old nvarchar(255)
		, @group_code_old nvarchar(50)
		, @is_in_use_old int
		, @display_seq_old int
		, @is_global_old int

	SET @now = GETDATE()
	SET @result = NULL
	SET @module_id = 1101009

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF LEN(ISNULL(@request_desc, '')) = 0
	BEGIN
		SET @result = 'Description Cannot Be Blank!!'
		SET NOCOUNT OFF
		RETURN 
	END

	--ensure that the code is unique
	IF EXISTS(
		SELECT *
		FROM tb_request
		WHERE
			request_code = @request_code
			AND request_id <> dbo.fn_to_uid(@request_id)
	)
	BEGIN
		SET @result = 'Request Code Already Exists!!'
		SET NOCOUNT OFF
		RETURN
	END

	IF EXISTS(
		SELECT *
		FROM tb_request
		WHERE
			request_desc = @request_desc
			AND request_id <> dbo.fn_to_uid(@request_id)
	)
	BEGIN
		SET @result = 'Description Already Exists!!'
		SET NOCOUNT OFF
		RETURN
	END

	-- ================================================================
	-- process 
	-- ================================================================

	IF dbo.fn_to_uid(@request_id) = dbo.fn_empty_guid()
	BEGIN

		-- ------------------------------------
		-- insert record
		-- ------------------------------------

		SET @request_id = NEWID()

		INSERT INTO tb_request(
			request_id,created_on,created_by,modified_on,modified_by,request_code,request_desc,remarks,is_in_use,display_seq,is_global,group_code
		) VALUES (
			@request_id,@now,@current_uid,@now,@current_uid,@request_code,@request_desc,@remarks
			,ISNULL(@is_in_use, 0)
			,@display_seq,@is_global,@group_code
		)

		SET @audit_log = 'Added Request - '
							+ 'Request Code: ' + @request_code

	END
	ELSE
	BEGIN

		-- ------------------------------------
		-- update record
		-- ------------------------------------

		SELECT 
			@request_code_old = a.request_code
			, @request_desc_old = a.request_desc
			, @remarks_old = a.remarks
			, @is_in_use_old = a.is_in_use
			, @display_seq_old = a.display_seq
			, @is_global_old = a.is_global
			, @group_code_old = a.group_code
		FROM tb_request a
		WHERE
			a.request_id = @request_id

		-- ------------------
		UPDATE tb_request
		SET
			modified_on = @now
			,modified_by = @current_uid
			,request_code = @request_code
			,request_desc = @request_desc
			,remarks = @remarks
			,is_in_use = ISNULL(@is_in_use, 0)
			,display_seq = @display_seq
			,is_global = @is_global
			,group_code = @group_code
		WHERE
			request_id = @request_id

		-- ------------------
		-- prepare the audit log
		SET @audit_log = ''
		SET @audit_log = @audit_log + dbo.fn_has_changes('Request Code', @request_code_old, @request_code)
		SET @audit_log = @audit_log + dbo.fn_has_changes('Description', @request_desc_old, @request_desc)
		SET @audit_log = @audit_log + dbo.fn_has_changes('Remarks', @remarks_old, @remarks)
		SET @audit_log = @audit_log + dbo.fn_has_changes('Group Code', @group_code_old, @group_code)
		SET @audit_log = @audit_log + dbo.fn_has_changes('Is Active', dbo.fn_fmt_yesno(@is_in_use_old), dbo.fn_fmt_yesno(@is_in_use))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Display Sequence', dbo.fn_int_to_str(@display_seq_old), dbo.fn_int_to_str(@display_seq))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Is Global', dbo.fn_fmt_yesno(@is_global_old), dbo.fn_fmt_yesno(@is_global))

		-- remove the first comma symbol
		IF LEN(@audit_log) > 0
		BEGIN
			SET @audit_log = right(@audit_log, len(@audit_log) - 1)

			SET @audit_log = 'Updated Request - '
							+ 'Request Code: ' + @request_code_old
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
			, @request_id								--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_request_save'							--@proc_name
			, null										--@task_fk_value2 

	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET nocount off

END
GO
