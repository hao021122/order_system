if exists (select * from sys.objects where name = 'pr_addon_save')
begin drop proc pr_addon_save end
go

CREATE PROCEDURE pr_addon_save (
	-- Add the parameters for the stored procedure here
	@current_uid nvarchar(255)
	, @result nvarchar(max) output			-- output 'ok'

	, @addon_id uniqueidentifier
	, @addon_code nvarchar(50)
	, @addon_desc nvarchar(255)
	, @remark nvarchar(255)
	, @amt money
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
20-4-2023
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
		, @addon_code_old nvarchar(50)
		, @addon_desc_old nvarchar(255)
		, @remark_old nvarchar(255)
		, @amt_old money
		, @is_in_use_old int
		, @display_seq_old int
		, @is_global_old int

	SET @now = GETDATE()
	SET @result = NULL
	SET @module_id = 2103009		-- tb_module, module_id

	-- ---------------------------------------------
	-- validation
	-- ---------------------------------------------

	IF LEN(ISNULL(@addon_code, '')) = 0
	BEGIN
		SET @result = 'Code cannot be blank!!'
		SET NOCOUNT OFF
		RETURN
	END 

	if LEN(ISNULL(@addon_desc, '')) = 0
	BEGIN
		SET @result = 'Description cannot be blank!!'
		SET NOCOUNT OFF
		RETURN
	END

	-- Ensure the code is unique
	IF EXISTS (
		SELECT *
		FROM tb_addon
		WHERE 
			addon_code = @addon_code
			AND addon_id <> dbo.fn_to_uid(@addon_id)
	)
	BEGIN
		SET @result = 'Code already exists!!'
		SET NOCOUNT OFF
		RETURN
	END

	-- ================================================================
	-- process
	-- ================================================================
	IF dbo.fn_to_uid(@addon_id) = dbo.fn_empty_guid()
	BEGIN
		
		-- ---------------------------------
		-- insert record
		-- ---------------------------------
		SET @addon_id = NEWID()

		INSERT INTO tb_addon (
			addon_id, created_on, created_by, modified_on, modified_by, addon_code, addon_desc, remark, amt, is_in_use, display_seq, is_global
		) VALUES (
			@addon_id, @now, @current_uid, @now, @current_uid, @addon_code, @addon_desc, @remark, @amt, ISNULL(@is_in_use, 0), @display_seq, @is_global
		)

		SET @audit_log = 'Added add-on --> ' + 'add-on: ' + @addon_code

	END
	ELSE 
	BEGIN
		-- ---------------------------------
		-- update record
		-- ---------------------------------
		
		SELECT
			@addon_code_old = a.addon_code
			, @addon_desc_old = a.addon_desc
			, @remark_old = a.remark
			, @amt_old = a.amt
			, @is_in_use_old = a.is_in_use
			, @display_seq_old = a.display_seq
			, @is_global_old = a.is_global
		FROM tb_addon a
		WHERE 
			addon_id = @addon_id

		-- ---------------------------

		UPDATE tb_addon
		SET
			created_on = @now
			, created_by = @current_uid
			, modified_on = @now
			, modified_by = @current_uid
			, addon_code = @addon_code
			, addon_desc = @addon_desc
			, remark = @remark
			, amt = @amt
			, is_in_use = ISNULL(@is_in_use, 0)
			, display_seq = @display_seq
			, is_global = @is_global
		WHERE 
			addon_id = @addon_id

		-- ---------------------------
		-- prepare the audit log

	END

	SET @result = 'OK'

	-- ---------------------------------
	-- create audit log
	-- ---------------------------------

	-- ================================================================
	-- cleanup
	-- ================================================================
    
	SET NOCOUNT OFF
END
GO
