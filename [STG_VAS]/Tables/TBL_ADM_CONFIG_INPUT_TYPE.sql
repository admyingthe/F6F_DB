/****** Object:  Table [dbo].[TBL_ADM_CONFIG_INPUT_TYPE]    Script Date: 08-Aug-23 8:39:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_CONFIG_INPUT_TYPE](
	[input_type_id] [int] IDENTITY(1,1) NOT NULL,
	[input_type_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[input_type_syntax] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
