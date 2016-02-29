/*
End to End Encryption - Dynamic Data Masking Demo with table create

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/

-- requery with user 'sjones'
EXECUTE AS USER = 'sjones';
GO
SELECT *
 INTO #mytable FROM dbo.Emails;
GO
SELECT * FROM #mytable
GO
DROP TABLE #mytable
GO
REVERT;
GO
-- check the manager
EXECUTE AS USER = 'kjohnson';
GO
SELECT *
 INTO #mytable FROM dbo.Emails;
GO
SELECT * FROM #mytable
GO
DROP TABLE #mytable
GO
REVERT;
GO

-- Can we get around this?
GRANT ALTER ON schema::dbo TO sjones
GRANT CREATE TABLE TO sjones
GO
EXECUTE AS USER = 'sjones';
GO
SELECT *
 INTO dbo.EmailExport
 FROM dbo.Emails;
GO
GRANT SELECT ON emailexport TO sjones
GO
SELECT *
 FROM EmailExport
GO
REVERT;
GO

DROP TABLE dbo.EmailExport;
GO
