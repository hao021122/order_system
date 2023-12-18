IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_tx_checkout')
BEGIN DROP PROC pr_order_tx_checkout END
GO

CREATE PROCEDURE [dbo].[pr_order_tx_checkout] (
	@current_uid nvarchar(255)	
	, @msg int output
	, @send_to nvarchar(255) output
	-- ------------------

	, @tr_type nvarchar(5)							-- compulsory. this is required for creating new profiler_trans rec
	, @tr_date datetime								-- optional.
	, @tr_id uniqueidentifier = null				-- optional-if has value, returns the item line amt + tax details.
	, @profiler_trans_id uniqueidentifier			-- compulsory.

	, @doc_no nvarchar(30)							-- this is required when calling by pr_pos_tx_add_line.
													-- except @tr_type=CUS is optional.

	-- ------------------
	
	, @co_id uniqueidentifier
	, @axn nvarchar(50)								-- 'skip-result'-don't return the result. The caller will handle it manually.
	, @my_role_id int = 0



	, @url nvarchar(255)
	
	, @is_debug int = 0
)
AS
BEGIN
/*pr_order_tx_checkout

- update to tb_profiler_trans WHERE checkout (in working table). 

exec pr_order_tx_checkout
	@current_uid=N'chinleehao@gmail.com'
	, @tr_type ='AC'
	, @tr_date = null
	, @tr_id = null
	, @profiler_trans_id='DE4DBB4C-A82C-4821-8C4F-926CAEFD0A96'
	, @doc_no = '#QUO000083'
	, @co_id='8FDF41BB-0285-462E-8FD6-E5D4EB64A808'
	, @axn=NULL
	--, @my_role_id=393
	, @url=N'::1'
	, @is_debug =1

exec pr_order_tx_checkout	
	@current_uid=N'cashier1@a.com'
	, @tr_type ='CUS'
	, @tr_date = '20211214'
	, @tr_id = NULL
	, @profiler_trans_id='F6B27E5F-C8DD-47E5-B059-8D762DBB28D0'
	, @doc_no = '00222'
	, @co_id='2BF5265B-FAEA-4731-9866-94FAD8A41490'
	, @axn=NULL
	, @my_role_id=393
	, @url=N'::1'
	, @is_debug =1

*/

	-- =====================================================================================
	-- init
	-- =====================================================================================

	SET NOCOUNT ON
	
	DECLARE
		@amt money
		, @total_tax money
		, @total_discount money
		, @rounding_adj_amt money
		, @bill_discount_amt money
		, @bill_discount_pct money
		, @calc_bill_discount_amt money
		, @now datetime
		

	IF @is_debug = 1 
		PRINT '=> @profiler_trans_id=' + ISNULL(CAST(@profiler_trans_id AS NVARCHAR(36)), '?')
				+', @tr_id='+ ISNULL(CAST(@tr_id AS NVARCHAR(36)), '?')

	IF LEN(ISNULL(@tr_type, '')) = 0
	BEGIN
		--returns the result in resultset so that it can be standardized (same first field name as pr_pos_tx_summ_refresh)!!!
		SELECT result = 'tr_type cannot be blank'
		SET NOCOUNT OFF
		RETURN
	END


	IF @tr_date is null
	BEGIN
		set @tr_date = dbo.fn_order_get_current_date()
	END

	SET @now = GETDATE()

	-- =====================================================================================


	-- process
	-- =====================================================================================
	
	IF EXISTS (
		SELECT *
		FROM tb_profiler_trans
		WHERE
			profiler_trans_id = @profiler_trans_id
			and tr_status = 'D'

	)
	BEGIN
		
		-- Update the status FROM Draft to Submitted
		UPDATE tb_profiler_trans 
			SET 
				modified_by = @current_uid
				, modified_on = @now
				, tr_date = dbo.fn_order_get_current_date()
				, tr_status = 'S'
		WHERE 
			profiler_trans_id = @profiler_trans_id
		
	END

	SELECT
		@total_tax = ROUND(SUM(ISNULL(total_tax, 0)), 2)
	FROM (
		SELECT
			total_tax = SUM(ISNULL(tax_amt1_calc, 0))
		FROM tb_stock_trans
		WHERE
			profiler_trans_id = @profiler_trans_id
			AND LEN(ISNULL(tax_code1, '')) > 0
			AND tr_type = 'AC'
	 
		UNION ALL

		SELECT
			total_tax = sum(isnull(tax_amt2_calc, 0))
		FROM tb_stock_trans
		WHERE
			profiler_trans_id = @profiler_trans_id
			AND len(isnull(tax_code2, '')) > 0 
			AND tr_type = 'AC'

	) AS a

	SELECT 
		@total_discount = ROUND(SUM(ISNULL(disc_total_calc, 0)), 2)
	FROM tb_stock_trans
	WHERE
		profiler_trans_id = @profiler_trans_id
		AND tr_type = 'AC'

	SELECT
		@amt = ROUND(SUM(ISNULL(amt, 0)), 2)
	FROM tb_stock_trans t
	INNER JOIN tb_prod_code pc ON pc.prod_id = t.prod_id			--<<== calc the product sales amount
	WHERE
		profiler_trans_id = @profiler_trans_id
		AND is_ready = 0
		AND tr_type = 'AC'

	SELECT
		@bill_discount_amt = ISNULL(bill_discount_amt, 0)
		, @bill_discount_pct = ISNULL(bill_discount_pct, 0)
	FROM tb_profiler_trans
	WHERE
		profiler_trans_id = @profiler_trans_id
		
	-- refresh the following fields
	-- calc bill discount												

	-- 15-06-2023, Lee,

	-- set @calc_bill_discount_amt = @amt * (@bill_discount_pct / 100.0) + @bill_discount_amt
	SET @calc_bill_discount_amt = @total_discount

	--calc the amount payable	
	SET @amt = @amt

	-- calc the rounding
	SET @rounding_adj_amt = dbo.fn_calc_rounding_adj(@amt)

	-- rounding the cents
	SET @amt = @amt + @rounding_adj_amt

	-- -------------------------
	--refresh the total
	-- -------------------------
	UPDATE tb_profiler_trans
	SET	
		total_tax = ISNULL(@total_tax, 0)
		, total_discount = ISNULL(@total_discount, 0)
		, amt = ISNULL(@amt, 0)
		
		, rounding_adj_amt = ISNULL(@rounding_adj_amt, 0)		
		, calc_bill_discount_amt = ISNULL(@calc_bill_discount_amt, 0)
	WHERE
		profiler_trans_id = @profiler_trans_id

	--SELECT
	--isnull(@amt, 0) , isnull(@total_pymt, 0) , isnull(@rounding_adj_amt, 0)
	--, round(isnull(@amt, 0) - isnull(@total_pymt, 0) + isnull(@rounding_adj_amt, 0), 2)


	-- =====================================================================================
	-- cleanup & result
	-- =====================================================================================
	
	IF ISNULL(@axn, '') <> 'skip-result'
	BEGIN

		DECLARE @tb table (
			json_var nvarchar(255)
			, merge_fld nvarchar(255)
		)

		IF dbo.fn_to_uid(@tr_id) <> dbo.fn_empty_guid()
		BEGIN
			INSERT INTO @tb (json_var, merge_fld)
			SELECT 'item_result' AS json_var , null AS merge_fld
		END


		INSERT INTO @tb (json_var, merge_fld)	
	
		SELECT 'bill_summ' AS json_var , null AS merge_fld
		UNION ALL
		SELECT 'tax_summ' , null


		--returns the json var
		SELECT *
		FROM @tb

		

		-- --------------------------
		IF dbo.fn_to_uid(@tr_id) <> dbo.fn_empty_guid()
		BEGIN

			IF @is_debug = 1 PRINT '==> returns item line..'
		
			--returns the result + tax for item line
			SELECT 
				result = 'OK'
				, net_amt = amt
				, sell_price

				--tax for item line
				, tax_code1 
				, tax_pct1 
				, tax_amt1 
				, tax_amt1_calc 
				, tax_code2 
				, tax_pct2 
				, tax_amt2 
				, tax_amt2_calc 
			FROM tb_stock_trans
			WHERE
				profiler_trans_id = @profiler_trans_id
				AND tr_id = @tr_id
				AND tr_type = 'AC'

		END

		-- --------------------------
		--returns bill summary
		SELECT
	
		result = 'OK'
			, amt = @amt 
			, total_discount = @total_discount
			, rounding_adj_amt = @rounding_adj_amt
			, total_tax = @total_tax

			, bill_discount_amt = @bill_discount_amt
			, bill_discount_pct = @bill_discount_pct
	
			, calc_bill_discount_amt = @calc_bill_discount_amt 
		
		--returns tax summary
		SELECT 
			tax_code
			, total_tax = ROUND(SUM(total_tax), 2)			--<<== we should group the taxes again 
													--because SST could be in tax_code1 or tax_code2.
		FROM (
			SELECT
			tax_code = st.tax_code1
			, total_tax = SUM(ISNULL(st.tax_amt1_calc, 0))
		FROM tb_stock_trans st
		WHERE
			st.profiler_trans_id = @profiler_trans_id
			AND LEN(ISNULL(st.tax_code1, '')) > 0
			AND tr_type = 'AC'
		GROUP BY 
			st.tax_code1
	 
		UNION ALL


		SELECT
			tax_code = st.tax_code2
			, total_tax = SUM(ISNULL(st.tax_amt2_calc, 0))
		FROM tb_stock_trans st
		WHERE
			st.profiler_trans_id = @profiler_trans_id
			AND LEN(ISNULL(st.tax_code2, '')) > 0
			AND tr_type = 'AC'
		GROUP BY 
			st.tax_code2


		) AS a
		GROUP BY
	
		tax_code

	END
	
	SET @msg = 1
	SET @send_to = ( SELECT created_by FROM tb_profiler_trans WHERE profiler_trans_id = @profiler_trans_id )

	SET NOCOUNT OFF

END
GO
