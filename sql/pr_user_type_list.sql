IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_user_type_list')
BEGIN DROP PROC pr_user_type_list END
GO

CREATE PROCEDURE [dbo].[pr_user_type_list] (
	@current_uid nvarchar(255) 
)
AS
BEGIN
/*#1000_0130
12-aug-15,lhw
- returns user types.

	exec pr_user_type_list
			@current_uid = 'tester'
	

*/

	-- ==========================================================
	-- init
	-- ==========================================================
	
	-- ==========================================================
	-- process
	-- ==========================================================

	select	
		user_type_id
		, user_type_desc
		, default_url
		, skip_rec_section_url
	from tb_user_type
	where
		is_in_use = 1
	order by 
		user_type_id
		, user_type_desc

	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	

END
GO
