/****** Object:  Table [dbo].[TBL_ADM_EMAIL_READER]    Script Date: 08-Aug-23 8:25:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_EMAIL_READER](
	[mail_id] [int] NULL,
	[email_addr] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[received_date] [datetime] NULL,
	[timezone] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mail_subject] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mail_content] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[comment] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[processing_status] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[processing_remarks] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[processing_date] [datetime] NULL,
	[db_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
