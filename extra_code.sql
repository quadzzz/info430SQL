ALTER TABLE tblProductStore
ADD CONSTRAINT FK_ProductStore_Store
FOREIGN KEY (StoreID) REFERENCES tblStore(StoreID);
ALTER TABLE tblProductStore DROP CONSTRAINT FK_ProductStore_Store;

ALTER TABLE tblEmployee
ADD CONSTRAINT FK_EmployeeStore_Store
FOREIGN KEY (StoreID) REFERENCES tblStore(StoreID);

ALTER TABLE tblEmployee DROP CONSTRAINT FK_EmployeeStore_Store;

-- SELECT 
--     fk.name AS FK_name,
--     OBJECT_NAME(fk.parent_object_id) AS Table_Name,
--     COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS Column_Name
-- FROM 
--     sys.foreign_keys AS fk
-- JOIN 
--     sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
-- WHERE 
--     fk.referenced_object_id = OBJECT_ID('tblStore');

SELECT top 20 * from tblOrder

DECLARE @sql NVARCHAR(MAX);

-- Generate and execute DROP CONSTRAINT commands
-- This part collects all constraints referencing 'tblStore' and builds SQL to drop them
SELECT @sql = STRING_AGG('ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) 
    + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) 
    + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';', ' ')
FROM sys.foreign_keys
WHERE referenced_object_id = OBJECT_ID('tblStore');

-- Check if there were any constraints and if so, execute the drop statements
IF @sql IS NOT NULL
BEGIN
    EXEC sp_executesql @sql;
    PRINT 'Foreign key constraints dropped.';
END
ELSE
    PRINT 'No foreign key constraints to drop.';

-- Now drop the table
SET @sql = N'DROP TABLE tblStore';
EXEC sp_executesql @sql;
PRINT 'Table tblStore dropped.';

SELECT * FROM fn_my_permissions(NULL, 'DATABASE');

SELECT IS_MEMBER('db_owner'), IS_MEMBER('db_ddladmin');



SELECT *
FROM tblProductStore ps
LEFT JOIN tblStore s ON ps.StoreID = s.StoreID
WHERE s.StoreID IS NULL;

SELECT StoreName, COUNT(*) AS Count
FROM tblStore
GROUP BY StoreName
HAVING COUNT(*) > 1;


select * from tblEmployee



-- Query to retrieve count of employees that occupy each position --

SELECT et.EmployeeTitle, COUNT(e.EmployeeID) AS EmployeeCount
FROM tblEmployee e
JOIN tblEmployeeTitle et on e.EmployeeTitleID = et.EmployeeTitleID
GROUP BY EmployeeTitle
