SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure SPP_YING_TEST
	@input NVARCHAR(MAX),
	@resultSet1 NVARCHAR(MAX) OUT,
    @resultSet2 NVARCHAR(MAX) OUT
as
begin
	SELECT 
	@resultSet1 = (SELECT * FROM (select 'asdf' as asdf) T1 FOR JSON AUTO),
	@resultSet2 = (SELECT * FROM (select 'qwer' as qwer, 'zxcv' as zxcv, @input as input) T2 FOR JSON AUTO)
end
GO
