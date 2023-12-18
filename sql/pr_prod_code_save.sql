if exists (select * from sys.objects where name = 'pr_prod_code_save')
begin drop proc pr_prod_code_save end
go

CREATE proc [dbo].[pr_prod_code_save] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @prod_id uniqueidentifier output
	, @prod_cat_id uniqueidentifier
	, @prod_code nvarchar(20)
	, @prod_desc nvarchar(255)
	--, @prod_size nvarchar(20)
	--, @prod_color nvarchar(20)
	, @barcode nvarchar(20)
	
	, @price money								--user keyed in this value - then calc net_amt & gross_amt
	, @cost money

	, @uom_id uniqueidentifier
	, @prod_type_id int
	, @prod_group_id uniqueidentifier
	--, @parent_prod_id uniqueidentifier
	, @is_in_use int
	--, @is_global int
	--, @max_allow_on_same_day int
	
	, @img_url nvarchar(255)					--11-apr-20,lhw-not able to handle the img url in this proc.
	
	, @tax_code1 nvarchar(50)
	, @amt_inclusive_tax1 int
	, @tax_code2 nvarchar(50)
	, @amt_inclusive_tax2 int
	, @calc_tax2_after_add_tax1 int

	, @start_dt datetime
	, @end_dt datetime
	, @prepare_time int
	--, @sell_on_web int
	--, @sell_in_outlet int
	, @prod_desc2 nvarchar(max)
	
	--, @keep_daily_avail int

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
as
begin
/*pr_prod_code_save
-

sample code:

	declare @s nvarchar(max), @id uniqueidentifier 
	exec pr_prod_code_save
		@current_uid = 'tester'
		, @result = @s output

		, @prod_id = @id output
		, @prod_cat_id = null
		, @prod_code = ''
		, @prod_desc = ''
		, @prod_size = ''
		, @prod_color = ''
		, @barcode = ''
		
		, @price = 10
		, @cost = 0

		, @uom_id = null
		, @prod_type_id = 0
		, @prod_group_id = null
		, @parent_prod_id = null
		, @is_in_use = 0
		, @is_global = 0
		, @max_allow_on_same_day = 0
		, @img_url = ''
		
		, @tax_code1 = ''
		, @amt_inclusive_tax1 = 0
		, @tax_code2 = ''
		, @amt_inclusive_tax2 = 0
		, @calc_tax2_after_add_tax1 = 0

		, @start_dt = null
		, @end_dt = null
		, @cook_minute = 20
		, @sell_on_web = 1
		, @sell_in_outlet  = 1
		, @prod_desc2 = null
		, @keep_daily_avail = 0


		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = '~/q'
		, @is_debug = 0

	select @s'@result', @id'@id' 

*/

	-- ================================================================
	-- init 
	-- ================================================================

	set nocount on

	declare
		@now datetime

		, @module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)

		, @prod_cat_id_old uniqueidentifier
		, @prod_code_old nvarchar(20)
		, @prod_desc_old nvarchar(255)
		, @prod_size_old nvarchar(20)
		, @prod_color_old nvarchar(20)
		, @barcode_old nvarchar(20)
		
		, @price_old money
		, @cost_old money

		, @uom_id_old uniqueidentifier
		, @prod_type_id_old int
		, @prod_group_id_old uniqueidentifier
		, @parent_prod_id_old uniqueidentifier

		, @is_in_use_old int
		, @is_global_old int
		, @max_allow_on_same_day_old int
		, @img_url_old nvarchar(255)

		, @tax_code1_old nvarchar(50)
		, @amt_inclusive_tax1_old int
		, @tax_code2_old nvarchar(50)
		, @amt_inclusive_tax2_old int
		, @calc_tax2_after_add_tax1_old int

		, @start_dt_old datetime
		, @end_dt_old datetime
		, @prepare_time_old int
		, @sell_on_web_old int
		, @sell_in_outlet_old int
		, @prod_desc2_old nvarchar(max)
		--1-aug-20,lhw
		, @keep_daily_avail_old int


		, @net_amt money
		, @gross_amt money

	set @now = getdate()
	set @result = null
	set @module_id = 2103018

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	if dbo.fn_to_uid(@prod_cat_id) = dbo.fn_empty_guid()
	begin
		set @result = 'Product Category Cannot Be Blank!!'
		set nocount off
		return 
	end

	if len(isnull(@prod_code, '')) = 0
	begin
		set @result = 'Product Code Cannot Be Blank!!'
		set nocount off
		return 
	end

	if len(isnull(@barcode, '')) = 0
	begin
		set @barcode = null
	end

	if len(isnull(@prod_desc, '')) = 0
	begin
		set @result = 'Description Cannot Be Blank!!'
		set nocount off
		return 
	end

	--ensure that the code is unique
	if exists(
		select *
		from tb_prod_code
		where
			prod_code = @prod_code
			and prod_id <> dbo.fn_to_uid(@prod_id)
	)
	begin
		set @result = 'Product Code Already Exists!!'
		set nocount off
		return
	end

	if exists(
		select *
		from tb_prod_code
		where
			prod_desc = @prod_desc
			and prod_id <> dbo.fn_to_uid(@prod_id)
			--and dbo.fn_to_uid(parent_prod_id ) <> dbo.fn_to_uid(@parent_prod_id)
	)
	begin
		set @result = 'Product Description Already Exists!!'
		set nocount off
		return
	end

	if isnull(@price, 0) < 0
	begin
		set @result = 'Price Must Be Greater Than Or Equal Zero!!'
		set nocount off
		return 
	end

	-- calc the price
	select
		@net_amt = final_price
		, @gross_amt = unit_price
	from dbo.fn_tax_calc_amt (
		null--@co_id	
		, @tax_code1 
		, @tax_code2 
		, @amt_inclusive_tax1 
		, @amt_inclusive_tax2 
		, @calc_tax2_after_add_tax1
		, 1--@qty 
		, @price--@amt
		, getdate()-- @dt
	)


	-- ================================================================
	-- process 
	-- ================================================================

	if dbo.fn_to_uid(@prod_id) = dbo.fn_empty_guid()
	begin

		-- ------------------------------------
		-- insert record
		-- ------------------------------------

		set @prod_id = newid()

		insert into tb_prod_code(
			prod_id,created_on,created_by,modified_on,modified_by,prod_cat_id,prod_code,prod_desc
			--,prod_size,prod_color
			,barcode,price,cost
			,uom_id,prod_type_id,prod_group_id,is_in_use
			--,parent_prod_id,is_global,max_allow_on_same_day
			,img_url
			,tax_code1,amt_inclusive_tax1,tax_code2,amt_inclusive_tax2,calc_tax2_after_add_tax1
			,net_amt, gross_amt
			, start_dt 
			, end_dt 
			, prepare_time
			--, sell_on_web
			--, sell_in_outlet
			, prod_desc2 
			--1-aug-20,lhw
			--, keep_daily_avail
		) values (
			@prod_id,@now,@current_uid,@now,@current_uid,@prod_cat_id,@prod_code,@prod_desc
			,@barcode,@price,@cost			
			,@uom_id,@prod_type_id,@prod_group_id
			,isnull(@is_in_use, 1)
			,@img_url			
			,@tax_code1,@amt_inclusive_tax1,@tax_code2,@amt_inclusive_tax2,@calc_tax2_after_add_tax1
			,@net_amt, @gross_amt

			, @start_dt 
			, @end_dt 
			, @prepare_time
			, @prod_desc2
		)

		set @audit_log = 'Added product/service - '
							+ 'product code:' + @prod_code
							+ ', description:' + @prod_desc

	end
	else
	begin

		-- ------------------------------------
		-- update record
		-- ------------------------------------

		select 
			@prod_cat_id_old = a.prod_cat_id
			, @prod_code_old = a.prod_code
			, @prod_desc_old = a.prod_desc
			, @prod_size_old = a.prod_size
			, @prod_color_old = a.prod_color
			, @barcode_old = a.barcode
			
			, @price_old = price
			, @cost_old = cost

			, @uom_id_old = a.uom_id
			, @prod_type_id_old = a.prod_type_id
			, @prod_group_id_old = a.prod_group_id
			, @parent_prod_id_old = a.parent_prod_id
			, @is_in_use_old = a.is_in_use
			, @is_global_old = a.is_global
			, @max_allow_on_same_day_old = a.max_allow_on_same_day
			, @img_url_old = a.img_url

			, @tax_code1_old = a.tax_code1
			, @amt_inclusive_tax1_old = a.amt_inclusive_tax1
			, @tax_code2_old = a.tax_code2
			, @amt_inclusive_tax2_old = a.amt_inclusive_tax2
			, @calc_tax2_after_add_tax1_old = a.calc_tax2_after_add_tax1

			, @start_dt_old = a.start_dt 
			, @end_dt_old = a.end_dt
			, @prepare_time_old = a.prepare_time
			, @sell_on_web_old = a.sell_on_web
			, @sell_in_outlet_old = a.sell_in_outlet
			, @prod_desc2_old = a.prod_desc2
			
			, @keep_daily_avail_old = a.keep_daily_avail

		from tb_prod_code a
		where
			a.prod_id = @prod_id

		-- ------------------
		update tb_prod_code
		set
			modified_on = @now
			,modified_by = @current_uid
			,prod_cat_id = @prod_cat_id
			,prod_code = @prod_code
			,prod_desc = @prod_desc
			--,prod_size = @prod_size
			--,prod_color = @prod_color
			,barcode = @barcode
			
			,price = @price
			,cost = @cost

			,uom_id = @uom_id
			,prod_type_id = @prod_type_id
			,prod_group_id = @prod_group_id
			--,parent_prod_id = @parent_prod_id
			,is_in_use = isnull(@is_in_use, 0)
			--,is_global = @is_global
			--,max_allow_on_same_day = @max_allow_on_same_day
			,img_url = @img_url
			
			,tax_code1 = @tax_code1
			,amt_inclusive_tax1 = @amt_inclusive_tax1
			,tax_code2 = @tax_code2
			,amt_inclusive_tax2 = @amt_inclusive_tax2
			,calc_tax2_after_add_tax1 = @calc_tax2_after_add_tax1

			, net_amt = @net_amt
			, gross_amt = @gross_amt

			, start_dt = @start_dt 
			, end_dt = @end_dt 
			, prepare_time = @prepare_time
			--, sell_on_web = @sell_on_web
			--, sell_in_outlet = @sell_in_outlet
			, prod_desc2 = @prod_desc2 
			--, keep_daily_avail = @keep_daily_avail

		where
			prod_id = @prod_id

		-- ------------------
		-- prepare the audit log
		set @audit_log = ''
		set @audit_log = @audit_log + dbo.fn_has_changes('product category', dbo.fn_order_get_prod_cat(@prod_cat_id_old), dbo.fn_order_get_prod_cat(@prod_cat_id))
		set @audit_log = @audit_log + dbo.fn_has_changes('product code', @prod_code_old, @prod_code)
		set @audit_log = @audit_log + dbo.fn_has_changes('description', @prod_desc_old, @prod_desc)
		--set @audit_log = @audit_log + dbo.fn_has_changes('prod_size', @prod_size_old, @prod_size)
		--set @audit_log = @audit_log + dbo.fn_has_changes('prod_color', @prod_color_old, @prod_color)
		set @audit_log = @audit_log + dbo.fn_has_changes('barcode', @barcode_old, @barcode)
		
		set @audit_log = @audit_log + dbo.fn_has_changes('price', dbo.fn_fmt_currency(@price_old, 2), dbo.fn_fmt_currency(@price, 2))
		set @audit_log = @audit_log + dbo.fn_has_changes('cost', dbo.fn_fmt_currency(@cost_old, 2), dbo.fn_fmt_currency(@cost, 2))

		set @audit_log = @audit_log + dbo.fn_has_changes('unit', dbo.fn_order_get_uom(@uom_id_old), dbo.fn_order_get_uom(@uom_id))
		set @audit_log = @audit_log + dbo.fn_has_changes('product type', dbo.fn_order_get_prod_type(@prod_type_id_old), dbo.fn_order_get_prod_type(@prod_type_id))
		set @audit_log = @audit_log + dbo.fn_has_changes('product group', dbo.fn_order_get_prod_group(@prod_group_id_old), dbo.fn_order_get_prod_group(@prod_group_id))
		
		set @audit_log = @audit_log + dbo.fn_has_changes('is active', dbo.fn_fmt_yesno(@is_in_use_old), dbo.fn_fmt_yesno(@is_in_use))
		--set @audit_log = @audit_log + dbo.fn_has_changes('max allow on same day', dbo.fn_int_to_str(@max_allow_on_same_day_old), dbo.fn_int_to_str(@max_allow_on_same_day))
		set @audit_log = @audit_log + dbo.fn_has_changes('img url', @img_url_old, @img_url)

		set @audit_log = @audit_log + dbo.fn_has_changes('tax #1', @tax_code1_old, @tax_code1)
		set @audit_log = @audit_log + dbo.fn_has_changes('amount inclusive tax #1', dbo.fn_fmt_yesno(@amt_inclusive_tax1_old), dbo.fn_fmt_yesno(@amt_inclusive_tax1))
		set @audit_log = @audit_log + dbo.fn_has_changes('tax #2', @tax_code2_old, @tax_code2)
		set @audit_log = @audit_log + dbo.fn_has_changes('amount inclusive tax #2', dbo.fn_fmt_yesno(@amt_inclusive_tax2_old), dbo.fn_fmt_yesno(@amt_inclusive_tax2))
		set @audit_log = @audit_log + dbo.fn_has_changes('calc tax #2 after added tax #1', dbo.fn_fmt_yesno(@calc_tax2_after_add_tax1_old), dbo.fn_fmt_yesno(@calc_tax2_after_add_tax1))
		
		set @audit_log = @audit_log + dbo.fn_has_changes('start date', dbo.fn_fmt_date(@start_dt_old), dbo.fn_fmt_date(@start_dt))
		set @audit_log = @audit_log + dbo.fn_has_changes('end date', dbo.fn_fmt_date(@end_dt_old), dbo.fn_fmt_date(@end_dt))
		set @audit_log = @audit_log + dbo.fn_has_changes('prepare time (days)', dbo.fn_int_to_str(@prepare_time_old), dbo.fn_int_to_str(@prepare_time))
		--set @audit_log = @audit_log + dbo.fn_has_changes('sell on web', dbo.fn_fmt_yesno(@sell_on_web_old), dbo.fn_fmt_yesno(@sell_on_web))
		--set @audit_log = @audit_log + dbo.fn_has_changes('sell in outlet', dbo.fn_fmt_yesno(@sell_in_outlet_old), dbo.fn_fmt_yesno(@sell_in_outlet))
		set @audit_log = @audit_log + dbo.fn_has_changes('long description', @prod_desc2_old, @prod_desc2)
		
		--set @audit_log = @audit_log + dbo.fn_has_changes('keep daily availability', dbo.fn_fmt_yesno(@keep_daily_avail_old), dbo.fn_fmt_yesno(@keep_daily_avail))
		

		-- remove the first comma symbol
		if len(@audit_log) > 0
		begin
			set @audit_log = right(@audit_log, len(@audit_log) - 1)

			set @audit_log = 'Updated product/service - '
							+ 'product code:' + @prod_code_old
							+ ', description:' + @prod_desc_old
							 + '=>' 
							 + @audit_log
		end

	end



	-- save is handle by ajax cmd step 2
	--delete from tb_prod_printer
	--where
	--	prod_id = @prod_id

	-- save is handle by ajax cmd step 3 
	delete from tb_prod_addon
	where
		prod_id = @prod_id



	set @result = 'OK'

	-- --------------------------------------------
	-- create audit log 
	-- --------------------------------------------

	if len(isnull(@audit_log, '')) > 0
	begin

		exec pr_sys_append_task_inbox 
			@current_uid
			, @url										--@task_inbox_url
			, @audit_log								--@task
			, @prod_id									--@task_fk_value
			, @module_id
			, @co_id
			, @task_inbox_id output	
			, 'pr_prod_code_save'						--@proc_name
			, null										--@task_fk_value2 

	end

	-- ================================================================
	-- cleanup 
	-- ================================================================

	set nocount off
end
GO
