SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TMP_SIA_INV_UPLOAD_VALIDATED](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[type] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_order] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ref_doc_no] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[arrival_date] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[arrival_time] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_no] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_no] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[quantity] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[client_code] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[expiry_date] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_valid_type] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__000AF8CF]  DEFAULT ('Invalid type.'),
	[is_valid_ref_doc_no] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__00FF1D08]  DEFAULT ('Invalid ref doc no.'),
	[is_valid_arrival_date] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__01F34141]  DEFAULT ('Invalid arrival date.'),
	[is_valid_arrival_time] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__02E7657A]  DEFAULT ('Invalid arrival date.'),
	[is_valid_prd_code] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__03DB89B3]  DEFAULT ('Invalid product code.'),
	[is_valid_batch_no] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__04CFADEC]  DEFAULT ('Invalid batch no.'),
	[is_valid_quantity] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__05C3D225]  DEFAULT ('Invalid quantity'),
	[is_valid_plant] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__06B7F65E]  DEFAULT ('Invalid plant'),
	[is_valid_client_code] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__07AC1A97]  DEFAULT ('Invalid client code'),
	[is_valid_uom] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__08A03ED0]  DEFAULT ('Invalid uom'),
	[is_valid_expiry_date] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__is_va__09946309]  DEFAULT ('Invalid expiry date'),
	[is_duplicate] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_msg] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TBL_TMP_S__error__0A888742]  DEFAULT (''),
	[creator_user_id] [int] NULL,
	[created_date] [datetime] NULL,
	[changed_user_id] [int] NULL,
	[changed_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
