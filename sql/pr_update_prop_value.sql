IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_update_prop_value')
BEGIN DROP PROC pr_update_prop_value END
GO

create proc [dbo].[pr_update_prop_value] (
	@prop_name nvarchar(255)
	, @prop_value nvarchar(max)
	, @uid nvarchar(255)
	, @co_id int
)
as
begin
/*#0000_0108
9-aug-2015,lhw
- update the prop value.

	declare @s nvarchar(255)
	select @s = cast(getdate() as nvarchar)

	exec pr_update_prop_value 
		'test_prop'
		, @s
		, 'aaa'--@uid
		, 1234 --@co_id

	select *
	from tb_sys_prop
	where prop_name = 'test_prop'


*/

	declare 
		@init_local_trans int,
		@sys_prop_id bigint

	set nocount on 

	if @@trancount = 0
	begin
		select @init_local_trans = 1
		begin tran
	end

	-- ---------------------------------------------------------------
	begin try
		if not exists(
			select * 
			from tb_sys_prop
			where
				prop_name =	@prop_name
				and co_id = @co_id
		)
		begin

			-- generate a new id.
			exec pr_sys_gen_new_id 
						'tb_sys_prop',
						@sys_prop_id output

			-- append the row
			insert into tb_sys_prop (
				sys_prop_id
				, row_guid
				, org_id
				, co_id
				, prop_group
				, modified_on,modified_by,created_on,created_by
				, prop_name
				, prop_value
			)
			select
				@sys_prop_id
				, newid()
				, 0
				, @co_id
				, 'SYSTEM'
				, getdate(), @uid, getdate(), @uid
				, @prop_name
				, @prop_value

		end
		else
		begin

			update tb_sys_prop
			set
				prop_value = @prop_value
				, modified_on = getdate()
				, modified_by = @uid
			where
				prop_name = @prop_name
				and co_id = @co_id

		end

		if @init_local_trans = 1
		begin
			commit
		end
	end try
	begin catch

		if @init_local_trans = 1
		begin
			rollback
		end
		print 'ERROR=>' + error_message()

	end catch

	-- ---------------------------------------------------------------
	set nocount off
 
end
GO
