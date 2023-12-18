IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_sys_pymt_type_list')
BEGIN DROP PROC pr_sys_pymt_type_list END
GO

CREATE PROCEDURE pr_sys_pymt_type_list (
	@current_uid nvarchar(255)
	, @sys_pymt_type_id int
	, @is_in_use int
	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*
	sample code: 

	EXEC pr_sys_pymt_type_list 
		@current_uid = 'tester'
		, @sys_pymt_type_id = null
		, @is_in_use = -1
		, @co_id = null
		, @axn = null
		, @my_role_id  = 0
		, @url = null
		, @is_debug = 0
*/
	-- ================================================================  
	-- int  
	-- ================================================================  

	SET NOCOUNT ON;

	-- ================================================================  
	-- process 
	-- ================================================================ 

	SELECT 
		sys_pymt_type_id
		, sys_pymt_type_desc
		, is_deposit
		, is_credit_sales
		, is_legal_tender
	FROM tb_sys_pymt_type
	WHERE 
		(ISNULL(@sys_pymt_type_id, 0) = 0 OR sys_pymt_type_id = @sys_pymt_type_id)
		AND (ISNULL(@is_in_use, -1) = -1 OR is_in_use = @is_in_use)
	ORDER BY 
		sys_pymt_type_desc

END
GO
