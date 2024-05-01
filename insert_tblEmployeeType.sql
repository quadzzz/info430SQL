USE Team8NordstromDB

INSERT INTO tblEmployeeType (EmployeeTypeDesc) 
VALUES ('full time');
SET IDENTITY_INSERT tblEmployeeType OFF; -- relaxes the identity constraint because w are insert values manually.

insert into tblEmployeeType (EmployeeTypeID, EmployeeTypeDesc) values (1, 'full time');
insert into tblEmployeeType (EmployeeTypeID, EmployeeTypeDesc) values (2, 'part time');
insert into tblEmployeeType (EmployeeTypeID, EmployeeTypeDesc) values (3, 'temporary');
insert into tblEmployeeType (EmployeeTypeID, EmployeeTypeDesc) values (4, 'seasonal');

select * from tblEmployeeType;
WITH Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY EmployeeTypeDesc ORDER BY EmployeeTypeID) as RowNum
    FROM tblEmployeeType
    WHERE EmployeeTypeDesc = 'part time'
)
DELETE FROM Duplicates WHERE RowNum > 0;
