/*
End to End Encryption - Cleanup

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/


USE EncryptionDemo
GO
-- Remove TDE

GO
-- Remove Always Encrypted
go
-- Remove RLS stuff
DROP SECURITY POLICY dbo.RLS_SalesPeople_Orders_Policy;
GO
DROP FUNCTION dbo.RLS_SalesPerson_OrderCheck;
GO
-- reset
UPDATE dbo.OrderHeader
 SET SalesPersonID = 1
 WHERE OrderID = 1001;
GO
DELETE dbo.OrderHeader
 WHERE OrderID > 1006;
GO
-- remove rights
REVOKE UNMASK FROM kjohnson
 
GO
ALTER ROLE SalesManager DROP MEMBER kjohnson
GO
DROP ROLE SalesManager

GO
ALTER TABLE OrderDetail ALTER COLUMN ProductName DROP MASKED;
ALTER TABLE OrderDetail ALTER COLUMN UnitPrice DROP MASKED;
GO

-- Remove DDM stuff
GO
-- Remoev Sym/Asym Keys
DROP TABLE dbo.Employees;
GO
DROP SYMMETRIC KEY MySalaryProtector;
GO
DROP ASYMMETRIC KEY ReallyStrongSalaryKey
GO
DROP MASTER KEY;
go
