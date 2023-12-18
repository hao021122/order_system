IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_details_list')
BEGIN DROP PROC pr_order_details_list END
GO

CREATE PROCEDURE pr_order_details_list(
	@profiler_trans_id uniqueidentifier
	, @result nvarchar(max) output
)
AS
BEGIN
/*
	declare @s nvarchar(max)
	exec pr_order_details_list 
		@profiler_trans_id = 'A32DE278-A518-472D-822B-2F82A09DFFAA'
		, @result = @s output

	select @s 'result'
*/
	
	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON;

	-- ================================================================
	-- process 
	-- ================================================================

	IF NOT EXISTS (
		SELECT * FROM tb_stock_trans WHERE profiler_trans_id = @profiler_trans_id
	)
	BEGIN
		SELECT *
		FROM tb_profiler_trans 
		WHERE profiler_trans_id = @profiler_trans_id

		SET @result = 'No Record...'
	END
	ELSE
	BEGIN
		SELECT 
			st.tr_id, st.tr_date, st.tr_type, st.doc_no, st.qty, st.cost, st.sell_price
			, st.modified_on, st.modified_by, st.created_on, st.created_by, st.seq
			, st.profiler_trans_id, st.discount_amt, st.discount_pct, st.disc_remarks
			, st.remarks, st.amt, st.tax_code1, st.tax_pct1, st.tax_amt1, st.tax_amt1_calc
			, st.tax_code2, st.tax_pct2, st.tax_amt2, st.tax_amt2_calc
			, pc.prod_code, pc.prod_desc, pc.img_url, pt.tr_status
		FROM tb_stock_trans st
		INNER JOIN tb_profiler_trans pt ON pt.profiler_trans_id = st.profiler_trans_id
		INNER JOIN tb_prod_code pc ON pc.prod_id = st.prod_id
		WHERE 
			st.profiler_trans_id = @profiler_trans_id
			AND st.tr_type = 'AC'

		SET @result = 'OK'
	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

END
GO
