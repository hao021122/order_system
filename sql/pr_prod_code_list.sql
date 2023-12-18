if exists (select * from sys.objects where name = 'pr_prod_code_list')
begin drop proc pr_prod_code_list end
go

CREATE PROCEDURE [dbo].[pr_prod_code_list] (
	@current_uid nvarchar(255)

	, @prod_id uniqueidentifier = null
	, @prod_type_id int = null
	, @prod_cat_id uniqueidentifier = null
	, @prod_group_id uniqueidentifier = null

	, @prod_code nvarchar(50) = null
	, @prod_desc nvarchar(255) = null
	, @barcode nvarchar(50) = null

	, @is_in_use int = null

	, @co_id uniqueidentifier
	
	, @axn nvarchar(50)					--null -
										--'setup' => returns full details for usually 'setup' purpose.
										--'condim' => returns the available 'condim' for the given prod.
										--'req' => returns the available 'request' for the given prod.
										--'last-mod-on' => returns the last modification timestamp.
										
										--'list0' => 31-jul-20,lhw-returns all items. For example, setup food menu requires to view the full list.

										--'food-menu' => for 3rd party system to access the full menu.

										-- 'snc-food-menu'-31-jul-20,lhw-reserved for integration with Sales & catering food menu
										--					for customer viewing.

										--29-Mar-23,al - 'addon' => for menu item add-on with amt


	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
as
begin
/*#2100-1800-pos-pr_prod_code_list
2019.12.21,lhw
-

sample code:

	exec pr_prod_code_list
		@current_uid = 'tester'

		, @prod_id = 'F27F83FB-6CDB-4855-9FE4-8ED4A4DBDBD8'
		, @is_in_use = -1

		, @co_id = null
		, @axn = 'setup'
		, @my_role_id = 0
		, @url = '~/q'
		, @is_debug = 0


exec pr_prod_code_list @current_uid=N'a@a.com',@prod_id='98FAF1DA-A081-4174-A6E7-EEDEA75A2713',@prod_type_id=NULL,@prod_cat_id=NULL
,@prod_group_id=NULL,@prod_code=NULL,@prod_desc=NULL,@barcode=NULL,@is_in_use=NULL,@co_id='A1EEE2B8-C66A-45DD-86D9-C6E45592CD12',@axn=N'setup',@my_role_id=3,@url=N'::1'




*/

	-- ================================================================
	-- init 
	-- ================================================================

	set nocount on

	declare
		@current_hour int
		, @curr_tr_date datetime

	declare @tb table (
		json_var nvarchar(255)
		, merge_fld nvarchar(255)
		, link_with_base int
	)


	if len(isnull(@prod_code, '')) > 0
	begin
		set @prod_code = '%' + @prod_code + '%'
	end

	if len(isnull(@prod_desc, '')) > 0
	begin
		set @prod_desc = '%' + @prod_desc + '%'
	end

	if len(isnull(@barcode, '')) > 0
	begin
		set @barcode = '%' + @barcode + '%'
	end

	


	insert into @tb (json_var) values ('list')

	-- ================================================================
	-- process 
	-- ================================================================

	
	if @axn = 'setup'
	begin
		
		if dbo.fn_to_uid(@prod_id) <> dbo.fn_empty_guid()
		begin
			
			insert into @tb (json_var, merge_fld, link_with_base )
			values 
				('condim', 'prod_id=prod_id', 1)
				, ('req', 'prod_id=prod_id', 1)
				, ('addon', 'prod_id=prod_id', 1)

		end
		

		--returns js header
		select * from @tb

		--returns data 
		select *
		from vw_prod
		where
			(dbo.fn_to_uid(@prod_id) = dbo.fn_empty_guid() or prod_id = @prod_id)
			and (isnull(@is_in_use, -1) = -1 or is_in_use = @is_in_use)

			and (isnull(@prod_type_id, 0) = 0 or prod_type_id = @prod_type_id)
			and (dbo.fn_to_uid(@prod_cat_id) = dbo.fn_empty_guid() or prod_cat_id = @prod_cat_id)
			and (dbo.fn_to_uid(@prod_group_id) = dbo.fn_empty_guid() or prod_group_id = @prod_group_id)

			and (
				len(isnull(@prod_code, '')) = 0
				or prod_code like @prod_code
			)

			and (
				len(isnull(@prod_desc, '')) = 0
				or prod_desc like @prod_desc
			)
			and (
				len(isnull(@barcode, '')) = 0
				or barcode like @barcode
			)

		order by
			prod_desc


		if dbo.fn_to_uid(@prod_id) <> dbo.fn_empty_guid()
		begin
			
			-- returns the 'condiment'
			select
				a.prod_id
				, a.condiment_id
				, c.condiment_code
				, c.condiment_desc 
			from tb_prod_addon a
			inner join tb_condiment c on c.condiment_id = a.condiment_id
			where
				a.prod_id = @prod_id	
			order by 
				a.prod_id 
				, c.condiment_desc
			
			-- returns the 'request'
			select 
				a.prod_id
				, a.request_group_code
			from tb_prod_addon a
			where
				a.prod_id = @prod_id
				and a.request_group_code is not null
			order by 
				a.prod_id
				, a.request_group_code

			--29-Mar-23,al
			-- returns the 'addon'
			select
				a.prod_id
				, a.addon_id
				, a2.addon_code
				, a2.addon_desc 
			from tb_prod_addon a
			inner join tb_addon a2 on a2.addon_id = a.addon_id
			where
				a.prod_id = @prod_id	
			order by 
				a.prod_id 
				, a2.addon_desc


		end
		
	
	end
	else if @axn = 'addon'
	begin
		
		insert into @tb (json_var, merge_fld, link_with_base )
		values ('addon', null, null) 
				
		--returns js header
		select * from @tb
		
		--returns as the list
		select prod_id = @prod_id

		-- returns the 'addon'
		select
			a.addon_id
			, c.addon_code
			, c.addon_desc 
			, addon_amt= c.amt
		from tb_prod_addon a
		inner join tb_addon c on c.addon_id = a.addon_id
		where
			a.prod_id = @prod_id	
		order by 
			c.display_seq
			, c.addon_desc

	end
	else if @axn = 'condim'
	begin
		
		insert into @tb (json_var, merge_fld, link_with_base )
		values ('condim', null, null) 
				
		--returns js header
		select * from @tb
		
		--returns as the list
		select prod_id = @prod_id

		-- returns the 'condiment'
		select
			a.condiment_id
			, c.condiment_code
			, c.condiment_desc 
		from tb_prod_addon a
		inner join tb_condiment c on c.condiment_id = a.condiment_id
		where
			a.prod_id = @prod_id	
		order by 
			c.display_seq
			, c.condiment_desc

	end
	else if @axn = 'req'
	begin

		insert into @tb (json_var, merge_fld, link_with_base )
		values ('req', null, null) 
		
		--returns js header
		select * from @tb
		
		--returns as the list
		select prod_id = @prod_id

		-- returns the 'request'
		select 
			r.group_code
			, r.request_code
			, r.request_desc
			, r.request_id
		from tb_prod_addon a
		inner join tb_request r on r.group_code = a.request_group_code
		where
			a.prod_id = @prod_id
			and a.request_group_code is not null
		order by 
			r.group_code
			, r.display_seq
			, r.request_desc


	end
	else if @axn = 'last-mod-on'
	begin
		
		--returns last modified on 
		select max(modified_on)
		from tb_prod_code

	end
	else if @axn = 'list0'
	begin
		
		--1-aug-20,lhw

		-- return full list for food menu setting up or reporting purpose
		set @is_in_use = 1
		

		--returns js header
		select * from @tb

		--returns data 

		select 
			p.prod_id
			, p.prod_code
			, p.prod_desc
			, p.barcode

			, p.net_amt
			, p.prod_cat_id				--js need this field for the ui.
			, p.prod_cat_desc
			, p.prod_group_desc
			, p.uom_desc

			, condim_cnt = (
				select count(*)
				from tb_prod_addon pa
				where
					pa.prod_id = p.prod_id
					and dbo.fn_to_uid(pa.condiment_id) <> dbo.fn_empty_guid()
					and len(isnull(pa.request_group_code, '')) = 0
			)

			, req_cnt = (
				select count(*)
				from tb_prod_addon pa
				where
					pa.prod_id = p.prod_id
					and dbo.fn_to_uid(pa.condiment_id) = dbo.fn_empty_guid()
					and len(isnull(pa.request_group_code, '')) > 0
			)
			
			--1-aug-20,lhw
			, keep_daily_avail

			--29-Mar-23,al
			, addon_cnt = (
				select count(*)
				from tb_prod_addon pa
				where
					pa.prod_id = p.prod_id
					and dbo.fn_to_uid(pa.addon_id) <> dbo.fn_empty_guid()
					and len(isnull(pa.request_group_code, '')) = 0
			)


		from vw_prod p
		where
			(dbo.fn_to_uid(@prod_id) = dbo.fn_empty_guid() or p.prod_id = @prod_id)
			and (isnull(@is_in_use, -1) = -1 or p.is_in_use = @is_in_use)

			and (isnull(@prod_type_id, 0) = 0 or p.prod_type_id = @prod_type_id)
			and (dbo.fn_to_uid(@prod_cat_id) = dbo.fn_empty_guid() or p.prod_cat_id = @prod_cat_id)
			and (dbo.fn_to_uid(@prod_group_id) = dbo.fn_empty_guid() or p.prod_group_id = @prod_group_id)
			
			and (
				len(isnull(@prod_code, '')) = 0
				or p.prod_code like @prod_code
			)

			and (
				len(isnull(@prod_desc, '')) = 0
				or p.prod_desc like @prod_desc
			)
			and (
				len(isnull(@barcode, '')) = 0
				or p.barcode like @barcode
			)

			--29-jun-20,lhw
			--and (
			--	@sell_in_outlet is null 
			--	or p.sell_in_outlet = @sell_in_outlet
			--)
			--and (
			--	@sell_on_web is null 
			--	or p.sell_on_web = @sell_on_web
			--)

		order by
			p.prod_cat_desc
			, p.prod_desc


	end
	else
	begin
		
		--this is for listing only.
		set @is_in_use = isnull(@is_in_use, 0)
		
		--returns js header
		select * from @tb

		--returns data 

		select 
			prod_id
			, prod_code
			, prod_desc
			, barcode

			, tax_code1
			, amt_inclusive_tax1
			, tax_code2
			, amt_inclusive_tax2
			, calc_tax2_after_add_tax1

			, net_amt
			, gross_amt			
			
			, prod_type_id
			, prod_type_desc			
			, prod_cat_id
			, prod_cat_desc
			, prod_group_id
			, prod_group_desc
			, uom_id
			, uom_desc

			----, img_url
			, modified_by
			, modified_on

			--1-aug-20,lhw
			, keep_daily_avail

		from vw_prod
		where
			(dbo.fn_to_uid(@prod_id) = dbo.fn_empty_guid() or prod_id = @prod_id)
			and (isnull(@is_in_use, -1) = -1 or is_in_use = @is_in_use)

			and (isnull(@prod_type_id, 0) = 0 or prod_type_id = @prod_type_id)
			and (dbo.fn_to_uid(@prod_cat_id) = dbo.fn_empty_guid() or prod_cat_id = @prod_cat_id)
			and (dbo.fn_to_uid(@prod_group_id) = dbo.fn_empty_guid() or prod_group_id = @prod_group_id)
			
			and (
				len(isnull(@prod_code, '')) = 0
				or prod_code like @prod_code
			)

			and (
				len(isnull(@prod_desc, '')) = 0
				or prod_desc like @prod_desc
			)
			and (
				len(isnull(@barcode, '')) = 0
				or barcode like @barcode
			)

		order by
			prod_desc

	end
	

	-- ================================================================
	-- cleanup 
	-- ================================================================

	set nocount off
end
go
