if exists (select * from sys.objects where name = 'pr_task_inbox_list')
begin drop proc pr_task_inbox_list end
go

create proc [dbo].[pr_task_inbox_list] (	
	@startRowIndex int				-- for pagination
	, @maximumRows int				-- for pagination
	, @current_uid nvarchar(255)	-- for access control

	, @co_id uniqueidentifier		-- OPTIONAL
	, @login_id nvarchar(255)
	, @start_dt datetime
	, @end_dt datetime
	
	--24-sep-18,lhw-
	, @app_uid uniqueidentifier = null	
	, @module_id int = 0
	, @task_fk_value nvarchar(255) = null
	, @search_text nvarchar(255) = null

	, @is_debug int = 0
)
as
begin

/*#1080_0110-hrms-secu-pr_task_inbox_list
17-mar-16,lhw
- returns audit log.

	exec pr_task_inbox_list
			@startRowIndex		= 0
			, @maximumRows		= 100
			, @current_uid 		= 'tester'
			, @co_id			= null--'8FDF41BB-0285-462E-8FD6-E5D4EB64A808'
			, @login_id			= null
			, @start_dt			= null
			, @end_dt			= null
			, @app_uid			= null-- 'E8F75F7F-01C1-4242-82C1-B9EA270157A4'
			, @module_id		= 0
			, @is_debug			= 1


*/

	-- ==========================================================
	-- init
	-- ==========================================================

	set nocount on

	if @is_debug = 1
		print 'pr_task_inbox_list - start'
	
	if len(isnull(@login_id, '')) > 0
		set @login_id = '%' + @login_id + '%'
	else	
		set @login_id = ''

	if len(isnull(@search_text, '')) > 0
		set @search_text = '%' + @search_text + '%'
	else	
		set @search_text = ''
		

	if @start_dt is null set @start_dt = dateadd(day, -7, getdate())
	if @end_dt is null set @end_dt = getdate()

	set @end_dt = dbo.fn_end_of_day(@end_dt)
	set @startRowIndex = isnull(@startRowIndex, 0)

	if @startRowIndex < 0
		set @startRowIndex = 0
	
	-- ==========================================================
	-- process
	-- ==========================================================

	--if @app_uid='1E12AEC1-EBA4-479C-9351-A2A714743715'
	--begin
	--	--<<=== 15-feb-19,lhw-handle city ledger
					
	--	select
	--		--m.module_name
	--		ti2.created_on
	--		, ti2.created_by
	--		, ti2.task

	--		----, cp.co_name

	--	from (
	--		select
	--			rowidx = row_number() over (order by ti0.created_on desc)
	--			, ti0.task_inbox_id
	--		from tb_task_inbox ti0 with (nolock)
	--		inner join tb_module m0 with (nolock) on m0.module_id = ti0.module_id
	--		inner join tb_app_access_map am0 with (nolock) on am0.app_id = m0.app_id

	--		where 
	--			(
	--				len(isnull(@login_id, '')) = 0
	--				or ti0.created_by like @login_id
	--			)
	--			and (
	--				dbo.fn_to_uid(@co_id) = dbo.fn_empty_guid()
	--				or ti0.co_row_guid = @co_id
	--			)
	--			and ((
	--					@start_dt is null 
	--					and @end_dt is null
	--				)
	--				or (
	--					ti0.created_on between @start_dt and @end_dt
	--				)
	--			) 
	--			--24-sep-18,lhw
	--			--and (
	--			--	isnull(@module_id, 0) = 0
	--			--	or ti0.module_id = @module_id
	--			--)
	--			--and m0.app_id = 440000											--<<=== 15-feb-19,lhw-handle city ledger

	--			and (
	--				len(isnull(@task_fk_value, '')) = 0
	--				or ti0.task_fk_value = @task_fk_value
	--			)
	--			and (
	--				len(isnull(@search_text, '')) = 0
	--				or ti0.task like @search_text
	--			)

	--	) as ti1
	--	inner join tb_task_inbox ti2 with (nolock) on ti2.task_inbox_id = ti1.task_inbox_id
	--	--left outer join tb_module m with (nolock) on m.module_id = ti2.module_id
	--	left outer join tb_co_profile cp with (nolock) on cp.co_row_guid = ti2.co_row_guid

	--	where
	--		ti1.rowidx between @startRowIndex + 1 and @startRowIndex + @maximumRows


	--end
	--else
	--begin

			
	--	select
	--		--m.module_name
	--		ti2.created_on
	--		, ti2.created_by
	--		, ti2.task

	--		----, cp.co_name

	--	from (
	--		select
	--			rowidx = row_number() over (order by ti0.created_on desc)
	--			, ti0.task_inbox_id
	--		from tb_task_inbox ti0 with (nolock)
	--		inner join tb_module m0 with (nolock) on m0.module_id = ti0.module_id
	--		inner join tb_app_access_map am0 with (nolock) on am0.app_id = m0.app_id

	--		where 
	--			(
	--				len(isnull(@login_id, '')) = 0
	--				or ti0.created_by like @login_id
	--			)
	--			and (
	--				dbo.fn_to_uid(@co_id) = dbo.fn_empty_guid()
	--				or ti0.co_row_guid = @co_id
	--			)
	--			and ((
	--					@start_dt is null 
	--					and @end_dt is null
	--				)
	--				or (
	--					ti0.created_on between @start_dt and @end_dt
	--				)
	--			) 
	--			--24-sep-18,lhw
	--			--and (
	--			--	isnull(@module_id, 0) = 0
	--			--	or ti0.module_id = @module_id
	--			--)
	--			and (
	--				dbo.fn_to_uid(@app_uid) = dbo.fn_empty_guid()
	--				or am0.app_uid = @app_uid
	--			)
	--			and (
	--				len(isnull(@task_fk_value, '')) = 0
	--				or ti0.task_fk_value = @task_fk_value
	--			)
	--			and (
	--				len(isnull(@search_text, '')) = 0
	--				or ti0.task like @search_text
	--			)

	--	) as ti1
	--	inner join tb_task_inbox ti2 with (nolock) on ti2.task_inbox_id = ti1.task_inbox_id
	--	--left outer join tb_module m with (nolock) on m.module_id = ti2.module_id
	--	left outer join tb_co_profile cp with (nolock) on cp.co_row_guid = ti2.co_row_guid

	--	where
	--		ti1.rowidx between @startRowIndex + 1 and @startRowIndex + @maximumRows

	--end

	SELECT TOP 100 * from tb_task_inbox ti 
	inner join tb_module m0 on m0.module_id = ti.module_id
	order by ti.created_on desc

	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	if @is_debug = 1
		print 'pr_task_inbox_list - exit'
		
	set nocount off

END
GO
