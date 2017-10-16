/*
End to End Encryption - RLS Write Demo
Let's show how RLS can leak info, and then work on fixing the issues.

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/

USE EncryptionDemo
GO
GRANT INSERT, UPDATE ON dbo.OrderHeader TO SalesUsers;
GO

--  what can sjones see?
EXECUTE AS USER = 'sjones';
go
SELECT
        o.OrderID
      , o.Orderdate
      , o.CustomerID
      , o.OrderTotal
      , o.OrderComplete
      , o.SalesPersonID
      , sp.SalesFirstName
      , sp.SalesLastName
      , sp.username
      , sp.IsManager
    FROM
        dbo.OrderHeader o
    INNER JOIN dbo.SalesPeople sp
    ON  sp.SalesPersonID = o.SalesPersonID;
go
REVERT
go
-- Note, I only see 3 orders. These are the orders associated with sjones (SalespersonID = 2)


-- What about OrderID 1001? This is a bsmith (salespersonid =1) order
-- can I change it? Let's try
EXECUTE AS USER = 'sjones';
GO
UPDATE dbo.OrderHeader
 SET SalesPersonID = 2
 WHERE OrderID = 1001;
GO
REVERT
go
SELECT * FROM dbo.OrderHeader;
GO




-- I cannot
-- I cannot update rows that are filtered. These don't exist as far as I'm concerned.


-- Can I add rows?
-- Let's add one for me. SalesPersonID = 2
EXECUTE AS USER = 'sjones';
GO
INSERT dbo.OrderHeader
    (Orderdate, CustomerID, OrderTotal, OrderComplete, SalesPersonID    )
 VALUES ( GETDATE(), 1, -2000, 1, 2)
GO
SELECT * FROM dbo.OrderHeader;
GO
-- Sure, I have permission to do so. 

-- Hmmm, can I cause trouble?
-- Can I add an order for bsmith, a negative order
INSERT dbo.OrderHeader VALUES ( GETDATE(), 1, -50000, 1, 1)
GO
SELECT * FROM dbo.OrderHeader;
GO
-- Can I add rows elsewhere? Yes.
REVERT
GO
SELECT * FROM dbo.OrderHeader;
GO
 


-- The same thing for updates.
-- Let's move the negative order to bsmith
EXECUTE AS USER = 'sjones';
GO
UPDATE dbo.OrderHeader
 SET SalesPersonID = 1
 WHERE OrderID = 1007
GO
SELECT * FROM dbo.OrderHeader;
GO
REVERT
GO


-- What's the effect?
SELECT * FROM dbo.OrderHeader;
GO
-- Note that I've "moved" a bad order to another salesperson, while adding another.
-- This is bad

-- Can I stop this?
-- Let's try
ALTER SECURITY POLICY dbo.RLS_SalesPeople_Orders_Policy
 ADD BLOCK PREDICATE dbo.RLS_SalesPerson_OrderCheck(salespersonid)
  ON dbo.OrderHeader;
GO

-- Now, let's see. sjones = SalesPersonID 2
EXECUTE AS USER = 'sjones';
GO
INSERT dbo.OrderHeader VALUES ( GETDATE(), 1, -75000, 1, 1)
GO



-- An error, but now I know RLS is in play.
-- This is some security leakage
REVERT
GO
-- Check, no OrderId = 1009
SELECT * FROM dbo.OrderHeader;
GO



