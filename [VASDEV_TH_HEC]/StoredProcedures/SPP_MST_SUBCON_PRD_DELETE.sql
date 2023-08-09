SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================================
-- Author:		Vijitha
-- Description: Remove product from SUBCON
-- Example Query: exec SPP_MST_SUBCON_PRD_DELETE @delete_obj=N'[{"subcon_no":"WI0001122100004","prd_code":"100016853"}]','Mark for Delete',@user_id=N'1'
-- ===========================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_PRD_DELETE]
	@delete_obj NVARCHAR(MAX),
	@subcon_status VARCHAR(50),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @subcon_no VARCHAR(50), @prd_code VARCHAR(50),@client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50)
	--SET @subcon_no = (SELECT JSON_VALUE(@delete_obj, '$.subcon_no'))
	--SET @prd_code = (SELECT JSON_VALUE(@delete_obj, '$.prd_code'))
	--SET @client_code = (SELECT client_code FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE subcon_no = @subcon_no)
	--SET @type_of_vas = (SELECT type_of_vas FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE subcon_no = @subcon_no)
	--SET @sub = (SELECT sub FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE subcon_no = @subcon_no)

	SELECT ROW_NUMBER ( ) OVER(ORDER BY subcon_no ASC) As id,*
	INTO #SUBCONTMP
	FROM OPENJSON(JSON_QUERY(@delete_obj))
	WITH (
		subcon_no VARCHAR(50) '$.subcon_no',
		prd_code VARCHAR(50) '$.prd_code'
	);

-----------------------------------------------------------------------
--- VALIDATION START HERE
-----------------------------------------------------------------------
CREATE TABLE #ASSIGNMENT_LIST_TEMP                    
(                                                                                     
	Subcon_SWI_No nvarchar(150), 
	status varchar(50) 
)                                    
       
INSERT INTO		#ASSIGNMENT_LIST_TEMP
(
	Subcon_SWI_No, status
)                    
SELECT		subcon_WI_no,
			work_ord_status 
from		TBL_Subcon_TXN_WORK_ORDER 
WHERE		subcon_WI_no in (SELECT subcon_no from #SUBCONTMP)            
GROUP BY	subcon_WI_no, work_ord_status  

CREATE TABLE #FINAL_ASSIGNMENT_LIST_TEMP                    
(                                                                                     
	Subcon_SWI_No nvarchar(150)
)                                    
       
INSERT INTO		#FINAL_ASSIGNMENT_LIST_TEMP
(
	Subcon_SWI_No
) 
select		Subcon_SWI_No
from		#ASSIGNMENT_LIST_TEMP
where		status in ('IP', 'OH')
GROUP BY	Subcon_SWI_No

SELECT	A.*,
		case 
		when B.Subcon_SWI_No is null then 1 
		else 0 end validity_status
into	#VALIDATION_TABLE
FROM	#SUBCONTMP A
		LEFT JOIN
		#FINAL_ASSIGNMENT_LIST_TEMP B
ON		A.subcon_no = B.Subcon_SWI_No 

if @subcon_status = 'Active' or @subcon_status = 'Mark for Delete'
begin
update	#VALIDATION_TABLE
set		validity_status = 1
end

if (select count(*) from #VALIDATION_TABLE where validity_status = 0) > 0
begin
print 'invalid'
end
else 
begin

-----------------------------------------------------------------------
--- VALIDATION END HERE
-----------------------------------------------------------------------

DECLARE @LoopCounter INT = (SELECT count(*) FROM #SUBCONTMP)
WHILE(@LoopCounter > 0)
			BEGIN
			   SELECT @subcon_no = subcon_no			  
			   FROM #SUBCONTMP WHERE Id = @LoopCounter
			   SELECT @prd_code = prd_code
			   FROM #SUBCONTMP WHERE Id = @LoopCounter

	--IF @subcon_status= 'Mark for Deletion'
		BEGIN
			   UPDATE TBL_MST_SUBCON_DTL
				SET subcon_status=@subcon_status
				WHERE subcon_no = @subcon_no 
				and prd_code=@prd_code
				PRINT @subcon_status
				INSERT INTO TBL_ADM_AUDIT_TRAIL
				(module, key_code, action, action_by, action_date)
				SELECT 'SUBCON', @subcon_no, CASE WHEN @subcon_status='Mark for Delete' THEN 'Marked for deletion - ' when @subcon_status='Active' THEN 'Activated - ' ELSE 'Deleted - ' END + @prd_code, @user_id, GETDATE()
				IF (SELECT COUNT(*) FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_no and subcon_status!=@subcon_status) = 0
					BEGIN
						UPDATE TBL_MST_SUBCON_HDR
						SET subcon_status=@subcon_status
						WHERE subcon_no = @subcon_no 
				END
			END
	--ELSE 
	--	BEGIN
	--		DELETE FROM TBL_MST_SUBCON_DTL
	--		WHERE subcon_no = @subcon_no AND prd_code = @prd_code

	--		INSERT INTO TBL_ADM_AUDIT_TRAIL
	--	(module, key_code, action, action_by, action_date)
	--	SELECT 'SUBCON', @subcon_no, 'Deleted item ' + @prd_code, @user_id, GETDATE()

	--	IF (SELECT COUNT(*) FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_no) = 0
	--		BEGIN
	--			DELETE FROM TBL_MST_SUBCON_HDR WHERE subcon_no = @subcon_no
	--		END
		--END
	SET @LoopCounter  = @LoopCounter  - 1 
	END	

END
select * from #VALIDATION_TABLE
DROP TABLE #SUBCONTMP	
-----------------------------------------------------------------------
--- VALIDATION START HERE
-----------------------------------------------------------------------
DROP TABLE #ASSIGNMENT_LIST_TEMP
DROP TABLE #FINAL_ASSIGNMENT_LIST_TEMP
DROP TABLE #VALIDATION_TABLE
-----------------------------------------------------------------------
--- VALIDATION END HERE
-----------------------------------------------------------------------
END

GO
