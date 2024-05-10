CREATE DATABASE Team8NordstromDB; 


DROP TABLE IF EXISTS tblCustomerType;
CREATE TABLE tblCustomerType (
    CustTypeID INT PRIMARY KEY IDENTITY(1,1),
    LoyaltyPoints INT, 
    CustTypeDescription VARCHAR(255)
);

DROP TABLE IF EXISTS tblCustomer;
CREATE TABLE tblCustomer (
     CustID INT PRIMARY KEY IDENTITY(1,1),
     CustFName VARCHAR(50) NOT NULL,
     CustLName VARCHAR(50) NOT NULL,
     CustEmail VARCHAR(50),
     CustAddress VARCHAR(50),
     CustDateOfBirth DATE,
     CustTypeID INT,
     FOREIGN KEY (CustTypeID) REFERENCES tblCustomerType(CustTypeID),
);


DROP TABLE IF EXISTS tblShipping;
CREATE TABLE tblShipping (
    ShippingID INT PRIMARY KEY IDENTITY(1,1),
    ShippingAddress VARCHAR(255),
    ShippingState VARCHAR(50),
    ShippingZip VARCHAR(5),
);

DROP TABLE IF EXISTS tblDiscount;
CREATE TABLE tblDiscount (
    DiscountID INT PRIMARY KEY IDENTITY(1,1),
    DiscountDescription VARCHAR(255)
);

CREATE TABLE tblProductType (
    ProductTypeID INT PRIMARY KEY IDENTITY(1,1),
    ProductTypeDesc VARCHAR(255)
);


CREATE TABLE tblBrand (
    BrandID INT PRIMARY KEY IDENTITY(1,1),
    BrandDescription VARCHAR(255),
);

CREATE TABLE tblEmployeeType (
    EmployeeTypeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeTypeDesc VARCHAR(255)
);

CREATE TABLE tblDepartment (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentDesc VARCHAR(255)
);

DROP TABLE IF EXISTS tblOrder;
CREATE TABLE tblOrder (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustID INT NOT NULL,
    OrderProductQuantity INT NOT NULL,
    OrderDate DATE NOT NULL,
    OrderTotal DECIMAL(10,2),
    ShippingID INT,
    FOREIGN KEY (CustID) REFERENCES tblCustomer(CustID),
    FOREIGN KEY (ShippingID) REFERENCES tblShipping(ShippingID)
);


CREATE TABLE tblProduct (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    BrandID INT,
    ProductTypeID INT,
    ProductName VARCHAR(50),
    ProductPrice DECIMAL(10,2),
    StockQuantity INT,
    FOREIGN KEY (BrandID) REFERENCES tblBrand(BrandID),
    FOREIGN KEY (ProductTypeID) REFERENCES tblProductType(ProductTypeID),
);

CREATE TABLE tblOrderProduct (
    OrderProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    OrderID INT,
    ProductQuantity INT,
    ListPrice DECIMAL(10,2),
    DiscountID INT,
    FOREIGN KEY (ProductID) REFERENCES tblProduct(ProductID),
    FOREIGN KEY (OrderID) REFERENCES tblOrder(OrderID),
    FOREIGN KEY (DiscountID) REFERENCES tblDiscount(DiscountID)
);


CREATE TABLE tblStore (
    StoreID INT PRIMARY KEY IDENTITY(1,1),
    Store VARCHAR(50),
    StoreAddress VARCHAR(50),
    StoreDivision VARCHAR(50)
);


CREATE TABLE tblProductStore (
    ProductStoreID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    StoreID INT,
    FOREIGN KEY (ProductID) REFERENCES tblProduct(ProductID),
    FOREIGN KEY (StoreID) REFERENCES tblStore(StoreID)
);

CREATE TABLE tblEmployee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeTypeID INT,
    StoreID INT,
    DepartmentID INT,
    EmployeeName VARCHAR(50),
    EmployeePhone NVARCHAR(50),
    EmployeeEmail NVARCHAR(50),
    EmployeeDateOfBirth DATE,
    FOREIGN KEY (EmployeeTypeID) REFERENCES tblEmployeeType(EmployeeTypeID),
    FOREIGN KEY (StoreID) REFERENCES tblStore(StoreID),
    FOREIGN KEY (DepartmentID) REFERENCES tblDepartment(DepartmentID)
);





