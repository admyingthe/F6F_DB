SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[nsku2](
	[PrdCode           ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName                                           ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AmCode    ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Division                     ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BaseUOM   ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UWT         ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UWTMeasure] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Car_Unit_Wt] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreationDate] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FoodCat   ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MDel      ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VOL          ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VOLMeasure] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Lab        OldMaterialCode    BasicMat        ABCind                               ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Column 14] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[                      MatType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdPrcGrp            ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Column 17] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IndStd            ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Column 19] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BarCode             ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GrossWeight         ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Taxrate             ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Taxcode             ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CrtUsrID    ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PurchaseUOM ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SizeDimension] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Length       ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Width        ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Height       ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UnitDimension] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MatCategory ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RemainingShelfLife] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TotalShelfLife ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GrossContents] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IntMatCode        ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DGIndProfile] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdInspMemo       ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Temp ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Temp  Description] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
