SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VAS_CONDITIONS](
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[start_date] [datetime] NULL,
	[end_date] [datetime] NULL,
	[previous_val] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[current_val] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[process_ind] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lastupdate] [datetime] NULL,
	[country] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
