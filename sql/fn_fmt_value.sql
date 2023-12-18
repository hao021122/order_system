IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE NAME = 'fn_fmt_value') 
BEGIN DROP FUNCTION fn_fmt_value END
GO

CREATE FUNCTION fn_fmt_value (
	-- Add the parameters for the function here
	@value nvarchar(255)
	, @fmt varchar(5)
)
RETURNS nvarchar(50)
AS
BEGIN
/*
-- return the date/ time value into proper format
	
	SELECT 
		dbo.fn_fmt_value('2010-12-31 23:44:55', 'd') 'd'
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 'dd') 'dd'
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 't') 't'
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 'dt') 'dt'
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 'ddt') 'ddt'

		-- 2 digit year
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 'd2') 'd2'
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 'dd2') 'dd2'
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 't2') 't2'
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 'dt2') 'dt2'
		, dbo.fn_fmt_value('2010-12-31 23:44:55', 'ddt2') 'ddt2'

		, dbo.fn_fmt_value('12345, 6897234, 'm') 'm'
		, dbo.fn_fmt_value('12345, 6897234', 'm4') 'm4'
		, dbo.fn_fmt_value('2143422345.6897234', 'm6') 'm6'
		, dbo.fn_fmt_value('2143422345.6897234', 'm8') 'm8'

		, dbo.fn_fmt_value('2143422345.6897234', 'b') 'space'

*/
	-- ================================================================
	-- init
	-- ================================================================
	DECLARE 
		@s nvarchar(50)
		, @short_yr int
		, @dt datetime
		, @decimal_value numeric(20, 8)
		, @no_of_digit int
		, @1k float

	-- ================================================================
	-- process
	-- ================================================================
	IF LEN(ISNULL(@fmt, '')) = 0
	BEGIN
		IF ISNUMERIC(@value) = 1
		BEGIN
			SET @fmt = 'm'
		END
		ELSE 
		BEGIN
			SET @fmt = 'd'
		END
 	END

	IF LEFT(@fmt, 1) IN ('d', 't')		-- date or time
	AND CHARINDEX('2', @fmt) > 0		-- request to show 2 digit year
	BEGIN
		SET @short_yr = 100
		SET @fmt = LEFT(@fmt, LEN(@fmt) - 1)
	END
	ELSE
	BEGIN
		SET @short_yr = 0
	END

	-- ----------------------------------------------------------------

	IF LEFT(@fmt, 1) = 'm'
	BEGIN
		-- date only
		SET @decimal_value = CAST(@value as numeric(20, 8))

		IF LEN(@fmt) > 1
			SET @no_of_digit = CAST(SUBSTRING(@fmt, 2, LEN(@fmt) - 1) as int)
		ELSE
			SET @no_of_digit = 2		-- default is 2 digits

		SET @s = dbo.fn_fmt_currency(@decimal_value, @no_of_digit)
	END

	-- ----------------------------------------------------------------

	ELSE IF @fmt = 'd'
	BEGIN
		-- date only
		SET @dt = CAST(@value as datetime)
		SET @s = REPLACE(CONVERT(nvarchar, @dt, 106 - @short_yr), ' ', '.')
	END
	ELSE IF @fmt = 'dd'
	BEGIN
		-- proper date
		SET @dt = CAST(@value as datetime)
		SET @s = REPLACE(CONVERT(nvarchar, @dt, 106 - @short_yr), ' ', '.')
					+ ', '
					+ LEFT(DATENAME(dw, GETDATE()), 3)
	END
	ELSE IF @fmt = 't'
	BEGIN
		-- time only
		SET @dt = CAST(@value as datetime)
		SET @s = CONVERT(nvarchar, @dt, 108)
	END
	ELSE IF @fmt = 'dt'
	BEGIN
		-- date + time
		SET @dt = CAST(@value as datetime)
		SET @s = REPLACE(CONVERT(nvarchar, @dt, 106 - @short_yr), ' ', '.')
					+ ' @ '
					+ CONVERT(nvarchar, @dt, 108)
	END
	ELSE IF @fmt = 'ddt'
	BEGIN
		-- proper date + time
		SET @dt = CAST(@value as datetime)
		SET @s = REPLACE(CONVERT(nvarchar, @dt, 106 - @short_yr), ' ', '.')
					+ ', '
					+ LEFT(DATENAME(dw, GETDATE()), 3)
					+ ' @ '
					+ CONVERT(nvarchar, @dt, 108)
	END
	ELSE IF @fmt = 'b'
	BEGIN
		-- format the value into storage space
		SET @1k = 1024.0
		SET @decimal_value = CAST(@value as float)

		SET @s = CASE
					WHEN @decimal_value = 0 THEN '0 byte'
					WHEN @decimal_value < POWER(@1k, 1) THEN CAST(@decimal_value / POWER(@1k, 0) as varchar) + 'bytes'
					WHEN @decimal_value < POWER(@1k, 2) THEN CAST(CAST(@decimal_value / POWER(@1k, 1) as numeric(15, 1)) as varchar) + 'KB'
					WHEN @decimal_value < POWER(@1k, 3) THEN CAST(CAST(@decimal_value / POWER(@1k, 2) as numeric(15, 1)) as varchar) + 'MB'
					WHEN @decimal_value < POWER(@1k, 4) THEN CAST(CAST(@decimal_value / POWER(@1k, 3) as numeric(15, 1)) as varchar) + 'GB'
				END
	END

	-- ================================================================
	-- cleanup
	-- ================================================================
	RETURN @s

END
GO
