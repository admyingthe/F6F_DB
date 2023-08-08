/****** Object:  Table [dbo].[TBL_ADM_CONFIG_PAGE_INPUT_SETTING]    Script Date: 08-Aug-23 8:46:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_CONFIG_PAGE_INPUT_SETTING](
	[country_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[principal_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[page_code] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[page_dtl_id] [int] NOT NULL,
	[display_name] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mandatory] [int] NULL,
	[readonly] [int] NULL,
	[seq] [int] NULL,
	[input_source] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[additional_input] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[additional_input_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[validation_message] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
