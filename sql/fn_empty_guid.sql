IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'fn_empty_guid')
BEGIN DROP FUNCTION fn_empty_guid END
GO

CREATE FUNCTION fn_empty_guid()
RETURNS uniqueidentifier
AS
BEGIN
	-- Declare the return variable here
	DECLARE @result uniqueidentifier

	-- Add the T-SQL statements to compute the return value here
	set @result = CAST(CAST(0 as varbinary) as uniqueidentifier)

	-- Return the result of the function
	RETURN @result

END
GO
