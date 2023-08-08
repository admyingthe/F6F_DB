/****** Object:  Table [dbo].[TBL_ADM_CONFIG_PAGE_LISTING_DTL]    Script Date: 08-Aug-23 8:39:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_CONFIG_PAGE_LISTING_DTL](
	[list_dtl_id] [int] IDENTITY(1,1) NOT NULL,
	[list_hdr_id] [int] NULL,
	[list_col_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[delete_flag] [int] NULL,
	[list_default_display_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[list_col_function] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
