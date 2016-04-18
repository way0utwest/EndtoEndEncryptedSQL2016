/*
End to End Always Encrypted - Setup

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/
IF NOT EXISTS( SELECT name FROM sys.databases AS d WHERE name = 'AlwaysEncryptedDemo')
  CREATE database AlwaysEncryptedDemo;
GO

USE AlwaysEncryptedDemo;
GO

-- Create the table with data
CREATE TABLE Customers
(CustomerID INT NOT NULL PRIMARY KEY
, CustomerName VARCHAR(200) NOT NULL
, CustomerEmail VARCHAR(200) COLLATE Latin1_General_BIN2 
, TaxID VARCHAR(20) NOT NULL
, CreditLimit int NOT NULL DEFAULT 0.0
, SecureCreditLimit INT NULL 
, Active BIT NOT NULL DEFAULT 1
);
GO


/*
Insert data
*/
INSERT customers 
 VALUES (1, 'Steve', 'sjones@myisp.net', '1234567', 100, 200, 1)
      , (2, 'Andy', 'andy@someisp.com', '45667778', 400, 2000, 1)
      , (3, 'Kyle', 'kylejohnson@hotmail.com', '9876765765', 200, 2000, 1)
      , (4, 'DJ', 'dj@halo.com', '55555555', 3500, 20000, 1)
      , (5, 'Sarah', 'ssmith@gmail.com', '4666688', 4000, 2000, 1)
GO

/*
Create a few procedures to work with the table.
*/
-- Create procedures if they don't exist
IF NOT EXISTS( SELECT name, * FROM sys.objects WHERE SCHEMA_ID = 1 AND name = 'Customers_Insert')
  EXEC('CREATE PROCEDURE dbo.Customers_Insert AS SELECT 1;')
GO
IF NOT EXISTS( SELECT name, * FROM sys.objects WHERE SCHEMA_ID = 1 AND name = 'Customers_SelectAll')
  EXEC('CREATE PROCEDURE dbo.Customers_SelectAll AS SELECT 1;')
GO
IF NOT EXISTS( SELECT name, * FROM sys.objects WHERE SCHEMA_ID = 1 AND name = 'Customers_SelectOne')
  EXEC('CREATE PROCEDURE dbo.Customers_SelectOne AS SELECT 1;')
GO
/*
-- SQL 2016 only
DROP PROCEDURE IF EXISTS dbo.Customers_Insert;
DROP PROCEDURE IF EXISTS dbo.Customers_SelectAll;
DROP PROCEDURE IF EXISTS dbo.Customers_SelectOne;
*/

ALTER PROCEDURE Customers_Insert
  @CustomerID INT
, @CustomerName VARCHAR(200)
, @CustomerEmail VARCHAR(200)
, @TaxID VARCHAR(20)
, @CreditLimit INT
, @SecureCreditLimit INT
, @Active BIT
AS
  BEGIN

    INSERT dbo.Customers
        (
          CustomerID
        , CustomerName
        , CustomerEmail
		, TaxID
        , CreditLimit
        , SecureCreditLimit
        , Active
        )
      VALUES
        (
          @CustomerID
        , @CustomerName
        , @CustomerEmail
		, @TaxID
        , @CreditLimit
        , @SecureCreditLimit
        , @Active
        )

  END

GO
ALTER PROCEDURE Customers_SelectOne
 @CustomerEmail VARCHAR(200)
AS
  BEGIN
    SELECT
        *
      FROM
        dbo.Customers AS c
      WHERE
        c.CustomerEmail = @CustomerEmail
  END
GO

ALTER PROCEDURE Customers_SelectAll
AS
  BEGIN
    SELECT
        *
      FROM
        dbo.Customers AS c
  END
 GO

 

/*
-- Reset

drop table Customers
drop procedure dbo.Customers_Insert
drop procedure dbo.Customers_SelectOne
drop procedure dbo.Customers_SelectAll


-- SSMS
Column Encryption Setting = Enabled


*/ 			   
			   