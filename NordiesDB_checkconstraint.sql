USE Team8NordstromDB

-- Check constraint to ensure all employees added to the database are older than 15 years of age
ALTER TABLE tblEmployee
ADD CONSTRAINT CHK_DateOfBirth CHECK (
    EmployeeDateOfBirth >= '1940-01-01' AND 
    EmployeeDateOfBirth <= DATEADD(YEAR, -15, GETDATE())
);

-- Check the check constraint
insert into tblEmployee (EmployeeTypeID, StoreID, DepartmentID, EmployeeFName, EmployeeLName, EmployeePhone, EmployeeEmail, EmployeeDateOfBirth) values 
(3, 122, 5, 'Gabriella', 'Rivera', '253-255-4497', 'grivera7@uw.edu', '2024-02-21');



-- Check constraint to ensure that DiscountType will not be greater than 1.0 (100%)

ALTER TABLE tblDiscount
ADD CONSTRAINT CHK_DiscountType
CHECK (DiscountType <= '1.0' AND DiscountType >= '0');

-- Check the check constraint
SET IDENTITY_INSERT tblDiscount ON;
insert into tblDiscount (DiscountID, DiscountType) VALUES (1202, 7.0)

