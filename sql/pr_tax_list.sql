IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_tax_list')
BEGIN DROP PROC pr_tax_list END
GO

CREATE PROCEDURE pr_tax_list (
	@current_uid nvarchar(255)
	, @tax_id uniqueidentifier
	, @is_in_use int
	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*
	SAMPLE CODE:
	EXEC pr_tax_list
		@current_uid = 'tester'
		, @tax_id = ''
		, @is_in_use = -1
		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = null
		, @is_debug = 0
*/
	-- ================================================================  
	-- int  
	-- ================================================================  

	SET NOCOUNT ON;

	-- ================================================================  
	-- process 
	-- ================================================================  
    IF @axn = 'setup'
	BEGIN
		SELECT
			tax_id
			, modified_on
			, modified_by
			, created_on
			, tax_code
			, tax_desc
			, tax_pct
			, tax_amt
			, is_in_use
			, display_seq
			, start_dt
			, end_dt
		FROM tb_tax
		WHERE
			(dbo.fn_to_uid(@tax_id) = dbo.fn_empty_guid() OR tax_id = @tax_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, tax_code
	END
	ELSE
	BEGIN
		
		SELECT 
			tax_id
			, tax_code
			, tax_desc
		FROM tb_tax
		WHERE
			(dbo.fn_to_uid(@tax_id) = dbo.fn_empty_guid() OR tax_id = @tax_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, tax_code
	END

	-- ================================================================  
	-- cleanup
	-- ================================================================

	SET NOCOUNT OFF
END
GO
