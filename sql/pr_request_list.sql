IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_request_list')
BEGIN DROP PROC pr_request_list END
GO

CREATE PROCEDURE [dbo].[pr_request_list] (
	@current_uid nvarchar(255)

	, @request_id uniqueidentifier
	, @is_in_use int

	, @co_id uniqueidentifier
	, @axn nvarchar(50)					-- 'setup' or null
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_request_list

sample code:

	exec pr_request_list
		@current_uid = 'tester'

		, @request_id = null
		, @is_in_use = -1

		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = '~/q'
		, @is_debug = 0


*/

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON


	-- ================================================================
	-- process 
	-- ================================================================

	IF @axn = 'setup'
	BEGIN
	
		SELECT *
		FROM tb_request
		WHERE
			(dbo.fn_to_uid(@request_id) = dbo.fn_empty_guid() OR request_id = @request_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			group_code
			, display_seq
			, request_code
	
	END
	ELSE
	BEGIN
	
		SELECT
			request_id
			, request_code
			, request_desc
		FROM tb_request
		WHERE
			(dbo.fn_to_uid(@request_id) = dbo.fn_empty_guid() OR request_id = @request_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			group_code
			, display_seq
			, request_code
	
	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF 

END
GO
