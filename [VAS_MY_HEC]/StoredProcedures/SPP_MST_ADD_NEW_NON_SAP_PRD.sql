SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SPP_MST_ADD_NEW_NON_SAP_PRD
	@prd_code VARCHAR(50),
	@prd_desc NVARCHAR(250),
	@princode VARCHAR(50),
	@old_mat_code VARCHAR(50) = NULL,
	@base_uom VARCHAR(50),
	@prd_type VARCHAR(50),
	@tax_code VARCHAR(50) = NULL,
	@tax_rate VARCHAR(50),
	@prdgrp4 VARCHAR(50) = NULL,
	@reg_no VARCHAR(50) = NULL,
	@temp VARCHAR(10) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO TBL_MST_PRODUCT (prd_code, prd_desc, princode, old_mat_code, base_uom, prd_type, tax_code, tax_rate, prdgrp4, reg_no, temp, status, updated_date, type) 
	SELECT @prd_code, @prd_desc, @princode, @old_mat_code, @base_uom, @prd_type, @tax_code, @tax_rate, @prdgrp4, @reg_no, @temp, '', GETDATE(), 'NONSAP'
END

GO
