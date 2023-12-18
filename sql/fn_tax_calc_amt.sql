IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'fn_tax_calc_amt')
BEGIN DROP FUNCTION fn_tax_calc_amt END
GO

create function fn_tax_calc_amt (
	@co_id uniqueidentifier
	
	, @tax_code1 nvarchar(50)
	, @tax_code2 nvarchar(50)
	, @amt_inclusive_tax1 int
	, @amt_inclusive_tax2 int
	, @calc_tax2_after_add_tax1 int 

	, @qty int
	, @unit_price money
	, @dt datetime		
				--for determining which tax % to use

)
returns @tb table (
	final_price money
	, unit_price money
	, qty int

	, tax_code1 nvarchar(50)
	, tax_pct1 money
	, tax_amt1 money
	, tax1 money

	, tax_code2 nvarchar(50)
	, tax_pct2 money
	, tax_amt2 money
	
, tax2 money

	, tax1_include int
	, tax2_include int
	, tax2_after_1 int
)
begin

/*2001_0052
30-apr-19,lhw
- calc the charges amt and returns the calc details that includes unit price, tax1, tax2 and net amt.

NOTES: 
- this proc was cloned from pr_char
ges_calc_amt but does not rely on tb_charge.
- same as pr_tax_calc_amt


		select *
		from dbo.fn_tax_calc_amt(
			'2BF5265B-FAEA-4731-9866-94FAD8A41490'--@co_id 
			, 'SC'--@tax_code1 
			, NULL--@tax_code2 
			, 0--@amt_inclusive_tax1 
			, 0--@amt_incl
usive_tax2
			, 0--@calc_tax2_after_add_tax1

			, 1--@qty
			, 10 --@unit_price
			, '20230525'--@dt
		)

*/

	-- ==========================================================
	-- init
	-- ==========================================================

	----if @is_debug = 1 print 'fn_tax_calc_amt - start '
	----set nocount on 

	declare
		@t1 nvarchar(50)
		, @i1 int
		, @t2 nvarchar(50)
		, @i2 int
		, @after_t1 int
		
		, @p1 money
		, @a1 money

		, @p2 money
		, @a2 money

		, @amt_temp money
		, @amt_temp2 money

		, @amt1 money
		, @calc1 money
		, @calc2 money
		, @final money

		, @tot_tax_pct money
		


	if isnull(@qty, 0) <= 0 set @qty = 1
	if @dt is null set @dt = dbo.fn_to_date(getdate())

	-- ==========================================================
	-- process
	-- ==========================================================

	-- ----------------------------------
	; with tax 
	as (
		select *
		from (
			--get the first tax setting if duplicate was found.
			select 
				row_idx = row_number()
					
	over (
							partition by (tax_code)
							order by (start_dt)
						)
				, tax_id, tax_code, tax_pct, tax_amt
			from tb_tax t0
			where 
				t0.is_in_use = 1
				and @dt between t0.start_dt and t0.end_dt
				
		) as t1
		where 
			t1.row_idx = 1
	)

	select 
		@p1 = isnull(t1.tax_pct, 0) / 100.0
		, @a1 = isnull(t1.tax_amt, 0)
	from tax  t1
	where
		t1.tax_code = @tax_code1

	-- ----------------------------------
	; with tax 
	as (
		select *
		from (
			--get the first tax setting if duplicate was found.
			select 
				row_idx = row_number()
						over (
							partition by (tax_code)
							order by (start_dt)
						)
				, tax_id, tax_code, tax_pct, tax_amt
			from tb_tax t0
			where 
				t0.is_in_use = 1
				and @dt between t0.start_dt and t0.end_dt
				
		) as t1
		where 
			t1.row_idx = 1
	)
	select 
		@p2 = isnull(t2.tax_pct, 0) / 100.0
		, @a2 = isnull(t2.tax_amt, 0)

	from tax t2
	where
		t2.tax_code = @tax_code2

	
	-- ----------------------------------
	set @t1 = @tax_code1
	set @t2 = @tax_code2
	

	--set @i1 = @amt_inclusive_tax1
	--set @i2 = @amt_inclusive_tax2
	--set @after_t1 = @calc_tax2_after_add_tax1
	
	--21-Oct-20,cj-enforce param as zero if no value
	set @i1 = isnull(@amt_inclusive_tax1, 0)
	set @i2 = isnull(@amt_inclusive_tax2, 0
)
	set @after_t1 = isnull(@calc_tax2_after_add_tax1, 0)



	------ -----------------------------
	----if @is_debug = 1 
	----begin
		
	----	print '@qty =' + cast(@qty as nvarchar)

	----	print '@t1=' + isnull(@t1, '?')
	----			+ ',@i1=' + isnull(cast(@i1 as nvarchar), '?')
	----			+ ',@p1=' + isnull(cast(@p1 as nvarchar), '?')
	----			+ ',@a1=' + isnull(cast(@a1 as nvarchar), '?')


	----	print '@t2=' + isnull(@t2, '?')
	----			+ ',@i2=' + isnull(cast(@i2 as nvarchar), '?')
	----			+ ',@p2=' + isnull(cast(@p2 as nvarchar), '?')
	----			+ ',@a2=' + isnull(cast(@a2 as nvarchar), '?')
	----			+ ', @after_t1=' + isnull(cast(@after_t1 as nvarchar), '?')
				

	----end

	-- -----------------------------

	if @t1 is null
	and @t2 is null
	begin
		
		--26-jan-19,lhw-bug fixed without tax.
		set @final = @unit_price * @qty

	end
	else if @t1 is not null
	and @t2 is not null
	and @i1 = 1
	and @i2 = 1
	and @after_t1 = 0
	begin
		
		----if @is_debug = 1 print '==> handle special case'

		--25.Jan.19,lhw-handle the special case
		--amt_inclusive_tax1: true, 
		--amt_inclusive_tax2: true, 
		--calc_tax2_after_add_tax1: false			--<<<====

		set @amt_temp = @unit_price * @qty
		set @final = @amt_temp

		set @tot_tax_pct = 1 + @p1 + @p2
		
		--++amt
        set @amt_temp2 = @amt_temp / @tot_tax_pct - @a1 - @a2

		-- ++ unit price 
		set @unit_price = @amt_temp2 / @qty

		set @calc1 = @amt_temp2 * @p1 + @a1		
		set @calc2 = @final - @calc1 - (@unit_price * @qty)


	end
	else
	begin

		-- -----------------------------
		if @t1 is not null
		begin
		
			--if @is_debug = 1 print '=> calc @t1'

			set @amt1 = @unit_price * @qty

			if isnull(@i1, 0) = 0 
			begin
				--// calc the tax
				set @calc1 = @amt1 * @p1  + @a1

				set @final = @amt1 + @calc1
			end
			else 
			begin

				-- the amt inclusive of tax - have to reverse the tax out.

				--reverse the tax out from the amt
				set @amt_temp = (@amt1 / (1 + @p1)) - @a1
			
				--//get the tax
				set @calc1 = @amt1 - @amt_temp

				--// the final amt is same as the unit price x qty.
				set @final = @amt1

				--//adjust the unit price by excluding the tax.
				set @unit_price = @amt_temp / @qty

			end

		end

		--//-------------------------------    
		if @t2 is not null
		begin
			----if @is_debug = 1 print '=> calc @t2'

			set @amt1 = @unit_price * @qty

			if @after_t1 = 1
			begin
				set @amt1 = @amt1 + @calc1
			end

			if isnull(@i2, 0) = 0
			begin
				----if @is_debug = 1 print '==> price not inclusive of t2'

				--// calc tax
				set @calc2 = @amt1 * @p2 + @a2

				set @final = @final + @calc2

			end
			else
			begin
				----if @is_debug = 1 print '==> price inclusive of t2'

				--//reverse the tax out from the amt
				set @amt_temp = (@amt1  / (1 + @p2)) - @a2

				--//get the tax
				set @calc2 = @amt1 - @amt_temp

				--// the final amt is same as the unit price x qty.
				set @final = @amt1

				--//<<=======
				--// recalc tax 1.
				--//reverse the tax out from the amt

				set @amt_temp2 = (@amt_temp / (1 + @p1)) - @a1

				--//get the tax => adjust tax 1									<<======
				set @calc1= @amt_temp - @amt_temp2

				--//set the 'unit_price' without the tax.
				set @amt_temp = @amt_temp2
				--//<<=======

				--//adjust the unit price by excluding the tax.
				set @unit_price = @amt_temp / @qty

			
			end
		end
	end

	-- -------------------------
	-- return the result
	-- -------------------------

	insert into @tb (
		final_price
		, unit_price
		, qty

		, tax_code1
		, tax_pct1
		, tax_amt1
		, tax1

		, tax_code2
		, tax_pct2
		, tax_amt2
		, tax2


		, tax1_include
		, tax2_include
		, tax2_after_1

	)
	select
		final = @final
		, unit_price = @unit_price

		, qty = @qty

		, tax_code1 = @t1
		, tax_pct1 = case when @p1 * 100 = 0 then null else @p1 * 100 end
		, tax_amt1 = case when @a1 = 0 then null else @a1 end
		, tax1 = case when @calc1 = 0 then null else @calc1 end
		
		, tax_code2 = @t2
		, tax_pct2 = case when @p2 * 100 = 0 then null else @p2 * 100 end
		, tax_amt2 = case when @a2 = 0 then null else @a2 end
		, tax2 = @calc2

		, tax1_include = case when @i1 = 0 then null else @i1 end
		, tax2_include = case when @i2 = 0 then null else @i2 end
		, tax2_after_1 = case when @after_t1 = 0 then null else @after_t1 end

	
	return

end
GO
