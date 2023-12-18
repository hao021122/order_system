if exists (Select * from sys.objects where name = 'pr_uom_list')
begin drop proc pr_uom_list end
go

CREATE PROCEDURE pr_uom_list (
	@current_uid nvarchar(255)
	, @uom_id uniqueidentifier
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

	EXEC pr_uom_list
		@current_uid = 'tester'
		, @uom_id = null
		, @is_in_use = 1
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
			uom_id
			, modified_on
			, modified_by
			, created_on
			, created_by
			, uom_desc
			, is_in_use
			, display_seq
		FROM tb_uom
		WHERE
			(dbo.fn_to_uid(@uom_id) = dbo.fn_empty_guid() OR uom_id = @uom_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, uom_desc
	END
	ELSE IF @axn = 'last-mod-on'
	BEGIN
		-- return last modified on 
		SELECT MAX(modified_on)
		FROM tb_uom
	END
	ELSE
	BEGIN
		
		SELECT 
			uom_id
			, uom_desc
		FROM tb_uom
		WHERE
			(dbo.fn_to_uid(@uom_id) = dbo.fn_empty_guid() OR uom_id = @uom_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, uom_desc
	END

	-- ================================================================  
	-- cleanup
	-- ================================================================

	SET NOCOUNT OFF

END
GO
