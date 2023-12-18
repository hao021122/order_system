IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_co_profile_load')
BEGIN DROP PROC pr_co_profile_load END
GO

CREATE PROCEDURE pr_co_profile_load ( 
	@current_uid nvarchar(255)
	, @org_row_guid uniqueidentifier
	, @co_row_guid uniqueidentifier
)
AS
BEGIN
	-- ==========================================================
	-- init
	-- ==========================================================
	SET NOCOUNT ON;

	-- ==========================================================
	-- process
	-- ==========================================================
    
	SELECT 
		cp.*
		, user_count = (
						SELECT COUNT(DISTINCT user_id)
						FROM tb_users_co c
						WHERE 
							c.co_row_guid = cp.co_row_guid
							AND user_id <> dbo.fn_empty_guid()
					)
	FROM tb_co_profile cp

	-- ==========================================================
	-- cleanup
	-- ==========================================================

END
GO
