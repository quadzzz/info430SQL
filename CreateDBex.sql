-- CREATE DATABASE
/*
Obtaining Data:
1) Real-world data from various sources depending on your topic
2) Fictitious or synthetic data using a tool like Mockaroo.com
3). Generating your own synthetic or fictitious data (can combine 2 & 3: i.e.,
generate
a few rows and then use Mockaroo to generate more data).
*/
/*
Steps to creating a database
1) Create and select your database to use
2) create data structure
3) Populate the tables with data:
Can use:
- a). Can use Convert CSV to SQL tool:https://www.convertcsv.com/csv-to-sql.htm
--Save your data as CSV files and then use this tool to generate the
SQL, even for thousands of rows
-- No need to write repeative code manually!
--b) Generate sample victitous values and then use mockaroo to generate more.
-- Note: Mockaroo can generate SQL too. Just chnage the format from the
default
CSV to SQL, supply table name, and check the "Include CREATE TABLE" checkbox.
However, what you get is not much customized as that of Convert CSV to SQL
c). If your data is in CSV or text file format, you can use Bulk Insert to
insert the data.
4). Add FK and other constraints
*/
USE master
CREATE DATABASE demoPizza_db
GO
--Select the database
USE demoPizza_db
GO
--Create table structure
--1) Create Categories table
DROP TABLE IF EXISTS Categories
CREATE TABLE Categories(CategoryID INT Primary Key IDENTITY(1,1),
CategoryName VARCHAR(60)
)
--Insert the data
INSERT INTO Categories(CategoryName)
VALUES('Chicken'),
('Classic'),
('Supreme'),
('Veggie')
--verify the data
SELECT * FROM Categories
--Ingredients table
DROP TABLE IF EXISTS Ingredients;
CREATE TABLE Ingredients(


IngredientID INTEGER NOT NULL PRIMARY KEY IDENTITY(1,1)
,IngredientName VARCHAR(50) NOT NULL
);
SET IDENTITY_INSERT Ingredients ON; -- relaxes the identity constraint because w are
--insert values manually.
INSERT INTO Ingredients(IngredientID,IngredientName) VALUES
(1,'Alfredo Sauce')
,(2,'Anchovies')
,(3,'Artichokes')
,(4,'Arugula')
,(5,'Asiago Cheese')
,(6,'Bacon')
,(7,'Barbecue Sauce')
,(8,'Barbecued Chicken')
,(9,'Beef Chuck Roast')
,(10,'Blue Cheese')
,(11,'Brie Carre Cheese')
,(12,'Calabrese Salami')
,(13,'Capocollo')
,(14,'Caramelized Onions')
,(15,'Chicken')
,(16,'Chipotle Sauce')
,(17,'Chorizo Sausage')
,(18,'Cilantro')
,(19,'Coarse Sicilian Salami')
,(20,'Corn')
,(21,'Eggplant')
,(22,'Feta Cheese')
,(23,'Fontina Cheese')
,(24,'Friggitello Peppers')
,(25,'Garlic')
,(26,'Genoa Salami')
,(27,'Goat Cheese')
,(28,'Gorgonzola Piccante Cheese')
,(29,'Gouda Cheese')
,(30,'Green Olives')
,(31,'Green Peppers')
,(32,'Green Peppers')
,(33,'Italian Sausage')
,(34,'Jalapeno Peppers')
,(35,'Kalamata Olives')
,(36,'Luganega Sausage')
,(37,'Mozzarella Cheese')
,(38,'Mushrooms')
,(39,'Nduja Salami')
,(40,'Onions')
,(41,'Oregano')
,(42,'Pancetta')
,(43,'Parmigiano Reggiano Cheese')
,(44,'Pears')
,(45,'Peperoncini verdi')
,(46,'Pepperoni')
,(47,'Pesto Sauce')
,(48,'Pineapple')
,(49,'Plum Tomatoes')
,(50,'Prosciutto')
,(51,'Prosciutto di San Daniele')

,(52,'Provolone Cheese')
,(53,'Red Onions')
,(54,'Red Peppers')
,(55,'Ricotta Cheese')
,(56,'Romano Cheese')
,(57,'Sliced Ham')
,(58,'Smoked Gouda Cheese')
,(59,'Soppressata Salami')
,(60,'Spinach')
,(61,'Sun-dried Tomatoes')
,(62,'Thai Sweet Chilli Sauce')
,(63,'Thyme')
,(64,'Tomatoes')
,(65,'Zucchini');
SET IDENTITY_INSERT Ingredients OFF; --enforces the identity constraint
--verify the insert
SELECT * FROM Ingredients
--Orders table
DROP TABLE IF EXISTS Orders
CREATE TABLE Orders(OrderID INTEGER PRIMARY KEY IDENTITY(1,1),
OrderDate date,
OrderTime Time
)
BULK INSERT Orders
FROM 'C:\Users\sotim\Documents\Spring2024\INFO 430\Labs\Pizza_Sales\orders.csv'
WITH (FORMAT = 'CSV'
, CODEPAGE = 'RAW'
, FIRSTROW = 2
-- , FIELDQUOTE = '\'
, FIELDTERMINATOR = ','
, ROWTERMINATOR = '\n');
--verify the insert
SELECT TOP 10 * FROM Orders
--Pizzas table
DROP TABLE IF EXISTS Pizzas
CREATE TABLE Pizzas(PizzaID INTEGER PRIMARY KEY IDENTITY(1,1),
CategoryID INT,
PizzaName VARCHAR(50)
)
BULK INSERT Pizzas
FROM 'C:\Users\sotim\Documents\Spring2024\INFO 430\Labs\Pizza_Sales\PizzaName.csv'
WITH (FORMAT = 'CSV'
, CODEPAGE = 'RAW'
, FIRSTROW = 2
-- , FIELDQUOTE = '\'
, FIELDTERMINATOR = ','
, ROWTERMINATOR = '\n');
--Verify the insert
SELECT * FROM Pizzas
--FK Constraints
ALTER TABLE Pizzas

ADD CONSTRAINT fk_pizza_cat
FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
