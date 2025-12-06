
/*=========================================================================================*/
-- Create Database and Schemas
/*=========================================================================================*/

-- Use master
USE master
-- Set the database to SINGLE_USER mode to kick off other connections
-- NOTE: Only use this if you are absolutely sure you want to drop the database.

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'datawarehouse')
BEGIN
 ALTER DATABASE datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
 DROP DATABASE datawarehouse;
 END
 GO
-- THEN CREATE DATABASE
CREATE DATABASE datawarehouse
GO

USE datawarehouse
GO

-- Create SCHEMA

CREATE SCHEMA bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
