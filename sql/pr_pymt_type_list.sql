IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_pymt_type_list')
BEGIN DROP PROC pr_pymt_type_list END
GO

CREATE PROCEDURE [dbo].[pr_pymt_type_list] (
	@current_uid nvarchar(255)

	, @pymt_type_id uniqueidentifier
	, @is_in_use int

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_pymt_type_list

sample code:

	exec pr_pymt_type_list
		@current_uid = 'tester'

		, @pymt_type_id = null
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
		FROM vw_pymt_type
		WHERE
			(dbo.fn_to_uid(@pymt_type_id) = dbo.fn_empty_guid() OR pymt_type_id = @pymt_type_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, pymt_type_desc
	
	END
	ELSE
	BEGIN
	
		SELECT
			pymt_type_id
			, pymt_type_desc

			, sys_pymt_type_desc
			, is_credit_sales
			, is_deposit
			, is_legal_tender

			, get_ref_no
			, get_credit_card_detail
			, allow_payment_change_due

		FROM vw_pymt_type
		WHERE
			(dbo.fn_to_uid(@pymt_type_id) = dbo.fn_empty_guid() OR pymt_type_id = @pymt_type_id)
			AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
		ORDER BY
			display_seq
			, pymt_type_desc
	
	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF
END
GO
