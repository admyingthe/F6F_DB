SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPP_GET_COMPLETED_QTY_VAS]
	@job_ref_no NVARCHAR(20),
	@prd_code NVARCHAR(20),
	@mll_no NVARCHAR(20)
AS
BEGIN
		CREATE TABLE #VAS_ACTIVITIES
			(
				id INT IDENTITY(1, 1),
				activity NVARCHAR(MAX)
			)

		INSERT INTO #VAS_ACTIVITIES(activity)
		SELECT A.vas_activities
		FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
		INNER JOIN TBL_TXN_WORK_ORDER B ON A.mll_no = B.mll_no AND B.mll_no = A.mll_no
		WHERE B.job_ref_no = @job_ref_no 
		AND A.mll_no = @mll_no
		AND A.prd_code = @prd_code
		GROUP BY A.vas_activities

		DECLARE @count INT = (SELECT COUNT(*) FROM #VAS_ACTIVITIES WITH(NOLOCK))
		DECLARE @i INT = 0
		DECLARE @json_activities NVARCHAR(MAX) = ''

		CREATE TABLE #DETAIL_ACTIVITIES
		(
			display_name NVARCHAR(250),
			prd_code VARCHAR(50),
			page_dtl_id INT,
			radio_val CHAR(1)
		)

		WHILE (@i <= @count)
		BEGIN
			SET @json_activities = (SELECT activity FROM #VAS_ACTIVITIES WHERE id = @i)

			--PRINT @json_activities-

			INSERT INTO #DETAIL_ACTIVITIES(prd_code, page_dtl_id, radio_val)
			SELECT * FROM OPENJSON ( @json_activities ) 
			WITH (
				prd_code	VARCHAR(50)	'$.prd_code',  
				page_dtl_id	INT			'$.page_dtl_id',  
				radio_val	CHAR(1)		'$.radio_val'
			)
			WHERE radio_val = 'Y'
			SET @i += 1
		END

		UPDATE A
		SET display_name = B.display_name
		FROM #DETAIL_ACTIVITIES A WITH(NOLOCK), VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK)
		WHERE A.page_dtl_id = B.page_dtl_id AND B.country_code='TH'

		SELECT display_name,cs.value AS prd_code, page_dtl_id, CONVERT(int,0) total_issued_qty
		INTO #FINAL_VAS_ACTIVITY
		FROM #DETAIL_ACTIVITIES
		WITH(NOLOCK)
		CROSS APPLY STRING_SPLIT (prd_code, ',') cs
		GROUP BY display_name, cs.value, page_dtl_id

		--get issue qty from submitted SAP
		UPDATE A
		SET A.total_issued_qty = B.completed_qty
		FROM #FINAL_VAS_ACTIVITY A
		INNER JOIN [TBL_TXN_JOB_EVENT] B ON B.job_ref_no = @job_ref_no
		where running_no in (select top 1 running_no from [TBL_TXN_JOB_EVENT] where event_id IN ('80') and job_ref_no = @job_ref_no order by running_no desc)
		
		DECLARE @ttl_qty_eaches int = 0, @prd_count int = 1

		SELECT top 1 @ttl_qty_eaches = completed_qty FROM TBL_TXN_JOB_EVENT where job_ref_no = @job_ref_no order by running_no desc

		SELECT @prd_count = COUNT(distinct prd_code) FROM TBL_TXN_PPM where job_ref_no = @job_ref_no
		
		--add sum of ppm issued qty
		SELECT (@ttl_qty_eaches - ((B.required_qty - B.issued_qty)/@prd_count)) as issued_qty, B.prd_code
		INTO #PPM_QTY
		FROM #FINAL_VAS_ACTIVITY A
		INNER JOIN TBL_TXN_PPM B ON A.prd_code = B.prd_code AND B.job_ref_no = @job_ref_no
		--GROUP BY b.job_ref_no, b.prd_code

		--add sum of ppm issued qty
		--SELECT sum(B.issued_qty) as issued_qty, B.prd_code
		--INTO #PPM_QTY
		--FROM #FINAL_VAS_ACTIVITY A
		--INNER JOIN TBL_TXN_PPM B ON A.prd_code = B.prd_code AND B.job_ref_no = @job_ref_no
		--GROUP BY b.job_ref_no, b.prd_code 
		
		--total sum of ppm and issue qty
		update A
		set total_issued_qty = issued_qty
		FROM #FINAL_VAS_ACTIVITY A 
		INNER JOIN #PPM_QTY B ON A.prd_code = B.prd_code
		
		DROP TABLE #PPM_QTY

		SELECT sum(total_issued_qty) as total_issued_qty, display_name		
		FROM #FINAL_VAS_ACTIVITY
		GROUP BY display_name

		DROP TABLE #VAS_ACTIVITIES
		DROP TABLE #DETAIL_ACTIVITIES
		DROP TABLE #FINAL_VAS_ACTIVITY
END

GO
