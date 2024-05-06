/* DATABASE TRIGGERS */
--Select the Database to use
USE SampleSuperStore_db
GO
/* Make a copy of the database table */
SELECT * INTO tblCUST_COPY2
FROM tblCUSTOMER
SELECT TOP 10 * FROM tblCUST_COPY2
GO
--1) AFTER TRIGGERS
--a) After Insert-Update Trigger
--first letter of customer Fname and Lname should be capitalized
--State the two-letter code should be capitalized
--record Audit information of the inserted row of data
--create audit table for logging purposes
DROP TABLE IF EXISTS tblCUST_LOG
CREATE TABLE tblCUST_LOG
(
CustomerID int,
Fname varchar(55),
Lname varchar(55),
BirthDate date,
CustAddress varchar(100),
CustCity varchar(55),
CustState varchar(55),
CustZip char(5),
Log_ation varchar(100), ---track the type of action that was performed on the database
Log_Timestamp datetime -- time stamp of the stated action
)
GO
-- Create trigger on table tblCUST_COPY2 for Insert statement
CREATE OR ALTER TRIGGER trgAfterInsertUpdate2 ON tblCUST_COPY2
AFTER INSERT, UPDATE
--declare parameters that are going to hold values to insert into the log table
AS declare @custid int, @custFname varchar(55), @custLname varchar(55),
@custBirthDate date,
@custAddress varchar(100), @custCity varchar(55), @custState
varchar(55), @custZip char(5), @log_action varchar(100)
--update customer first name, last name, and state code as required
--replace (string, old_value, new_value)
/*UPDATE tblCUST_COPY2
SET Fname = REPLACE(Fname, LEFT(TRIM(Fname),1),
UPPER(LEFT(TRIM(Fname),1))), -- replace the first letter of first name
with uppercase
Lname = REPLACE(Lname, LEFT(TRIM(Lname),1),
UPPER(LEFT(TRIM(Lname),1))), -- replace the first letter of last name with
uppercase
CustState = REPLACE(CustState, RIGHT(TRIM(CustState),2),
UPPER(RIGHT(TRIM(CustState),2))) -- replace state code with uppercase
WHERE CustomerID IN (SELECT CustomerID FROM Inserted);
*/
--gather the information to log into tblCUST_LOG
SELECT @custid = i.CustomerID, @custFname = i.Fname, @custLname = i.Lname,
        @custBirthDate = i.BirthDate,
        @custAddress = i.CustAddress, 
        @custCity = i.CustCity, 
        @custState =i.CustState, 
        @custZip = i.CustZip
FROM Inserted i set @log_action='Inserted Record -- After Insert Trigger.';
INSERT INTO
tblCUST_LOG(CustomerID,Fname,Lname,BirthDate,CustAddress,CustCity,CustState,CustZip, Log_ation,Log_Timestamp)
values
(@custid,@custFname,@custLname,@custBirthDate,@custAddress,@custCity,@custState,@custZip, @Log_action,getdate());
PRINT 'AFTER INSERT trigger fired successfully.' -- provide some feedback to the user
--End of the trigger code
GO
--Test the trigger: insert one row of data into tblCust_copy (after compiling the trigger -- i.e., run the trigger code to compile it)
INSERT INTO
tblCUST_COPY2(Fname,Lname,BirthDate,CustAddress,CustCity,CustState,CustZip)
VALUES('bill','gates','1990-02-21','1 Campus Pkway', 'Seattle', 'Washington, wa', '98185')
--Verify that the trigger worked
SELECT * FROM tblCUST_LOG
SELECT TOP 2 * FROM tblCUST_COPY2
ORDER BY CustomerID DESC
GO
--b) After Update Trigger
-- Create trigger on table tblCUST_COPY1 for Update statement
CREATE OR ALTER TRIGGER trgAfterUpdate2 ON tblCUST_COPY2
FOR UPDATE --specify the action
AS
DECLARE @custid int, @custFname varchar(55), @custLname varchar(55),
@custBirthDate date,
@custAddress varchar(100), @custCity varchar(55), @custState
varchar(55), @custZip char(5), @log_action varchar(100)
SELECT @custid = i.CustomerID, @custFname = i.Fname, @custLname = i.Lname,
@custBirthDate = i.BirthDate,
@custAddress = i.CustAddress, @custCity = i.CustCity, @custState =
i.CustState, @custZip = i.CustZip
FROM Inserted i
if update(CustAddress)
set @log_action='Updated customer address --- After Update Trigger.';
if update (CustCity)
set @log_action='Updated customer city--- After Update Trigger.';
if update (CustState)
set @log_action='Updated customer State--- After Update Trigger.';
if update (CustZip)
set @log_action='Updated customer Zip --- After Update Trigger.';
INSERT INTO
tblCUST_LOG(CustomerID,Fname,Lname,BirthDate,CustAddress,CustCity,CustState,CustZip, Log_ation,Log_Timestamp)
values
(@custid,@custFname,@custLname,@custBirthDate,@custAddress,@custCity,@custState,@custZip, @log_action,getdate());
PRINT 'AFTER UPDATE trigger fired successfully.'
--Test the trigger
UPDATE tblCUST_COPY2
SET CustAddress = '100 Porland Avenue',
CustCity = 'Portland',
CustState = 'Oregon, OR',
CustZip ='97012'
WHERE customerID = 5001
--Verify that it worked
SELECT * FROM tblCUST_LOG
GO
SELECT TOP 2 * FROM tblCUST_COPY2
ORDER BY CustomerID DESC
GO
--c) After Delete Trigger
-- Create trigger on table tblCUST_COPY for Delete statement
CREATE OR ALTER TRIGGER trgAfterDelete2 ON tblCUST_COPY2
AFTER DELETE
AS
DECLARE @custid int, @custFname varchar(55), @custLname varchar(55),
@custBirthDate date,
@custAddress varchar(100), @custCity varchar(55), @custState
varchar(55), @custZip char(5), @audit_action varchar(100)
SELECT @custid = d.CustomerID, @custFname = d.Fname, @custLname = d.Lname,
@custBirthDate = d.BirthDate,
@custAddress = d.CustAddress, @custCity = d.CustCity, @custState =
d.CustState, @custZip = d.CustZip
FROM Deleted d
SET @audit_action='Deleted Customer --- After Delete Trigger.';
INSERT INTO
tblCUST_LOG(CustomerID,Fname,Lname,BirthDate,CustAddress,CustCity,CustState,CustZip, Log_ation, Log_Timestamp) values
(@custid,@custFname,@custLname,@custBirthDate,@custAddress,@custCity,@custState,@custZip, @audit_action,getdate());
PRINT 'AFTER DELETE trigger fired successfully.'
--Test the trigger
DELETE tblCUST_COPY2
WHERE CustomerID = 5001
--verify that it worked
SELECT * FROM tblCUST_LOG
SELECT TOP 2 * FROM tblCUST_COPY2
ORDER BY CustomerID DESC