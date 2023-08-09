SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Update PPM
-- Example Query: exec SPP_TXN_PPM_UPDATE @param=N'{"pk":"V2022/09/0009|;|4","name":"issued_qty","value":"6"}',@user_id=N'8032'
-- ========================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_PPM_UPDATE]
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @key VARCHAR(50), @job_ref_no VARCHAR(50), @line_no INT, @name NVARCHAR(100), @value NVARCHAR(100)
	SET @key = (SELECT JSON_VALUE(@param, '$.pk'))
	SET @name = (SELECT JSON_VALUE(@param, '$.name'))
	SET @value = (SELECT JSON_VALUE(@param, '$.value'))
	SET @job_ref_no = (SELECT LEFT(@key, CHARINDEX('|;|', @key, CHARINDEX('|;|', @key)) -1))
	SET @line_no = (SELECT RIGHT(@key, (CHARINDEX('|;|',REVERSE(@key),0))-1))

	EXEC REPLACE_SPECIAL_CHARACTER @value, @value OUTPUT

	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'UPDATE A 
				SET ' + @name + ' = N''' + @value + ''' 
				FROM TBL_TXN_PPM A WITH(NOLOCK) 
				LEFT JOIN VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP B WITH(NOLOCK) ON A.system_running_no = B.requirement_no AND A.line_no=B.line_no
				WHERE A.job_ref_no = ''' + @job_ref_no + ''' AND A.line_no = ' + CAST(@line_no as VARCHAR(10)) -- + ' AND B.status <> ''R'''
	EXEC (@sql)
	PRINT(@sql)
	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	SELECT 'PPM', @job_ref_no, 'Updated ' + @name + ' [' + CAST(@line_no as VARCHAR(10)) + ']', @user_id, GETDATE()
END



--SELECT * FROM TBL_TXN_PPM WHERE job_ref_no='V2022/09/0009'
GO
