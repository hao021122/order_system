IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_prod_type_list')
BEGIN DROP PROC pr_prod_type_list END
GO

CREATE PROCEDURE [dbo].[pr_prod_type_list] (
	@current_uid nvarchar(255)

	, @prod_type_id int
	, @is_in_use int

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_prod_type_list

sample code:

	exec pr_prod_type_list
		@current_uid = 'tester'

		, @prod_type_id = null
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

	
	SELECT
		prod_type_id
		, prod_type_desc
	FROM tb_prod_type
	WHERE
		(
			ISNULL(@prod_type_id, 0) = 0 
			OR prod_type_id = @prod_type_id
		)
		AND (
			ISNULL(@is_in_use, -1) = -1 
			OR is_in_use = @is_in_use
		)
	
	ORDER BY
		display_seq
		, prod_type_desc


	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
