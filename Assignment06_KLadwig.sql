--*************************************************************************--
-- Title: Assignment06
-- Author: KLadwig
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-08-16,KLadwig,Answered questions 1-4
-- 2022-08-17,KLadwig,Answered questions 5-10
-- 2022-08-17,KLadwig,Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KLadwig')
	 Begin 
	  Alter Database [Assignment06DB_KLadwig] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KLadwig;
	 End
	Create Database Assignment06DB_KLadwig;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KLadwig;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- 1/ Create view for Categories table
GO
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
	SELECT CategoryID
		,CategoryName
	FROM dbo.Categories;
GO
-- SELECT * FROM vCategories;

-- 2/ Create view for Products table
CREATE VIEW vProducts
WITH SCHEMABINDING
AS
	SELECT ProductID
		,ProductName
        ,CategoryID
        ,UnitPrice
	FROM dbo.Products;
GO
-- SELECT * FROM vProducts;

-- 3/ Create view for Employees table
CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT EmployeeID
		,EmployeeFirstName
        ,EmployeeLastName
        ,ManagerID
	FROM dbo.Employees;
GO
-- SELECT * FROM vEmployees;

-- 4/ Create view for Inventories table
CREATE VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT InventoryID
		,InventoryDate
        ,EmployeeID
        ,ProductID
        ,[Count]
	FROM dbo.Inventories;
GO
-- SELECT * FROM vInventories;

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- 1/ Restrict Categories table permissions and grant vCategories view permissions
Deny Select On Categories to Public;
Grant Select On vCategories to Public;

-- 2/ Restrict Products table permissions and grant vProducts view permissions
Deny Select On Products to Public;
Grant Select On vProducts to Public;

-- 3/ Restrict Employees table permissions and grant vEmployees view permissions
Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

-- 4/ Restrict Inventories table permissions and grant vInventories view permissions
Deny Select On Inventories to Public;
Grant Select On vInventories to Public;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

/*
1/ See all columns in Category and Product tables
SELECT *
FROM vCategories
SELECT *
FROM vProducts

2/ Refine columns and add table aliases
SELECT CategoryName
FROM vCategories AS c
SELECT ProductName
	,UnitPrice
FROM vProducts AS p

3/ Add join
SELECT c.CategoryName
	,p.ProductName
	,p.UnitPrice
FROM vCategories AS c
INNER JOIN vProducts AS p
	ON c.CategoryId = p.CategoryId

4/ Add CREATE VIEW and ORDER BY clauses
CREATE
VIEW vProductsByCategories
AS
    SELECT TOP 10000
        ,c.CategoryName
        ,p.ProductName
        ,p.UnitPrice
    FROM vCategories AS c
    INNER JOIN vProducts AS p
        ON c.CategoryId = p.CategoryId
    ORDER BY c.CategoryName ASC
        ,p.ProductName ASC;
GO
*/

-- Answer:
CREATE VIEW vProductsByCategories
AS
    SELECT TOP 10000
        c.CategoryName
        ,p.ProductName
        ,p.UnitPrice
    FROM vCategories AS c
    INNER JOIN vProducts AS p
        ON c.CategoryId = p.CategoryId
    ORDER BY c.CategoryName ASC
        ,p.ProductName ASC;
GO
-- SELECT * FROM vProductsByCategories;

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

/*
1/ Need: ProductName, InventoryDate, Count

2/ Review Product and Inventory Tables
SELECT *
FROM vProducts;
Select *
From vInventories;

3/ Refine Columns
SELECT p.ProductName
	,p.ProductID
FROM vProducts AS p
Select i.ProductID
	,i.InventoryDate
	,i.Count
From vInventories AS i

4/ Add JOIN om ProductID
SELECT p.ProductName
	,p.ProductID
	,i.ProductID
	,i.InventoryDate
	,i.Count
FROM vProducts AS p
INNER JOIN vInventories AS i
	ON p.ProductID = i.ProductID

5/ Remove ProductID, add CREATE VIEW, and add ORDER BY clause
CREATE VIEW vInventoriesByProductsByDates
AS
    SELECT TOP 10000
        p.ProductName
        ,i.InventoryDate
        ,i.Count
    FROM vProducts AS p
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    ORDER BY p.ProductName ASC
        ,i.InventoryDate ASC
        ,i.Count ASC;
GO
*/

-- Answer:
CREATE VIEW vInventoriesByProductsByDates
AS
    SELECT TOP 10000
        p.ProductName
        ,i.InventoryDate
        ,i.Count
    FROM vProducts AS p
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    ORDER BY p.ProductName ASC
        ,i.InventoryDate ASC
        ,i.Count ASC;
GO
-- SELECT * FROM vInventoriesByProductsByDates;

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/*
1/ Need: InventoryDate, Employee Name

2/ Look at Inventory and Employees tables
Select * From vInventories;
Select * From vEmployees;

3/ Refine Categories and add table aliases
SELECT DISTINCT i.InventoryDate
    ,AVG(i.EmployeeID) AS NewEmployeeID
FROM vInventories AS i
GROUP BY i.InventoryDate

SELECT e.EmployeeID
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
FROM vEmployees AS e

4/ Add JOIN
SELECT DISTINCT i.InventoryDate
    ,i.EmployeeID
    ,e.EmployeeID
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
FROM vInventories AS i
INNER JOIN vEmployees AS e
    ON i.EmployeeID = e.EmployeeID

5/ Add CONCT functions, remove employee ID, add CREATE VIEW, and add ORDER BY
CREATE VIEW vInventoriesByEmployeesByDates
AS
    SELECT DISTINCT TOP 10000
        i.InventoryDate
        ,CONCAT(e.EmployeeFirstName,CONCAT(' ',e.EmployeeLastName)) AS EmployeeName
    FROM vInventories AS i
    INNER JOIN vEmployees AS e
        ON i.EmployeeID = e.EmployeeID
    ORDER BY i.InventoryDate ASC;
GO
*/

-- Answer:
CREATE VIEW vInventoriesByEmployeesByDates
AS
    SELECT DISTINCT TOP 10000
        i.InventoryDate
        ,CONCAT(e.EmployeeFirstName,CONCAT(' ',e.EmployeeLastName)) AS EmployeeName
    FROM vInventories AS i
    INNER JOIN vEmployees AS e
        ON i.EmployeeID = e.EmployeeID
    ORDER BY i.InventoryDate ASC;
GO
-- SELECT * FROM vInventoriesByEmployeesByDates;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

/*
1/ Need: CategoryName, ProductName, InventoryDate, Count

2/ Look at Category, Product, and Inventory tables
Select * From vCategories;
Select * From vProducts;
Select * From vInventories;

3/ Refine Columns and add aliases
SELECT c.CategoryName
    ,c.CategoryID
FROM vCategories AS c;

SELECT p.ProductName
    ,p.CategoryID
    ,p.ProductID
FROM vProducts AS p;

SELECT i.ProductID
    ,i.InventoryDate
    ,i.Count
FROM vInventories AS i;

4/ JOIN Products and Categories tables
SELECT p.ProductName
    ,p.ProductID
    ,p.CategoryID
    ,c.CategoryID
    ,c.CategoryName
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID

5/ JOIN with Inventories table
SELECT p.ProductName
    ,p.CategoryID
    ,c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,i.ProductID
    ,i.InventoryDate
    ,i.Count
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID
INNER JOIN vInventories AS i
    ON p.ProductID = i.ProductID

6/ Rearrange columns, remove IDs, add CREATE VIEW, and add ORDER BY clause
CREATE VIEW vInventoriesByProductsByCategories
AS
    SELECT TOP 10000
        c.CategoryName
        ,p.ProductName
        ,i.InventoryDate
        ,i.Count
    FROM vProducts AS p
    INNER JOIN vCategories AS c
        ON p.CategoryID = c.CategoryID
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    ORDER BY c.CategoryName ASC
        ,p.ProductName ASC
        ,i.InventoryDate ASC
        ,i.Count ASC;
*/

-- Answer:
CREATE VIEW vInventoriesByProductsByCategories
AS
    SELECT TOP 10000
        c.CategoryName
        ,p.ProductName
        ,i.InventoryDate
        ,i.Count
    FROM vProducts AS p
    INNER JOIN vCategories AS c
        ON p.CategoryID = c.CategoryID
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    ORDER BY c.CategoryName ASC
        ,p.ProductName ASC
        ,i.InventoryDate ASC
        ,i.Count ASC;
GO
-- SELECT * FROM vInventoriesByProductsByCategories;

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan

/*
1/ Needs: CategoryName, ProductName, Inventory Date, Count, and EmployeeName

2/ Look at Category, Product, and Inventory tables
Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Select * From vEmployees;

3/ Refine Columns and add aliases
SELECT c.CategoryName
    ,c.CategoryID
FROM vCategories AS c;

SELECT p.ProductName
    ,p.CategoryID
    ,p.ProductID
FROM vProducts AS p;

SELECT i.ProductID
    ,i.InventoryDate
    ,i.Count
    ,i.EmployeeID
FROM vInventories AS i;

SELECT e.EmployeeID
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
FROM vEmployees AS e;

4/ JOIN Products and Categories tables
SELECT p.ProductName
    ,p.ProductID
    ,p.CategoryID
    ,c.CategoryID
    ,c.CategoryName
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID

5/ JOIN with Inventories table
SELECT p.ProductName
    ,p.CategoryID
    ,c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,i.ProductID
    ,i.InventoryDate
    ,i.Count
    ,i.EmployeeID
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID
INNER JOIN Inventories AS i
    ON p.ProductID = i.ProductID

6/ JOIN with employees table
SELECT p.ProductName
    ,p.CategoryID
    ,c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,i.ProductID
    ,i.InventoryDate
    ,i.Count
    ,i.EmployeeID
    ,e.EmployeeID
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID
INNER JOIN vInventories AS i
    ON p.ProductID = i.ProductID
INNER JOIN vEmployees AS e
    ON i.EmployeeID = e.EmployeeID;

7/ Rearrange columns, remove IDs, add CONCAT, add CREATE VIEW, and add ORDER BY clause
CREATE VIEW vInventoriesByProductsByEmployees
AS
    SELECT TOP 10000
        c.CategoryName
        ,p.ProductName
        ,i.InventoryDate
        ,i.Count
        ,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS EmployeeName
    FROM vProducts AS p
    INNER JOIN vCategories AS c
        ON p.CategoryID = c.CategoryID
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    INNER JOIN vEmployees AS e
        ON i.EmployeeID = e.EmployeeID
    ORDER BY i.InventoryDate ASC
        ,c.CategoryName ASC
        ,p.ProductName ASC
        ,EmployeeName ASC;
GO
*/

-- Answer:
CREATE VIEW vInventoriesByProductsByEmployees
AS
    SELECT TOP 10000
        c.CategoryName
        ,p.ProductName
        ,i.InventoryDate
        ,i.Count
        ,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS EmployeeName
    FROM vProducts AS p
    INNER JOIN vCategories AS c
        ON p.CategoryID = c.CategoryID
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    INNER JOIN vEmployees AS e
        ON i.EmployeeID = e.EmployeeID
    ORDER BY i.InventoryDate ASC
        ,c.CategoryName ASC
        ,p.ProductName ASC
        ,EmployeeName ASC;
GO
-- SELECT * FROM vInventoriesByProductsByEmployees;

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:
-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

/*
1/ Needs: CategoryName, ProductName, Inventory Date, Count, and EmployeeName

2/ Look at Category, Product, and Inventory tables
Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Select * From vEmployees;

3/ Refine Columns and add aliases
SELECT c.CategoryName
    ,c.CategoryID
FROM vCategories AS c;

SELECT p.ProductName
    ,p.CategoryID
    ,p.ProductID
FROM vProducts AS p;

SELECT i.ProductID
    ,i.InventoryDate
    ,i.Count
    ,i.EmployeeID
FROM vInventories AS i;

SELECT e.EmployeeID
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
FROM vEmployees AS e;

4/ JOIN Products and Categories tables
SELECT p.ProductName
    ,p.ProductID
    ,p.CategoryID
    ,c.CategoryID
    ,c.CategoryName
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID

5/ JOIN with Inventories table
SELECT p.ProductName
    ,p.CategoryID
    ,c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,i.ProductID
    ,i.InventoryDate
    ,i.Count
    ,i.EmployeeID
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID
INNER JOIN vInventories AS i
    ON p.ProductID = i.ProductID

6/ JOIN with employees table
SELECT p.ProductName
    ,p.CategoryID
    ,c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,i.ProductID
    ,i.InventoryDate
    ,i.Count
    ,i.EmployeeID
    ,e.EmployeeID
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID
INNER JOIN vInventories AS i
    ON p.ProductID = i.ProductID
INNER JOIN vEmployees AS e
    ON i.EmployeeID = e.EmployeeID;

7/ Rearrange columns, remove IDs, add CONCAT, and add ORDER BY clause
SELECT c.CategoryName
    ,p.ProductName
    ,i.InventoryDate
    ,i.Count
    ,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS EmployeeName
FROM vProducts AS p
INNER JOIN vCategories AS c
    ON p.CategoryID = c.CategoryID
INNER JOIN vInventories AS i
    ON p.ProductID = i.ProductID
INNER JOIN vEmployees AS e
    ON i.EmployeeID = e.EmployeeID
ORDER BY i.InventoryDate ASC
    ,c.CategoryName ASC
    ,p.ProductName ASC;

8/ Add WHERE clause with Subquery and CREATE VIEW
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
    SELECT TOP 10000
        c.CategoryName
        ,p.ProductName
        ,i.InventoryDate
        ,i.Count
        ,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS EmployeeName
    FROM vProducts AS p
    INNER JOIN vCategories AS c
        ON p.CategoryID = c.CategoryID
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    INNER JOIN vEmployees AS e
        ON i.EmployeeID = e.EmployeeID
    WHERE p.ProductID IN (
        SELECT ProductID
        FROM Products
        WHERE ProductName IN ('Chai'
            ,'Chang')
        )
    ORDER BY i.InventoryDate ASC
        ,c.CategoryName ASC
        ,p.ProductName ASC;
GO
*/

-- Answer:
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
    SELECT TOP 10000
        c.CategoryName
        ,p.ProductName
        ,i.InventoryDate
        ,i.Count
        ,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS EmployeeName
    FROM vProducts AS p
    INNER JOIN vCategories AS c
        ON p.CategoryID = c.CategoryID
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    INNER JOIN vEmployees AS e
        ON i.EmployeeID = e.EmployeeID
    WHERE p.ProductID IN (
        SELECT ProductID
        FROM Products
        WHERE ProductName IN ('Chai'
            ,'Chang')
        )
    ORDER BY i.InventoryDate ASC
        ,c.CategoryName ASC
        ,p.ProductName ASC;
GO
-- SELECT * FROM vInventoriesForChaiAndChangByEmployees;

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

/*
1/ Need: Manager (First and Last Name) and Employee (First and Last Name)

2/ Look at employees table
Select * From vEmployees;

3/ Self join table on Manager ID and Employee ID
SELECT e1.EmployeeID
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
    ,e.ManagerID
    ,m.EmployeeID
    ,m.EmployeeFirstName
    ,m.EmployeeLastName
    ,m.ManagerID
FROM vEmployees AS e
INNER JOIN vEmployees AS m
    ON e.ManagerID = m.EmployeeID

4/ rearrange columns and add aliases
SELECT (m.EmployeeFirstName + ' ' + m.EmployeeLastName) AS Manager
    ,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS Employee
FROM vEmployees AS e
INNER JOIN vEmployees AS m
    ON e.ManagerID = m.EmployeeID

5/ add ORDER BY clause and CREATE VIEW
CREATE VIEW vEmployeesByManager
AS
    SELECT TOP 10000
        (m.EmployeeFirstName + ' ' + m.EmployeeLastName) AS Manager
        ,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS Employee
    FROM vEmployees AS e
    INNER JOIN vEmployees AS m
        ON e.ManagerID = m.EmployeeID
    ORDER BY Manager ASC
        ,Employee ASC;
GO
*/

-- Answer:
CREATE VIEW vEmployeesByManager
AS
    SELECT TOP 10000
        (m.EmployeeFirstName + ' ' + m.EmployeeLastName) AS Manager
        ,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS Employee
    FROM vEmployees AS e
    INNER JOIN vEmployees AS m
        ON e.ManagerID = m.EmployeeID
    ORDER BY Manager ASC
        ,Employee ASC;
GO
-- SELECT * FROM vEmployeesByManager;

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

/*
1/ Need:
    - CategoryID and CategoryName from Categories
    - ProductID, ProductName, and UnitPrice from Products
    - InventoryID, InventoryDate, and Count from Inventories
    - EmployeeID and EmployeeFirstName + EmployeeLastName from Employees
    - Employee Manager Name

2/ Begin with SELECT STATEMENT for Categories table
SELECT c.CategoryID
    ,c.CategoryName
FROM vCategories AS c;

3/ JOIN with Products on CategoryID
SELECT c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,p.ProductName
    ,p.UnitPrice
FROM vCategories AS c
INNER JOIN vProducts AS p
    ON c.CategoryID = p.CategoryID;

4/ JOIN with Inventories on ProductID
SELECT c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,p.ProductName
    ,p.UnitPrice
    ,i.InventoryID
    ,i.InventoryDate
    ,i.Count
FROM vCategories AS c
INNER JOIN vProducts AS p
    ON c.CategoryID = p.CategoryID
INNER JOIN vInventories AS i
    ON p.ProductID = i.ProductID;

5/ JOIN with Employees on EmployeeID
SELECT c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,p.ProductName
    ,p.UnitPrice
    ,i.InventoryID
    ,i.InventoryDate
    ,i.Count
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
    ,e.ManagerID
FROM vCategories AS c
INNER JOIN vProducts AS p
    ON c.CategoryID = p.CategoryID
INNER JOIN vInventories AS i
    ON p.ProductID = i.ProductID
INNER JOIN vEmployees AS e
    ON i.EmployeeID = e.EmployeeID;

6/ SELF JOIN with Employees on ManagerID
SELECT c.CategoryID
    ,c.CategoryName
    ,p.ProductID
    ,p.ProductName
    ,p.UnitPrice
    ,i.InventoryID
    ,i.InventoryDate
    ,i.Count
    ,e.EmployeeID
    ,e.EmployeeFirstName
    ,e.EmployeeLastName
    ,e.ManagerID
    ,m.EmployeeFirstName AS ManagerFirstName
    ,m.EmployeeLastName AS ManagerLastName
FROM vCategories AS c
INNER JOIN vProducts AS p
    ON c.CategoryID = p.CategoryID
INNER JOIN vInventories AS i
    ON p.ProductID = i.ProductID
INNER JOIN vEmployees AS e
    ON i.EmployeeID = e.EmployeeID
INNER JOIN vEmployees AS m
    ON e.ManagerID = m.EmployeeID;

7/ Add CREATE VIEW, ORDER BY, and concat name fields
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
    SELECT c.CategoryID
        ,c.CategoryName
        ,p.ProductID
        ,p.ProductName
        ,p.UnitPrice
        ,i.InventoryID
        ,i.InventoryDate
        ,i.Count
        ,e.EmployeeID
        ,e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
        ,e.ManagerID
        ,m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager
    FROM vCategories AS c
    INNER JOIN vProducts AS p
        ON c.CategoryID = p.CategoryID
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    INNER JOIN vEmployees AS e
        ON i.EmployeeID = e.EmployeeID
    INNER JOIN vEmployees AS m
        ON e.ManagerID = m.EmployeeID
    ORDER BY c.CategoryName
        ,p.ProductName
        ,i.InventoryID
        Employee;
GO
*/

-- Answer:
-- DROP VIEW vInventoriesByProductsByCategoriesByEmployees
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
    SELECT TOP 10000
        c.CategoryID
        ,c.CategoryName
        ,p.ProductID
        ,p.ProductName
        ,p.UnitPrice
        ,i.InventoryID
        ,i.InventoryDate
        ,i.Count
        ,e.EmployeeID
        ,e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
        ,e.ManagerID
        ,m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager
    FROM vCategories AS c
    INNER JOIN vProducts AS p
        ON c.CategoryID = p.CategoryID
    INNER JOIN vInventories AS i
        ON p.ProductID = i.ProductID
    INNER JOIN vEmployees AS e
        ON i.EmployeeID = e.EmployeeID
    INNER JOIN vEmployees AS m
        ON e.ManagerID = m.EmployeeID
    ORDER BY c.CategoryName
        ,p.ProductName
        ,i.InventoryID
        ,Employee;
GO
-- SELECT * FROM vInventoriesByProductsByCategoriesByEmployees;

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/