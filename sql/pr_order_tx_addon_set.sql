IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_tx_addon_set')
BEGIN DROP PROC pr_order_tx_addon_set END
GO

CREATE PROCEDURE [dbo].[pr_order_tx_addon_set] (
	@current_uid nvarchar(255)	
	-- ------------------
	, @profiler_trans_id uniqueidentifier
	, @tr_id uniqueidentifier
	
	, @addon_id uniqueidentifier
	, @condiment_id uniqueidentifier
	, @request_id uniqueidentifier
	, @remarks nvarchar(255)

	-- ------------------
	, @co_id uniqueidentifier
	, @axn nvarchar(50)

	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_order_tx_addon_set

- add addon/condiment/request to the product item line.


*/

	-- =====================================================================================
	-- init
	-- =====================================================================================

	SET NOCOUNT ON

	DECLARE
		@now datetime
		
		, @module_id int
		, @task_inbox_id uniqueidentifier
		, @audit_log nvarchar(max)

		, @prod_id uniqueidentifier
		, @trans_addon_id uniqueidentifier
				
	set @now = GETDATE()
	set @module_id = 2101001

	-- -----------------------
	-- validate
	-- -----------------------

	IF dbo.fn_to_uid(@condiment_id) = dbo.fn_empty_guid()
	AND dbo.fn_to_uid(@request_id) = dbo.fn_empty_guid()
	AND dbo.fn_to_uid(@addon_id) = dbo.fn_empty_guid()
	BEGIN		
		--RETURNs the result in resultset so that it can be standardized (same first field name as pr_pos_tx_summ_refresh)!!!
		SELECT result = 'Either Addon, Condiment or Request Cannot be Blank!!'
		SET NOCOUNT OFF
		RETURN
	END
	
	IF dbo.fn_to_uid(@addon_id) <> dbo.fn_empty_guid()
	AND NOT EXISTS (
		SELECT *
		FROM tb_addon
		WHERE
			addon_id = @addon_id
	)
	BEGIN			
		--RETURNs the result in resultset so that it can be standardized (same first field name as pr_pos_tx_summ_refresh)!!!
		SELECT result = 'Invalid Addon!!'
		SET NOCOUNT OFF
		RETURN
	END
	
	
	IF dbo.fn_to_uid(@condiment_id) <> dbo.fn_empty_guid()
	AND NOT EXISTS(
		SELECT *
		FROM tb_condiment
		WHERE
			condiment_id = @condiment_id
	)
	BEGIN			
		--RETURNs the result in resultset so that it can be standardized (same first field name as pr_pos_tx_summ_refresh)!!!
		SELECT result = 'Invalid Condiment!!'
		SET NOCOUNT OFF
		RETURN
	END
	
	
	IF dbo.fn_to_uid(@request_id) <> dbo.fn_empty_guid()
	AND NOT EXISTS(
		SELECT *
		FROM tb_request
		WHERE
			request_id = @request_id
	)
	BEGIN			
		--RETURNs the result in resultset so that it can be standardized (same first field name as pr_pos_tx_summ_refresh)!!!
		SELECT result = 'Invalid Request!!'
		SET NOCOUNT OFF
		RETURN
	END

	-- make sure the current item line 'product' sales
	SELECT 
		@prod_id = prod_id
	FROM tb_stock_trans
	WHERE
		profiler_trans_id = @profiler_trans_id
		and tr_id = @tr_id 
	
	IF dbo.fn_to_uid(@prod_id) = dbo.fn_empty_guid()
	BEGIN			
		--RETURNs the result in resultset so that it can be standardized (same first field name as pr_pos_tx_summ_refresh)!!!
		SELECT result = 'Invalid Item Line!!'
		SET NOCOUNT OFF
		RETURN
	END


	-- =====================================================================================
	-- process
	-- =====================================================================================
	
	
	-- always create new rec

	IF @is_debug = 1 PRINT '=> add new addon rec..'

	SET @trans_addon_id = NEWID()

	INSERT INTO tb_trans_addon (
		profiler_trans_id, trans_addon_id, tr_id
		, created_on, created_by, modified_on, modified_by
		, condiment_id, request_id, addon_id, remarks	
	)
	VALUES (
		@profiler_trans_id, @trans_addon_id, @tr_id
		, @now, @current_uid, @now, @current_uid
		, @condiment_id, @request_id, @addon_id, @remarks
	)

	IF dbo.fn_to_uid(@addon_id) <> dbo.fn_empty_guid()
	BEGIN
		SET @audit_log = 'Added Addon: ' 
						+ dbo.fn_order_get_addon(@addon_id, null)
						+ ' for '
						+ dbo.fn_order_get_prod(@prod_id, null)

	END
	ELSE IF dbo.fn_to_uid(@condiment_id) <> dbo.fn_empty_guid()
	BEGIN
		SET @audit_log = 'Added Condiment: ' 
						+ dbo.fn_order_get_condiment(@condiment_id, null)
						+ ' for '
						+ dbo.fn_order_get_prod(@prod_id, null)

	END
	ELSE
	BEGIN

		SET @audit_log = 'Added Request: ' 
						+ dbo.fn_order_get_request(@request_id, null)
						+ ' for '
						+ dbo.fn_order_get_prod(@prod_id, null)


	END

	IF LEN(ISNULL(@remarks, '')) > 0
	BEGIN

		SET @audit_log = @audit_log 
						+ ', Remarks: '
						+ @remarks
	END

	-- -----------------------
	-- create audit log
	-- -----------------------

	INSERT INTO tb_task_inbox (
		task_inbox_id, task_inbox_url,task_inbox_status_id,task,task_fk_value
		, remarks, proc_name, module_id
		, modified_on,modified_by,created_on,created_by
	)
	VALUES (
		newid()
		, '~/q'--@task_inbox_url
		, 0	--task_inbox_status_id,
		, @audit_log
		, @profiler_trans_id
		, ''--@remarks
		, 'pr_order_tx_addon_set'--@proc_name
		, @module_id
		, @now, @current_uid, @now, @current_uid
	)


	SELECT 
		result = 'OK'
		, id = @trans_addon_id 

	-- =====================================================================================
	-- cleanup & result
	-- =====================================================================================
		
	SET NOCOUNT OFF

END
GO
