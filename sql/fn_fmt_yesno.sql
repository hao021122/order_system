IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'fn_fmt_yesno')
BEGIN DROP FUNCTION fn_fmt_yesno END
GO

CREATE FUNCTION fn_fmt_yesno (
	-- Add the parameters for the function here
	@value int
)
RETURNS nvarchar(3)
AS
BEGIN
/*
-- returns 'yes' if the @value is '1'. Otherwise, return 'no'

	SELECT
		dbo.fn_fmt_yesno(1)
		, dbo.fn_fmt_yesno(0)
		, dbo.fn_fmt_yesno(1123456)
*/
	
	DECLARE
		@s nvarchar(3)

	IF @value = 1
		SET @s = 'Yes'
	ELSE
		SET @s = 'No'

	RETURN @s

END
GO
