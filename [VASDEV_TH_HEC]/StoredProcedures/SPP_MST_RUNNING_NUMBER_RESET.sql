SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 27/02/2023
-- Description:	Reset Runnung Number
-- =============================================
CREATE PROCEDURE SPP_MST_RUNNING_NUMBER_RESET
	@Reset_Mode AS tinyint -- 1: DAILY 2: MONTHLY 3: YEARLY
AS
BEGIN

	IF(@Reset_Mode = 1)
		BEGIN
			UPDATE TBL_MST_RUNNING_NO
			SET Last_Running_No = Start_No - 1
			WHERE Is_Daily_Reset = 1
		END
	ELSE IF(@Reset_Mode = 2)
		BEGIN
			UPDATE TBL_MST_RUNNING_NO
			SET Last_Running_No = Start_No - 1
			WHERE Is_Month_Reset = 1
		END
	ELSE IF(@Reset_Mode = 3)
		BEGIN
			UPDATE TBL_MST_RUNNING_NO
			SET Last_Running_No = Start_No - 1
			WHERE Is_Yearly_Reset = 1
		END
END

GO
