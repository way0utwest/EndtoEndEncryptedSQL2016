/*
End to End Encryption - Dynamic Data Masking Demo

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/
USE EncryptionDemo
GO

-- Let's add masking to the OrderDetail table
-- First look at the structure
SELECT OrderDetailID
     , OrderID
     , ProductName
     , Qty
     , UnitPrice
 FROM dbo.OrderDetail;

-- Now, let's mask the ProductName
ALTER TABLE dbo.OrderDetail
 ALTER COLUMN ProductName ADD MASKED WITH (FUNCTION = 'default()');
GO

-- Now, requery
SELECT * FROM dbo.OrderDetail;


-- requery with user 'sjones'
EXECUTE AS USER = 'sjones';
GO
SELECT * FROM dbo.OrderDetail;
GO
REVERT;

-- Let's change the mask
ALTER TABLE dbo.OrderDetail
 ALTER COLUMN ProductName ADD MASKED WITH (FUNCTION ='partial(5, "xxxxxx", 0)')

-- requery with user 'sjones'
EXECUTE AS USER = 'sjones';
GO
SELECT * FROM dbo.OrderDetail;
GO
REVERT;

-- we can use random values. Let's mask the unit price with a random number
ALTER TABLE dbo.OrderDetail
 ALTER COLUMN UnitPrice ADD MASKED WITH (FUNCTION = 'random(.1, .9)')

-- requery with user 'bsmith'
EXECUTE AS USER = 'bsmith';
GO
SELECT * FROM dbo.OrderDetail;
GO
REVERT;


-- what about our manager? They need to see data.
GRANT UNMASK TO kjohnson;


-- query as kjohnson
EXECUTE AS USER = 'kjohnson';
GO
SELECT * FROM dbo.OrderDetail;
GO
REVERT;


-- reset permissions
REVOKE UNMASK FROM kjohnson;
go
EXECUTE AS USER = 'kjohnson';
GO
SELECT * FROM dbo.OrderDetail;
GO
REVERT;
GO

-- Add unmask to a role
CREATE ROLE SalesManager;
GO
ALTER ROLE SalesManager ADD MEMBER kjohnson;
GO
GRANT UNMASK TO SalesManager;
GO

-- requery
EXECUTE AS USER = 'kjohnson';
GO
SELECT * FROM dbo.OrderDetail;
GO
REVERT;

GO
-- undo the masking
-- ALTER TABLE OrderDetail ALTER COLUMN ProductName DROP MASKED;