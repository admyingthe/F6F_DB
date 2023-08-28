SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_SIA_INV](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[vas_order] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ref_doc_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[arrival_date] [date] NOT NULL,
	[arrival_time] [time](7) NOT NULL,
	[to_no] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[batch_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[quantity] [int] NOT NULL,
	[plant] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[uom] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[expiry_date] [datetime] NOT NULL,
	[creator_user_id] [int] NULL,
	[created_date] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[changed_user_id] [int] NULL,
	[changed_date] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
