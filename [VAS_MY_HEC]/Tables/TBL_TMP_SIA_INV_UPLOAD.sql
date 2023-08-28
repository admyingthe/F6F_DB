SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TMP_SIA_INV_UPLOAD](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_order] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ref_doc_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[arrival_date] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[arrival_time] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[quantity] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[expiry_date] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[creator_user_id] [int] NULL,
	[created_date] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[changed_user_id] [int] NULL,
	[changed_date] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
