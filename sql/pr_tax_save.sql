IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_tax_save')
BEGIN DROP PROC pr_tax_save END
GO

CREATE PROCEDURE pr_tax_save (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output
	, @tax_id uniqueidentifier output
	, @tax_code nvarchar(50)
	, @tax_desc nvarchar(255)
	, @tax_pct numeric
	, @tax_amt money
	, @is_in_use int
	, @display_seq int
	, @is_global int
	, @start_dt datetime
	, @end_dt datetime
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

	DECLARE @s nvarchar(max), @id uniqueidentifier
	EXEC pr_tax_save
		@current_uid = 'tester'
		, @result = @s output
		, @tax_id = ''
		, @tax_code = ''
		, @tax_desc = ''
		, @tax_pct = null
		, @tax_amt 0
		, @is_in_use 0
		, @display_seq 0
		, @is_global 0
		, @start_dt = '20990101'
		, @end_dt = '20990101'
		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = null
		, @is_debug = 0

	SELECT @s'result', @id'@id'
*/
	-- ================================================================  
	-- int  
	-- ================================================================

	SET NOCOUNT ON;

	DECLARE 
		@now datetime
		, @module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)
		, @tax_code_old nvarchar(50)
		, @tax_desc_old nvarchar(255)
		, @tax_pct_old numeric
		, @tax_amt_old money
		, @is_in_use_old int
		, @display_seq_old int
		, @is_global_old int
		, @start_dt_old datetime
		, @end_dt_old datetime

	SET @now = GETDATE()
	SET @result = NULL
	SET @module_id = 1101010

	-- ---------------------------------------------
	-- validation
	-- ---------------------------------------------

	IF LEN(ISNULL(@tax_desc, '')) = 0
	BEGIN
		SET @result = 'Description Cannot Be Blank!!'
		SET NOCOUNT OFF 
		RETURN
	END

	-- ensure that the code is unique
	IF EXISTS (
		SELECT *
		FROM tb_tax
		WHERE 
			tax_code = @tax_code
			AND tax_id <> dbo.fn_to_uid(@tax_id)
	)
	BEGIN
		SET @result = 'Tax Already Exists!!'
		SET NOCOUNT OFF
		RETURN
	END

	-- ================================================================  
	-- process  
	-- ================================================================
    IF dbo.fn_to_uid(@tax_id) = dbo.fn_empty_guid()
	BEGIN
		
		-- ---------------------------------
		-- insert record
		-- ---------------------------------
		SET @tax_id = NEWID()

		INSERT INTO tb_tax (
			tax_id, created_on, created_by, modified_on, modified_by, tax_code, tax_desc, tax_pct, tax_amt, is_in_use, display_seq, is_global, start_dt, end_dt
		) VALUES (
			@tax_id, @now, @current_uid, @now, @current_uid, @tax_code, @tax_desc, @tax_pct, @tax_amt, ISNULL(@is_in_use, 0), @display_seq, @is_global, @start_dt, @end_dt
		)

		SET @audit_log = 'Added Tax --> ' + 'Tax: ' + @tax_code

	END
	ELSE 
	BEGIN
		-- ---------------------------------
		-- update record
		-- ---------------------------------
		
		SELECT
			@tax_code_old = a.tax_code
			, @tax_desc_old = a.tax_desc
			, @tax_pct_old = a.tax_pct
			, @tax_amt_old = a.tax_amt
			, @is_in_use_old = a.is_in_use
			, @display_seq_old = a.display_seq
			, @is_global_old = a.is_global
			, @start_dt_old = a.start_dt
			, @end_dt_old = a.end_dt
		FROM tb_tax a
		WHERE 
			tax_id = @tax_id

		-- ---------------------------

		UPDATE tb_tax
		SET
			created_on = @now
			, created_by = @current_uid
			, modified_on = @now
			, modified_by = @current_uid
			, tax_code = @tax_code
			, tax_desc = @tax_desc
			, tax_pct = @tax_pct
			, tax_amt = @tax_amt
			, is_in_use = ISNULL(@is_in_use, 0)
			, display_seq = @display_seq
			, is_global = @is_global
			, start_dt = @start_dt
			, end_dt = @end_dt
		WHERE 
			tax_id = @tax_id

		-- ---------------------------
		-- prepare the audit log
		SET @audit_log = ''
		SET @audit_log = @audit_log + dbo.fn_has_changes('Tax', @tax_code_old, @tax_code)
		SET @audit_log = @audit_log + dbo.fn_has_changes('Description', @tax_desc_old, @tax_desc)
		SET @audit_log = @audit_log + dbo.fn_has_changes('Tax %', dbo.fn_fmt_currency(@tax_pct_old, 2), dbo.fn_fmt_currency(@tax_pct, 2))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Tax Amount', dbo.fn_fmt_currency(@tax_amt_old, 2), dbo.fn_fmt_currency(@tax_amt, 2))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Is Active', dbo.fn_fmt_yesno(@is_in_use_old), dbo.fn_fmt_yesno(@is_in_use))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Display Sequence', dbo.fn_int_to_str(@display_seq_old), dbo.fn_int_to_str(@display_seq))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Is Global', dbo.fn_fmt_yesno(@is_global_old), dbo.fn_fmt_yesno(@is_global))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Effective Start Date', dbo.fn_fmt_date(@start_dt_old), dbo.fn_fmt_date(@start_dt))
		SET @audit_log = @audit_log + dbo.fn_has_changes('Effective End Date', dbo.fn_fmt_date(@end_dt_old), dbo.fn_fmt_date(@end_dt))

		-- remove the first comma symbol
		IF LEN(@audit_log) > 0
		BEGIN
			SET @audit_log = RIGHT(@audit_log, LEN(@audit_log) - 1)

			SET @audit_log = 'Updated Tax - '
								+ 'Tax: ' + @tax_code_old
								+ '=>'
								+ @audit_log
		END
	END

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
			, @tax_id							-- @task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output
			, 'pr_tax_save'						-- @proc_name
			, null								-- @task_fk_value2
	END

	-- ================================================================
	-- cleanup
	-- ================================================================
    
	SET NOCOUNT OFF

END
GO
