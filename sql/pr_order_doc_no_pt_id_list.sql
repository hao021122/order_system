IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_doc_no_pt_id_list')
BEGIN DROP PROC pr_order_doc_no_pt_id_list END
GO

CREATE PROCEDURE pr_order_doc_no_pt_id_list (
	@current_uid nvarchar(255)

	, @doc_no nvarchar(50) output
	, @profiler_trans_id uniqueidentifier output
	, @co_id uniqueidentifier
	, @axn nvarchar(255)
	, @url nvarchar(255)
	, @my_role_id int = 0
	, @is_debug int = 0
)
AS
BEGIN
/*
 -- return the doc_no/ profiler_trans_id when user login
	
	declare @d nvarchar(50), @p uniqueidentifier

	exec pr_order_doc_no_pt_id_list 
		@current_uid = 'b@a.com'
		, @doc_no = null
		, @profiler_trans_id = null
		, @co_id = '8FDF41BB-0285-462E-8FD6-E5D4EB64A808'
		, @axn = null
		, @url = null
		, @is_debug = 1

	select @d '@Doc_no', @p '@profiler_trans_id'
*/

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON;

	declare 
		@s nvarchar(max)
		, @i uniqueidentifier
		, @now datetime

	SET @now = GETDATE()

	-- ================================================================
	-- process 
	-- ================================================================

	IF EXISTS (
		SELECT TOP 1 * 
		FROM tb_profiler_trans
		WHERE
			created_by = @current_uid
			AND tr_status = 'D'
		ORDER BY 
			created_on DESC
	)
	BEGIN
		-- return last ordering under status "Draft"
		SELECT TOP 1
			@doc_no = doc_no
	       ,  @profiler_trans_id = profiler_trans_id
		FROM tb_profiler_trans
		WHERE
			created_by = @current_uid
			and tr_status = 'D'
		ORDER BY 
			created_on DESC
	END
	ELSE
	BEGIN
		
		SET @doc_no = NULL
		SET @profiler_trans_id = NULL

		-- GENERATE NEW DOC # AND PROFILER_TRAN_ID
		EXEC pr_sys_gen_new_doc_no 
			@current_uid = @current_uid
			, @result = @s OUTPUT
			, @doc_no = @doc_no OUTPUT
			, @co_id = @co_id
			, @doc_group = 'receipt_no'
			, @url = @url

		IF @is_debug = 1 PRINT @doc_no
		SET @doc_no = @doc_no

		EXEC pr_order_tx_new
			@current_uid = @current_uid
			, @result = @s OUTPUT
			, @profiler_trans_id = @profiler_trans_id OUTPUT
			, @co_id = @co_id
			, @axn = @axn
			, @my_role_id = @my_role_id
			, @url = @url

		IF @is_debug = 1 PRINT @profiler_trans_id
		SET @profiler_trans_id = @profiler_trans_id

		INSERT INTO tb_profiler_trans (
			profiler_trans_id, created_on, created_by, doc_no, tr_type, tr_status, amt, total_tax, total_discount, rounding_adj_amt, calc_bill_discount_amt
		) VALUES (
			@profiler_trans_id, @now, @current_uid, @doc_no, 'AC', 'D', 0, 0, 0, 0, 0
		)


	END


	-- ================================================================
	-- cleanup 
	-- ================================================================
	
	SET NOCOUNT OFF
    
END
GO
