-- USE Team8NordstromDB

-- Stored Procedure to insert a new row into Brand table --

CREATE PROCEDURE sp_InsertBrand
    @BrandDescription VARCHAR(255),
    @BrandName VARCHAR(50)
AS
BEGIN
    -- Inserting the data into the tblBrand table
    INSERT INTO tblBrand (BrandDescription, BrandName)
    VALUES (@BrandDescription, ISNULL(@BrandName, 'Unknown'));
END;

EXEC sp_InsertBrand 
    @BrandDescription = 'slay slay slay',
    @BrandName = 'Prada';
GO


-- Stored Procedure to insert row into tblOrder (contains foreign key lookups) --

-- First stored procedure: Retrieve CustomerID
CREATE OR ALTER PROCEDURE sp_GetorCreateCustomerID
    @CustFName VARCHAR(50),
    @CustLName VARCHAR(50),
    @CustEmail VARCHAR(50),
    @CustAddress VARCHAR(50),
    @CustDateOfBirth DATE,
    @CustTypeID INT,
    @CustID INT OUTPUT  -- Define CustID as an OUTPUT parameter
AS
BEGIN
    IF @CustFName IS NULL  or @CustLName IS NULL
        THROW 51000, 'The customer''s full name cannot be null.', 1;

    -- DECLARE @CustID INT
    SELECT @CustID = CustID FROM tblCustomer WHERE CustFName = @CustFName AND CustLName = @CustLName;

    IF @CustID IS NULL
    BEGIN
        INSERT INTO tblCustomer (CustFName, CustLName, CustEmail, CustAddress, CustDateOfBirth, CustTypeID) VALUES (@CustFName, @CustLName, @CustEmail, @CustAddress, @CustDateOfBirth, @CustTypeID);
        SELECT @CustID = SCOPE_IDENTITY();
    END
END;
GO

-- Check to ensure CustID is either created or found correctly
DECLARE @CustomerID INT;
EXEC sp_GetOrCreateCustomerID
    @CustFName = 'Jane',
    @CustLName = 'Doe',
    @CustEmail = 'jane.doe@example.com',
    @CustAddress = '123 Maple Street',
    @CustDateOfBirth = '1980-04-01',
    @CustTypeID = 1,
    @CustID = @CustomerID OUTPUT;
SELECT @CustomerID AS OutputCustID;
GO


-- Second stored procedure: Create ShippingID
CREATE OR ALTER PROCEDURE sp_CreateShippingID
    @ShippingAddress VARCHAR(255),
    @ShippingState VARCHAR(50),
    @ShippingZip VARCHAR(5),
    @ShippingID INT OUTPUT
AS
BEGIN
    -- Checking if any of the input parameters are null and throwing an error if they are
    IF @ShippingAddress IS NULL OR @ShippingState IS NULL OR @ShippingZip IS NULL
        THROW 51000, 'The shipping details must not be null.', 1;

    -- DECLARE @ShippingID INT;
    INSERT INTO tblShipping (ShippingAddress, ShippingState, ShippingZip)
    VALUES (@ShippingAddress, @ShippingState, @ShippingZip);
    SELECT @ShippingID = SCOPE_IDENTITY();
END;
GO

-- Now the main stored procedure that inserts into tblOrder
CREATE OR ALTER PROCEDURE sp_InsertOrder
-- parameters
    @CustFName VARCHAR(50),
    @CustLName VARCHAR(50),
    @CustEmail VARCHAR(50),
    @CustAddress VARCHAR(50),
    @CustDateOfBirth VARCHAR(50),
    @CustTypeID INT,
    @ShippingAddress VARCHAR(255),
    @ShippingState VARCHAR(50),
    @ShippingZip VARCHAR(5),
    @OrderProductQuantity INT,
    @OrderDate DATE,
    @OrderTotal DECIMAL(10, 2)
AS
BEGIN
     -- Variables to store customer and shipping IDs
    DECLARE @CustID INT;
    DECLARE @ShippingID INT;
    
        EXEC sp_GetOrCreateCustomerID
            @CustFName,
            @CustLName,
            @CustEmail,
            @CustAddress,
            @CustDateOfBirth,
            @CustTypeID,
            @CustID = @CustID OUTPUT;
        PRINT 'Retrieved CustID: ' + CAST(@CustID AS VARCHAR(10));
        
        EXEC sp_CreateShippingID 
            @ShippingAddress, 
            @ShippingState, 
            @ShippingZip,
            @ShippingID OUTPUT;
        PRINT 'ShippingID: ' + CAST(@ShippingID AS VARCHAR(10));

        -- Check for NULL values after nested procedures
        IF @CustID IS NULL
            BEGIN
                PRINT 'CustID is NULL';
                THROW 51000, 'CustID retrieval failed.', 1;
            END
        
         IF @ShippingID IS NULL
            BEGIN
                PRINT 'ShippingID is NULL';
                THROW 51000, 'ShippingID retrieval failed.', 1;
            END

        -- Insert the new order into tblOrder
    INSERT INTO tblOrder (CustID, OrderProductQuantity, OrderDate, OrderTotal, ShippingID)
    VALUES (@CustID, @OrderProductQuantity, @OrderDate, @OrderTotal, @ShippingID);
END;
GO

EXEC sp_InsertOrder 
    @CustFName = 'Griselda',                 -- Customer's first name
    @CustLName = 'Blanco',                  -- Customer's last name
    @CustEmail = 'griselda.b@example.com', -- Customer's email address
    @CustAddress = '123 Jarritos Dr',   -- Customer's physical address
    @CustDateOfBirth = '1966-04-20',     -- Customer's date of birth
    @CustTypeID = 1,                     -- Customer type ID (assuming 1 corresponds to a certain customer type)
    @ShippingAddress = '717 Cocaine Dr',   -- Shipping address
    @ShippingState = 'CA',               -- Shipping state
    @ShippingZip = '98761',              -- Shipping ZIP code
    @OrderProductQuantity = 2,           -- Quantity of products in the order
    @OrderDate = '2021-10-05',           -- Date of the order
    @OrderTotal = 900.70;                -- Total cost of the order


