
CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN

BEGIN TRY

DECLARE @start_time DATETIME , @end_time DATETIME

SET @start_time = GETDATE()

SET @start_time = GETDATE()
PRINT '------------------------------------------------------------------------------'
PRINT 'Load CRM data from Bronze layer to Silver layer'
PRINT '------------------------------------------------------------------------------'
TRUNCATE TABLE silver.crm_cust_info
INSERT INTO Silver.crm_cust_info ([cst_id],[cst_key],[cst_firstname],[cst_lastname],[cst_marital_status],[cst_gndr],[cst_create_date])
SELECT
cst_id,
cst_key,
-- Use of TRIM to remove unwanted space
TRIM(cst_firstname) cst_firstname,
TRIM(cst_lastname) cst_lastname,
CASE WHEN TRIM(cst_marital_status) = 'M' THEN 'Married' 
WHEN TRIM(cst_marital_status) = 'S' THEN 'Single'
ELSE 'n/a'
END cst_marital_status,
CASE WHEN TRIM(cst_gndr) = 'M' THEN 'Male' 
WHEN TRIM(cst_gndr) = 'F' THEN 'Female'
ELSE 'n/a'
END cst_gndr,
cst_create_date
-- In subquery we have removed duplicate using WINDOW fucntion
FROM(
SELECT
*,
ROW_NUMBER() OVER(Partition by cst_id order by cst_create_date DESC) cn
FROM bronze.crm_cust_info
)t
WHERE cn = 1 AND cst_id IS NOT NULL



TRUNCATE TABLE silver.crm_prd_info
INSERT INTO Silver.crm_prd_info(
[prd_id]
      ,[cat_id]
      ,[prd_key]
      ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt])
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') As  cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
prd_nm,
COALESCE(prd_cost,0) prd_cost,
CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
ELSE 'n/a'
END prd_line,
prd_start_dt,
DATEADD(DAY,-1,CAST(LEAD(prd_start_dt) OVER (partition by prd_key order by prd_start_dt) AS DATE)) prd_end_dt
FROM bronze.crm_prd_info



TRUNCATE TABLE silver.crm_sales_details
INSERT INTO silver.crm_sales_details(sls_ord_num
      ,sls_prd_key
      ,sls_cust_id
      ,sls_order_dt
      ,sls_ship_dt
      ,sls_due_dt
      ,sls_sales
      ,sls_quantity
      ,sls_price)
SELECT 
       sls_ord_num
      ,sls_prd_key
      ,sls_cust_id
      ,CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8  THEN NULL
       ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS date)
       END sls_order_dt
      ,CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8  THEN NULL
       ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS date)
       END sls_ship_dt
      ,CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8  THEN NULL
       ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS date)
       END sls_due_dt
      ,CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> sls_quantity * ABS(sls_price) 
      THEN sls_quantity * ABS(sls_price)
      ELSE sls_sales
      END sls_sales
      ,sls_quantity
      ,CASE WHEN sls_price IS NULL OR sls_price <= 0
      THEN sls_sales/NULLIF(sls_quantity,0)
      ELSE sls_price
      END sls_price
  FROM bronze.crm_sales_details
  SET @end_time = GETDATE()

  PRINT '>> Load duration >> ' + CAST(DATEDIFF(second,@start_time,@end_time) AS VARCHAR) + ' ' + 'seconds'

  SET @start_time = GETDATE()
PRINT '------------------------------------------------------------------------------'
PRINT 'Load CRM data from Bronze layer to Silver layer'
PRINT '------------------------------------------------------------------------------'

TRUNCATE TABLE silver.erp_loc_a101
INSERT INTO Silver.erp_loc_a101(cid,cntry)
SELECT
REPLACE(cid,'-','') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
WHEN TRIM(cntry) IN ('USA','US') THEN 'United States'
WHEN TRIM(cntry) = '' OR CNTRY IS NULL THEN 'n/a'
ELSE TRIM(cntry)
END CNTRY
FROM bronze.erp_LOC_A101


TRUNCATE TABLE silver.erp_px_cat_g1v2
INSERT INTO Silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
SELECT
id,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_PX_CAT_G1V2

SET @end_time = GETDATE()

PRINT '>> Load duration >> ' + CAST(DATEDIFF(second,@start_time,@end_time) AS VARCHAR) + ' ' + 'seconds'

PRINT '==================================================================================='

SET @end_time = GETDATE()

PRINT '>> Load duration of Silver layer >> ' + CAST(DATEDIFF(second,@start_time,@end_time) AS VARCHAR) + ' ' + 'seconds'


END TRY

BEGIN CATCH

PRINT 'Error found in Silver Layer '
PRINT 'Error Message : ' + error_message()
PRINT 'Error Nubmer : ' +  CAST(error_number() AS VARCHAR)

END CATCH
END
