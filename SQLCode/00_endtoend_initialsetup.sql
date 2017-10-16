/*
End to End Encryption - Setup


Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/
IF NOT EXISTS ( SELECT
                    d.name
                  FROM
                    sys.databases AS d
                  WHERE
                    d.name = 'EncryptionDemo' )
  CREATE DATABASE EncryptionDemo;
GO
-- create login AEUser
USE EncryptionDemo;
GO
CREATE TABLE SalesPeople
  (
    SalesPersonID INT IDENTITY(1, 1)
                      PRIMARY KEY
  , SalesFirstName VARCHAR(200)
  , SalesLastName VARCHAR(200)
  , username VARCHAR(100)
  , IsManager BIT
  );
GO
INSERT dbo.SalesPeople
  VALUES
    ( 'Bob', 'Smith', 'bsmith', 0 )
,   ( 'Sally', 'Jones', 'sjones', 0 )
,   ( 'Kathy', 'Johnson', 'kjohnson', 1 ); 
GO
CREATE TABLE OrderHeader
  (
    OrderID INT IDENTITY(1, 1)
                PRIMARY KEY
  , Orderdate DATETIME2(3)
  , CustomerID INT
  , OrderTotal NUMERIC(12, 4)
  , OrderComplete TINYINT
  , SalesPersonID INT
  );
GO
SET IDENTITY_INSERT dbo.OrderHeader ON;
INSERT dbo.OrderHeader
    ( OrderID, Orderdate, CustomerID, OrderTotal, OrderComplete, SalesPersonID )
  VALUES
    ( 1001, '2016/01/12', 1, 5000.00, 1, 1 )
,   ( 1002, '2016/01/23', 2, 1250.25, 1, 2 )
,   ( 1003, '2016/01/23', 1, 922.50, 1, 2 )
,   ( 1004, '2016/01/24', 3, 125.00, 0, 1 )
,   ( 1005, '2016/02/03', 3, 4200.99, 0, 3 )
,   ( 1006, '2016/02/13', 2, 1652.89, 1, 2 );
SET IDENTITY_INSERT dbo.OrderHeader OFF;
GO
/*
Add security for best practicse
*/
CREATE ROLE SalesUsers;
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.OrderHeader TO SalesUsers; 
GRANT SELECT ON dbo.SalesPeople TO SalesUsers;
GO
CREATE TABLE OrderDetail
  (
    OrderDetailID INT IDENTITY(1, 1)
                      PRIMARY KEY
  , OrderID INT FOREIGN KEY REFERENCES dbo.OrderHeader ( OrderID )
  , ProductName VARCHAR(200)
  , Qty INT
  , UnitPrice NUMERIC(10, 4)
  );
GO
INSERT dbo.OrderDetail
    ( OrderID, ProductName, Qty, UnitPrice )
  VALUES
    ( 1001, 'Widget #10', 2, 2500 )
	  ,
    ( 1002, 'Baseball Bat', 14, 50 )
	  ,
    ( 1002, 'Baseballs', 100, 5 ) 
	  ,
    ( 1002, 'Gift Wrapping', 1, 50.25 ) 
	  ,
    ( 1003, 'Hats', 22, 24 )
	  ,
    ( 1003, 'Ties', 10, 39.45 )
	  ,
    ( 1004, 'Calculator', 1, 125 )
	  ,
    ( 1005, 'Dirt Bike', 1, 4000 )
	  ,
    ( 1005, 'Off-road tires', 1, 200.99 )
	  ,
    ( 1006, 'K-cups', 1, 52.89 )
	  ,
    ( 1006, 'Super Amazing Espresso machine', 2, 800.00 );

GO
-- Add security for the role
GRANT SELECT, INSERT, UPDATE ON dbo.OrderDetail TO SalesUsers;
GO

-- DDM Nonsecurity demo
CREATE TABLE Staff
( EmployeeID INT, 
  EmployeeName VARCHAR(200),
  Salary MONEY,
  CONSTRAINT Staff_PK PRIMARY KEY CLUSTERED (EmployeeID)
  )
  GO
INSERT INTO dbo.Staff
        ( EmployeeID, EmployeeName, Salary )
    VALUES ( 1, 'Steve', 50000 ),
		   ( 2, 'Kyle', 35000 ),
		   ( 3, 'Delaney', 12000 ),
		   ( 4, 'Kendall', 2000 ),
		   ( 4, 'Andy', 42000 ),
		   ( 4, 'Dean', 36000 ),
		   ( 4, 'Tia', 52000 ),
		   ( 4, 'Chrissy', 39000 ),
GO
CREATE INDEX staffIDX_Salar ON dbo.Staff(Salary)
GO
GRANT SELECT ON dbo.Staff TO SalesUsers
GO
