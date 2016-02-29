/*
End to End Encryption - Dynamic Data Masking Demo with table create

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/

CREATE TABLE Emails
( emailid INT IDENTITY(1,1) PRIMARY KEY
, customerid INT
, emailtype VARCHAR(10)
, emailaddress VARCHAR(400) MASKED WITH (FUNCTION = 'email()')
);
GO
INSERT dbo.Emails
        (
          customerid
        , emailtype
        , emailaddress
        )
    VALUES
        (1, 'Business', 'bill.towers@mycompany.com' )
	  , (2, 'Business', 'tom.tolbert@myothercorp.com')
	  , (2, 'Personal', 'ttolbert@live.com')

GO
-- add security
GRANT SELECT ON dbo.Emails TO SalesUsers;
GRANT SELECT ON dbo.Emails TO SalesManager;
GO

-- requery with user 'sjones'
EXECUTE AS USER = 'sjones';
GO
SELECT * FROM dbo.Emails;
GO
REVERT;
GO
-- check the manager
EXECUTE AS USER = 'kjohnson';
GO
SELECT * FROM dbo.Emails;
GO
REVERT;
GO
