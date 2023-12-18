IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_history_list')
BEGIN DROP PROC pr_order_history_list END
GO

CREATE PROCEDURE pr_order_history_list (
	@current_uid nvarchar(255)
	, @doc_no nvarchar(50)
	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*
	EXEC pr_order_history_list

*/

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON;

	-- ================================================================
	-- process 
	-- ================================================================

	IF @axn = 'history-list'
	BEGIN
		SELECT
			tr_date
			, pt.profiler_trans_id
			, doc_no
			, amt 
			, total_tax
			, ts.tr_status_desc
		FROM tb_profiler_trans pt
		INNER JOIN tb_tr_status ts ON ts.tr_status = pt.tr_status
		WHERE 
			created_by = @current_uid
			AND pt.tr_status <> 'D'
		ORDER BY 
			doc_no
	END


	-- ================================================================
	-- cleanup 
	-- ================================================================
	
	SET NOCOUNT OFF

END
GO
