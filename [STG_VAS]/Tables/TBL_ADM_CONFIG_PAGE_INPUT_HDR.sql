/****** Object:  Table [dbo].[TBL_ADM_CONFIG_PAGE_INPUT_HDR]    Script Date: 08-Aug-23 8:39:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_CONFIG_PAGE_INPUT_HDR](
	[page_hdr_id] [int] IDENTITY(1,1) NOT NULL,
	[page_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[page_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[section_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[section_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[submodule_id] [int] NULL
) ON [PRIMARY]

GO
