IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_order_tx_admin_allow_edit')
BEGIN DROP PROC pr_order_tx_admin_allow_edit END
GO

CREATE PROCEDURE [dbo].[pr_order_tx_admin_allow_edit] (
	@current_uid nvarchar(255)
	, @result int output
	, @msg nvarchar(max) output

	, @profiler_trans_id uniqueidentifier
	, @tr_type nvarchar(5)
	, @last_mod_on datetime

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS 
BEGIN
/*pr_order_tx_user_allow_edit

- control ADMIN update order

sample code:

	declare @s int
	exec pr_order_tx_admin_allow_edit
		@current_uid = 'tester'
		, @result = @s output

		, @profiler_trans_id = null
		, @tr_type = 'cus'
		, @tr_date = '2020-03-02'
	
		, @last_mod_on = '2020-03-02 17:48:42.370'

		, @co_id = 'A1EEE2B8-C66A-45DD-86D9-C6E45592CD12'
		, @axn = null
		, @my_role_id = 0
		, @url = '~/q'
		, @is_debug = 1

	select @s'@result' 

*/

	-- ================================================================
	-- init 
	-- ================================================================

	SET NOCOUNT ON

	IF @is_debug = 1 PRINT 'pr_order_tx_admin_allow_edit - start'

	DECLARE
		@tr_type_old nvarchar(10)
		, @tr_status_old nvarchar(10)

	SET @result = ''
	SET @msg = ''

	-- ================================================================
	-- process 
	-- ================================================================

	-- The record exists or not
	IF EXISTS (
		SELECT *
		FROM tb_profiler_trans
		WHERE 
			profiler_trans_id = @profiler_trans_id
	)
	BEGIN	
		-- start to check 
		SELECT 
			@tr_type_old = tr_type
			, @tr_status_old = tr_status
		FROM tb_profiler_trans
		WHERE 
			profiler_trans_id = @profiler_trans_id

		IF @tr_type_old = 'AC'
		BEGIN
			IF @tr_status_old IN ('S', 'A') 			-- Submitted, Approved
			BEGIN
				SET @result = 1
				SET @msg = 'OK'
			END
			ELSE										-- Draft, Rejected, Completed, Cancel
			BEGIN
				SET @result = 0
			END
		END
		ELSE
		BEGIN
			SET @result = 0
			SET @msg = 'Editing is not Allowed because the Order Already Canceled!!'
			SET NOCOUNT OFF
			RETURN
		END
	END

	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF

	IF @is_debug = 1 PRINT 'pr_order_tx_admin_allow_edit - end'

END
GO
