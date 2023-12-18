IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'fn_has_changes')
BEGIN DROP FUNCTION fn_has_changes END
GO

CREATE FUNCTION fn_has_changes (
	-- Add the parameters for the function here
	@msg nvarchar(255)
	, @old_values nvarchar(255)
	, @new_values nvarchar(255)
)
RETURNS nvarchar(max)
AS
BEGIN
/*
-- returns audit log message if there is any changes

	SELECT 
		dbo.fn_has_changes('customer name', 'ABC S/B', 'ABC SDN BHD', )
		, dbo.fn_has_changes('customer name', 'ABC S/B', NULL )

	RESULT:
		, 'customer name' has changed from 'AMC S/B' to 'ABC SDN BHD'
*/
	-- Declare the return variable here
	DECLARE 
		@s nvarchar(max)

	IF ISNULL(@old_values, '') <> ISNULL(@new_values, '')
	BEGIN
		SET @s = ', "' 
					+ @msg
					+ '" has changed from "' 
					+ ISNULL(@old_values, '')
					+ '" to "'
					+ ISNULL(@new_values, '')
					+ '"'
	END
	ELSE
	BEGIN
		SET @s = ''
	END

	-- Return the result of the function
	RETURN @s 

END
GO
