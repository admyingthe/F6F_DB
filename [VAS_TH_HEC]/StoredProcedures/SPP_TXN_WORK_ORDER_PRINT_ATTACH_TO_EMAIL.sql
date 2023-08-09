SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_PRINT_ATTACH_TO_EMAIL]
	@param nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @job_ref_no VARCHAR(50)
	--SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))

	DECLARE @resultSet1 NVARCHAR(MAX), @resultSet2 NVARCHAR(MAX), @resultSet3 NVARCHAR(MAX);
	--EXEC SPP_TXN_WORK_ORDER_PRINT '{"job_ref_no":"G2022/10/00007"}', @resultSet1 OUT, @resultSet2 OUT, @resultSet3 OUT;
	EXEC SPP_TXN_WORK_ORDER_PRINT @param, @resultSet1 OUT, @resultSet2 OUT, @resultSet3 OUT;

	SELECT * 
	INTO #t1
	FROM OpenJson(@resultSet1)
	WITH (row_num NVARCHAR(MAX) '$.row_num', prd_code NVARCHAR(MAX) '$.prd_code', prd_name NVARCHAR(MAX) '$.prd_name', batch_no NVARCHAR(MAX) '$.batch_no', expiry_date NVARCHAR(MAX) '$.expiry_date', total_quantity NVARCHAR(MAX) '$.total_quantity', base_uom NVARCHAR(MAX) '$.base_uom', arrival_date NVARCHAR(MAX) '$.arrival_date', sub_con_no NVARCHAR(MAX) '$.sub_con_no', ppm_by NVARCHAR(MAX) '$.ppm_by', damaged_qty NVARCHAR(MAX) '$.damaged_qty', completed_qty NVARCHAR(MAX) '$.completed_qty');

	-- second resultset as table
	SELECT *  
	INTO #t2
	FROM OpenJson(@resultSet2)
	WITH (work_ord_format NVARCHAR(MAX) '$.work_ord_format', client_name NVARCHAR(MAX) '$.client_name', station_no NVARCHAR(MAX) '$.station_no', mpo_created_by_and_date NVARCHAR(MAX) '$.mpo_created_by_and_date');

	SELECT * 
	INTO #t3
	FROM OpenJson(@resultSet3)
	WITH (section_b NVARCHAR(MAX) '$.section_b', section_c NVARCHAR(MAX) '$.section_c');

	SELECT * FROM #t1;
	SELECT * FROM #t2;
	SELECT * FROM #t3;
	

	-- combine template and output

	--select #T1.prd_code, #T2.work_ord_format, #T3.section_b, #T3.section_c from #T1, #T2, #T3

	DROP TABLE #T1, #T2, #t3
END
GO
