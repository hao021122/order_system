IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_prod_group_list') 
BEGIN DROP PROC pr_prod_group_list END
GO

CREATE PROCEDURE [dbo].[pr_prod_group_list] (
	@current_uid nvarchar(255)

	, @prod_group_id uniqueidentifier
	, @is_in_use int

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_prod_group_list

sample code:

	exec pr_prod_group_list
		@current_uid = 'tester'

		, @prod_group_id = null
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
		FROM tb_prod_group
		WHERE
			(dbo.fn_to_uid(@prod_group_id) = dbo.fn_empty_guid() OR prod_group_id = @prod_group_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, prod_group_desc
	
	END
	ELSE IF @axn = 'last-mod-on'
	BEGIN
		
		--returns last modified on 
		SELECT MAX(modified_on)
		FROM tb_prod_group

	END
	ELSE
	BEGIN
	
		SELECT
			prod_group_id
			, prod_group_desc
		FROM tb_prod_group
		WHERE
			(dbo.fn_to_uid(@prod_group_id) = dbo.fn_empty_guid() OR prod_group_id = @prod_group_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, prod_group_desc
	
	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
