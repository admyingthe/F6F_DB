SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_VAS_ACTIVITY_RATE_HDR](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VAS_Activity_Rate_Code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Effective_Start_Date] [datetime] NOT NULL,
	[Effective_End_Date] [datetime] NOT NULL,
	[Created_Date] [datetime] NULL,
	[Changed_Date] [datetime] NULL,
	[Creator_User_Id] [int] NULL,
	[Changed_User_Id] [int] NULL,
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_deleted] [bit] NULL DEFAULT ((0)),
	[status] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[approver_user_ID] [int] NULL,
	[approval_datetime] [datetime] NULL
) ON [PRIMARY]

GO
