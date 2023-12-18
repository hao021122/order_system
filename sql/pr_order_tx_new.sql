IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_tx_new')
BEGIN DROP PROC pr_order_tx_new END
GO

CREATE PROC [dbo].[pr_order_tx_new] (
	@current_uid nvarchar(255)	
	, @result nvarchar(max) output
	-- ------------------

	, @profiler_trans_id uniqueidentifier output		--new id

	-- ------------------
	, @co_id uniqueidentifier
	, @axn nvarchar(50)								
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS 
BEGIN
/*	
	declare @i nvarchar(max), @s uniqueidentifier --= 'B254E37B-1145-4A12-BA4A-06746F7E4FB7'
	exec pr_order_tx_new
		@current_uid = 'tester'
		, @result = @i output
		-- ------------------
		, @profiler_trans_id = 'B254E37B-1145-4A12-BA4A-06746F7E4FB7'
		-- ------------------
		, @co_id = null
		, @axn = null								
		, @my_role_id = 0
		, @url = null
		, @is_debug = 1

	select @i '@result', @s '@profiler_trans_id'
*/

	-- =====================================================================================
	-- init
	-- =====================================================================================

	SET NOCOUNT ON

	SET @result = NULL

	-- =====================================================================================
	-- process
	-- =====================================================================================
	
	-- CHECK IS THE profiler_trans_id IS EXISTS OR NOT
	IF NOT EXISTS (
		SELECT TOP 1 *
		FROM tb_stock_trans
		WHERE 
			profiler_trans_id = @profiler_trans_id
	)
	BEGIN
		SET @profiler_trans_id = NEWID()
		if @is_debug = 1 print @profiler_trans_id
	END
	ELSE
	BEGIN
		SET @profiler_trans_id = (
									SELECT 
										TOP 1 profiler_trans_id
									FROM tb_stock_trans
									WHERE 
										profiler_trans_id = @profiler_trans_id
								)
		--SET @profiler_trans_id = @profiler_trans_id
		if @is_debug = 1 print @profiler_trans_id
	END

	SET @result = 'OK'
	-- =====================================================================================
	-- cleanup 
	-- =====================================================================================
	
	SET NOCOUNT OFF

END
GO
