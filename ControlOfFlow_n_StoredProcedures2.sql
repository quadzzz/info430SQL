/* CONTROL OF FLOW, STORED PROCEDURES, ERROR-HANDLING AND MODULARITY */

use SampleSuperStore_db
GO
SELECT TOP 10 * FROM tblORDER
SELECT TOP 10 * FROM tblORDER_PRODUCT
/*


/* CONTROL OF FLOW */
--====================================
--Using CASE Statements
-- Q1) Write the SQL to label and count the number of customers that meet the following conditions:
--	a) Purchased fewer than 20 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Blue'
--	b) Purchased between 20 and 30 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Green'
--	c) Purchased between 31 and 45 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Orange'
--	d) Purchased between 46 and 60 units of 'automotive' products lifetime AND spent BETWEEN $801 and $3000 lifetime of product type 'kitchen', label them 'Purple'
--	e) Else 'Unknown'
-- HINT: this is best written with a CASE statement drawing from 2 subqueries(!!)
-- that each have an aggregated alias like 'AutoUnits' and 'TotalBucksKitchen'
*/
SELECT (CASE
	WHEN NumUnits < 20 AND sales <800
	THEN 'Blue'
	WHEN  NumUnits BETWEEN 20 AND 30 AND sales <800
	THEN 'Green'
	WHEN NumUnits BETWEEN 31 AND 45 AND sales <800
	THEN 'Orange'
	WHEN NumUnits BETWEEN 46 AND 60 AND sales BETWEEN 801 AND 3000
	THEN 'Purple'
	ELSE 'Unknown'
	END) AS CustomerType, COUNT(*) AS NumCustomers
FROM
(SELECT c.CustomerID, SUM(op.Quantity) AS NumUnits
FROM tblCUSTOMER c
JOIN tblORDER o ON c.CustomerID = o.CustomerID
JOIN tblORDER_PRODUCT op ON o.OrderID = op.OrderID
JOIN tblPRODUCT p ON op.ProductID = p.ProductID
JOIN tblPRODUCT_TYPE pt ON p.ProdTypeID = pt.ProdTypeID
WHERE pt.ProdTypeName = 'Automotive'
GROUP BY c.CustomerID) TU
JOIN
(SELECT c.CustomerID, SUM(op.Calc_LineTotal) AS sales
FROM tblCUSTOMER c
JOIN tblORDER o ON c.CustomerID = o.CustomerID
JOIN tblORDER_PRODUCT op ON o.OrderID = op.OrderID
JOIN tblPRODUCT p ON op.ProductID = p.ProductID
JOIN tblPRODUCT_TYPE pt ON p.ProdTypeID = pt.ProdTypeID
WHERE pt.ProdTypeName = 'Kitchen'
GROUP BY c.CustomerID
HAVING SUM(op.Calc_LineTotal) < 800) TS
ON TU.CustomerID = TS.CustomerID
GROUP BY
(CASE
	WHEN NumUnits < 20 AND sales <800
	THEN 'Blue'
	WHEN  NumUnits BETWEEN 20 AND 30 AND sales <800
	THEN 'Green'
	WHEN NumUnits BETWEEN 31 AND 45 AND sales <800
	THEN 'Orange'
	WHEN NumUnits BETWEEN 46 AND 60 AND sales BETWEEN 801 AND 3000
	THEN 'Purple'
	ELSE 'Unknown'
	END)
ORDER BY CustomerType

/*Stored Procedure FOR INSERT with Explict Transaction and Error Handling */
-- Q2) Write the SQL to create a stored procedure to INSERT a new row 
-- into tblPRODUCT under the following conditions:
-- a) pass in parameters of @ProdName, @ProdTypeName, and @Price
-- b) DECLARE a variable to look-up the associated ProdTypeID for 
-- @ProdTypeName parameter (no error-handling required)
-- c) make the INSERT statement inside an explicit transaction

SELECT TOP 5 * FROM tblPRODUCT
SELECT TOP 5 * FROM tblPRODUCT_TYPE
GO
-------------------------------
CREATE OR ALTER PROCEDURE uspInsertProduct
(@ProdID int, 
@ProdName varchar(60), 
@ProdTypeName varchar(60),
@ProdDesc varchar(100), 
@Price numeric(5,2)
)

AS
BEGIN -- same as { in some programming languages
--Look up prodct type ID and store in the @ProdTypeID  variable
DECLARE @ProdTypeID int
SET @ProdTypeID = (SELECT ProdTypeID FROM tblPRODUCT_TYPE
					WHERE ProdTypeName = @ProdTypeName)

--BEGIN TRANSACTION
	BEGIN TRAN T

	--Error handling
		IF @ProdTypeID IS NULL
			BEGIN
				PRINT '@ProdTypeID is NULL and will fail during the INSERT transaction. Check spelling of all parameters';
				THROW 50061, '@ProdTypeID cannot be NULL; statement is terminating', 1;
				ROLLBACK;
			END

		ELSE
			BEGIN
				INSERT INTO tblPRODUCT(ProductID,ProductName, ProdTypeID, ProductDescr, Price)
							VALUES(@ProdID, @ProdName, @ProdTypeID, @ProdDesc, @Price)
				COMMIT TRAN T
				Print ('A new row of data has been inserted into tblPRODUCT successfully.');
			END
END -- same as } in some prog languanges. Denotes end of procedure
GO
SELECT TOP 1 * FROM tblPRODUCT
ORDER BY ProductID DESC

-- Test the procedure (after compiling it)
--1) Guaranteed to fail -- ProdTypeID doesn't exist
EXEC uspInsertProduct 1519,'Serving Dish', 'Kilowatts', 'Present your food in style', 75 
GO

--2) Guaranteed to succeed (ProdTypeID exists)
--ProductName: 20-lb Bag of Top Soil; Original price=30
EXEC uspInsertProduct 1519,'Serving Dish', 'Kitchen', 'Present your food in style', 75 
GO

---Verify that it worked
SELECT TOP 10 * FROM tblPRODUCT
ORDER BY ProductID DESC


SELECT TOP 5 * FROM tblPRODUCT_TYPE

/*Stored Procedure FOR UPDATE with Explict Transaction and Error Handling */
/*-- Q3) Write the SQL to create a stored procedure to UPDATE the price of 
a single product in SampleSuperStore database with the following conditions:
-- a) be sure to affect only a single row (hint: populate a variable and 
     set that to the PK of tblPRODUCT)
-- b) make the UPDATE statement inside an explicit transaction
-- c) pass in parameters of @ProdName and @NewPrice
*/
SELECT TOP 5 * FROM tblPRODUCT
GO
-------------------------------------------
CREATE OR ALTER PROCEDURE uspUpdateProductPrice
@ProdName varchar(60), @NewPrice numeric(5,2)

AS
BEGIN
--Look up product using product name
DECLARE @ProdID int
SET @ProdID = (SELECT ProductID FROM tblPRODUCT WHERE ProductName = @ProdName)
--look up old price
DEClARE @oldPrice numeric(5,2)
SET @oldPrice = (SELECT Price FROM tblPRODUCT WHERE ProductName = @ProdName)
	
	BEGIN TRAN T1

	--Error handling
		IF @ProdID IS NULL
			BEGIN
				PRINT '@Product ID is NULL and will fail during the UPDATE transaction. Check spelling of all parameters';
				THROW 50062, '@Product ID cannot be NULL; statement is terminating', 1;
				ROLLBACK;
			END

		ELSE
			BEGIN
				UPDATE tblPRODUCT
				SET Price = @NewPrice
				WHERE ProductID = @ProdID
				COMMIT TRAN T1
				Print (CONCAT('Price for Product ', @ProdName, ' updated from ', @oldPrice,
				' to ', @NewPrice));
			END
END -- end of procedure
GO
-- Test the procedure (after compiling it)
--1) Guaranteed to fail -- productID doesn't exist
EXEC uspUpdateProductPrice 'Kilowatts', 35

--2) Guaranteed to succeed (product ID exists)
--ProductName: 20-lb Bag of Top Soil; Original price=30
EXEC uspUpdateProductPrice '20-lb Bag of Top Soil', 35
GO

---Verify that it worked
SELECT TOP 5 * FROM tblPRODUCT

--3) Clean up: Change the price back to 30
EXEC uspUpdateProductPrice '20-lb Bag of Top Soil', 30
GO

---Verify that it worked
SELECT * FROM tblPRODUCT
WHERE ProductName = '20-lb Bag of Top Soil'


/*NESTED STORED PROCEDURES */
/*
Query: Write the SQL code to create a stored procedure to INSERT 
and new row into tblBUILDING that calls two nested stored procedures 
(one for each FK). You will need to also write the SQL code to create 
the nested stored procedures as well. Include an explicit transaction 
as well as error-handling if any variable ends-up NULL 
(either RAISERROR or THROW).

HINT: Use @B_TypeName to retrieve BuildingTypeID; use @LocationName to 
retrieve LocationID. There will need to be 4 additional parameters 
that pass values straight through to the INSERT statement, 
including @BuildingName, @BldgShortName, @B_Description, and @YearOpened.
*/
USE UNIVERSITY
GO
--Examine the building table
SELECT TOP 5 * FROM tblBUILDING
SELECT TOP 5 * FROM tblLOCATION
SELECT TOP 5 * FROM tblBUILDING_TYPE
GO

--Procedure to look up  building type ID
CREATE OR ALTER PROCEDURE uspGetBuildingTypeID
@BT_Name varchar(50),
@BldgTypeID INT OUTPUT
AS
BEGIN
	SET @BldgTypeID = (SELECT BuildingTypeID 
	FROM tblBUILDING_TYPE 
	WHERE BuildingTypeName = @BT_Name)
END
GO

--Procedure to look up location ID
CREATE OR ALTER PROCEDURE uspGetLocationID
@Loc_Name varchar(50),
@LocID INT OUTPUT
AS
BEGIN
	SET @LocID = (SELECT LocationID 
	FROM tblLOCATION 
	WHERE LocationName = @Loc_Name)
END
GO

SELECT TOP 5 * FROM tblBUILDING
GO
--Main procedure to insert values into tblBUILDING
CREATE OR ALTER PROCEDURE uspINSERT_BUILDING
@B_ID int,
@B_Name varchar(50),
@Location varchar(50),
@BldgType varchar(50),
@B_Descr varchar(500),
@B_Shorty varchar(12),
@YrOp char(4)

AS
BEGIN
	DECLARE @BT_ID INT, @L_ID INT -- declare variables

	--Execute the procedure to look up building type ID. Pass building type name.
	EXEC uspGetBuildingTypeID
	@BT_Name = @BldgType,
	@BldgTypeID = @BT_ID OUTPUT  --retrieves output parameter value

	--Error handling
IF @BT_ID IS NULL
	BEGIN
		PRINT '@BT_ID is NULL and will fail during the INSERT transaction; check spelling of all parameters';
		THROW 56676, '@BT_ID cannot be NULL; statement is terminating', 1;
	END

--Execute to retrieve location ID
EXEC uspGetLocationID
@Loc_Name = @Location,
@LocID = @L_ID OUTPUT -- retrieve the output parameter value

IF @L_ID IS NULL
	BEGIN
		PRINT '@L_ID is NULL and will fail during the INSERT transaction; check spelling of all parameters';
		RAISERROR ('@L_ID cannot be NULL; statement is terminating', 11, 1)
		RETURN
	END


	BEGIN TRAN T1
	INSERT INTO tblBUILDING(BuildingID, BuildingName, LocationID, BuildingTypeID, BuildingDescr,BldgShortName, YearOpened)
	VALUES (@B_ID, @B_Name, @BT_ID, @L_ID, @B_Descr, @B_Shorty, @YrOp)
	COMMIT TRAN T1;
	Print CONCAT('Insert building with id ', @B_ID, 'of building type ',
		@BTName, ' at ',  @Location, ' location successfully.')
END
GO

--Look up the last building ID (in order to insert just after last ID)
SELECT TOP 1 * FROM tblBUILDING
ORDER BY BuildingID DESC
SELECT TOP 5 * FROM tblBUILDING_TYPE
SELECT TOP 5 * FROM tblLOCATION
GO
--Test the procedure
--1) Guaranteed to fail due to BuildingTypeID
EXEC uspINSERT_BUILDING
118, 'Test Building', 'Stevens Way', 'Killowatts', 'Just testing', 'TestB', '2024'

--2) Guaranteed to fail due to LocationeID
EXEC uspINSERT_BUILDING
118, 'Test Building', 'Kilowatts', 'Primary Instruction', 'Just testing', 'TestB', '2024'

-- Guaranteed to succeed
--1) Guaranteed to fail due to BuildingTypeID
EXEC uspINSERT_BUILDING
119, 'Test Building', 'Stevens Way', 'Primary Instruction','Just testing', 'TestB', '2024'


/* ALTERNATIVE ERROR HANDLING APPROACH: USING TRY...CATCH */
--In most programming languages, the try...catch framework is used for error-handling
--Using TRY...CATCH in a transaction
--Refer to the following resource for more details:
-- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql?view=sql-server-ver16


/*Stored Procedure FOR UPDATE with Explict Transaction and Error Handling */
/*-- Q3) Write the SQL to create a stored procedure to UPDATE the price of 
a single product in SampleSuperStore database with the following conditions:
-- a) be sure to affect only a single row (hint: populate a variable and 
     set that to the PK of tblPRODUCT)
-- b) make the UPDATE statement inside an explicit transaction
-- c) pass in parameters of @ProdName and @NewPrice
*/
SELECT TOP 5 * FROM tblPRODUCT
GO

--You can use either RAISERROR or THROW in the try block to provide
--custom error messages and then report those errors in the catch block.
  use SampleSuperStore_db
  GO
-------------------------------------------
CREATE OR ALTER PROCEDURE uspUpdateProductPrice1
@ProdName varchar(60), @NewPrice numeric(5,2)

AS
BEGIN
--Look up product using product name
DECLARE @ProdID int
SET @ProdID = (SELECT ProductID FROM tblPRODUCT WHERE ProductName = @ProdName)
--look up old price
DEClARE @oldPrice numeric(5,2)
SET @oldPrice = (SELECT Price FROM tblPRODUCT WHERE ProductName = @ProdName)
	
	BEGIN TRANSACTION T2

	--Begin try
			BEGIN TRY
				UPDATE tblPRODUCT
				SET Price = @NewPrice
				WHERE ProductID = @ProdID

				IF @ProdID IS NULL
				--BEGIN
				/*    RAISERROR ('Product ID cannot be null.', -- Message text.
               16, -- Severity.
               1 -- State.
               );*/

			   THROW 50061, '@ProdTypeID cannot be NULL; statement is terminating', 1;

			 --  END
				--Commit transaction
				COMMIT TRANSACTION T2;
				Print (CONCAT('Price for Product ', @ProdName, ' updated from ', @oldPrice,
				' to ', @NewPrice));
			END TRY
	--Begin Catch
			BEGIN CATCH

					IF @@TRANCOUNT > 0  
					ROLLBACK TRANSACTION T2; 
 /*
 DECLARE @Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE();
 
   RAISERROR(@Message, @Severity, @State);*/
		THROW;
   END CATCH
END -- end of procedure
GO

-- Test the procedure (after compiling it)
--1) Guaranteed to fail -- productID doesn't exist
EXEC uspUpdateProductPrice1 'Kilowatts', 35
SELECT * FROM tblDBErrors

--2) Guaranteed to succeed (product ID exists)
--ProductName: 20-lb Bag of Top Soil; Original price=30
EXEC uspUpdateProductPrice '20-lb Bag of Top Soil', 35

-- Verify that it worked.
SELECT * FROM tblPRODUCT
WHERE ProductName = '20-lb Bag of Top Soil'

--3) Clean up: change the price back to 30 - the original price
EXEC uspUpdateProductPrice '20-lb Bag of Top Soil', 30

-- Verify that it worked.
SELECT * FROM tblPRODUCT
WHERE ProductName = '20-lb Bag of Top Soil'


