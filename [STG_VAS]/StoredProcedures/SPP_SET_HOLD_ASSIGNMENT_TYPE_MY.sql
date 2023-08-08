/****** Object:  StoredProcedure [dbo].[SPP_SET_HOLD_ASSIGNMENT_TYPE_MY]    Script Date: 08-Aug-23 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SPP_SET_HOLD_ASSIGNMENT_TYPE_MY
	@holdAssignmentType int
AS
BEGIN
	SET NOCOUNT ON;

    update [dbo].[TBL_ADM_CONFIGURATION]
	set config_value = @holdAssignmentType
	where config = 'MY_HEC_HOLD_ASSIGNMENT_VALUE'
END

GO
