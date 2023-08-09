SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_JOB_VENDOR](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[job_ref_no] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vendor_id] [int] NULL,
	[vas_activity_id] [int] NOT NULL,
	[issued_qty] [decimal](18, 2) NULL,
	[normal_qty] [decimal](18, 2) NULL,
	[ot_qty] [decimal](18, 2) NULL,
	[VAS_Activity_Rate_HDR_ID] [int] NULL,
	[activity_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[changed_date] [datetime] NULL
) ON [PRIMARY]

GO
