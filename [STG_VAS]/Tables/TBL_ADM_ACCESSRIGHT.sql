/****** Object:  Table [dbo].[TBL_ADM_ACCESSRIGHT]    Script Date: 08-Aug-23 8:37:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_ACCESSRIGHT](
	[accessright_id] [int] IDENTITY(1,1) NOT NULL,
	[accessright_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[principal_id] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[accessright_button_id] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[creator_user_id] [numeric](18, 0) NULL,
	[changed_date] [datetime] NULL,
	[changed_user_id] [numeric](18, 0) NULL,
	[status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
