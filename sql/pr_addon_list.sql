if exists (select * from sys.objects where name = 'pr_addon_list')
begin drop proc pr_addon_list end
go

CREATE PROCEDURE pr_addon_list (
	@current_uid nvarchar(255)
	, @addon_id uniqueidentifier 
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
	EXEC pr_addon_list
		@current_uid = 'tester'
		, @addon_id = null
		, @is_in_use = -1
		, @co_id = null
		, @axn null
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
		SELECT *
		FROM tb_addon
		WHERE
			(dbo.fn_to_uid(@addon_id) = dbo.fn_empty_guid() OR addon_id = @addon_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, addon_code
	END
	ELSE
	BEGIN
		
		SELECT 
			addon_id
			, addon_code
			, addon_desc
		FROM tb_addon
		WHERE
			(dbo.fn_to_uid(@addon_id) = dbo.fn_empty_guid() OR addon_id = @addon_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, addon_code
	END

	-- ================================================================  
	-- cleanup
	-- ================================================================

	SET NOCOUNT OFF
END
GO
