SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_VAS_ACTIVITY_RATE_DTL](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VAS_Activity_Rate_HDR_ID] [int] NOT NULL,
	[VAS_Activity_ID] [int] NOT NULL,
	[Normal_Rate] [decimal](18, 2) NOT NULL,
	[OT_Rate] [decimal](18, 2) NOT NULL,
	[Created_Date] [datetime] NULL,
	[Changed_Date] [datetime] NULL,
	[Creator_User_Id] [int] NULL,
	[Changed_User_Id] [int] NULL
) ON [PRIMARY]

GO
