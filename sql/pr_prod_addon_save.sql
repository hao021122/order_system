IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_prod_addon_save')
BEGIN DROP PROC pr_prod_addon_save END
GO

CREATE PROCEDURE [dbo].[pr_prod_addon_save] (
	@current_uid nvarchar(255)
	, @result nvarchar(max) output

	, @prod_addon_id uniqueidentifier output
	, @prod_id uniqueidentifier
	, @condiment_id uniqueidentifier
	, @request_group_code nvarchar(50)
	, @addon_id uniqueidentifier				-- 29-Mar-23,al

	, @co_id uniqueidentifier
	, @axn nvarchar(50)
	, @my_role_id int = 0
	, @url nvarchar(255)
	, @is_debug int = 0
)
AS
BEGIN
/*pr_prod_addon_save

-

sample code:

	declare @s nvarchar(max), @id uniqueidentifier 
	exec pr_prod_addon_save
		@current_uid = 'tester'
		, @result = @s output

		, @prod_addon_id = @id output
		, @prod_id = null
		, @condiment_id = null
		, @request_group_code = 'Doneness'
		, @addon_id = null

		, @co_id = null
		, @axn = null
		, @my_role_id = 0
		, @url = '~/q'
		, @is_debug = 0

	select @s'@result', @id'@id' 

*/

	-- ================================================================
	-- init 
	-- ================================================================

	set nocount on

	declare
		@now datetime

		, @module_id int

	set @now = getdate()
	set @result = null
	set @module_id = 2103018

	-- ------------------------------------
	-- validation
	-- ------------------------------------

	if dbo.fn_to_uid(@prod_id) = dbo.fn_empty_guid()
	begin
		set @result = 'Prod Id Cannot Be Blank!!'
		set nocount off
		return 
	end



	-- ================================================================
	-- process 
	-- ================================================================

	-- ------------------------------------
	-- insert record
	-- ------------------------------------

	if not exists(
		select *
		from tb_prod_addon
		where
			prod_id = @prod_id
			and dbo.fn_to_uid(condiment_id) = dbo.fn_to_uid(@condiment_id)
			and isnull(request_group_code, '') = isnull(@request_group_code, '')
			--29-Mar-23,al
			and dbo.fn_to_uid(addon_id) = dbo.fn_to_uid(@addon_id)
	)
	begin

		--append if not exists
		set @prod_addon_id = newid()

		insert into tb_prod_addon(
			prod_addon_id,prod_id,condiment_id,request_group_code,addon_id
		) values (
			@prod_addon_id,@prod_id,@condiment_id,@request_group_code,@addon_id
		)

	end


	set @result = 'OK'



	-- ================================================================
	-- cleanup 
	-- ================================================================

	SET NOCOUNT OFF
	
END
GO
