IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_pymt_type_save')
BEGIN DROP PROC pr_pymt_type_save END
GO

CREATE PROCEDURE [dbo].[pr_pymt_type_save] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @pymt_type_id uniqueidentifier output
	, @pymt_type_desc nvarchar(50)
	, @sys_pymt_type_id int
	, @is_in_use int
	, @display_seq int
	, @is_global int
	, @pymt_type_img_idx int
	, @allow_payment_change_due int
	, @get_credit_card_detail int
	, @get_ref_no int
	----, @img varbinary

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_pymt_type_save

sample code:

	declare @s nvarchar(max), @id uniqueidentifier 
	exec pr_pymt_type_save
		@current_uid = 'tester'
		, @result = @s output

		, @pymt_type_id = @id output
		, @pymt_type_desc = ''
		, @sys_pymt_type_id = 0
		, @is_in_use = 0
		, @display_seq = 0
		, @is_global = 0
		, @pymt_type_img_idx = 0
		, @allow_payment_change_due = 0
		, @get_credit_card_detail = 0
		, @get_ref_no = 0
		----, @img = null

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

		, @pymt_type_desc_old nvarchar(50)
		, @sys_pymt_type_id_old int
		, @is_in_use_old int
		, @display_seq_old int
		, @is_global_old int
		, @pymt_type_img_idx_old int
		, @allow_payment_change_due_old int
		, @get_credit_card_detail_old int
		, @get_ref_no_old int
		----, @img_old varbinary

	SET @now = GETDATE()
	SET @result = NULL
	SET @module_id = 1101007

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	IF LEN(ISNULL(@pymt_type_desc, '')) = 0
	BEGIN
		SET @result = 'Payment Type Cannot Be Blank!!'
		SET NOCOUNT OFF
		RETURN 
	END

	--ensure that the code is unique
	IF exists(
		SELECT *
		FROM tb_pymt_type
		WHERE
			pymt_type_desc = @pymt_type_desc
			AND pymt_type_id <> dbo.fn_to_uid(@pymt_type_id)
	)
	BEGIN
		SET @result = 'Payment Type Already Exists!!'
		SET NOCOUNT OFF
		RETURN
	END


	-- ================================================================
	-- process 
	-- ================================================================

	IF dbo.fn_to_uid(@pymt_type_id) = dbo.fn_empty_guid()
	BEGIN

		-- ------------------------------------
		-- insert record
		-- ------------------------------------

		SET @pymt_type_id = NEWID()

		INSERT INTO tb_pymt_type(
			pymt_type_id,created_on,created_by,modified_on,modified_by,pymt_type_desc,sys_pymt_type_id
			,is_in_use
			,display_seq,is_global,pymt_type_img_idx,allow_payment_change_due,get_credit_card_detail,get_ref_no
			----,img
		) VALUES (
			@pymt_type_id,@now,@current_uid,@now,@current_uid,@pymt_type_desc,@sys_pymt_type_id
			,ISNULL(@is_in_use, 0)
			,@display_seq,@is_global,@pymt_type_img_idx,@allow_payment_change_due,@get_credit_card_detail,@get_ref_no
			----,@img
		)

		SET @audit_log = 'Added Payment Type: ' + @pymt_type_desc

	END
	ELSE
	BEGIN

		-- ------------------------------------
		-- update record
		-- ------------------------------------

		SELECT 
			@pymt_type_desc_old = a.pymt_type_desc
			, @sys_pymt_type_id_old = a.sys_pymt_type_id
			, @is_in_use_old = a.is_in_use
			, @display_seq_old = a.display_seq
			, @is_global_old = a.is_global
			, @pymt_type_img_idx_old = a.pymt_type_img_idx
			, @allow_payment_change_due_old = a.allow_payment_change_due
			, @get_credit_card_detail_old = a.get_credit_card_detail
			, @get_ref_no_old = a.get_ref_no
		FROM tb_pymt_type a
		WHERE
			a.pymt_type_id = @pymt_type_id

		-- ------------------
		UPDATE tb_pymt_type
		SET
			modified_on = @now
			,modified_by = @current_uid
			,pymt_type_desc = @pymt_type_desc
			,sys_pymt_type_id = @sys_pymt_type_id
			,is_in_use = ISNULL(@is_in_use, 0)
			,display_seq = @display_seq
			,is_global = @is_global
			,pymt_type_img_idx = @pymt_type_img_idx
			,allow_payment_change_due = @allow_payment_change_due
			,get_credit_card_detail = @get_credit_card_detail
			,get_ref_no = @get_ref_no
		WHERE
			pymt_type_id = @pymt_type_id

		-- ------------------
		-- prepare the audit log
		SET @audit_log = ''
		SET @audit_log = @audit_log + dbo.fn_has_changes('Payment Type', @pymt_type_desc_old, @pymt_type_desc)
		SET @audit_log = @audit_log + dbo.fn_has_changes('System Payment Type', dbo.fn_int_to_str(@sys_pymt_type_id_old), dbo.fn_int_to_str(@sys_pymt_type_id))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Is Active', dbo.fn_fmt_yesno(@is_in_use_old), dbo.fn_fmt_yesno(@is_in_use))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Display Sequence', dbo.fn_int_to_str(@display_seq_old), dbo.fn_int_to_str(@display_seq))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Is Global', dbo.fn_fmt_yesno(@is_global_old), dbo.fn_fmt_yesno(@is_global))
		----SET @audit_log = @audit_log + dbo.fn_has_changes('payment type image change', dbo.fn_int_to_str(@pymt_type_img_idx_old), dbo.fn_int_to_str(@pymt_type_img_idx))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Allow Payment Change Due', dbo.fn_int_to_str(@allow_payment_change_due_old), dbo.fn_int_to_str(@allow_payment_change_due))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Get Credit Card Detail', dbo.fn_int_to_str(@get_credit_card_detail_old), dbo.fn_int_to_str(@get_credit_card_detail))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Get Ref No', dbo.fn_int_to_str(@get_ref_no_old), dbo.fn_int_to_str(@get_ref_no))
		----SET @audit_log = @audit_log + dbo.fn_has_changes('img', @img_old, @img)

		-- remove the first comma symbol
		IF LEN(@audit_log) > 0
		BEGIN
			SET @audit_log = RIGHT(@audit_log, LEN(@audit_log) - 1)

			SET @audit_log = 'Updated Payment Type :' + @pymt_type_desc_old
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
			, @pymt_type_id								--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_pymt_type_save'						--@proc_name
			, null										--@task_fk_value2 

	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
