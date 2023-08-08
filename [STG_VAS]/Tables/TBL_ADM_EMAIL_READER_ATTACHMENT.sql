/****** Object:  Table [dbo].[TBL_ADM_EMAIL_READER_ATTACHMENT]    Script Date: 08-Aug-23 8:25:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_EMAIL_READER_ATTACHMENT](
	[mail_id] [int] NULL,
	[file_name] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_size] [int] NULL,
	[file_extension] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[attachment] [varbinary](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
