/* DATABASE TRIGGERS */
--Select the Database to use

USE SampleSuperStore_db
GO

SELECT TOP 10 * FROM tblPRODUCT
SELECT TOP 10 * FROM tblORDER_PRODUCT
SELECT TOP 5 * FROM tblPRODUCT_TYPE

/* Make a copy of the database table */

SELECT * INTO tblPROD_COPY
FROM tblPRODUCT

SELECT TOP 10 * FROM tblPROD_COPY
GO

--1) AFTER TRIGGERS
--a) After Insert-Update Trigger
--first letter of customer Fname and Lname should be capitalized
--State the two-letter code should be capitalized
--record Audit information of the inserted row of data
--create audit table for logging purposes

DROP TABLE IF EXISTS tblPROD_LOG
CREATE TABLE tblPROD_LOG
(
 ProductID int,
 ProductName varchar(60),
 ProductTypeID int,
 ProductDesc varchar(100),
 Price numeric(5,2),
 Log_Action varchar(100), ---track the type of action that was performed on the database
 Log_Timestamp datetime -- time stamp of the stated action
) 
GO
 -- Create trigger on table tblPROD_COPY for instead of Insert statement
CREATE OR ALTER TRIGGER trgInsteadOfInsertProduct ON tblPROD_COPY
INSTEAD OF INSERT
--declare parameters that are going to hold values to insert into the log table
AS
declare @prod_id int, @prod_name varchar(60), @prod_type_ID int, @prodDesc varchar(100), @price numeric(5,2), @audit_action varchar(100);
select @prod_id=i.ProductID, @prod_name = i.ProductName, @prod_type_ID = i.ProdTypeID, @prodDesc = i.ProductDescr, @price = i.Price 
FROM inserted i;
SET @audit_action='Inserted Record -- Instead Of Insert Trigger.';

BEGIN 
 BEGIN TRAN
	SET NOCOUNT ON
	---Prevet users from inserting product prices equl to or less than 0
	IF(@price <=0)
		BEGIN
			RAISERROR('Cannot update price for product table where price <=0',16,1); 
			ROLLBACK; 
		END

		--price is in the positive range
	ELSE
		BEGIN
			INSERT INTO tblPROD_COPY(ProductName,ProdTypeID, ProductDescr, Price) 
				VALUES (@prod_name, @prod_type_ID, @prodDesc, @price); 

			INSERT INTO tblPROD_LOG(ProductID, ProductName, ProductTypeID, ProductDesc, Price, Log_Action, Log_Timestamp)
				VALUES (@@identity,@prod_name, @prod_type_ID, @prodDesc, @price,@audit_action,getdate());
			COMMIT;
			PRINT 'Record Inserted -- Instead Of Insert Trigger.'
			--PRINT 'AFTER INSERT trigger fired successfully.' -- provide some feedback to the user
		END
 END
--End of the trigger code
GO

--Test the trigger: insert one row of data into tblprod_copy (after compiling the trigger -- i.e., run the trigger code to compile it)
--1) Guaranteed to fail

INSERT INTO tblPROD_COPY(ProductName,ProdTypeID, ProductDescr, Price) 
VALUES('Skillet', 2,'Iron Skillet - doesn''t burn food!',0)

--2) success
INSERT INTO tblPROD_COPY(ProductName,ProdTypeID, ProductDescr, Price) 
VALUES('Skillet', 2,'Iron Skillet - doesn''t burn food!',50)

--Verify that the trigger worked
SELECT * FROM tblPROD_LOG

SELECT TOP 2 * FROM tblPROD_COPY
ORDER BY ProductID DESC
GO


--2) INSTEAD OF UPDATE TRIGGER
 -- Create trigger on table tblCUST_COPY2 for Insert statement
CREATE OR ALTER TRIGGER trgInsteadOfUpdateProduct ON tblPROD_COPY
INSTEAD OF UPDATE
--declare parameters that are going to hold values to insert into the log table
AS
declare @prod_id int, @prod_name varchar(60), @prod_type_ID int, @prodDesc varchar(100), @price numeric(5,2), @audit_action varchar(100);
select @prod_id=i.ProductID, @prod_name = i.ProductName, @prod_type_ID = i.ProdTypeID, @prodDesc = i.ProductDescr, @price = i.Price 
FROM inserted i;
SET @audit_action='Updated Record -- Instead Of Update Trigger.';

BEGIN 
 BEGIN TRAN
	--SET NOCOUNT ON
	--No discounts for intems whose price is <=50
	IF(@price <=50)
		BEGIN
			/*RAISERROR('Cannot Insert into product table where price <=50',16,1); */
			PRINT 'You are not permitted to update price for product table where price<=50';
			THROW 50062, 'Discounts cannot be applied to pocducts with a price of $50 or less', 1;
			ROLLBACK; 
		END

	ELSE
		BEGIN
		--10% discount on products whose price is greater than 50
			UPDATE tblPROD_COPY
			SET Price = Price*(1-0.10)
			WHERE ProductID = @prod_id

			INSERT INTO tblPROD_LOG(ProductID, ProductName, ProductTypeID, ProductDesc, Price, Log_Action, Log_Timestamp)
				VALUES (@prod_id,@prod_name, @prod_type_ID, @prodDesc, @price,@audit_action,getdate());
				COMMIT;
				PRINT (CONCAT('The price for product with id of ', @prod_id, ' had been updated successfully'))
				PRINT 'INSTEAD OF trigger fired successfully.' -- provide some feedback to the user
		END
 END
--End of the trigger code
GO

--Test the trigger: insert one row of data into tblprod_copy (after compiling the trigger -- i.e., run the trigger code to compile it)
--1) Guaranteed to fail

UPDATE tblPROD_COPY
--10% discount (price is 30)
SET Price = Price*(1-.10)
WHERE ProductID=2

--2) success
UPDATE tblPROD_COPY
--10% discount for product ID =1 (original price = 200)
SET Price = Price*(1-.10)
WHERE ProductID=1

--Verify that the trigger worked
SELECT * FROM tblPROD_LOG

SELECT TOP 10 * FROM tblPROD_COPY
--ORDER BY ProductID DESC
GO


--3) INSTEAD OF DELETE TRIGGER
 -- Create trigger on table tblCUST_COPY2 for Insert statement
CREATE OR ALTER TRIGGER trgInsteadOfDeleteProduct ON tblPROD_COPY
INSTEAD OF DELETE
--declare parameters that are going to hold values to insert into the log table
AS
declare @prod_id int, @prod_name varchar(60), @prod_type_ID int, @prodDesc varchar(100), @price numeric(5,2), @audit_action varchar(100);
select @prod_id=d.ProductID, @prod_name = d.ProductName, @prod_type_ID = d.ProdTypeID, @prodDesc = d.ProductDescr, @price = d.Price 
FROM deleted d;
SET @audit_action='Deleted Record -- Instead Of Delete Trigger.';

BEGIN 
 BEGIN TRAN
	--Cannot delete products whose price is greater than 100
	IF(@price > 100)
		BEGIN
			/*RAISERROR('Cannot Insert into product table where price <=50',16,1); */
			PRINT 'You are not permitted to delete aproduct from product table where price >100';
			THROW 50062, 'products with a price >100 cannot be deleted', 1;
			ROLLBACK; 
		END

	ELSE 
		BEGIN
			DELETE tblPROD_COPY
			WHERE ProductID = @prod_id

			INSERT INTO tblPROD_LOG(ProductID, ProductName, ProductTypeID, ProductDesc, Price, Log_Action, Log_Timestamp)
				VALUES (@prod_id,@prod_name, @prod_type_ID, @prodDesc, @price,@audit_action,getdate());
			COMMIT;
			PRINT (CONCAT('Product with product ID of ', @prod_id, ' has been deleted from the database successfully.'))
			PRINT 'INSTEAD OF trigger fired successfully.' -- provide some feedback to the user
		END
 END
--End of the trigger code
GO

--Test the trigger: insert one row of data into tblprod_copy (after compiling the trigger -- i.e., run the trigger code to compile it)
--1) Guaranteed to fail

DELETE tblPROD_COPY
--ProductID =1 has a price >100
WHERE ProductID=1

--2) success
--first insert a row to be deleted
	 INSERT INTO tblPROD_COPY(ProductName,ProdTypeID, ProductDescr, Price) 
		VALUES ('Sam''s Product', 2, 'Just testing', 35); 

SELECT TOP 1 * FROM tblPROD_COPY
ORDER BY ProductID DESC

--dlete the new insert with ID=1519
DELETE tblPROD_COPY
WHERE ProductID = 1519

--Verify that the trigger worked
SELECT * FROM tblPROD_LOG

SELECT TOP 2 * FROM tblPROD_COPY
ORDER BY ProductID DESC
GO
