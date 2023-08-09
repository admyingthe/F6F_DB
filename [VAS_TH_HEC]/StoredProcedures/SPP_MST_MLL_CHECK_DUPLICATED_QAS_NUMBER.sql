SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure SPP_MST_MLL_CHECK_DUPLICATED_QAS_NUMBER
	@param nvarchar(max)
AS
BEGIN
	DECLARE @client VARCHAR(50) = (SELECT JSON_VALUE(@param, '$.client'))
	DECLARE @sub VARCHAR(50) = (SELECT JSON_VALUE(@param, '$.sub'))
	DECLARE @type_of_vas VARCHAR(50) = (SELECT JSON_VALUE(@param, '$.type_of_vas'))
	DECLARE @qas_no VARCHAR(50) = (SELECT JSON_VALUE(@param, '$.qas_no'))
	DECLARE @mll_no VARCHAR(50) = (SELECT JSON_VALUE(@param, '$.mll_no'))

	-- check duplicated QAS Number
	IF exists (select 1 from TBL_MST_MLL_HDR where client_code = @client and sub = @sub and type_of_vas = @type_of_vas and mll_desc = @qas_no and @qas_no <> '' and @qas_no is not null and (@mll_no is null or mll_no <> @mll_no))
	BEGIN
		select 1 as error_code, 'Duplicated' as message
	END
	ELSE IF (@qas_no = '' or @qas_no is null) and exists (select 1 from TBL_MST_MLL_HDR where client_code = @client and sub = @sub and type_of_vas = @type_of_vas and mll_status = 'Draft' and (mll_desc = '' or mll_desc is null) and (@mll_no is null or mll_no <> @mll_no))
	BEGIN
		select 2 as error_code, 'Duplicated Empty' as message
	END
	ELSE
	BEGIN
		select 0 as error_code, 'Unique' as message
	END

	-- Check duplicated prd code
	--IF exists (
	--	select 1 from TBL_MST_MLL_HDR H 
	--	left join TBL_MST_MLL_DTL D on H.mll_no = D.mll_no 
	--	where H.client_code = @client and H.sub = @sub and H.type_of_vas = @type_of_vas
	--	and 
	--)
	--BEGIN
		
	--END

END
GO
