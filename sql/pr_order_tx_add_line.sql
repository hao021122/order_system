IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_tx_add_line')
BEGIN DROP PROC pr_order_tx_add_line END
GO

create proc [dbo].[pr_order_tx_add_line] (
	@current_uid nvarchar(255)

	-- ------------------
	, @result nvarchar(max) output
	, @tr_id uniqueidentifier output
	, @tr_date datetime	 = null						--optional. If NULL, current trans date will be used.
	, @tr_type nvarchar(5)							--compulsory. 'AC'
	, @doc_no nvarchar(30) = null					--optional for @tr_type=AC
	, @profiler_trans_id uniqueidentifier			--compulsory for @tr_type=AC

	, @prod_id uniqueidentifier = null
	, @qty int = 0
	, @cost money = null
	, @sell_price money = 0							--for @tr_type=AC, this value will be loaded from tb_prod_code.
	, @amt money = 0

	--30-Mar-23,al
	, @addon_amt money = 0

	, @profile_id uniqueidentifier = null

	, @discount_amt money = null
	, @discount_pct numeric(12,2) = null
	--, @discount_id uniqueidentifier = null
	, @disc_total_calc money = null

	, @is_ready int = null
	--, @pymt_type_id uniqueidentifier = null
	--, @ref_no nvarchar(255) = null
	, @remarks nvarchar(255) = null	
	--, @pymt_dt datetime = null

	, @c1 nvarchar(255) = null
	, @c2 nvarchar(255) = null
	, @c3 nvarchar(255) = null
	
	, @coupon_no nvarchar(50) = null
	, @coupon_id uniqueidentifier = null

	-- ------------------	
	, @co_id uniqueidentifier	
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
as
begin
/*pr_order_tx_add_line

- insert/update item line to the trans (in working table).
- this works for product item & payment.
	
	declare @s nvarchar(max), @i uniqueidentifier

	exec pr_order_tx_add_line 
		@current_uid = 'b@a.com'
		, @result = @s output
		, @tr_id = '40CDB803-0379-484B-8667-0F6E1C4FB1ED'
		, @tr_date = '2023-08-18 00:00:00.000'
		, @tr_type = 'AC'
		, @doc_no = '#QUO000072'
		, @profiler_trans_id = '19FDD157-1075-439C-953F-6D18C542239E'
		, @prod_id = '82FB61DA-7626-4A55-82C7-28AA488A608A'
		, @qty = 2
		, @cost = null
		, @sell_price = 137.931
		, @amt = 160
		, @addon_amt = null
		, @profile_id = null
		, @co_id = null
		, @axn = null
		, @url = null
		, @is_debug =1 

	select @s '@result', @i '@tr_id'
*/

	-- =====================================================================================
	-- init
	-- =====================================================================================

	set nocount on
	
	declare
		@tax_code1 nvarchar(255)
		, @tax_pct1 money
		, @tax_amt1 money
		, @tax_amt1_calc money

		, @tax_code2 nvarchar(255)
		, @tax_pct2 money
		, @tax_amt2 money
		, @tax_amt2_calc money

		, @amt_inclusive_tax1 int
		, @amt_inclusive_tax2 int
		, @calc_tax2_after_add_tax1 int

		, @tax_code1_summ nvarchar(255)
		, @tax_amt1_summ money
		, @tax_code2_summ nvarchar(255)
		, @tax_amt2_summ money
				
		, @seq int
		, @disc_remarks nvarchar(255)
		, @is_new int
		, @qty_old int
		, @sell_price_old money
		, @amt_old money

		, @now datetime		
		, @module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)

	set @now = getdate()
	set @module_id = 2101001


	-- --------------------------------

	if @tr_date is null
	begin
		set @tr_date = dbo.fn_order_get_current_date()
	end

	if len(isnull(@tr_type, '')) = 0
	begin
		--default is sales
		set @tr_type = 'AC'
	end	


	if @profile_id IS NULL
	begin
		if @tr_type = 'AC'
		begin
			set @profile_id = dbo.fn_order_get_cash_sales_profile_id()
		end
		else
		begin
			set @profile_id = dbo.fn_empty_guid()
		end
	end

	-- --------------
	if dbo.fn_to_uid(@tr_id) <> dbo.fn_empty_guid()
	and not exists(
		select *
		from tb_stock_trans
		where
			profiler_trans_id = @profiler_trans_id
			and tr_id = @tr_id
	)
	begin
		set @result = 'The Item Line Does Not Exist!!'
		set nocount off
		return
	end


	-- =====================================================================================
	-- process
	-- =====================================================================================
	
	if dbo.fn_to_uid(@prod_id) <> dbo.fn_empty_guid()
	begin
		
		if @is_debug = 1 print '=> calc tax for the product..'
		
		--reset the pymt fields
		set @is_ready = 0
		--set @pymt_type_id = dbo.fn_empty_guid()
		--set @pymt_dt = null
		set @c1 = null
		set @c2 = null
		set @c3 = null	
		set @coupon_no = null
		set @coupon_id = null

		--for prod sales, max seq is 999
		set @seq = isnull((
							select 
								max(seq)
							from tb_stock_trans
							where
								profiler_trans_id = @profiler_trans_id
								and seq < 1000			--sales item line is limited to 999 lines
							), 0) + 1

		-- get tax settings
		select
			@tax_code1 = tax_code1
			, @amt_inclusive_tax1 = amt_inclusive_tax1
			, @tax_code2 = tax_code2
			, @amt_inclusive_tax2 = amt_inclusive_tax2
			, @calc_tax2_after_add_tax1 = calc_tax2_after_add_tax1

			, @sell_price = price + isnull(@addon_amt,0)	--30-Mar-23,al

		from tb_prod_code
		where prod_id = @prod_id



		if @is_debug = 1 
			print '=> @sell_price(1)=' + dbo.fn_fmt_currency(@sell_price, 2)
					+ ', @tax_code1=' + isnull(@tax_code1, '?')
					+ ', @tax_code2=' + isnull(@tax_code2, '?')
			
					+ ', @amt_inclusive_tax1 =' + dbo.fn_fmt_currency(@amt_inclusive_tax1 , 0)
					+ ', @amt_inclusive_tax2=' + dbo.fn_fmt_currency( @amt_inclusive_tax2, 0)
					+ ', @calc_tax2_after_add_tax1=' + dbo.fn_fmt_currency(@calc_tax2_after_add_tax1,0)
					+ ', @qty=' + dbo.fn_fmt_currency( @qty, 0)
					+ ', @sell_price=' + dbo.fn_fmt_currency(@sell_price, 2)
					+ ', @tr_date =' + isnull(cast( @tr_date  as nvarchar), '?')

		-- calc taxes
		select
			@amt = final_price
			, @sell_price = unit_price		--<<==== this value might be changed after calculation!!

			, @tax_pct1 = tax_pct1
			, @tax_amt1 = tax_amt1
			, @tax_amt1_calc = tax1 

			, @tax_pct2 = tax_pct2
			, @tax_amt2 = tax_amt2
			, @tax_amt2_calc = tax2 

		from dbo.fn_tax_calc_amt (
			null--@co_id	
			, @tax_code1 
			, @tax_code2 
			
			, @amt_inclusive_tax1 
			, @amt_inclusive_tax2 
			, @calc_tax2_after_add_tax1

			, @qty 
			, @sell_price--@amt
			, @tr_date -- @dt
		)

		if @is_debug = 1 print '=> @sell_price(2)=' + dbo.fn_fmt_currency(@sell_price, 2)


		--run the item discount process (if any)
		if isnull(@discount_pct, 0) > 0
		or isnull(@discount_amt, 0) > 0
		begin

/*
discount sample:

	select *
	from dbo.fn_tax_calc_amt(
		'da73cba2-1272-41ae-8106-903f77af1175'--@co_id 
		, 'SST'--@tax_code1 
		, 'SC'--@tax_code2 
		, 1--@amt_inclusive_tax1 
		, 1--@amt_inclusive_tax2
		, 0--@calc_tax2_after_add_tax1

		, 2--@qty
		, 100--@unit_price				<==== net price - tax to be reversed, result => 86.9565
		, '2018-01-01'--@dt
	)


	select *
	from dbo.fn_tax_calc_amt(
		'da73cba2-1272-41ae-8106-903f77af1175'--@co_id 
		, 'SST'--@tax_code1 
		, 'SC'--@tax_code2 
		, 0--@amt_inclusive_tax1 
		, 0--@amt_inclusive_tax2
		, 0--@calc_tax2_after_add_tax1

		, 2--@qty
		, 86.9565 * 0.8--@unit_price		<=== gross price (after reversed tax) & give 20% discount
		, '2018-01-01'--@dt
	)

*/
				
			-- total discount
			set @disc_total_calc = @qty * @sell_price * isnull(@discount_pct, 0) /100.0
									+ @qty * isnull(@discount_amt, 0)

			-- unit price after discount
			set @sell_price = @sell_price 
								* (1 - isnull(@discount_pct, 0) /100.0)
								- isnull(@discount_amt, 0)
				
			if @sell_price < 0
				set @sell_price = 0

			select
				@amt = final_price
				, @sell_price = unit_price		--<<==== this value might be changed after calculation!!

				, @tax_pct1 = tax_pct1
				, @tax_amt1 = tax_amt1
				, @tax_amt1_calc = tax1 

				, @tax_pct2 = tax_pct2
				, @tax_amt2 = tax_amt2
				, @tax_amt2_calc = tax2 

			from dbo.fn_tax_calc_amt (
				null--@co_id	
				, @tax_code1 
				, @tax_code2 
			
				, 0--@amt_inclusive_tax1					--reset for calc the final price
				, 0--@amt_inclusive_tax2					--reset for calc the final price
				, 0--@calc_tax2_after_add_tax1				--reset for calc the final price

				, @qty 
				, @sell_price--@amt							<<==== discounted price!!!!
				, @tr_date -- @dt
			)
			
		end

	end
	
	-- ------------------------------------------------------------------------------------------------

	
	if dbo.fn_to_uid(@tr_id) = dbo.fn_empty_guid()
	begin
	
		if @is_debug = 1 print '=> Append New Item Line..'

		set @tr_id = NEWID()
		
		-- append the item line
		insert into tb_stock_trans (
			tr_id, tr_date, tr_type, doc_no
			, prod_id, qty, cost, sell_price
			, profile_id, modified_on, modified_by, created_on, created_by
			, seq, profiler_trans_id
			, discount_amt, discount_pct, disc_remarks, disc_total_calc
			, is_ready, remarks, amt
			, c1, c2, c3
			, coupon_no, coupon_id		
			, tax_code1, tax_pct1, tax_amt1, tax_amt1_calc
			, tax_code2, tax_pct2, tax_amt2, tax_amt2_calc
		)
		values (
			@tr_id, @tr_date, @tr_type, ISNULL(@doc_no, '')
			, @prod_id, @qty, @cost, @sell_price
			, @profile_id, @now, @current_uid, @now, @current_uid
			, @seq, @profiler_trans_id
			, @discount_amt, @discount_pct, @disc_remarks, @disc_total_calc
			, @is_ready, @remarks
			, @amt																--<<=== this is the total amount for the item line.
		
			, @c1, @c2, @c3
			, @coupon_no, @coupon_id
			, @tax_code1, @tax_pct1, @tax_amt1, @tax_amt1_calc
			, @tax_code2, @tax_pct2, @tax_amt2, @tax_amt2_calc
		)

		if isnull(@is_ready, 0) = 0
		begin
			set @audit_log = 'Added Product Item: ' 
								+ dbo.fn_order_get_prod(@prod_id, null)
								+ ', QTY: '
								+ dbo.fn_int_to_str(@qty)

		end
		--else
		--begin

		--	select
		--		 @audit_log = 'Added payment item: ' 
		--						+ pymt_type_desc
		--						+ ', amount: '
		--						+ dbo.fn_fmt_currency(@amt, 2)

		--	from vw_pymt_type
		--	where
		--		pymt_type_id = @pymt_type_id

		--end

	end
	else
	begin

		
		if @is_debug = 1 print '=> Update Item Line...'

		select 
			@prod_id = prod_id
			, @qty_old = qty
			, @cost = cost
			, @sell_price_old = sell_price
			, @profile_id = profile_id
			, @discount_amt = discount_amt
			, @discount_pct = discount_pct
			, @disc_total_calc = disc_total_calc
			, @is_ready = is_ready
			, @remarks = remarks
			, @amt_old = amt
			, @c1 = c1
			, @c2 = c2
			, @c3 = c3
			, @coupon_no = coupon_no
			, @coupon_id = coupon_id
			, @tax_code1 = tax_code1
			, @tax_pct1 = tax_pct1  
			, @tax_amt1 = tax_amt1  
			, @tax_amt1_calc = tax_amt1_calc  

			, @tax_code2 = tax_code2  
			, @tax_pct2 = tax_pct2  
			, @tax_amt2 = tax_amt2  
			, @tax_amt2_calc = tax_amt2_calc  
		from tb_stock_trans 
		where 
			profiler_trans_id = @profiler_trans_id
			AND tr_id = @tr_id
			AND tr_type = 'AC'

		update tb_stock_trans
		set
			prod_id = @prod_id
			, qty = @qty
			, cost = @cost
			, sell_price = @sell_price
			, profile_id = @profile_id

			, discount_amt = @discount_amt
			, discount_pct = @discount_pct
			, disc_total_calc = @disc_total_calc

			, is_ready = @is_ready
			, remarks = @remarks
			, amt = @amt

			, c1 = @c1
			, c2 = @c2
			, c3 = @c3
			, coupon_no = @coupon_no
			, coupon_id = @coupon_id

			, tax_code1 = @tax_code1
			, tax_pct1 = @tax_pct1
			, tax_amt1 = @tax_amt1
			, tax_amt1_calc = @tax_amt1_calc

			, tax_code2 = @tax_code2
			, tax_pct2 = @tax_pct2
			, tax_amt2 = @tax_amt2
			, tax_amt2_calc = @tax_amt2_calc
			
		where
			profiler_trans_id = @profiler_trans_id
			AND tr_id = @tr_id
			AND tr_type = 'AC'


		--delete the addon so that it can be re-inserted by the 2nd (condim) & 3rd (req) steps.
		delete from tb_trans_addon
		where
			profiler_trans_id = @profiler_trans_id
			and tr_id = @tr_id

		if isnull(@is_ready, 0) = 0
		begin 
			set @audit_log = 'Updated Product Item: ' 
								+ dbo.fn_order_get_prod(@prod_id, null)
								+ ', QTY: '
								+ dbo.fn_int_to_str(@qty)

		end
		--else
		--begin

		--	select
		--		 @audit_log = 'Updated payment item: ' 
		--						+ pymt_type_desc
		--						+ ', amount: '
		--						+ dbo.fn_fmt_currency(@amt, 2)

		--	from vw_pymt_type
		--	where
		--		pymt_type_id = @pymt_type_id

		--end

	end


	-- -----------------------
	-- create audit log
	-- -----------------------

	INSERT INTO tb_task_inbox (
		task_inbox_id
		, modified_on,modified_by,created_on,created_by
		, task_inbox_url,task_inbox_status_id,task,task_fk_value
		, remarks
		,module_id
		, proc_name
	)
	values (
		newid()
		, @now, @current_uid, @now, @current_uid
		, '~/q'--@task_inbox_url
		, 0	--task_inbox_status_id,
		, @audit_log
		, @profiler_trans_id
		, ''--@remarks
		, @module_id
		, 'pr_order_tx_add_line'--@proc_name

	)

	
	-- -----------------------
	SET @result = 'OK'

	-- =====================================================================================
	-- cleanup 
	-- =====================================================================================
	
	SET NOCOUNT OFF

END
GO
