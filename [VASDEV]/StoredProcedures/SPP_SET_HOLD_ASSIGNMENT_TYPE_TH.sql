SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SPP_SET_HOLD_ASSIGNMENT_TYPE_TH
	@holdAssignmentType int
AS
BEGIN
	SET NOCOUNT ON;

    update [dbo].[TBL_ADM_CONFIGURATION_TH]
	set config_value = @holdAssignmentType
	where config = 'TH_HEC_HOLD_ASSIGNMENT_VALUE'
END

GO
