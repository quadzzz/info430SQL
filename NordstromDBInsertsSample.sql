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

insert into tblProductType (ProductTypeDesc) values ('SwimWear');
insert into tblProductType (ProductTypeDesc) values ('Loungewear');
insert into tblProductType (ProductTypeDesc) values ('Athletic');
insert into tblProductType (ProductTypeDesc) values ('Dining');
insert into tblProductType (ProductTypeDesc) values ('Bedding');
insert into tblProductType (ProductTypeDesc) values ('Jackets&Blazers');
insert into tblProductType (ProductTypeDesc) values ('Dresses');
insert into tblProductType (ProductTypeDesc) values ('Coats');
insert into tblProductType (ProductTypeDesc) values ('Boots');
insert into tblProductType (ProductTypeDesc) values ('HomeDecor');
insert into tblProductType (ProductTypeDesc) values ('Bath');
insert into tblProductType (ProductTypeDesc) values ('HairCare');
insert into tblProductType (ProductTypeDesc) values ('Heels');
insert into tblProductType (ProductTypeDesc) values ('Jeans&Denim');
insert into tblProductType (ProductTypeDesc) values ('Sweaters');
insert into tblProductType (ProductTypeDesc) values ('T-shirts');
insert into tblProductType (ProductTypeDesc) values ('Activewear');
insert into tblProductType (ProductTypeDesc) values ('Sneakers');
insert into tblProductType (ProductTypeDesc) values ('Intimites');
insert into tblProductType (ProductTypeDesc) values ('Comfort');
insert into tblProductType (ProductTypeDesc) values ('Dresses');
insert into tblProductType (ProductTypeDesc) values ('HomeDecor');
insert into tblProductType (ProductTypeDesc) values ('Makeup');
insert into tblProductType (ProductTypeDesc) values ('Kitchen');
insert into tblProductType (ProductTypeDesc) values ('Flats');
insert into tblProductType (ProductTypeDesc) values ('Sleepwear');
insert into tblProductType (ProductTypeDesc) values ('Shorts');
insert into tblProductType (ProductTypeDesc) values ('Sweatshirts&Hoodies');


ALTER TABLE tblCustomerType
DROP COLUMN LoyaltyPoints;

DELETE FROM tblCustomerType
WHERE CustTypeID > 3;

SET IDENTITY_INSERT tblDepartment ON;

insert into tblDepartment (DepartmentID, DepartmentDesc) values (1, 'Shoes');
insert into tblDepartment (DepartmentID, DepartmentDesc) values (2, 'Designer');
insert into tblDepartment (DepartmentID, DepartmentDesc) values (3, 'Clothing');
insert into tblDepartment (DepartmentID, DepartmentDesc) values (4, 'Accessories');
insert into tblDepartment (DepartmentID, DepartmentDesc) values (5, 'Beauty');
insert into tblDepartment (DepartmentID, DepartmentDesc) values (6, 'Home');

INSERT INTO tblBrand (BrandDescription) VALUES ('designer')
SELECT * FROM tblBrand
INSERT INTO tblBrand (BrandDescription) VALUES ('shoe women')
INSERT INTO tblBrand (BrandDescription) VALUES ('shoe men')
INSERT INTO tblBrand (BrandDescription) VALUES ('youth clothing')
INSERT INTO tblBrand (BrandDescription) VALUES ('clothing women')
INSERT INTO tblBrand (BrandDescription) VALUES ('clothing men')
INSERT INTO tblBrand (BrandDescription) VALUES ('denim women')
INSERT INTO tblBrand (BrandDescription) VALUES ('fine jewlery')
INSERT INTO tblBrand (BrandDescription) VALUES ('athletic')
INSERT INTO tblBrand (BrandDescription) VALUES ('plus size women')
INSERT INTO tblBrand (BrandDescription) VALUES ('accessories')
INSERT INTO tblBrand (BrandDescription) VALUES ('youth shoes')
INSERT INTO tblBrand (BrandDescription) VALUES ('cosmetics')
INSERT INTO tblBrand (BrandDescription) VALUES ('home')


use Team8NordstromDB

insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (4, '2022-12-22', 20904.36, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (38, '1985-08-31', 30967.97, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (42, '1986-05-21', 7822.87, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (16, '2001-05-21', 40827.6, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (17, '2002-08-03', 8046.76, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (22, '1999-10-06', 9317.06, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (29, '1990-10-09', 29000.07, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (63, '2019-03-22', 12550.85, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (40, '2002-01-16', 23660.4, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (30, '1983-04-11', 8507.08, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (60, '1992-04-09', 9576.97, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (29, '2023-07-26', 23305.18, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (83, '2023-05-27', 5527.31, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (10, '2009-09-07', 21193.02, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (4, '2002-01-16', 39309.93, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (37, '1988-12-24', 20368.5, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (9, '2008-06-10', 24669.43, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (53, '1989-08-10', 26749.63, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (78, '1984-04-05', 658.11, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));
insert into tblOrder (OrderProductQuantity, OrderDate, OrderTotal, ShippingID, CustID) values (38, '1987-02-21', 7629.06, (SELECT TOP 1 ShippingID FROM tblShipping WHERE ShippingID BETWEEN 1 AND 1000 ORDER BY NEWID()), (SELECT TOP 1 CustID FROM tblCustomer WHERE CustID BETWEEN 2001 AND 3000 ORDER BY NEWID()));

