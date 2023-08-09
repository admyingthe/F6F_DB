SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADD_REDRESSING_JOB_TABLE]
@redressingJob NVARCHAR(50)
AS
BEGIN
	DELETE [dbo].[TBL_REDRESSING_JOB_FORMAT]

	INSERT INTO [dbo].[TBL_REDRESSING_JOB_FORMAT]
           ([format_code])
     VALUES
           (@redressingJob)
END
GO
