/****** Object:  Table [dbo].[TBL_ADM_PWD_HIST]    Script Date: 08-Aug-23 8:46:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_PWD_HIST](
	[user_id] [int] NULL,
	[password] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL
) ON [PRIMARY]

GO
