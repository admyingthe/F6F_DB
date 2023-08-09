SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_YING_TEST]
	@input NVARCHAR(MAX),
	@resultSet1 NVARCHAR(MAX) OUT,
    @resultSet2 NVARCHAR(MAX) OUT
AS
BEGIN
	SELECT 
		@resultSet1 = (SELECT * FROM (SELECT 'asdf' AS asdf) T1 FOR JSON AUTO),
		@resultSet2 = (SELECT * FROM (SELECT 'qwer' AS qwer, 'zxcv' AS zxcv, @input AS input) T2 FOR JSON AUTO);

	-- testing bulk replace
END
GO
