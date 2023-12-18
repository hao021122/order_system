IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'fn_calc_rounding_adj')
BEGIN DROP FUNCTION fn_calc_rounding_adj END
GO

CREATE FUNCTION fn_calc_rounding_adj (
	-- Add the parameters for the function here
	@value money
)
RETURNS money
AS
BEGIN
/*
-- returns rounding adjustment for the total amount 

samples:
	
	SELECT 
		dbo.fn_calc_rounding_adj(1234.50)'1234.50'
		dbo.fn_calc_rounding_adj(1234.51)'1234.51'
		dbo.fn_calc_rounding_adj(1234.52)'1234.52'
		dbo.fn_calc_rounding_adj(1234.53)'1234.53'
		dbo.fn_calc_rounding_adj(1234.54)'1234.54'
		dbo.fn_calc_rounding_adj(1234.55)'1234.55'
		dbo.fn_calc_rounding_adj(1234.56)'1234.56'
		dbo.fn_calc_rounding_adj(1234.57)'1234.57'
		dbo.fn_calc_rounding_adj(1234.58)'1234.58'
		dbo.fn_calc_rounding_adj(1234.59)'1234.59'
*/
	-- Declare the return variable here
	DECLARE 
		@ch char(1)
		, @i int

		, @result money

	SET @ch = RIGHT(CAST(CAST(@value as numeric(15, 2)) as varchar), 1)
	SET @i = CAST(@ch as int)
	
	-- No adjustment
	IF ((@i = 0) OR (@i = 5))
	BEGIN
		SET @result = 0
	END
	ELSE 
	BEGIN
		IF ((@i = 1) OR (@i = 6))
		BEGIN
			SET @result = -0.01
		END
		ELSE IF ((@i = 2) OR (@i = 7))
		BEGIN
			SET @result = -0.02
		END
		ELSE IF ((@i = 3) OR (@i = 8))
		BEGIN
			SET @result = 0.02
		END
		ELSE IF ((@i = 4) OR (@i = 9))
		BEGIN
			SET @result = 0.01
		END
	END

	-- Return the result of the function
	RETURN @result

END
GO