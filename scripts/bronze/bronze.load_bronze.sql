
/*
========================================================================================
DML Scripts: Bulk Insert data into Bronze tables.
========================================================================================

Script Purpose: This Stored Procedure (SP) loads raw data from the source system into the Bronze table. It utilises a 
Truncate-and-Load pattern to ensure data freshness and prevent duplicates. Encapsulation in an SP guarantees efficient script reuse.

----------------------------------------------------------------------------
*/


CREATE OR ALTER procedure bronze.load_bronze AS

BEGIN
	BEGIN TRY
	---------------------------------------------------------
	PRINT 'Loading bronze layer'
	---------------------------------------------------------

	DECLARE @start_time DATETIME , @end_time DATETIME

	SET @start_time = GETDATE()
	---------------------------------------------------------
	PRINT 'Loading CRM'
	---------------------------------------------------------

	SET @start_time = GETDATE()

		TRUNCATE  TABLE bronze.crm_cust_info
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\iamta\Desktop\SQL_DataWarehouose_Project\datasets\source_crm\cust_info.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);

		TRUNCATE  TABLE bronze.crm_prd_info
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\iamta\Desktop\SQL_DataWarehouose_Project\datasets\source_crm\prd_info.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);

		TRUNCATE  TABLE bronze.crm_sales_details
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\iamta\Desktop\SQL_DataWarehouose_Project\datasets\source_crm\sales_details.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);

		SET @end_time  = GETDATE()
	 PRINT '>> Loading duration >> ' + CAST(DATEDIFF(Second,@start_time,@end_time) AS VARCHAR) + ' ' + 'seconds'
	---------------------------------------------------------
	PRINT 'Loading ERP'
	---------------------------------------------------------
	 SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.erp_CUST_AZ12
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'C:\Users\iamta\Desktop\SQL_DataWarehouose_Project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK);

		TRUNCATE TABLE bronze.erp_LOC_A101
		BULK INSERT bronze.erp_LOC_A101
		FROM 'C:\Users\iamta\Desktop\SQL_DataWarehouose_Project\datasets\source_erp\LOC_A101.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK)

		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2
		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'C:\Users\iamta\Desktop\SQL_DataWarehouose_Project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK)

		SET @end_time = GETDATE()
	PRINT '>> Loading duration >> ' + CAST(DATEDIFF(Second,@start_time,@end_time) AS VARCHAR) + ' ' + 'seconds'

	SET @end_time  =GETDATE()
		PRINT 'CRM Load Done'
	  PRINT '>> Loading duration >> ' + CAST(DATEDIFF(Second,@start_time,@end_time) AS VARCHAR) + ' ' + 'seconds'

	END TRY

	BEGIN CATCH
				PRINT '================================================================='
				PRINT 'ERROR MESSAGE DURING BRONZE LAYER'
				PRINT 'Error message : ' + error_message()
				PRINT 'Error Number : ' + CAST(error_number() AS VARCHAR)
				PRINT '================================================================='
	END CATCH
END

