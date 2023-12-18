IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'pr_co_save')
BEGIN DROP PROC pr_co_save END
GO

CREATE PROCEDURE [dbo].[pr_co_save] (
	@current_uid nvarchar(255) 
	, @result nvarchar(max) output

	, @co_name nvarchar(255)
	, @reg_no nvarchar(50)
	, @addr1 nvarchar(50)
	, @addr2 nvarchar(50)
	, @postcode nvarchar(50)
	, @city nvarchar(50)
	, @state nvarchar(50)
	, @country nvarchar(50)
	, @phone nvarchar(50)
	, @fax nvarchar(50)
	, @email nvarchar(255)
	, @mobile_phone nvarchar(50)
	, @co_status_id int
	, @org_row_guid uniqueidentifier 
	, @co_row_guid uniqueidentifier output
	
	, @url nvarchar(255)
	, @co_code nvarchar(50) = null					--9-apr-19,lhw
	, @is_debug int = 0
)
AS 
BEGIN

/*pr_co_save
- add/UPDATE company record. (Company Profile)

	declare @s nvarchar(max), @id uniqueidentifier
	--SET @id = '661437a8-a139-4f25-952a-594e90eed1e5'
	exec pr_co_save
			@current_uid			= 'tester'
			, @result				=@s output
			, @co_name				='Xdd SB'
			, @reg_no				= ''
			, @addr1				= ''
			, @addr2				= ''
			, @postcode				= ''
			, @city					= ''
			, @state				= ''
			, @country				= ''
			, @phone				= ''
			, @fax					= ''
			, @email				= ''
			, @mobile_phone			= ''
			, @co_status_id			= 1
			, @org_row_guid			= '824690a3-9243-43cc-b973-ac3f1e95b9b4' 
			, @co_row_guid			=@id output	
			, @url					='~/modules/admin/org_mt.aspx'
			, @co_code				= 'XDD'
			, @is_debug				=1
	SELECT @s 'result', @id 'id'
	

*/

	-- ==========================================================
	-- init
	-- ==========================================================
	
	IF @is_debug = 1 PRINT 'pr_co_save - start'

	SET NOCOUNT ON

	DECLARE	
		@co_name_old nvarchar(255)
		, @reg_no_old nvarchar(50)
		, @addr1_old nvarchar(50)
		, @addr2_old nvarchar(50)
		, @postcode_old nvarchar(50)
		, @city_old nvarchar(50)
		, @state_old nvarchar(50)
		, @country_old nvarchar(50)
		, @phone_old nvarchar(50)
		, @fax_old nvarchar(50)
		, @email_old nvarchar(255)
		, @mobile_phone_old nvarchar(50)
		, @co_status_old nvarchar(50)
		, @co_status nvarchar(50)
		, @org_id int
		, @org_name  nvarchar(50)

		, @audit_log nvarchar(max)
		, @audit_log_id uniqueidentifier
		, @module_id int
		, @co_code_old nvarchar(50)

	IF LEN(ISNULL(@co_name, '')) = 0
	BEGIN
		SET @result = 'Company Name Cannot Be Blank!!'
		SET NOCOUNT OFF
		RETURN
	END


	SELECT TOP 1
		@org_id = org_id
		, @org_name = org_name
	FROM tb_org
	--19-Oct-22,al - no passing guid into system.
	--WHERE org_row_guid = @org_row_guid
	
	SET @module_id = 1101006	--co module

	IF @co_status_id IS NULL
	BEGIN
		SET @co_status_id = 1
	END
	
	SELECT @co_status = co_status_desc
	FROM tb_co_status
	WHERE co_status_id = @co_status_id 

	-- ==========================================================
	-- process
	-- ==========================================================

	SELECT
		@co_name_old = a.co_name
		,@reg_no_old = a.reg_no
		,@addr1_old = a.addr1
		,@addr2_old = a.addr2
		,@postcode_old = a.postcode
		,@city_old = a.city
		,@state_old = a.state
		,@country_old = a.country
		,@phone_old = a.phone
		,@fax_old = a.fax
		,@email_old = a.email
		,@mobile_phone_old = a.mobile_phone
		,@co_status_old = s.co_status_desc
		,@co_code_old = a.co_code
		,@co_row_guid = a.co_row_guid
	FROM tb_co_profile a
	INNER JOIN tb_co_status s ON s.co_status_id = a.co_status_id
	----WHERE
	----	co_row_guid = @co_row_guid
		

	UPDATE tb_co_profile
	SET
		co_name = @co_name
		, reg_no = @reg_no
		, addr1 = @addr1
		, addr2 = @addr2
		, postcode = @postcode
		, city = @city
		, state = @state
		, country = @country
		, phone = @phone
		, fax = @fax
		, email = @email
		, mobile_phone = @mobile_phone
		, co_status_id = @co_status_id
		, org_id = @org_id
		, co_code = @co_code
	

	SET @audit_log = ''
	SET @audit_log = @audit_log + dbo.fn_has_changes('Company Name', @co_name_old, @co_name)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Company Code', @co_code_old, @co_code)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Registration #', @reg_no_old, @reg_no)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Address Line 1', @addr1_old, @addr1)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Address Line 2', @addr2_old, @addr2)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Postcode', @postcode_old, @postcode)
	SET @audit_log = @audit_log + dbo.fn_has_changes('City', @city_old, @city)
	SET @audit_log = @audit_log + dbo.fn_has_changes('State', @state_old, @state)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Country', @country_old, @country)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Phone', @phone_old, @phone)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Fax', @fax_old, @fax)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Email', @email_old, @email)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Mobile Phone', @mobile_phone_old, @mobile_phone)
	SET @audit_log = @audit_log + dbo.fn_has_changes('Status', @co_status_old, @co_status)


	-- remove the first comma symbol
	IF LEN(@audit_log) > 0
		SET @audit_log = RIGHT(@audit_log, LEN(@audit_log) - 1)
	ELSE
		SET @audit_log = '(No Changes)'

	SET @audit_log = 'Updated Company Record: '
						+ @audit_log
	

	SET @result = 'OK'

	IF @is_debug = 1 PRINT 'Audit Log Msg=>' + ISNULL(@audit_log, '???')

	-- ------------------------------------
	-- append audit log	
	-- ------------------------------------

	EXEC pr_sys_append_task_inbox 
			@current_uid
			, @url					--@task_inbox_url 
			, @audit_log			--@task 
			, @co_row_guid			--@task_fk_value
			, @module_id			--@module_id
			, null					--@co_row_guid
			, @audit_log_id output	--@task_inbox_id 
			, 'pr_co_save'			--@proc_name

	-- ==========================================================
	-- cleanup
	-- ==========================================================
	
	IF @is_debug = 1 PRINT 'pr_co_save - exit'
	
	SET NOCOUNT OFF

END
GO
