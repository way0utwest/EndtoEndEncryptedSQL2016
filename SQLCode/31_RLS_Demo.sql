/*
End to End Encryption - RLS Demo
RLS Setup with existing users and demo of security for users and sysadmin.

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/

USE EncryptionDemo
GO
-- Check the table. We should see 6 rows
-- Note, I'm dbo
SELECT
        OrderID
      , Orderdate
      , CustomerID
      , OrderTotal
      , OrderComplete
      , SalesPersonID
	  , USER_NAME()
    FROM
        dbo.OrderHeader;
GO




/*
The security predicate function is used to determine if a 
user can access particular rows of data.

In this case, our predicate looks at the SalesPeople table and 
joins this with the Orders table to check access. 
Salespeople can only see their own orders. Managers can see all orders.

This is a normal function.
select * from salespeople
*/
CREATE FUNCTION dbo.RLS_SalesPerson_OrderCheck ( @salespersonid INT )
RETURNS TABLE
    WITH SCHEMABINDING
AS
RETURN
    SELECT
            1 AS [RLS_SalesPerson_OrderCheck_Result]
        FROM
            dbo.SalesPeople sp
        WHERE
            (
              @salespersonid = sp.SalesPersonID
              OR sp.IsManager = 1
            )
            AND USER_NAME() = sp.username;
go


/*
The security policy maps the function to a particular table. 

Note that the parameter used here must exist in our table (OrderHeader)
CREATE SECURITY POLICY - https://msdn.microsoft.com/en-us/library/dn765135.aspx

*/
CREATE SECURITY POLICY dbo.RLS_SalesPeople_Orders_Policy
  ADD FILTER PREDICATE dbo.RLS_SalesPerson_OrderCheck(salespersonid)
  ON dbo.OrderHeader;

-- SELECT top 10 * FROM dbo.OrderHeader AS oh
 


-- Now our function is enabled. Let us test how a user sees this table.
-- SalesPersonID = 2
EXECUTE AS USER = 'sjones';
go
SELECT
        o.OrderID
      , o.CustomerID
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




-- Let's check bsmith
EXECUTE AS USER = 'bsmith';
go
SELECT
        o.OrderID
      , o.CustomerID
      , o.OrderTotal
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



-- But there are more rows. Let's view them
-- execute this as dbo
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
GO
SELECT USER_NAME()



-- What happened?
-- Let's check the manager
EXECUTE AS USER = 'kjohnson'
GO
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
GO
REVERT
GO


-- The manager sees all rows, however DBO sees none.
SELECT * FROM dbo.OrderHeader;

-- Why?








-- RLS is independent of SQL Server security (GRANT SELECT). 
-- Sysadmins are bound by the same
-- security policy.














-- Let's change our function
-- Add an AND to the WHERE.
ALTER FUNCTION dbo.RLS_SalesPerson_OrderCheck ( @salespersonid INT )
RETURNS TABLE
    WITH SCHEMABINDING
AS
RETURN
    SELECT
            1 AS [RLS_SalesPerson_OrderCheck_Result]
        FROM
            dbo.SalesPeople sp
        WHERE
            ((
              @salespersonid = sp.SalesPersonID
              OR sp.IsManager = 1
            )
            AND USER_NAME() = sp.username
			)
			OR (IS_SRVROLEMEMBER(N'sysadmin') = 1
			);
go
-- Error, We have a security policy in effect.


/*
Older demo
Try this if you like, but this will fail. The policy can't just
be disabled.
*/

-- Let's disable this.
-- ALTER SECURTIY POLICY - https://msdn.microsoft.com/en-us/library/dn765135.aspx
--ALTER SECURITY POLICY dbo.RLS_SalesPeople_Orders_Policy 
--  WITH (STATE = OFF);
--GO
---- Try again
--ALTER FUNCTION dbo.RLS_SalesPerson_OrderCheck ( @salespersonid INT )
--RETURNS TABLE
--    WITH SCHEMABINDING
--AS
--RETURN
--    SELECT
--            1 AS [RLS_SalesPerson_OrderCheck_Result]
--        FROM
--            dbo.SalesPeople sp
--        WHERE
--            ((
--              @salespersonid = sp.SalesPersonID
--              OR sp.IsManager = 1
--            )
--            AND USER_NAME() = sp.username
--			)
--			OR (IS_SRVROLEMEMBER(N'sysadmin') = 1
--			);
--go

-- still fails


-- We need to remove the predicate
ALTER SECURITY POLICY dbo.RLS_SalesPeople_Orders_Policy 
  DROP FILTER PREDICATE ON dbo.OrderHeader;
GO

ALTER FUNCTION dbo.RLS_SalesPerson_OrderCheck ( @salespersonid INT )
RETURNS TABLE
    WITH SCHEMABINDING
AS
RETURN
    SELECT
            1 AS [RLS_SalesPerson_OrderCheck_Result]
        FROM
            dbo.SalesPeople sp
        WHERE
            ((
              @salespersonid = sp.SalesPersonID
              OR sp.IsManager = 1
            )
            AND USER_NAME() = sp.username
			)
			OR (IS_SRVROLEMEMBER(N'sysadmin') = 1
			);
go


-- add the predicate and enable
ALTER SECURITY POLICY dbo.RLS_SalesPeople_Orders_Policy 
  ADD FILTER PREDICATE dbo.RLS_SalesPerson_OrderCheck(salespersonid)
   ON dbo.orderheader;
GO
ALTER SECURITY POLICY dbo.RLS_SalesPeople_Orders_Policy 
  WITH (STATE = ON)
GO


-- Now, Can I see rows as dbo?
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
	  , USER_NAME()
    FROM
        dbo.OrderHeader o
    INNER JOIN dbo.SalesPeople sp
    ON  sp.SalesPersonID = o.SalesPersonID;
GO
-- Yes

-- End demo