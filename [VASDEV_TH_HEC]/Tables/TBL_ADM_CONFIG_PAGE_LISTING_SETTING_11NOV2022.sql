SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_CONFIG_PAGE_LISTING_SETTING_11NOV2022](
	[country_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[principal_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[page_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[list_dtl_id] [int] NOT NULL,
	[list_col_seq] [int] NULL,
	[list_col_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[list_col_display_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[editable] [int] NULL,
	[editable_data_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hidden] [int] NULL
) ON [PRIMARY]

GO
