IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_user_group_list') 
BEGIN DROP PROC pr_user_group_list END
GO

create proc [dbo].[pr_user_group_list] (
	@current_uid nvarchar(255) 
	, @user_group_id uniqueidentifier

	, @show_active_rec int
)
as
begin

/*#1050_0110
23-feb-16,lhw
- returns user groups.

	exec pr_user_group_list
			@current_uid = 'tester'
			, @user_group_id = null
			, @show_active_rec = -1
	

*/

	-- ==========================================================
	-- init
	-- ==========================================================
	
	-- ==========================================================
	-- process
	-- ==========================================================

	select
		ug.*

		, user_count = (
							select count(distinct user_id)
							from tb_users_co c
							where 
								c.user_group_id = ug.user_group_id 
								and user_id <> dbo.fn_empty_guid()
						)

		--, axn_count = (
		--					select count(*)
		--					from tb_user_allow_action a
		--					where a.user_group_id = ug.user_group_id 
		--				)


	from tb_user_group ug
	where
		(
			isnull(@show_active_rec, -1) = -1
			or ug.is_in_use = 1
		)
		and (
			dbo.fn_to_uid(@user_group_id ) = dbo.fn_empty_guid()
			or ug.user_group_id = @user_group_id 
		)
		
	order by 
		ug.user_group_desc


	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	

end
GO
