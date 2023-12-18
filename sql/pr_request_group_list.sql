IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_request_group_list')
BEGIN DROP PROC pr_request_group_list END
GO

CREATE PROCEDURE [dbo].[pr_request_group_list] (
	@current_uid nvarchar(255)

	
	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_request_group_list

-returns the unique group code only.

sample code:

	exec pr_request_group_list
		@current_uid = 'tester'
		 
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

	
	SELECT 
		DISTINCT group_code AS request_group_code
	FROM tb_request


	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF
END
GO
