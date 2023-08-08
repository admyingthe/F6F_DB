/****** Object:  Table [dbo].[TBL_ADM_CONFIG_PAGE_INPUT_DTL]    Script Date: 08-Aug-23 8:39:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_CONFIG_PAGE_INPUT_DTL](
	[page_dtl_id] [int] IDENTITY(1,1) NOT NULL,
	[page_hdr_id] [int] NULL,
	[input_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[input_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[input_type_id] [int] NULL,
	[input_type_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[style_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[onclick_function] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[onkeyup] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[onchange] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[accessright_ind] [int] NULL,
	[delete_flag] [int] NULL,
	[default_display_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mass_upload_ind] [int] NULL
) ON [PRIMARY]

GO
