/****** Object:  StoredProcedure [dbo].[CONFIG_GET_INPUT_SOURCE_DDL]    Script Date: 08-Aug-23 8:39:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CONFIG_GET_INPUT_SOURCE_DDL]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT name as spp_name FROM sys.procedures
END

GO
