/****** Object:  Table [dbo].[TBL_ERROR_LOG]    Script Date: 08-Aug-23 8:46:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ERROR_LOG](
	[connection_string] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[method_name] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_info] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[login_id] [int] NULL,
	[created_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
