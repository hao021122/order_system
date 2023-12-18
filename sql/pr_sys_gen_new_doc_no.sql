IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_sys_gen_new_doc_no')
BEGIN DROP PROC pr_sys_gen_new_doc_no END
GO

create proc [dbo].[pr_sys_gen_new_doc_no] (
	@current_uid nvarchar(255) 
	
	, @result nvarchar(max) output
	, @doc_no nvarchar(50) output
	, @co_id uniqueidentifier					--COMPULSORY
	
	, @doc_group nvarchar(50)					--eg, "receipt_no"

	, @url nvarchar(255)
	, @is_debug int = 0
)
as
begin

/*#1000_0030
20-nov-18,lhw
- this is a generic stored proc that generate new doc ref #.


	declare @i nvarchar(max), @s nvarchar(max)
	
	exec pr_sys_gen_new_doc_no
			@current_uid			= 'tester'
			, @result				= @i output
			, @doc_no				= null
			, @co_id				= '8FDF41BB-0285-462E-8FD6-E5D4EB64A808'
			, @doc_group			= 'receipt_no'
			, @url					='~/q'
			, @is_debug				= 1

	select @i '@result', @s '@doc_no'

	-- --------------------

	exec pr_update_prop_value 
		'receipt_no_prefix'
		, '#QUO'
		, 'admin'		--@uid
		, 50			--@co_id

	exec pr_update_prop_value 
		'receipt_no_postfix'
		, ''
		, 'admin'		--@uid
		, 50			--@co_id

	exec pr_update_prop_value 
		'receipt_no_len'
		, '6'
		, 'admin'		--@uid
		, 50			--@co_id

	

*/

	-- ==========================================================
	-- init
	-- ==========================================================
	
	if @is_debug = 1 print 'pr_sys_gen_new_doc_no - start'

	set nocount on

	declare			
		@new_no bigint
		, @doc_no_prefix nvarchar(50)
		, @doc_no_postfix nvarchar(50)
		, @len int
		, @id int

	-- ------------------------------------------------------
	if dbo.fn_to_uid(@co_id) = dbo.fn_empty_guid()
	begin
		if @is_debug = 1 print '@co_id cannot be blank'
		SET @result = '@co_id Cannot Be Blank!!'
		set nocount off
		return
	end

	if len(isnull(@doc_group, '')) = 0
	begin
		if @is_debug = 1 print '@doc_group cannot be blank'
		SET @result = '@doc_group Cannot Be Blank!!'
		set nocount off
		return
	end


	-- ==========================================================
	-- process
	-- ==========================================================

	--exec pr_sys_get_map_id
	--		@current_uid
	--		, @co_id
	--		, @id output
	--		, @is_debug

	set @id = (select co_id from tb_co_profile)
	
	-- get number length
	select @len = cast(prop_value as int)
	from tb_sys_prop with (nolock)
	where 
		co_id = @id
		and prop_name = @doc_group + '_len'

	if isnull(@len, 0) <= 0
	begin
		set @len = 5
	end

	-- get prefix
	select @doc_no_prefix = prop_value 
	from tb_sys_prop with (nolock)
	where 
		co_id = @id
		and prop_name = @doc_group + '_prefix'

	if @doc_no_prefix is null 
	begin
		set @doc_no_prefix = ''
	end

	-- get postfix
	select @doc_no_postfix = prop_value 
	from tb_sys_prop with (nolock)
	where 
		co_id = @id
		and prop_name = @doc_group + '_postfix'

	if @doc_no_postfix is null 
	begin
		set @doc_no_postfix = ''
	end
	
	if not exists (
		select * 
		from tb_stock_trans 
		where 
			doc_no = @doc_no
	)
	begin
		-- generate new @doc_no
		exec pr_sys_gen_new_id_for_co 
				@co_id
				, @doc_group  --@tb_name 
				, @new_no output
				
		set @doc_no = cast(@new_no as nvarchar)

		if len(@doc_no) < @len
		begin
			set @doc_no = right(replicate('0', 5) + @doc_no, @len)
		end

		-- concate the prefix & postfix.
		if len(@doc_no_prefix) > 0
		or len(@doc_no_postfix) > 0
		begin
			set @doc_no = @doc_no_prefix
							+ @doc_no
							+ @doc_no_postfix

			if @is_debug = 1 print 'concate the ' + @doc_group 
		end

		if @is_debug = 1 print @doc_no
	end
	else
	begin
		set @doc_no = (
						select top 1 doc_no
						from tb_stock_trans 
						where doc_no = @doc_no
					)
		if @is_debug = 1 print @doc_no
	end
	
	if @is_debug = 1 
	begin

		print '@doc_no_prefix=' + isnull(@doc_no_prefix, '?')
				+ ',@doc_no=' + isnull(@doc_no, '?')
				+ ',@doc_no_postfix=' + isnull(@doc_no_postfix, '?')
				+ ',@len=' + cast(isnull(@len, -1) as nvarchar)


	end

	set @result = 'OK'

	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	if @is_debug = 1 print 'pr_sys_gen_new_doc_no - exit'
	
	set nocount off

end
GO