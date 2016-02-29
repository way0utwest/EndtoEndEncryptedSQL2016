create database EncryptionDemo;
go
-- create login AEUser
use EncryptionDemo
go
create table SalesPeople
( SalesPersonID int identity(1,1) PRIMARY KEY
, SalesFirstName varchar(200)
, SalesLastName varchar(200)
, username varchar(100)
, IsManager bit
)
go
insert SalesPeople values
  ('Bob', 'Smith', 'bsmith' ,0)
, ('Sally', 'Jones', 'sjones', 0)
, ('Kathy', 'Johnson', 'kjohnson', 1) 
go
create table OrderHeader
( OrderID int identity(1,1) PRIMARY KEY
, Orderdate datetime2(3)
, CustomerID int
, OrderTotal numeric(12, 4)
, OrderComplete tinyint
, SalesPersonID int
)
GO
SET IDENTITY_INSERT dbo.OrderHeader ON;
insert OrderHeader (OrderID, Orderdate, CustomerID, OrderTotal, OrderComplete, SalesPersonID)
 values
  ( 1001, '2016/01/12', 1, 5000.00, 1, 1)
, ( 1002, '2016/01/23', 2, 1250.25, 1, 2)
, ( 1003, '2016/01/23', 1, 922.50, 1, 2)
, ( 1004, '2016/01/24', 3, 125.00, 0, 1)
, ( 1005, '2016/02/03', 3, 4200.99, 0, 3)
, ( 1006, '2016/02/13', 2, 1652.89, 1, 2)
SET IDENTITY_INSERT dbo.OrderHeader OFF
GO
/*
Add security for best practicse
*/
create role SalesUsers
go
grant select, insert, update, delete on OrderHeader to SalesUsers 
grant select on SalesPeople to SalesUsers
GO
CREATE TABLE OrderDetail
( OrderDetailID INT IDENTITY(1,1) PRIMARY KEY
, OrderID INT FOREIGN KEY REFERENCES dbo.OrderHeader(OrderID)
, ProductName VARCHAR(200)
, Qty INT
, UnitPrice NUMERIC(10, 4)
)
;
GO
INSERT dbo.OrderDetail
        ( OrderID
        , ProductName
        , Qty
        , UnitPrice
        )
    VALUES
        ( 1001, 'Widget #10', 2, 2500)
	  , ( 1002, 'Baseball Bat', 14, 50)
	  , ( 1002, 'Baseballs', 100, 5) 
	  , ( 1002, 'Gift Wrapping', 1, 50.25) 
	  , ( 1003, 'Hats', 22, 24)
	  , ( 1003, 'Ties', 10, 39.45)
	  , ( 1004, 'Calculator', 1, 125)
	  , ( 1005, 'Dirt Bike', 1, 4000)
	  , ( 1005, 'Off-road tires', 1, 200.99)
	  , ( 1006, 'K-cups', 1, 52.89)
	  , ( 1006, 'Super Amazing Espresso machine', 2, 800.00 )

GO
-- Add security for the role
GRANT SELECT, INSERT, update ON dbo.OrderDetail TO SalesUsers
GO
