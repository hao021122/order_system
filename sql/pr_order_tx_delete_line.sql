IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_tx_delete_line')
BEGIN DROP PROC pr_order_tx_delete_line END
GO

CREATE PROCEDURE [dbo].[pr_order_tx_delete_line] (
	@current_uid nvarchar(255)	
	, @result nvarchar(max) output
	-- ------------------

	, @profiler_trans_id uniqueidentifier
	, @tr_id uniqueidentifier
	
	-- ------------------

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_order_tx_delete_line

- delete an item line in the transaction (in working table).


*/

	-- =====================================================================================
	-- init
	-- =====================================================================================

	set nocount on
	 
	declare
		@tr_type nvarchar(50)
		, @tr_date datetime

		, @prod_id_old uniqueidentifier
		, @sell_price_old money
		, @qty_old int
		
		, @now datetime		
		, @module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max) 
				
	set @now = getdate()
	set @module_id = 2101001

	if not exists(
		select *
		from tb_stock_trans
		where
			profiler_trans_id = @profiler_trans_id
			and tr_id = @tr_id
	)
	begin

		if @is_debug = 1 print '=> item line does not exist. exit with OK'

		--returns the result in resultset so that it can be standardized (same first field name as pr_pos_tx_summ_refresh)!!!
		select result = 'OK'

		set nocount off
		return
	end

	-- =====================================================================================
	-- process
	-- =====================================================================================
	
	--get the details for refresh summ process
	select top 1
		@tr_type = tr_type
		, @tr_date = tr_date
		, @prod_id_old = prod_id
		, @sell_price_old = sell_price
		, @qty_old = qty
	from tb_stock_trans
	where
		profiler_trans_id = @profiler_trans_id


	-- --------------------------------------------

	--copy the voided item line for audit purpose
	insert into tb_stock_trans_void (
		tr_id, tr_date, tr_type, doc_no, prod_id, qty, cost, sell_price, profile_id
		, modified_by, modified_on, seq, profiler_trans_id
		, discount_amt, discount_pct, disc_remarks,disc_total_calc
		, is_ready, remarks
		, amt, c1, c2, c3, coupon_no, coupon_id
		, tax_code1, tax_pct1, tax_amt1, tax_amt1_calc
		, tax_code2, tax_pct2, tax_amt2, tax_amt2_calc
	)
	select 
		tr_id, tr_date, tr_type, doc_no, prod_id, qty, cost, sell_price, profile_id
		, modified_by, modified_on, seq, profiler_trans_id
		, discount_amt, discount_pct, disc_remarks, disc_total_calc
		, is_ready, remarks
		, amt, c1, c2, c3, coupon_no, coupon_id
		, tax_code1, tax_pct1, tax_amt1, tax_amt1_calc
		, tax_code2, tax_pct2, tax_amt2, tax_amt2_calc
	from tb_stock_trans
	where
		profiler_trans_id = @profiler_trans_id
		and tr_id = @tr_id


	-- -----------------------
	--delete the item line
	-- -----------------------

	delete from tb_trans_addon
	where
		profiler_trans_id = @profiler_trans_id
		and tr_id = @tr_id

	-- -----------------------
	-- update the to Cancel 
	-- -----------------------

	update tb_stock_trans
	SET 
		tr_type = 'C'
		, modified_on = GETDATE()
		, modified_by = @current_uid
	WHERE
		profiler_trans_id = @profiler_trans_id
		and tr_id = @tr_id

	-- -----------------------
	-- create audit log
	-- -----------------------

	set @audit_log = 'Void Item Line - Product: '
					+ dbo.fn_order_get_prod(@prod_id_old, null)					
					+ ', Price: '
					+ dbo.fn_org_get_curr_code(null)
					+ dbo.fn_fmt_currency(@sell_price_old, 2)
					+ ', QTY: '
					+ dbo.fn_fmt_currency(@qty_old, 2)
	


	insert into tb_task_inbox (
		task_inbox_id, task_inbox_url, task_inbox_status_id
		, task, task_fk_value, remarks, proc_name
		, module_id, modified_on, modified_by, created_on, created_by
		, co_row_guid
	)
	values (
		newid()
		,'~/q'--@task_inbox_url
		, 0	--task_inbox_status_id,
		, @audit_log
		, @profiler_trans_id
		, ''--@remarks
		, 'pr_order_tx_delete_line'--@proc_name
		, @module_id
		, @now, @current_uid, @now, @current_uid
		, @co_id
	)



	-- --------------------------------------------
	--refresh & returns the result
	-- --------------------------------------------
	--exec pr_order_tx_summ_refresh
	--	@current_uid
	--	--, @sess_id
	--	, @tr_type 
	--	, @tr_date 
	--	, null--@tr_id
	--	, @profiler_trans_id 
	--	, null--@doc_no 
	--	, @co_id 
	--	, @axn 
	--	, @my_role_id 
	--	, @url 
	--	, @is_debug

	SET @result = 'OK'
	-- =====================================================================================
	-- cleanup & result
	-- =====================================================================================
		
	set nocount off

END
GO
