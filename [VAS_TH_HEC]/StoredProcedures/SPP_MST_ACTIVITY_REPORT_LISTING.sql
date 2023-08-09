SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ying
-- Create date: 2023-03-07
-- Description:	Retrieve Activity Report Listing
-- Example Query: exec [SPP_MST_ACTIVITY_REPORT_LISTING] '{"start_date":"2023-05-02","end_date":"2023-05-09","client_code":"0351","product_code":"","page_index":0,"page_size":20,"search_term":"","export_ind":1}'
-- with result: 210070739; without result: 100941178
-- =============================================

CREATE PROCEDURE [dbo].[SPP_MST_ACTIVITY_REPORT_LISTING]
	@param nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	--declare @param nvarchar(max) = '{"start_date":"1900-01-01","end_date":"2023-03-07","client_code":"0093","product_code":"210070739","page_index":0,"page_size":20,"search_term":"","export_ind":0}'
	declare @start_date varchar(20) = (SELECT JSON_VALUE(@param, '$.start_date'))
	declare @end_date varchar(20) = (SELECT JSON_VALUE(@param, '$.end_date'))
	declare @client_code varchar(20) = (SELECT JSON_VALUE(@param, '$.client_code'))
	declare @product_code varchar(20) = (SELECT JSON_VALUE(@param, '$.product_code'))
	declare @page_index int = (SELECT JSON_VALUE(@param, '$.page_index'))
	declare @page_size int = (SELECT JSON_VALUE(@param, '$.page_size'))
	declare @search_term nvarchar(max) = (SELECT JSON_VALUE(@param, '$.search_term'))
	declare @export_ind char(1) = (SELECT JSON_VALUE(@param, '$.export_ind'))

	if (@export_ind = 1)
	begin
		set @page_index = 0
		set @page_size = 99999
	end

	select D.job_ref_no, D.prd_code, completed_qty into #TempPrdQty from TBL_TXN_JOB_EVENT_DET D 
	left join tbl_mst_product P on D.prd_code = P.prd_code
	right join (select job_ref_no, prd_code, max(running_no) as max_running_no from TBL_TXN_JOB_EVENT_DET where (@product_code = '' or prd_code = @product_code) group by job_ref_no, prd_code) T3 
	on D.job_ref_no = T3.job_ref_no AND D.prd_code = T3.prd_code AND D.running_no = T3.max_running_no 
	where (@product_code = '' or D.prd_code = @product_code) AND (@client_code = '' or @client_code = 'All' or P.princode = @client_code) 
	
	select IDENTITY(int,1,1) tempRowID, W.mll_no, --JV.vas_activity_id,
	CONVERT(VARCHAR(10), W.created_date, 121) as job_creation_date, W.job_ref_no as job_no, W.prd_code as product_code, P.prd_desc as product_name, W.batch_no as batch, D.completed_qty as quantity, W.uom as uom, C.client_name as client_name, P.prdgrp4 as prd_grp4, G.PrdGrpDesc4 as prd_grp4_desc, case when (N.urgent = 1) then 'Yes' else 'No' end as urgent
	--, L.description as vas_activity, JV.normal_qty, R.normal_rate, JV.ot_qty, R.ot_rate
	into #TempActivityReportListing1
	from TBL_TXN_WORK_ORDER W 
	left join #TempPrdQty D on W.job_ref_no = D.job_ref_no and W.prd_code = D.prd_code 
	left join TBL_MST_PRODUCT P on W.prd_code = P.prd_code
	left join TBL_MST_MATGRP G on P.prdgrp4 = G.PrdGrp4
	left join TBL_MST_CLIENT C on W.client_code = C.client_code
	left join TBL_MST_MLL_DTL M on W.mll_no = M.mll_no and W.prd_code = M.prd_code
	--left join TBL_ADM_JOB_VENDOR JV on W.job_ref_no = JV.job_ref_no
	--left join TBL_MST_VENDOR_LISTING VL on JV.vendor_id = VL.id
	--left join TBL_MST_VAS_ACTIVITY_RATE_DTL R on JV.VAS_ACTIVITY_RATE_HDR_ID = R.VAS_ACTIVITY_RATE_HDR_ID and JV.VAS_ACTIVITY_ID = R.VAS_ACTIVITY_ID
	--left join TBL_MST_ACTIVITY_LISTING L on JV.VAS_ACTIVITY_ID = L.ID
	left join TBL_TXN_WORK_ORDER_JOB_DET N on W.job_ref_no = N.job_ref_no
	where (@client_code = '' or @client_code = 'All' or W.client_code = @client_code) 
	and (@product_code = '' or W.prd_code = @product_code) 
	and CONVERT(VARCHAR(10), W.created_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121) 
	--AND (
	--	W.job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE W.job_ref_no END OR
	--	W.prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE W.prd_code END OR
	--	P.prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE P.prd_desc END OR
	--	W.batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE W.batch_no END OR
	--	W.uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE W.uom END OR
	--	C.client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE C.client_name END OR
	--	L.description LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE L.description END
	--)
	
	
	--alter table #TempActivityReportListing1 add vas_activity varchar(max), normal_qty int, normal_rate decimal, ot_qty int, ot_rate decimal

	create table #TempActivityReportListing2 (
		job_creation_date varchar(20), job_no varchar(50), product_code varchar(50), product_name nvarchar(max), vendor_name nvarchar(max), batch varchar(50), quantity decimal(18,2), uom varchar(10), client_name varchar(50), prd_grp4 varchar(50), prd_grp4_desc nvarchar(max), urgent varchar(10), vas_activity varchar(max), normal_qty decimal(18,2), normal_rate decimal(18,2), ot_qty decimal(18,2), ot_rate decimal(18,2)
	)

	declare @tempRowID_s int, @job_creation_date_s varchar(20), @job_no_s varchar(50), @product_code_s varchar(50), @product_name_s nvarchar(max), @vendor_name_s nvarchar(max), @batch_s varchar(50), @quantity_s decimal(18,2), @uom_s varchar(10), @client_name_s varchar(50), @prd_grp4_s varchar(50), @prd_grp4_desc_s nvarchar(max), @urgent_s varchar(10),
			@temp_vas_id int, @row int = 1, @max_row int = (select max(tempRowID) from #TempActivityReportListing1),
			@VAS_Activity_Rate_HDR_ID_s int, @vas_activity_s varchar(max), @normal_qty_s decimal(18,2), @normal_rate_s decimal(18,2), @ot_qty_s decimal(18,2), @ot_rate_s decimal(18,2)

	while (@row <= @max_row)
	begin
		select @tempRowID_s = tempRowID, @job_creation_date_s = job_creation_date, @job_no_s = job_no, @product_code_s = product_code, @product_name_s = product_name, @batch_s = batch, @quantity_s = quantity, @uom_s = uom, @client_name_s = client_name, @prd_grp4_s = prd_grp4, @prd_grp4_desc_s = prd_grp4_desc, @urgent_s = urgent 
		from #TempActivityReportListing1 where tempRowID = @row

		select * into #TEMP_ACTIVITY_LISTING from TBL_MST_ACTIVITY_LISTING

		while exists (select 1 from #TEMP_ACTIVITY_LISTING)
		begin
			set @temp_vas_id  = (select top 1 ID from #TEMP_ACTIVITY_LISTING)

			if exists (select 1 from TBL_ADM_JOB_VENDOR where job_ref_no = @job_no_s and prd_code = @product_code_s and vas_activity_id = @temp_vas_id)
			begin
				select @normal_qty_s = V.normal_qty, @ot_qty_s = V.ot_qty, @VAS_Activity_Rate_HDR_ID_s = V.VAS_Activity_Rate_HDR_ID, @vendor_name_s = L.vendor_code from TBL_ADM_JOB_VENDOR V left join TBL_MST_VENDOR_LISTING L on V.vendor_id = L.id where V.job_ref_no = @job_no_s and V.prd_code = @product_code_s and V.vas_activity_id = @temp_vas_id
				select @normal_rate_s = Normal_Rate, @ot_rate_s = OT_Rate from TBL_MST_VAS_ACTIVITY_RATE_DTL where VAS_Activity_ID = @temp_vas_id and VAS_Activity_Rate_HDR_ID = @VAS_Activity_Rate_HDR_ID_s
				select @vas_activity_s = description from TBL_MST_ACTIVITY_LISTING where id = @temp_vas_id

				-- for additional VAS activities, the quantity should follow the inserted billing qty instead of the prd qty
				select @quantity_s = issued_qty, @normal_qty_s = normal_qty, @ot_qty_s = ot_qty from TBL_ADM_JOB_VENDOR where job_ref_no = @job_no_s and prd_code = @product_code_s and vas_activity_id = @temp_vas_id and activity_type in ('Additional', 'Additional Standard')

				insert into #TempActivityReportListing2 (job_creation_date, job_no, product_code, product_name, vendor_name, batch, quantity, uom, client_name, prd_grp4, prd_grp4_desc, urgent, vas_activity, normal_qty, normal_rate, ot_qty, ot_rate)
				values (@job_creation_date_s, @job_no_s, @product_code_s, @product_name_s, @vendor_name_s, @batch_s, @quantity_s, @uom_s, @client_name_s, @prd_grp4_s, @prd_grp4_desc_s, @urgent_s,  @vas_activity_s, @normal_qty_s, @normal_rate_s, @ot_qty_s, @ot_rate_s)
			end
			-- remove the zeros vas activities
			--else 
			--begin
			--	select @normal_rate_s = Normal_Rate, @ot_rate_s = OT_Rate from TBL_MST_VAS_ACTIVITY_RATE_DTL where VAS_Activity_ID = @temp_vas_id and VAS_Activity_Rate_HDR_ID = @VAS_Activity_Rate_HDR_ID_s
			--	select @vas_activity_s = description from TBL_MST_ACTIVITY_LISTING where id = @temp_vas_id
			--	insert into #TempActivityReportListing2 (job_creation_date, job_no, product_code, product_name, vendor_name, batch, quantity, uom, client_name, vas_activity, normal_qty, normal_rate, ot_qty, ot_rate)
			--	values (@job_creation_date_s, @job_no_s, @product_code_s, @product_name_s, '', @batch_s, @quantity_s, @uom_s, @client_name_s, @vas_activity_s, 0, @normal_rate_s, 0, @ot_rate_s)
			--end

			delete from #TEMP_ACTIVITY_LISTING where ID = @temp_vas_id
		end

		drop table #TEMP_ACTIVITY_LISTING
		set @row = @row + 1
	end

	--while (@row <= @max_row)
	--begin
	--	select @tempRowID_s = tempRowID, @job_creation_date_s = job_creation_date, @job_no_s = job_no, @product_code_s = product_code, @product_name_s = product_name, @batch_s = batch, @quantity_s = quantity, @uom_s = uom, @client_name_s = client_name 
	--	from #TempActivityReportListing1

	--	select top 1 @temp_vas_id = id from #TEMP_ACTIVITY_LISTING order by id
	--	select vas_activity_id from TBL_ADM_JOB_VENDOR where job_ref_no = @job_no_s and prd_code = @product_code_s

	--	case when 

	--	if not exists (select 1 from #TempActivityReportListing1 where vas_activity_id <> @temp_vas_id)
	--	begin
	--		insert into #TempActivityReportListing1
	--		select T1.*, 
	--		into #TempActivityReportListing2 
	--		from #TempActivityReportListing1 T1 
	--		full join TBL_MST_ACTIVITY_LISTING 
	--		where
	--	end
	--	delete from #TEMP_ACTIVITY_LISTING where id = @temp_vas_id
	--end

	--1--
	SELECT COUNT(1) as ttl_rows FROM #TempActivityReportListing2
	where (
		job_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_no END OR
		product_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE product_code END OR
		product_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE product_name END OR
		vendor_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vendor_name END OR
		batch LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch END OR
		uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR
		client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
		prd_grp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_grp4 END OR
		prd_grp4_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_grp4_desc END OR
		vas_activity LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_activity END
	)
	
	--2--
	if (@export_ind = 1)
	begin
		-- thousand separator
		--SELECT FORMAT(12345.00,'#,0.00')
		select urgent, job_creation_date, job_no, product_code, product_name, vendor_name, batch, FORMAT(quantity,'#,0') as quantity, uom, client_name, prd_grp4, prd_grp4_desc, vas_activity, FORMAT(normal_qty, '#,0') as normal_qty, FORMAT(normal_rate, '#,0') as normal_rate, FORMAT(ot_qty, '#,0') as ot_qty, FORMAT(ot_rate, '#,0') as ot_rate
		from #TempActivityReportListing2
		where (
			job_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_no END OR
			product_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE product_code END OR
			product_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE product_name END OR
			vendor_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vendor_name END OR
			batch LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch END OR
			uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR
			client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
			prd_grp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_grp4 END OR
			prd_grp4_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_grp4_desc END OR
			vas_activity LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_activity END
		)
	end
	else 
	begin
		select * from #TempActivityReportListing2
		where (
			job_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_no END OR
			product_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE product_code END OR
			product_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE product_name END OR
			vendor_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vendor_name END OR
			batch LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch END OR
			uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR
			client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
			prd_grp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_grp4 END OR
			prd_grp4_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_grp4_desc END OR
			vas_activity LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_activity END
		)
		order by job_creation_date desc
		OFFSET (@page_index * @page_size) ROWS FETCH NEXT (@page_size) ROWS ONLY
	end

	--3--
	SELECT @export_ind AS export_ind
	
	drop table #TempActivityReportListing1
	drop table #TempActivityReportListing2
	drop table #TempPrdQty
	
END
GO
