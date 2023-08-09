SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Generate HTML file
-- Example Query: 
-- ================================

CREATE PROCEDURE [dbo].[SPP_GENERATE_HTML]
(
	@String NVARCHAR(MAX),
	@Path NVARCHAR(255),
	@Filename NVARCHAR(100)
)
AS
	SET NOCOUNT ON;

	DECLARE @objFileSystem INT, @objTextStream INT, @objErrorObject INT, @strErrorMessage NVARCHAR(1000), 
			@Command VARCHAR(1000), @hr INT, @fileAndPath VARCHAR(80)

	SELECT @strErrorMessage = 'Opening the File System Object'
	EXECUTE @hr = sp_OACreate 'Scripting.FileSystemObject', @objFileSystem OUT

	SELECT @FileAndPath = @path + '\' + @filename
	IF @hr = 0 SELECT @objErrorObject = @objFileSystem, @strErrorMessage = 'Creating file "' + @FileAndPath + '"' 
	IF @hr = 0 EXECUTE @hr = sp_OAMethod @objFileSystem, 'CreateTextFile', @objTextStream OUT, @FileAndPath, 2, True
	IF @hr = 0 SELECT @objErrorObject = @objTextStream, @strErrorMessage = 'Writing to the file "' + @FileAndPath + '"'
	IF @hr = 0 EXECUTE @hr = sp_OAMethod @objTextStream, 'Write', NULL, @String
	IF @hr = 0 SELECT @objErrorObject = @objTextStream, @strErrorMessage = 'Closing the file "' + @FileAndPath + '"'
	IF @hr = 0 EXECUTE @hr = sp_OAMethod @objTextStream, 'Close'

	IF @hr <> 0
	BEGIN
		DECLARE @Source NVARCHAR(255), @Description NVARCHAR(255), @Helpfile NVARCHAR(255), @HelpID INT

		EXECUTE sp_OAGetErrorInfo @objErrorObject, @source OUTPUT, @Description OUTPUT, @Helpfile OUTPUT, @HelpID OUTPUT
		SELECT @strErrorMessage = 'Error whilst ' + COALESCE(@strErrorMessage, 'doing something') + ', ' + COALESCE(@Description, '')
		RAISERROR(@strErrorMessage, 16, 1)
	END

	EXECUTE sp_OADestroy @objTextStream
	EXECUTE sp_OADestroy @objTextStream
GO
