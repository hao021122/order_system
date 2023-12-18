IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'fn_get_app_desc')
BEGIN DROP FUNCTION fn_get_app_desc END
GO

CREATE FUNCTION fn_get_app_desc ()
RETURNS nvarchar(50)
AS
BEGIN
/*
-- return app description

	SELECT 
		dbo.fn_get_app_desc()
*/
	
	DECLARE 
		@s nvarchar(255)

	SELECT
		@s = prop_value
	FROM tb_sys_prop
	WHERE
		-- prop_name = 'app_desc'
		prop_name = 'app_config_title'

	RETURN @s

END
GO
