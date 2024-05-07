USE Team8NordstromDB
GO

-- /*Stored Procedure FOR INSERT with Explict Transaction and Error Handling */

CREATE OR ALTER PROCEDURE AddEmployee
    @EmployeeFName VARCHAR(50),
    @EmployeeLName VARCHAR(50),
    @EmployeePhone VARCHAR(50),
    @EmployeeEmail VARCHAR(50),
    @EmployeeDateOfBirth DATE,
    @EmployeeTitle VARCHAR(50),  -- Description of employee type
    @PositionType VARCHAR(50), 
    @StoreName VARCHAR(50),         -- Name of the store
    @DepartmentName VARCHAR(50)     -- Name of the department
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN -- Start the transaction

        -- Checking if any of the input parameters are null and throwing an error if they are
        -- IF @EmployeeFName IS NULL OR @EmployeeLName IS NULL OR @EmployeePhone IS NULL OR @EmployeeEmail IS NULL OR @EmployeeDateOfBirth IS NULL OR @EmployeeTypeDesc IS NULL OR @StoreName IS NULL OR @DepartmentName IS NULL
        -- THROW 51000, 'The employee details must not be null.', 1;
        -- Insert the new employee record into the tblEmployee table
        INSERT INTO tblEmployee (
            EmployeeTitleID, 
            PositionTypeID,
            StoreID, 
            DepartmentID, 
            EmployeeFName, 
            EmployeeLName, 
            EmployeePhone, 
            EmployeeEmail, 
            EmployeeDateOfBirth
        )
        VALUES (
            (SELECT EmployeeTitleID FROM tblEmployeeTitle WHERE EmployeeTitle = @EmployeeTitle),
            (SELECT PositionTypeID FROM tblPositionType WHERE PositionType = @PositionType),
            (SELECT StoreID FROM tblStore WHERE StoreName = @StoreName),
            (SELECT DepartmentID FROM tblDepartment WHERE DepartmentName = @DepartmentName),
            @EmployeeFName, 
            @EmployeeLName, 
            @EmployeePhone, 
            @EmployeeEmail, 
            @EmployeeDateOfBirth
        )

        COMMIT TRAN -- Commit the transaction if no errors

        -- Output a message indicating success
        SELECT 'New employee added successfully!'

    END TRY
    BEGIN CATCH
        ROLLBACK TRAN -- Roll back the transaction in case of error
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() as ErrorState,
            ERROR_PROCEDURE() as ErrorProcedure,
            ERROR_LINE() as ErrorLine,
            ERROR_MESSAGE() as ErrorMessage;
    END CATCH
END

-- Test stored procedure --
EXEC AddEmployee 
    @EmployeeFName = 'Gabriela',
    @EmployeeLName = 'Sabatini',
    @EmployeePhone = '360-789-9456',
    @EmployeeEmail = 'gabrielllla_s.tennis@fila.com',
    @EmployeeDateOfBirth = '1977-01-22',
    @EmployeeTitle = 'Manager',
    @PositionType = 'part time',
    @StoreName = 'Bellevue Square',
    @DepartmentName = 'Cosmetics'




/*Stored Procedure to UPDATE DepartmentName with Error Handling */
GO
CREATE OR ALTER PROCEDURE UpdateDepartmentName
    @OldDepartmentName VARCHAR(50),
    @NewDepartmentName VARCHAR(50)
AS
BEGIN
    -- Check if the department exists
    IF EXISTS (SELECT * FROM tblDepartment WHERE DepartmentName = @OldDepartmentName)
    BEGIN
        -- Update the department description
        UPDATE tblDepartment
        SET DepartmentName = @NewDepartmentName
        WHERE DepartmentName = @OldDepartmentName;

        -- Output success message
        SELECT 'Department name updated successfully!';
    END
    ELSE
    BEGIN
        -- Output error message if department not found
        SELECT 'Error: Department not found.';
    END
END

-- Test stored procedure -- 
EXEC UpdateDepartmentName
    @OldDepartmentName = 'Women''s Sunglasses & Eyewear',
    @NewDepartmentName = 'Sunglasses & Eyewear';
GO



/*Stored Procedure to DELETE a row of data form tblEmployee with Error Handling */

CREATE OR ALTER PROCEDURE DeleteEmployeeByDetails
    @EmployeeFName NVARCHAR(50),
    @EmployeeLName NVARCHAR(50),
    @EmployeeDateOfBirth DATE
AS
BEGIN
    
    DECLARE @EmployeeID INT;

    -- First, find the EmployeeID based on the provided details
    SELECT @EmployeeID = EmployeeID
    FROM tblEmployee
    WHERE EmployeeFName = @EmployeeFName
      AND EmployeeLName = @EmployeeLName
      AND EmployeeDateOfBirth = @EmployeeDateOfBirth;

    -- Check if an EmployeeID was found
    IF @EmployeeID IS NULL
        THROW 50001, 'No employee found with the specified details.', 1;

    ELSE
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION; -- Start the transaction

            -- Proceed to delete the employee now that we know the ID exists
            DELETE FROM tblEmployee
            WHERE EmployeeID = @EmployeeID;

            -- Check if the deletion was actually performed
            IF @@ROWCOUNT = 0
                THROW 50002, 'No employee was deleted, an unexpected error occurred.', 1;
            
            COMMIT TRANSACTION; -- Commit the transaction if no errors
            SELECT 'Employee deleted successfully!'

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION; -- Roll back the transaction in case of error

            SELECT
                ERROR_NUMBER() AS ErrorNumber,
                ERROR_SEVERITY() AS ErrorSeverity,
                ERROR_STATE() AS ErrorState,
                ERROR_PROCEDURE() AS ErrorProcedure,
                ERROR_LINE() AS ErrorLine,
                ERROR_MESSAGE() AS ErrorMessage;    
        END CATCH
    END
END
GO

-- Test DELETE stored procedure --
EXEC DeleteEmployeeByDetails 
    @EmployeeFName = 'Thaddeus', 
    @EmployeeLName = 'McCourtie', 
    @EmployeeDateOfBirth = '1961-11-13';
GO


/* Create an AFTER insert trigger */ 

DROP TABLE IF EXISTS tblEmployee_LOG
CREATE TABLE tblEmployeeLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    EmployeeTitleID INT,
    PositionTypeID INT,
    StoreID INT,
    DepartmentID INT,
    EmployeeFName VARCHAR(255),
    EmployeeLName VARCHAR(255),
    EmployeePhone VARCHAR(50),
    EmployeeEmail VARCHAR(255),
    EmployeeDateOfBirth DATE,
    Action VARCHAR(255),
    LogDate DATETIME
);
GO

CREATE TRIGGER trg_AfterEmployeeInsert
ON tblEmployee
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert detailed log entry for each new employee
    INSERT INTO tblEmployeeLog (EmployeeID, EmployeeTitleID, PositionTypeID, StoreID, DepartmentID, 
                                EmployeeFName, EmployeeLName, EmployeePhone, EmployeeEmail, 
                                EmployeeDateOfBirth, Action, LogDate)
    SELECT 
        i.EmployeeID, 
        i.EmployeeTitleID, 
        i.PositionTypeID, 
        i.StoreID, 
        i.DepartmentID, 
        i.EmployeeFName, 
        i.EmployeeLName, 
        i.EmployeePhone, 
        i.EmployeeEmail, 
        i.EmployeeDateOfBirth, 
        'New employee inserted', 
        GETDATE()
    FROM 
        inserted i;

END;
GO

-- check if log table correctly updates --
INSERT INTO tblEmployee (EmployeeTitleID, StoreID, DepartmentID, PositionTypeID, EmployeeFName, EmployeeLName, EmployeePhone, EmployeeEmail, EmployeeDateOfBirth) values ((SELECT TOP 1 EmployeeTitleID FROM tblEmployeeTitle WHERE EmployeeTitleID BETWEEN 1 AND 13 ORDER BY NEWID()), (SELECT TOP 1 StoreID FROM tblStore WHERE StoreID BETWEEN 1 AND 360 ORDER BY NEWID()), (SELECT TOP 1 DepartmentID FROM tblDepartment WHERE DepartmentID BETWEEN 1 AND 23 ORDER BY NEWID()), (SELECT TOP 1 PositionTypeID FROM tblPositionType WHERE PositionTypeID BETWEEN 1 AND 4 ORDER BY NEWID()), 'Gabriella', 'Rivera', '253-225-4497', 'grivera7@uw.edu', '1991-09-17');
SELECT * FROM tblEmployeeLog



/* Create an INSTEAD 0F update trigger */ 

SELECT * from tblDiscount
-- GO

CREATE TABLE tblDiscount_Log (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    DiscountID INT,
    DiscountType DECIMAL(3,2),
    ActionTaken VARCHAR(255),
    LogDate DATETIME
);
GO

CREATE TRIGGER trgInsteadOfInsertDiscount
ON tblDiscount
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for DiscountType greater than 1.0
    IF EXISTS (SELECT 1 FROM inserted WHERE DiscountType > 1.0)
    BEGIN
        -- Log the attempt to insert an invalid discount type
        INSERT INTO tblDiscount_Log (DiscountID, DiscountType, ActionTaken, LogDate)
        SELECT DiscountID, DiscountType, 'Insert failed: DiscountType greater than 1.0', GETDATE()
        FROM inserted;

        RAISERROR ('Insert failed: DiscountType cannot be greater than 1.0', 16, 1);
        RETURN;
    END

    -- If the DiscountType is valid, insert the record into the original table
    INSERT INTO tblDiscount (DiscountID, DiscountType)
    SELECT DiscountID, DiscountType
    FROM inserted;

    -- Log the successful insertion
    INSERT INTO tblDiscount_Log (DiscountID, DiscountType, ActionTaken, LogDate)
    SELECT DiscountID, DiscountType, 'Insert successful', GETDATE()
    FROM inserted;
END;
GO

-- check if INSTEAD OF insert trigger works
INSERT INTO tblDiscount (DiscountType)
VALUES (1.50);


-- SELECT top 20 * from tblEmployee ORDER by EmployeeID DESC
-- SELECT * from tblEmployeeTitle

/* Computed column to compute the amount of StockQuantity Nordstrom has of a specific brand */ 
ALTER TABLE tblProduct
ADD TotalStockValue AS (ProductPrice * StockQuantity);

-- check to see if it was created successfully --
SELECT TOP 10 * FROM tblProduct
GO


-- Complex query as a Stored Procedure to get manager count by store --

CREATE PROCEDURE GetEmployeeCountByTitle
AS
BEGIN
    SELECT 
        et.EmployeeTitle,
        COUNT(e.EmployeeID) AS NumberOfEmployees
    FROM 
        tblEmployeeTitle et
    LEFT JOIN 
        tblEmployee e ON et.EmployeeTitleID = e.EmployeeTitleID
    GROUP BY 
        et.EmployeeTitle;
END;
GO

-- Ensure the query works --
EXECUTE GetEmployeeCountByTitle
GO



/* Complex query [that takes given inputs and returns the expected output] which fetches a list of all employees, including their names, title, position, department description, 
and the store they work at, filtered by a specific store name and employee title */ 

DECLARE @StoreName VARCHAR(50) = 'Denver Mountain Mall';
DECLARE @EmployeeTitle VARCHAR(50) = 'Sales Associate'; 

SELECT 
    e.EmployeeFName AS FirstName,
    e.EmployeeLName AS LastName,
    et.EmployeeTitle AS Title,
    pt.PositionType AS Position,
    d.DepartmentName AS Department,
    s.StoreName AS Store,
    s.StoreAddress AS Address,
    s.StoreDivision AS Division

FROM tblEmployee e
    JOIN tblEmployeeTitle et ON e.EmployeeTitleID = et.EmployeeTitleID
    JOIN tblPositionType pt ON e.PositionTypeID = pt.PositionTypeID
    JOIN tblDepartment d ON e.DepartmentID = d.DepartmentID
    JOIN tblStore s ON e.StoreID = s.StoreID
WHERE 
    s.StoreName = @StoreName AND et.EmployeeTitle = @EmployeeTitle;

