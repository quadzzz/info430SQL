--1) CONTROL OF FLOW

/*USING CASE STATEMENTS
In programming, we have 3 common structures:
1) Sequential structure - code is processed sequentially from the first line up to the last.
3) conditional or selection structure - Only blocks of code that meet certian conditions are processed
3) Repetition or Looping structure - the same block is executed repeatedly until certain codntion becomes false.

CASE statements are similar to IF statements but are more preferrable if you have multiple alternatives
IF...ELE IF -- ELSE IF.. ELSE

Example: The RFM model is quite commonly used in marketing to measure customer value
R: Recency -- how recently a customer visited
F: Frequency -- how often a customer buys
M: Monetary value -- how much they spend
Using sample store data, generate the following example
High value (M): >20000 total order valued
Medium vale (M): 10000 to 19999
Low Value (M): <10000
Frequency: >20 more frequent
Frequency: <20 less frequent
Recency: >2019-12-31 More recent
Recency: < 2020-01-0 Less recent

Count the corresponding number of customers
*/

use SampleSuperStore_db
GO

SELECT TOP 10 * FROM tblCUSTOMER
GO

SELECT TOP 10 * FROM tblPRODUCT
GO

SELECT TOP 10 * FROM tblPRODUCT_TYPE
GO

SELECT * INTO tblCUST_COPY
FROM tblCUSTOMER
GO

SELECT TOP 10 * FROM tblCUST_COPY
GO


SELECT(CASE
		--first case
		WHEN numOrders >20 AND RecentOrderDate >'2019-12-31' AND Sales >20000
		THEN 'High value, most frequent, most recent buyers'
		--second case
		WHEN numOrders <20 AND RecentOrderDate >'2019-12-31' AND Sales >20000
		THEN 'High value, less frequent, most recent buyers'
		WHEN numOrders >20 AND RecentOrderDate <'2020-01-01' AND Sales >20000
		THEN 'High value, less frequent,and less recent buyers'
		WHEN numOrders <20 AND RecentOrderDate <'2020-01-01' AND Sales >20000
		THEN 'High value, less frequent,and less recent buyers'
		WHEN numOrders >20 AND RecentOrderDate >'2019-12-31' AND Sales <20000
		THEN 'Low value, most frequent, most recent buyers'
		WHEN numOrders <20 AND RecentOrderDate >'2019-12-31' AND Sales <20000
		THEN 'Low value, less frequent, most recent buyers'
		WHEN numOrders >20 AND RecentOrderDate <'2020-01-01' AND Sales <20000
		THEN 'Low value, less frequent,and less recent buyers'
		ELSE 'UnCategorized Customer Group'
	END) AS customerType, COUNT(*) as NumCustomers, SUM(Sales) AS SegSales

	--ORDER OS SQL CLAUSES: Whatever is at the top cannoy see whatever is declared below it
	/*1) FROM
	2) WHERE
	3) GROUP BY
	4) HAVING
	5) SELECT
	6) ORDER BY
	7) LIMIT/TOP
	*/
FROM (SELECT CustomerID, COUNT(*) AS numOrders, MAX(OrderDate) AS RecentOrderDate, SUM(Calc_OrderTotal) AS Sales
FROM tblORDER
GROUP BY CustomerID) AS temp

GROUP BY
(CASE
		--first case
		WHEN numOrders >20 AND RecentOrderDate >'2019-12-31' AND Sales >20000
		THEN 'High value, most frequent, most recent buyers'
		--second case
		WHEN numOrders <20 AND RecentOrderDate >'2019-12-31' AND Sales >20000
		THEN 'High value, less frequent, most recent buyers'
		WHEN numOrders >20 AND RecentOrderDate <'2020-01-01' AND Sales >20000
		THEN 'High value, less frequent,and less recent buyers'
		WHEN numOrders <20 AND RecentOrderDate <'2020-01-01' AND Sales >20000
		THEN 'High value, less frequent,and less recent buyers'
		WHEN numOrders >20 AND RecentOrderDate >'2019-12-31' AND Sales <20000
		THEN 'Low value, most frequent, most recent buyers'
		WHEN numOrders <20 AND RecentOrderDate >'2019-12-31' AND Sales <20000
		THEN 'Low value, less frequent, most recent buyers'
		WHEN numOrders >20 AND RecentOrderDate <'2020-01-01' AND Sales <20000
		THEN 'Low value, less frequent,and less recent buyers'
		ELSE 'UnCategorized Customer Group'
	END)
--2). MODULARITY: STORED PROCEDURES
	-- Stored procedures are database objects and are developed and precompiled for
	--subsequent use.
	/*
	--Cornerstones of Object-Oriented Programming applicable to stored procedures:
	a). Modularity: Program code can be broken down into smaller modular components
	(we will see this on Wednesday with the use of nested stored procedures)
	b). Code reuse: code is created once and then reused as desired. Usually,
	this is achieved by use of classes and methods in object-oriented programming.
	Likewise, when we define stored procedures with parameters and compile them,
	we can use the stored procedure whenever we want just executing it and passing
	values to those parameters.
	*/
	--Typology of Methors: Parameterized vs. Non-parameterized
	---Eiether of these can be value-returnin or void.
	--For stored procedures, we will focuse on parameterized ones ony.
	--Stored procedures that retrieve data from the database (i.e., using 'SELECT'
	--statement are value-returning, while those that post data or modify data in 
	--the database (INSERT, UPDATE, DELETE) are void stored procedures.
	--=============================================================
	/* Value-returning Procedure
	---------------------------------------------------------------
	For SELECT queries, we need value-returning procedures
	For Action queries (INSERT, UPDATE, DELETE), we use void procedures
	*/

	/* Stored Procedure for SELECT Statement
	Example: Return the name of cusomer and Vaue of customer order.
	Should take customer city and customer state as parameters
	*/

	/* STEP 1: Determine required tables */
	--We need tblCustomer and tblOrder
	SELECT TOP 5 * FROM tblCUSTOMER
	SELECT TOP 5 * FROM tblORDER
	GO

	/* STEP 2: DEFINE The Stored procedure */
	CREATE OR ALTER Procedure uspSelectCustOrder
		(@C_city VARCHAR(50), @C_state VARCHAR(50))
		AS
		BEGIN
		--define select query
			SELECT c.Lname, c.Fname, o.CustomerID, SUM(o.Calc_OrderTotal) AS OrderTotal
			FROM tblCUSTOMER c JOIN tblORDER o ON c.CustomerID = o.CustomerID
			--where condition with parameter values
			WHERE c.CustCity = @C_city
				AND c.CustState = @C_state
			GROUP BY c.Lname, c.Fname, o.CustomerID
			--value-returning
			RETURN;
		END
	GO

	/* STEP 3: Compile the procedure */
	--i.e, run the procedure code to create the procedure as an object stored in the database

	/*STEP 4: test the procedure */
	--Execute the procedure supplying representative values for the parameters
	--Note: parameter values can be provided as literals  or pass as variables

	--a) As Literals
	 EXEC uspSelectCustOrder 'Mobile', 'Alabama, AL'
	 EXEC uspSelectCustOrder 'Seattle', 'Washington, WA'

	 --b) As variables
		DECLARE @city VARCHAR(50), @state VARCHAR(50);
		SET @city = 'Portland'
		SET @state = 'Oregon, OR'
		EXEC uspSelectCustOrder @city, @state

/* VOid Stored Procedures
=====================================================
ACTION Queries: No need to return a value - can use Void stored procedures
*/
/* 
1) INSERT Action Query
*/
--STEP 1: Determine tables and columns required
--Note: ProductID is autogenerated
SELECT TOP 5 * FROM tblPRODUCT
SELECT TOP 5 * FROM tblPRODUCT_TYPE
GO
--STEP 2: Define the procedure
CREATE OR ALTER PROCEDURE uspInsertProduct
	--parameters
	@P_id INT, @P_name VARCHAR(60), @PT_name VARCHAR(50), 
	@P_desc VARCHAR(100), @P_price NUMERIC(10,2)
	AS
	BEGIN
		---lookup ProdTypeID
		DECLARE @PT_id INT;
		--assign value to @PT_id
		SET @PT_id = (SELECT ProdTypeID FROM
						tblPRODUCT_TYPE
						WHERE ProdTypeName = @PT_name)
		--Define Insert Query
		INSERT INTO tblPRODUCT(ProductID, ProductName, ProdTypeID, ProductDescr, Price)
		VALUES(@P_id, @P_name, @PT_id, @P_desc,@P_price)
	END
GO

--STEP 3: Compile the Procedure
--Run the procedure code


--STEP 4: Test the procedure
SELECT TOP 5 * FROM tblPRODUCT_TYPE
SELECT TOP 1 * FROM tblPRODUCT
ORDER BY ProductID  DESC

EXEC uspInsertProduct 1517, 'Test Product', 'Kitchen','Cooking skillet',55.00

--See the inserted row
SELECT TOP 1 * FROM tblPRODUCT
ORDER BY ProductID  DESC



