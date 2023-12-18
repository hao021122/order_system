IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'fn_to_uid ')
BEGIN DROP FUNCTION fn_to_uid  END
GO

CREATE FUNCTION fn_to_uid 
(
	-- Add the parameters for the function here
	@user_id nvarchar(36)
)
RETURNS uniqueidentifier
AS
BEGIN
	-- Declare the return variable here
	DECLARE 
		@result uniqueidentifier

	if LEN(ISNULL(@user_id, '')) <> 36
	begin
		set @result = CAST(CAST(0 as varbinary) as uniqueidentifier)
	end
	else 
	begin
		set @result = CAST(@user_id as uniqueidentifier)
	end

	-- Return the result of the function
	RETURN @result

END
GO
