/****** Object:  Table [dbo].[TBL_ADM_PRINCIPAL]    Script Date: 08-Aug-23 8:39:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_PRINCIPAL](
	[principal_id] [int] IDENTITY(1,1) NOT NULL,
	[principal_code] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[principal_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[currency_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[country_id] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[setting_id] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_date] [datetime] NULL,
	[creator_user_id] [int] NULL,
	[changed_date] [datetime] NULL,
	[changed_user_id] [int] NULL,
	[status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
