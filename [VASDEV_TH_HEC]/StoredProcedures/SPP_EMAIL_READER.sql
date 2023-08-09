SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =================================================================================================================
-- Author:		Smita Thorat
-- Create date: 2022-07-13
-- Description:	(Run by Job) Get Client's reply email from Central DB, Generate all the attachments to File Server
-- Example Query: 
-- =================================================================================================================

CREATE PROCEDURE [dbo].[SPP_EMAIL_READER]
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TEMP_EMAIL
	(
	row_id INT IDENTITY(1,1),
	mail_id INT,
	email_addr NVARCHAR(100),
	received_date DATETIME,
	timezone VARCHAR(50),
	mail_subject NVARCHAR(4000),
	mail_content NVARCHAR(4000),
	comment NVARCHAR(4000),
	system_running_no VARCHAR(15),
	approval_status VARCHAR(5)
	)


		 --Added to get Thailand Time along with date
	 DECLARE @CurrentDateTime AS DATETIME
	 SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
      --Added to get Thailand Time along with date


	INSERT INTO #TEMP_EMAIL (mail_id, email_addr, received_date, timezone, mail_subject, mail_content, comment, system_running_no, approval_status)
	SELECT mail_id, email_addr, received_date, timezone, mail_subject, mail_content, comment, SUBSTRING(RIGHT(mail_subject, 12), 1, 10), RIGHT(mail_subject, 1)
	FROM VASDEV.dbo.TBL_ADM_EMAIL_READER WITH(NOLOCK)
	WHERE processing_status = 'N' AND processing_remarks IS NULL AND db_name = 'VAS_TH_HEC'
	ORDER BY received_date

	DECLARE @tblDrive TABLE (drive varchar(10))
	DECLARE @outputdata TABLE (output varchar(MAX))

	DECLARE @i INT = 0, @mail_id INT, @running_no VARCHAR(50), @processing_status VARCHAR(10) = '', @processing_remarks NVARCHAR(150),
	@start_date DATETIME, @client_comments NVARCHAR(250)

	WHILE @i < (SELECT COUNT(*) FROM #TEMP_EMAIL)
	BEGIN
		SET @i = @i + 1

		SET @running_no = (SELECT system_running_no FROM #TEMP_EMAIL WHERE row_id = @i)
		SET @mail_id = (SELECT mail_id FROM #TEMP_EMAIL WHERE row_id = @i)
		SET @start_date = (SELECT end_date FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
		SET @client_comments = (SELECT comment FROM #TEMP_EMAIL WHERE row_id = @i)
		--Check if running no (MY00000001) exists in TBL_TXN_JOB_EVENT
		IF NOT EXISTS(SELECT * FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
			SELECT @processing_status = 'Y', @processing_remarks = 'Invalid running no'

		--Check if running no had been approved/rejected before (User replied to the email[same running_no] more than once)
		IF @processing_status = '' AND EXISTS (SELECT * FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE parent_running_no = @running_no)
			SELECT @processing_status = 'Y', @processing_remarks = 'Event had been approved/rejected before'

		IF @processing_status = ''
		BEGIN
			DECLARE @new_running_no VARCHAR(50) = 1, @len INT = 8, @job_ref_no VARCHAR(50)
			SELECT TOP 1 @new_running_no = CAST(CAST(RIGHT(running_no, 8) as INT) + 1 AS VARCHAR(50))
								FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, 8) AS INT) DESC
			SET @new_running_no = 'TH' + REPLICATE('0', @len - LEN(@new_running_no)) + @new_running_no

			SET @job_ref_no = (SELECT job_ref_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)

			IF (@job_ref_no IS NOT NULL)
			BEGIN
				IF (SELECT approval_status FROM #TEMP_EMAIL WHERE row_id = @i) = 'A'
				BEGIN
					SELECT @processing_status = 'Y', @processing_remarks = 'Approved'

					INSERT INTO TBL_TXN_JOB_EVENT
					(running_no, job_ref_no, event_id, start_date, end_date, remarks, parent_running_no, created_date)
					SELECT @new_running_no, @job_ref_no, '76', @start_date , @CurrentDateTime, @client_comments + ' (Auto generated [Approved on ' + CONVERT(varchar(10), GETDATE(), 121) + '][' + @running_no + '])', @running_no, @CurrentDateTime

					IF(LEFT(@job_ref_no,1) = 'S')
					begin
					UPDATE TBL_Subcon_TXN_WORK_ORDER
					SET current_event = '76'
					WHERE job_ref_no = @job_ref_no
					end
					else
					begin
					UPDATE TBL_TXN_WORK_ORDER_JOB_DET
					SET current_event = '76'
					WHERE job_ref_no = @job_ref_no
					end

					--Get Attachment--
					SELECT IDENTITY(INT, 1, 1) AS row_id, file_name, attachment
					INTO #TEMP_EMAIL_ATTACHMENT
					FROM VASDEV.dbo.TBL_ADM_EMAIL_READER_ATTACHMENT WITH(NOLOCK)
					WHERE mail_id = @mail_id

					DECLARE @j INT = 1, @count_attachment INT = 0
					SET @count_attachment = (SELECT COUNT(*) FROM #TEMP_EMAIL_ATTACHMENT)
					IF @count_attachment > 0
					BEGIN
						DECLARE @folder_path NVARCHAR(4000), @cmdpath VARCHAR(4000)

						--List of map drive
						INSERT INTO @tblDrive(drive) EXECUTE master.sys.xp_cmdshell N'wmic logicaldisk get name';

if				(select count(0) from @tblDrive where drive like 'Z%') = 0
begin

delete from		@outputdata
INSERT INTO		@outputdata(output) 
EXECUTE			master.sys.xp_cmdshell N'net use Z: \\10.208.2.53\FileServer B$@dm1n#Rdc03 /USER:bsadmin /PERSISTENT:YES';

if				(select count(0) from @outputdata where output = 'The command completed successfully.') > 0
begin

print 'drive mapped'
end

end

						CREATE TABLE #ResultSet (Directory varchar(200))
						INSERT INTO #ResultSet EXEC master.dbo.xp_subdirs N'Z:\WebApplications\Q00\VAS\Documents\TH-HEC\'
						DECLARE @folder_exists INT 
						SET @folder_exists = (SELECT COUNT(*) FROM #ResultSet WHERE Directory = @new_running_no)
							SET @folder_path = N'Z:\WebApplications\Q00\VAS\Documents\TH-HEC\' + @new_running_no + '\'
						IF (@folder_exists = 0)
						BEGIN
							SET @cmdpath = 'MD ' + @folder_path
						EXEC master..xp_cmdshell @cmdpath, no_output;
						END
						DROP TABLE #ResultSet
						--- Check if folder exists ---
						
						--- Convert binary file to physical files ---
						DECLARE @img_path VARBINARY(MAX), @timestamp NVARCHAR(500), @ObjectToken INT
						WHILE @j <= @count_attachment
						BEGIN
							SELECT @img_path = attachment from #TEMP_EMAIL_ATTACHMENT WHERE row_id = @j
							SELECT @timestamp =  @folder_path + file_name FROM #TEMP_EMAIL_ATTACHMENT  WHERE row_id = @j
							EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
							EXEC sp_OASetProperty @ObjectToken, 'Type', 1
							EXEC sp_OAMethod @ObjectToken, 'Open'
							EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @img_path
							EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @timestamp, 2
							EXEC sp_OAMethod @ObjectToken, 'Close'
							EXEC sp_OADestroy @ObjectToken
							SET @j = @j + 1
						END 
						--- Convert binary file to physical files ---
					END
					--Get Attachment--
					DROP TABLE #TEMP_EMAIL_ATTACHMENT
				END
				ELSE IF (SELECT approval_status FROM #TEMP_EMAIL WHERE row_id = @i) = 'R'
				BEGIN
					SELECT @processing_status = 'Y', @processing_remarks = 'Rejected'

					INSERT INTO TBL_TXN_JOB_EVENT
					(running_no, job_ref_no, event_id, start_date, end_date, remarks, parent_running_no, created_date)
					SELECT @new_running_no, @job_ref_no, '77', @start_date, @CurrentDateTime, @client_comments + ' (Auto generated [Rejected on ' + CONVERT(varchar(10), GETDATE(), 121) + '][' + @running_no + '])', @running_no, @CurrentDateTime

					IF(LEFT(@job_ref_no,1) = 'S')
					begin
					UPDATE TBL_Subcon_TXN_WORK_ORDER
					SET current_event = '77'
					WHERE job_ref_no = @job_ref_no
					end
					else
					begin
					UPDATE TBL_TXN_WORK_ORDER_JOB_DET
					SET current_event = '77'
					WHERE job_ref_no = @job_ref_no
					end

					--Get Attachment--
					SELECT IDENTITY(INT, 1, 1) AS row_id, file_name, attachment
					INTO #TEMP_EMAIL_ATTACHMENT_REJECTED
					FROM VASDEV.dbo.TBL_ADM_EMAIL_READER_ATTACHMENT WITH(NOLOCK)
					WHERE mail_id = @mail_id

					DECLARE @k INT = 1, @count_attachment_rejected INT = 0
					SET @count_attachment_rejected = (SELECT COUNT(*) FROM #TEMP_EMAIL_ATTACHMENT_REJECTED)
					IF @count_attachment_rejected > 0
					BEGIN
						DECLARE @folder_path_rejected NVARCHAR(4000), @cmdpath_rejected VARCHAR(4000)

						--List of map drive
						INSERT INTO @tblDrive(drive) EXECUTE master.sys.xp_cmdshell N'wmic logicaldisk get name';

if				(select count(0) from @tblDrive where drive like 'Z%') = 0
begin

delete from		@outputdata
INSERT INTO		@outputdata(output) 
EXECUTE			master.sys.xp_cmdshell N'net use Z: \\10.208.2.53\FileServer B$@dm1n#Rdc03 /USER:bsadmin /PERSISTENT:YES';

if				(select count(0) from @outputdata where output = 'The command completed successfully.') > 0
begin

print 'drive mapped'
end

end

						CREATE TABLE #ResultSetRejected (Directory varchar(200))
						INSERT INTO #ResultSetRejected EXEC master.dbo.xp_subdirs N'Z:\WebApplications\Q00\VAS\Documents\TH-HEC\'
						DECLARE @folder_exists_rejected INT 
						SET @folder_exists_rejected = (SELECT COUNT(*) FROM #ResultSetRejected WHERE Directory = @new_running_no)
							SET @folder_path_rejected = N'Z:\WebApplications\Q00\VAS\Documents\TH-HEC\' + @new_running_no + '\'
						IF (@folder_exists_rejected = 0)
						BEGIN
							SET @cmdpath_rejected = 'MD ' + @folder_path_rejected
						EXEC master..xp_cmdshell @cmdpath_rejected, no_output;
						END
						DROP TABLE #ResultSetRejected
						--- Check if folder exists ---
						
						--- Convert binary file to physical files ---
						DECLARE @img_path_rejected VARBINARY(MAX), @timestamp_rejected NVARCHAR(500), @ObjectToken_rejected INT
						WHILE @k <= @count_attachment_rejected
						BEGIN
							SELECT @img_path_rejected = attachment from #TEMP_EMAIL_ATTACHMENT_REJECTED WHERE row_id = @j
							SELECT @timestamp_rejected =  @folder_path_rejected + file_name FROM #TEMP_EMAIL_ATTACHMENT_REJECTED  WHERE row_id = @j
							EXEC sp_OACreate 'ADODB.Stream', @ObjectToken_rejected OUTPUT
							EXEC sp_OASetProperty @ObjectToken_rejected, 'Type', 1
							EXEC sp_OAMethod @ObjectToken_rejected, 'Open'
							EXEC sp_OAMethod @ObjectToken_rejected, 'Write', NULL, @img_path_rejected
							EXEC sp_OAMethod @ObjectToken_rejected, 'SaveToFile', NULL, @timestamp_rejected, 2
							EXEC sp_OAMethod @ObjectToken_rejected, 'Close'
							EXEC sp_OADestroy @ObjectToken_rejected
							SET @k = @k + 1
						END 
						--- Convert binary file to physical files ---
					END
					--Get Attachment--
					DROP TABLE #TEMP_EMAIL_ATTACHMENT_REJECTED
				END
			END
		END

		--Exec master.dbo.xp_cmdshell 'net use Z: /delete'

		UPDATE VASDEV.dbo.TBL_ADM_EMAIL_READER
		SET processing_status = @processing_status,
			processing_remarks = @processing_remarks,
			processing_date = GETDATE()
		WHERE mail_id = @mail_id  AND db_name = 'VAS_TH_HEC'
	END 
	DROP TABLE #TEMP_EMAIL
Exec master.dbo.xp_cmdshell 'net use Z: /delete'
END



GO
