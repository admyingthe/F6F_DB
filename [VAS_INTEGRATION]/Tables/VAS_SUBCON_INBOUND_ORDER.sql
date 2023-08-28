SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VAS_SUBCON_INBOUND_ORDER](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[country_code] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[outbound_doc] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[inbound_doc] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Subcon_Doc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Subcon_Item_No] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[whs_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[supplier_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[supplier_name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_desc] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qty] [float] NULL,
	[expiry_date] [datetime] NULL,
	[SWI_No] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[created_by] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sloc] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[po_date] [datetime] NULL,
	[subcon_po] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[component] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[component_desc] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lastupdated_date] [datetime] NULL,
	[lastupdated_by] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_date] [datetime] NULL,
	[to_time] [datetime] NULL,
	[delete_flag] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Subcon_Job_No] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[process_ind] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Remarks] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Recounter] [int] NULL,
	[running_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[job_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
