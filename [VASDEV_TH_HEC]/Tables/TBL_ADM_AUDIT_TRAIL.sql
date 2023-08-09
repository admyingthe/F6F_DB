SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_AUDIT_TRAIL](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[module] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[key_code] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[action] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[action_by] [int] NULL,
	[action_date] [datetime] NULL
) ON [PRIMARY]

GO
