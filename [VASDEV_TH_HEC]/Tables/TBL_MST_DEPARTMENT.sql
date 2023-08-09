SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_DEPARTMENT](
	[dept_code] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dept_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[approver_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[approver_email] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
