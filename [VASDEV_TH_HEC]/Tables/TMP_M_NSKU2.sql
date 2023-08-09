SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMP_M_NSKU2](
	[PrdCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrdName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AmCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Division] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BaseUOM] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UWT] [float] NULL,
	[UWTMeasure] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Car_Unit_Wt] [float] NULL,
	[CreationDate] [datetime] NULL,
	[FoodCat] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MDel] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VOL] [float] NULL,
	[VOLMeasure] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Lab] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OldMaterialCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BasicMat] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ABCInd] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MatType] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdPrcGrp] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IndStd] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BarCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GrossWeight] [float] NULL,
	[Taxrate] [int] NULL,
	[Taxcode] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CrtUsrID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PurchaseUOM] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SizeDimension] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Length] [float] NULL,
	[Wdith] [float] NULL,
	[Height] [float] NULL,
	[UnitDimension] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MatCategory] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RemainingShelfLife] [float] NULL,
	[TotalShelfLife] [float] NULL,
	[GrossContents] [float] NULL,
	[IntMatCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DGIndProfile] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdInspMemo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Temp.] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Temp.Description] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
