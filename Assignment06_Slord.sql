--*************************************************************************--
-- Title: Assignment06
-- Author: Slord
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2026-03-04, Stephen Lord, Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Slord')
	 Begin 
	  Alter Database [Assignment06DB_Slord] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Slord;
	 End
	Create Database Assignment06DB_Slord;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Slord;

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

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*

1) Review the structure of each table in the database: Categories, Products, Employees, and Inventories

2) Select * From Categories;

	-- Note: Identify available columns in the Categories table: CategoryID and CategoryName --

3)	Create View vCategories
	As
	Select CategoryID, CategoryName
	From Categories;
	Go

	-- Note: Create a view for the Categories table, using the SELECT command for the CategoryID and CategoryName columns FROM the Categories table --
	-- Comment: Need to use SchemaBinding to protect the views from being orphaned 

4)	Create View vCategories
	With SchemaBinding
	As
	Select CategoryID, CategoryName
	From dbo.Categories;
	Go

	--Note: Applied SchemaBinding to the view and issolated to the "dbo" Categories table.

*/

Create View vCategories
With SchemaBinding
As
Select CategoryID, CategoryName
From dbo.Categories;
Go

/*

5) Select * From Products;

	-- Note: Identify available columns in the Products table: ProductID, ProductName, CategoryID, and UnitPrice --

6)	Create View vProducts
	As
	Select ProductID, ProductName, CategoryID, UnitPrice
	From Products;
	Go

	-- Note: Create a view for the Products table, using the SELECT command for the ProductID, ProductName, CategoryID, and UnitPrice columns FROM the Products table --
	-- Comment: Need to use SchemaBinding to protect the views from being orphaned 

7)	Create View vProducts
	With SchemaBinding
	As
	Select ProductID, ProductName, CategoryID, UnitPrice
	From dbo.Products;
	Go

	--Note: Applied SchemaBinding to the view and issolated to the "dbo" Products table.

*/

Create View vProducts
With SchemaBinding
As
Select ProductID, ProductName, CategoryID, UnitPrice
From dbo.Products;
Go

/*

8) Select * From Employees;

	-- Note: Identify available columns in the Employees table: EmployeeID, EmployeeFirstName, EmployeeLastName, and ManagerID --

9)	Create View vEmployees
	As
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From Employees;
	Go

	-- Note: Create a view for the Employees table, using the SELECT command for the EmployeeID, EmployeeFirstName, EmployeeLastName, and ManagerID FROM the Employees table --
	-- Comment: Need to use SchemaBinding to protect the views from being orphaned 

10)	Create View vEmployees
	With SchemaBinding
	As
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From dbo.Employees;
	Go

	--Note: Applied SchemaBinding to the view and issolated to the "dbo" Products table.

*/

Create View vEmployees
With SchemaBinding
As
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees;
Go

/*

11)	Select * From Inventories;

	-- Note: Identify available columns in the Inventories table: InventoryID, InventoryDate, EmployeeID, ProductID, and [Count] --

12)	Create View vInventories
	As
	Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	From Inventories;
	Go

	-- Note: Create a view for the Inventories table, using the SELECT command for the InventoryID, InventoryDate, EmployeeID, ProductID, and [Count] FROM the Inventories table --
	-- Comment: Need to use SchemaBinding to protect the views from being orphaned 

13) Create View vInventories
	With SchemaBinding
	As
	Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	From dbo.Inventories
	Go

	--Note: Applied SchemaBinding to the view and issolated to the "dbo" Products table.

*/

Create View vInventories
With SchemaBinding
As
Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
From dbo.Inventories
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*

1) Created views for four tables/views; Categories, Products, Employees, and Inventories: vCategories, vProducts, vEmployees, and vInventories

2) Applied SchemaBinding to the views and issolated to each "dbo" table; dbo.Categories, dbo.Products, dbo.Employees, and dbo.Inventories

	-- Comment: Need to set permissions that deny access to the selected data 
	-- Comment: Need to set permissions that grant access to the views established

3)  Deny Select On dbo.Categories To Public;	-- Used the DENY SELECT ON command to deny access to the "dbo" Categories table TO PUBLIC users of the database --
	Deny Select On dbo.Products To Public;		-- Used the DENY SELECT ON command to deny access to the "dbo" Products table TO PUBLIC users of the database --
	Deny Select On dbo.Employees To Public;     -- Used the DENY SELECT ON command to deny access to the "dbo" Employees table TO PUBLIC users of the database --
	Deny Select On dbo.Inventories To Public;   -- Used the DENY SELECT ON command to deny access to the "dbo" Inventories table TO PUBLIC users of the database --
	Go

4)  Grant Select On vCategories To Public;      -- Used the GRANT SELECT ON command to grant access to the "view" Categories (vCategories) table TO PUBLIC users of the database --
	Grant Select On vProducts To Public;        -- Used the GRANT SELECT ON command to grant access to the "view" Products (vProducts) table TO PUBLIC users of the database --
	Grant Select On vEmployees To Public;       -- Used the GRANT SELECT ON command to grant access to the "view" Employees (vEmployees) table TO PUBLIC users of the database --
	Grant Select On vInventories To Public;     -- Used the GRANT SELECT ON command to grant access to the "view" Inventories (vInventories) table TO PUBLIC users of the database --
	Go

*/

Deny Select On dbo.Categories To Public;
Deny Select On dbo.Products To Public;
Deny Select On dbo.Employees To Public;
Deny Select On dbo.Inventories To Public;
Go

Grant Select On vCategories To Public;
Grant Select On vProducts To Public;
Grant Select On vEmployees To Public;
Grant Select On vInventories To Public;
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*

	-- Note: Working with (Category and Product) that will need to be combined to query against --
	-- Comment: CategoryID exists in both the Categories and Products table: PK/FK
	-- Comment: !!!REMINDER!!! You must use the BASIC views for each table after they are created in Question 1

1) Select
	Categories.CategoryName, Products.ProductName, Products.UnitPrice
   From Categories
	Join Products
		On Categories.CategoryID = Products.CategoryID;

	-- Note: Using the JOIN statement, combine Categories and Products, specificaly ON the CategoryID --
	-- Comment: Need to order the result by the Category and Product

2) Select
	Categories.CategoryName, Products.ProductName, Products.UnitPrice
   From Categories
	Join Products
		On Categories.CategoryID = Products.CategoryID
	Order By 1, 2;

	-- Note: Using ORDER BY, having the query order the results by CategoryName first and ProductName second --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Need to create a "view" --

3)  Create View vProductsByCategories														
	As
	Select Top 100000 Categories.CategoryName, Products.ProductName, Products.UnitPrice      
	From Categories
		Join Products
			On Categories.CategoryID = Products.CategoryID
	Order By 1,2;

	-- Created a view called "ProductsByCategories" --
	-- Used the SELECT TOP command as a workaround for the ORDER BY to be followed --

	-- Comment: Enhance the code for readability

4) Create View vProductsByCategories														
	As
	Select Top 100000 c.CategoryName, p.ProductName, p.UnitPrice      
	From vCategories As c                                                  -- defining vCategories as "c" (alias)
		Inner Join vProducts As p                                          -- defining vProducts as "p" (alias)
			On c.CategoryID = p.CategoryID
	Order By c.CategoryName,p.ProductName;                                 -- Using aliases, defining the order by the column names
	Go

*/

Create View vProductsByCategories														
	As
	Select Top 10000 c.CategoryName, p.ProductName, p.UnitPrice      
	From vCategories As c
		Inner Join vProducts As p
			On c.CategoryID = p.CategoryID
	Order By c.CategoryName,p.ProductName;
	Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
/*

	-- Note: Working with (Products and Inventories) that will need to be combined to query against --
	-- Comment: ProductID exists in both the Products and Inventories table: PK/FK
	-- Comment: !!!REMINDER!!! You must use the BASIC views for each table after they are created in Question 1

1) Select
	Products.ProductName, Inventories.InventoryDate, Inventories.[Count]
   From Products
	Join Inventories
		On Products.ProductID = Inventories.ProductID

	-- Note: Using the JOIN statement, combine Products and Inventories, specificaly ON the ProductID --
	-- Comment: Need to order the result by the Product, Date and Count

2) Select
	Products.ProductName, Inventories.InventoryDate, Inventories.[Count]
   From Products
	Join Inventories
		On Products.ProductID = Inventories.ProductID
	Order By 1, 2, 3;
	-- Note: Using ORDER BY, having the query order the results by ProductName first, InventoryDate second and Count third --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Need to create a "view" -- 

3)  Create View vInventoriesByProductsByDates												   
	As
	Select Top 100000 Products.ProductName, Inventories.InventoryDate, Inventories.[Count]      
   From Products
	Join Inventories
		On Products.ProductID = Inventories.ProductID
	Order By 1, 2, 3;

	-- Created a view called "InventoriesByProductsByDates" --
	-- Used the SELECT TOP command as a workaround for the ORDER BY to be followed --

	-- Comment: Enhance the code for readability

4) Create View vInventoriesByProductsByDates														
	As
	Select Top 100000 p.ProductName, i.InventoryDate, i.[Count]      
	From vProducts As p                                               -- defining vProducts as "p" (alias)
		Inner Join vInventories As i                                  -- defining vInventories as "i" (alias)
			On p.ProductID = i.ProductID
	Order By p.ProductName,i.InventoryDate, i.[Count];                -- Using aliases, defining the order by the column names
	Go

*/

	
Create View vInventoriesByProductsByDates														
	As
	Select Top 10000 p.ProductName, i.InventoryDate, i.[Count]      
	From vProducts As p
		Inner Join vInventories As i
			On p.ProductID = i.ProductID
	Order By p.ProductName,i.InventoryDate, i.[Count];
	Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*

	-- Note: Working with (Inventories and Employees) that will need to be combined to query against --
	-- Comment: EmployeeID exists in both the Inventories and Employees table: PK/FK
	-- Comment: !!!REMINDER!!! You must use the BASIC views for each table after they are created in Question 1

1) Select
	Inventories.InventoryDate, Employees.EmployeeFirstName, Employees.EmployeeLastName
   From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID;

	-- Note: Using the JOIN statement, combine Inventories and Employees, specificaly ON the EmployeeID --
	-- Comment: Need to order the result by the Date and return only one row per date

2) Select
	Inventories.InventoryDate, Employees.EmployeeFirstName, Employees.EmployeeLastName
  From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID;
	Order By 1, 2, 3;

	-- Note: Using ORDER BY, having the query order the results by InventoryDate first, EmployeeFirstName second and EmployeeLastName third --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --

	-- Comment: Need to return only one row per date
	
3) Select Distinct
	Inventories.InventoryDate, Employees.EmployeeFirstName, Employees.EmployeeLastName
   From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
	Order By 1, 2, 3;

	-- Note: Added "Distinct" onto the SELECT statement to return only one row per date --
	-- Comment: Need to create a "view"  

4)  Create View vInventoriesByEmployeesByDates                                          
	As
	Select Distinct Top 100000                                                           
	Inventories.InventoryDate, Employees.EmployeeFirstName, Employees.EmployeeLastName
    From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
	Order By 1, 2, 3;

	-- Created a view called "InventoriesByEmployeesByDates" --
	-- Used the SELECT TOP command as a workaround for the ORDER BY to be followed --

	-- Comment: Enhance the code for readability

5)  Create View vInventoriesByEmployeesByDates														
	As
	Select Distinct Top 100000 i.InventoryDate, e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName    -- Combined FirsName and LastName for normalization --
	From vInventories As i																						  -- defining vInventories as "i" (alias)                                                                          
		Inner Join vEmployees As e                                                                                -- defining vEmployees as "e" (alias)
			On i.EmployeeID = e.EmployeeID
	Order By i.InventoryDate;                                                                                     -- Using aliases, defining the order by the column names
	Go

*/

Create View vInventoriesByEmployeesByDates														
	As
	Select Distinct Top 10000 i.InventoryDate, e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName      
	From vInventories As i
		Inner Join vEmployees As e
			On i.EmployeeID = e.EmployeeID
	Order By i.InventoryDate;
	Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
	-- Note: Working with (Inventories, Employees, Products, and Categories) that will need to be combined to query against --
	-- Comment: EmployeeID exists in both the Inventories and Employees table: PK/FK
	-- Comment: ProductID exists in both the Inventories and Products tables: PK/FK
	-- Comment: CategoryID exists in both the Products and Category tables: PK/FK
	-- Comment: !!!REMINDER!!! You must use the BASIC views for each table after they are created in Question 1

1)  Select Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count]
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID;

	-- Note: Combining everything --
	-- Note: Need to order the results by the Category, Product, Date, and Count --

2)  Select Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count]
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID
	Order By 1,2,3,4;

	-- Note: Using ORDER BY, having the query order the results by CategoryName first, ProductName second, InventoryDate third and Count fourth --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Need to create a "view" -- 

3) Create View vInventoriesByProductsByCategories                                                                   
	As
	Select Top 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count] 
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID
	Order By 1,2,3,4;

	-- Created a view called "InventoriesByProductsByCategories" --
	-- Used the SELECT TOP command as a workaround for the ORDER BY to be followed --

	-- Comment: Enhance the code for readability

4) Create View vInventoriesByProductsByCategories
	As
	Select Top 1000000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count]
	From vInventories As i                                                       -- defining vInventories as "i" (alias)
		Inner Join vEmployees As e                                               -- defining vEmployees as "e" (alias)
			On i.EmployeeID = e.EmployeeID
		Inner Join vProducts As p                                                -- defining vProducts as "p" (alias)
			On i.ProductID = p.ProductID
		Inner Join vCategories As c                                              -- defining vCategories as "c" (alias)
			On p.CategoryID = c.CategoryID
	Order By c.CategoryName, p.ProductName, i.InventoryDate, i.[Count];          -- Using aliases, defining the order by the column names 

*/

Create View vInventoriesByProductsByCategories
	As
	Select Top 1000000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count]
	From vInventories As i
		Inner Join vEmployees As e
			On i.EmployeeID = e.EmployeeID
		Inner Join vProducts As p
			On i.ProductID = p.ProductID
		Inner Join vCategories As c
			On p.CategoryID = c.CategoryID
	Order By c.CategoryName, p.ProductName, i.InventoryDate, i.[Count];

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*

	-- Note: Working with (Inventories, Employees, Products, and Categories) that will need to be combined to query against --
	-- Comment: EmployeeID exists in both the Inventories and Employees table: PK/FK
	-- Comment: ProductID exists in both the Inventories and Products tables: PK/FK
	-- Comment: CategoryID exists in both the Products and Category tables: PK/FK
	-- Comment: !!!REMINDER!!! You must use the BASIC views for each table after they are created in Question 1

1)  Select Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeFirstName, Employees.EmployeeLastName
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID;

	-- Note: Combining everything --
	-- Note: Need to order the results by the Inventory Date, Category, Product and Employee --

2)  Select Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeFirstName, Employees.EmployeeLastName
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID
	Order By 3, 1, 2, 4;

	-- Note: Using ORDER BY, having the query order the results by InventoryDate first, CategoryName second, ProductName third, EmployeeFirstName fourth, and EmployeeLastName fifth --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Need to create a "view" -- 

3)  Create View vInventoriesByProductsByEmployees    
	As
	Select Top 1000000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeFirstName, Employees.EmployeeLastName
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID
	Order By 3, 1, 2, 4;

	-- Created a view called "InventoriesByProductsByEmployees" --
	-- Used the SELECT TOP command as a workaround for the ORDER BY to be followed --

	
	-- Comment: Enhance the code for readability

4) Create View vInventoriesByProductsByEmployees
	As
	Select Top 100000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName  
	From vInventories As i                                                                    
		Inner Join vEmployees As e
			On i.EmployeeID = e.EmployeeID
		Inner Join vProducts As p
			On i.ProductID = p.ProductID
		Inner Join vCategories As c
			On p.CategoryID = c.CategoryID
	Order By i.InventoryDate, c.CategoryName, p.ProductName, i.[Count], EmployeeName;

	-- Combined FirsName and LastName for normalization --
	-- defining vInventories as "i" (alias) --
	-- defining vEmployees as "e" (alias) --
	-- defining vProducts as "p" (alias) --
	-- defining vCategories as "c" (alias) --
	-- Using aliases, defining the order by the column names --
*/

Create View vInventoriesByProductsByEmployees
As
Select Top 100000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
From vInventories As i
	Inner Join vEmployees As e
		On i.EmployeeID = e.EmployeeID
	Inner Join vProducts As p
		On i.ProductID = p.ProductID
	Inner Join vCategories As c
		On p.CategoryID = c.CategoryID
Order By i.InventoryDate, c.CategoryName, p.ProductName, i.[Count], EmployeeName;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
	-- Note: Working with (Inventories, Employees, Products, and Categories) that will need to be combined to query against --
	-- Comment: EmployeeID exists in both the Inventories and Employees table: PK/FK
	-- Comment: ProductID exists in both the Inventories and Products tables: PK/FK
	-- Comment: CategoryID exists in both the Products and Category tables: PK/FK
	-- Comment: !!!REMINDER!!! You must use the BASIC views for each table after they are created in Question 1

1)  Select Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeFirstName, Employees.EmployeeLastName
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID;

	-- Note: Combining everything --
	-- Note: Need to order the results by the Inventory Date, Category, Product and Employee --

2)  Select Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeFirstName, Employees.EmployeeLastName
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID
	Order By 3, 1, 2, 4;

	-- Note: Using ORDER BY, having the query order the results by InventoryDate first, CategoryName second, ProductName third, EmployeeFirstName fourth, and EmployeeLastName fifth --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Need to create a "view" -- 

3)  Create View vInventoriesForChaiAndChangByEmployees    
	As
	Select Top 1000000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeFirstName, Employees.EmployeeLastName
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID
	Order By 3, 1, 2, 4;

	-- Created a view called "InventoriesForChaiAndChangByEmployees" --
	-- Used the SELECT TOP command as a workaround for the ORDER BY to be followed --

	-- Comment: Need to restrict the query to just Products 'Chai' and 'Chang'
	-- Comment: Use a subquery to select from the Inventory.ProductID which has Chai and Chang

4)  Create View vInventoriesForChaiAndChangByEmployees
	As
	Select Top 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeFirstName, Employees.EmployeeLastName
	From Inventories
		Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Join Products
			On Inventories.ProductID = Products.ProductID
		Join Categories
			On Products.CategoryID = Categories.CategoryID
	Where Inventories.ProductID in (Select ProductID From vProducts Where ProductName In ('Chai', 'Chang'))
	Order By 3, 1, 2, 4

	-- Note: Added a subqeury WHERE the ProductName of Chai or Chang is selected in the ProductID from the Inventories table --

	-- Comment: Enhance the code for readability

5)  Create View vInventoriesForChaiAndChangByEmployees
	As
	Select Top 100000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
	From vInventories As i
		Inner Join vEmployees As e
			On i.EmployeeID = e.EmployeeID
		Inner Join vProducts As p
			On i.ProductID = p.ProductID
		Inner Join vCategories As c
			On p.CategoryID = c.CategoryID
	Where i.ProductID in (Select ProductID From vProducts Where ProductName In ('Chai', 'Chang'))
	Order By i.InventoryDate, c.CategoryName, p.ProductName,i.[Count], EmployeeName 

	-- Combined FirsName and LastName for normalization --
	-- defining vInventories as "i" (alias) --
	-- defining vEmployees as "e" (alias) --
	-- defining vProducts as "p" (alias) --
	-- defining vCategories as "c" (alias) --
	-- Using aliases, defining the order by the column names --

*/

Create View vInventoriesForChaiAndChangByEmployees
As
Select Top 100000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
From vInventories As i
	Inner Join vEmployees As e
		On i.EmployeeID = e.EmployeeID
	Inner Join vProducts As p
		On i.ProductID = p.ProductID
	Inner Join vCategories As c
		On p.CategoryID = c.CategoryID
Where i.ProductID in (Select ProductID From vProducts Where ProductName In ('Chai', 'Chang'))
Order By i.InventoryDate, c.CategoryName, p.ProductName,i.[Count], EmployeeName;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*

1) Select * From Employees;
	-- Note: Return all columns/rows from the Employees table: EmployeeID, EmployeeFirstName, EmployeeLastName and ManagerID --

	-- Comment: Self-Join required, as all the data comes from the Employees table

2) Select
	m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
 From Employees as e
	Join Employees As m
		On e.ManagerID = m.EmployeeID

	-- Comment: Going to streamline the columns in the Employee table by combining FN/LN to a new column called Manager
	-- Comment: Going to streamline the columns in the Employee table by combining FN/LN to a new column called Employee
	-- Comment: Going to Self-Join knowing the Employee table has EmployeeID and ManagerID 

	-- Note: Using the JOIN statement, combine Employees and Employees table (Self-Join), specificaly ON the ManagerID and EmployeeID --

	-- Comment: Need to order the result by the Manager's name

3) Select
	m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
 From Employees as e
	Join Employees As m
		On e.ManagerID = m.EmployeeID
 Order By 1, 2

 	-- Note: Using ORDER BY, having the query order the results by ManagerID first, then EmployeeID second --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Need to create a "view" -- 


4)	Create View vEmployeesByManager
	As
	Select Top 100000
	m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
	From Employees as e
		Inner Join vEmployees As m
			On e.ManagerID = m.EmployeeID
	Order By Manager, Employee                                       

*/

Create View vEmployeesByManager
As
Select Top 1000000 m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager,
e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
From vEmployees As e
	Inner Join vEmployees As m
		On e.ManagerID = m.EmployeeID
Order By Manager, Employee;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*

	-- Note: Working with (Inventories, Employees, Products, Categories, and Employee/Manager) that will need to be combined to query against --
	-- Comment: CategoryID exists in both the Categories and Products table: PK/FK
	-- Comment: ProductID exists in both the Inventories and Products tables: PK/FK
	-- Comment: EmplooyeeID exists in both the Inventories and Employees tables: PK/FK
	-- Comment: Self-join results in both Manager and Employee hierarchy
	-- Comment: !!!REMINDER!!! You must use the BASIC views for each table after they are created in Question 1
	-- Note: Combining everything --
	-- Note: Self-joined Employee columns to create Employee/Manager --
	-- Comment: Need to order the result by Category, Product, InventoryID and Employee
	-- Note: Need to create "view" --
	-- Comment: "Enhance" the script with table aliases

1)	Create View vInventoriesByProductsByCategoriesByEmployees
	As
	Select Top 1000000 c.CategoryID, c.CategoryName, p.ProductID, p.ProductName, p.UnitPrice, i.InventoryID, i.InventoryDate, i.[Count], e.EmployeeID, 
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee,
	m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager
	From vCategories As c
		Inner Join vProducts As p
			On p.CategoryID = c.CategoryID
		Inner Join vInventories As i
			On p.ProductID = i.ProductID
		Inner Join vEmployees As e
			On i.EmployeeID = e.EmployeeID
		Inner Join vEmployees As m
			On e.ManagerID = m.EmployeeID
	Order By c.CategoryID, p.ProductID, i.InventoryID, e.EmployeeID;

*/

Create View vInventoriesByProductsByCategoriesByEmployees
As
Select Top 1000000 c.CategoryID, c.CategoryName, p.ProductID, p.ProductName, p.UnitPrice, i.InventoryID, i.InventoryDate, i.[Count], e.EmployeeID, 
e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee,
m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager
From vCategories As c
	Inner Join vProducts As p
		On p.CategoryID = c.CategoryID
	Inner Join vInventories As i
		On p.ProductID = i.ProductID
	Inner Join vEmployees As e
		On i.EmployeeID = e.EmployeeID
	Inner Join vEmployees As m
		On e.ManagerID = m.EmployeeID
Order By c.CategoryID, p.ProductID, i.InventoryID, e.EmployeeID;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
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