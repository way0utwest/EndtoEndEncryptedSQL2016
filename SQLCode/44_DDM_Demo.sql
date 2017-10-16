/*
End to End Encryption - Dynamic Data Masking Demo

Steve Jones, copyright 2017

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/
USE EncryptionDemo
GO

-- Let's add masking to the Employee table
-- First look at the structure
SELECT *
 FROM dbo.Employees;

 -- Vertical tab group


-- Now, let's mask the ProductName
ALTER TABLE dbo.Employees
 ALTER COLUMN Salary ADD MASKED WITH (FUNCTION = 'random(10000, 40000)');
GO

-- requery with user 'sjones'
EXECUTE AS USER = 'sjones';
GO
SELECT * FROM dbo.Employees;
GO
REVERT;










-- Can sjones find out salaries?
-- Let's try
EXECUTE AS USER = 'sjones';
SELECT top 10
 *
 FROM dbo.Employees;
 
WITH myTally(n)
AS
(SELECT n = ROW_NUMBER() OVER (ORDER BY (SELECT null))
 FROM (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)) a(n)
  CROSS JOIN (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)) b(n)
)
SELECT e.EmployeeName,
       Salary = t.n * 1000
FROM myTally t
 INNER JOIN dbo.Employees e
  ON (t.n * 1000) = e.Salary;
REVERT;

GO


-- why?
-- The query optimizer and execution engine does not use DDM.



-- More
DBCC SHOW_STATISTICS(Staff, staffIDX_Salar) ;
