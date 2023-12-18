IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_cart_list')
BEGIN DROP PROC pr_order_cart_list END
GO

CREATE PROCEDURE pr_order_cart_list (
	@current_uid nvarchar(255)
	, @doc_no nvarchar(50)
	, @profiler_trans_id uniqueidentifier
	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*
	exec pr_order_cart_list
		@current_uid = 'tester'
		, @doc_no = '#QUO000084'
		, @profiler_trans_id = '6CEC5CF5-0798-4987-B70E-0F4C11FD9D40'
		, @co_id = null
		, @axn = 'cart-list'
		, @my_role_id = 0
		, @url = null
		, @is_debug = 0
*/
	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON;

	-- ================================================================
	-- process 
	-- ================================================================

	IF @axn = 'cart-list'
	BEGIN
		-- prod list
		SELECT 
			st.*
			, pc.img_url
			, pc.prod_code
			, pc.prod_desc
		FROM tb_stock_trans st
		INNER JOIN tb_prod_code pc ON pc.prod_id = st.prod_id
		WHERE 
			profiler_trans_id = @profiler_trans_id
			AND doc_no = @doc_no
			AND st.tr_type = 'AC'

		-- Addon List
		SELECT 
			ta.profiler_trans_id
			, ta.tr_id
			, a.addon_id
			, a.addon_code
			, a.addon_desc
			, a.amt
		FROM tb_trans_addon ta
		INNER JOIN tb_addon a ON a.addon_id = ta.addon_id
		WHERE 
			profiler_trans_id = @profiler_trans_id

		-- Request List 
		SELECT 
			ta.profiler_trans_id
			, ta.tr_id
			, r.request_id
			, r.request_code
			, r.request_desc
		FROM tb_trans_addon ta
		INNER JOIN tb_request r ON r.request_id = ta.request_id
		WHERE 
			profiler_trans_id = @profiler_trans_id
		
		-- Tax Summary
		SELECT
			tax_code
			, total_tax = SUM(total_tax)							
		FROM (
			SELECT
				tax_code = tax_code1
				, total_tax = SUM(ISNULL(tax_amt1_calc, 0))
			FROM tb_stock_trans
			WHERE
				profiler_trans_id = @profiler_trans_id
				AND LEN(ISNULL(tax_code1, '')) > 0
				AND tr_type = 'AC'
			GROUP BY
				tax_code1
			
			UNION ALL

			SELECT
				tax_code2
				, total_tax = SUM(ISNULL(tax_amt2_calc, 0))
			FROM tb_stock_trans
			WHERE
				profiler_trans_id = @profiler_trans_id
				AND LEN(ISNULL(tax_code2, '')) > 0
				AND tr_type = 'AC'
			GROUP BY
				tax_code2

		) AS a
		GROUP BY
			tax_code
	END

	-- ================================================================
	-- cleanup 
	-- ================================================================
	
	SET NOCOUNT OFF

END
GO
