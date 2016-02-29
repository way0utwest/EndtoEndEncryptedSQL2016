create database EncryptionDemo;
go
-- create login AEUser
use EncryptionDemo
go
create table SalesPeople
( SalesPersonID int identity(1,1)
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
( OrderID int identity(1,1)
, Orderdate datetime2(3)
, CustomerID int
, OrderTotal numeric(12, 4)
, OrderComplete tinyint
, SalesPersonID int
)
GO
SET IDENTITY_INSERT dbo.OrderHeader ON;
insert OrderHeader
 values
  ( 1001, '2016/01/12', 1, 5000.00, 1, 1)
, ( 1002, '2016/01/23', 2, 1250.25, 1, 2)
, ( 1003, '2016/01/23', 1, 922.13, 1, 2)
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



