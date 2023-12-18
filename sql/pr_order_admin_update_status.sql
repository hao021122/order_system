IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_admin_update_status')
BEGIN DROP PROC pr_order_admin_update_status END
GO

CREATE PROCEDURE pr_order_admin_update_status (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output
	, @profiler_trans_id uniqueidentifier
	, @tr_status nvarchar(10)

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*
-- Admin check all the order request
*/
	-- ==========================================================
	-- init
	-- ==========================================================

	IF @is_debug = 1 PRINT 'pr_order_admin_update_status - start'

	SET NOCOUNT ON;

	--DECLARE
	--	@module_id int

	IF LEN(ISNULL(@tr_status, '')) = 0
	BEGIN
		SET @result = 'Invalid Status!!'
		SET NOCOUNT OFF
		RETURN
	END

	-- ==========================================================
	-- process
	-- ==========================================================

	IF EXISTS (
		SELECT *
		FROM tb_profiler_trans
		WHERE profiler_trans_id = @profiler_trans_id
	)
	BEGIN
		
		UPDATE tb_profiler_trans
		SET tr_status = @tr_status
		WHERE profiler_trans_id = @profiler_trans_id

	END
	ELSE
	BEGIN
		SET @result = 'The Record is Not Exists!!'
		SET NOCOUNT OFF
		RETURN
	END

	SET @result = 'OK'

	-- append audit log

    -- ==========================================================
	-- cleanup
	-- ==========================================================
	
	SET NOCOUNT OFF

END
GO
