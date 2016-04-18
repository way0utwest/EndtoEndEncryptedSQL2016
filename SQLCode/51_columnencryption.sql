/*
End to End Encryption - Column Level Encryption Demo

Encrypt data in a column

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/

USE EncryptionDemo
GO

CREATE TABLE Employees
    (
      id INT IDENTITY(1, 1)
    , firstname VARCHAR(200)
    , lastname VARCHAR(200)
    , title VARCHAR(200)
    , salary NUMERIC(10, 4)
    );
GO
INSERT Employees
    VALUES
        ( 'Steve', 'Jones', 'CEO', 5000 )
 ,      ( 'Delaney', 'Jones', 'Manure Shoveler', 10 )
 ,      ( 'Kendall', 'Jones', 'Window Washer', 5 );
 GO
-- check the data
SELECT
        id
      , firstname
      , lastname
      , title
      , salary
    FROM
        Employees;
GO








-- don't want to disclose salary
-- let's encrypt it
-- alter the table
ALTER TABLE Employees
ADD EncryptedSalary VARBINARY(MAX);
GO










-- Before we create our encryption keys, we need a master key.
IF NOT EXISTS ( SELECT
                        *
                    FROM
                        sys.symmetric_keys
                    WHERE
                        symmetric_key_id = 101 )
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Th!sShou4ldB6Rea99yR%nD*m';
GO


/*
Our hierarchy for encryption keys should be like this:

- Windows DPAPI
|
|--- Service Master Key for SQL Server (auto created)
     |
     |--- Database Master Key (Created above)
	      |
		  |---- Asymmetric key (or cert) that uses very strong encryption
		        |
				|--- Symmetric key - weaker, but faster than asym key.

*/

-- Create the asym key
CREATE ASYMMETRIC KEY ReallyStrongSalaryKey
 WITH ALGORITHM = RSA_2048
 ENCRYPTION BY PASSWORD = 'Something4heC!#ntNeeds4Know';
go


-- Create a symmetric key
CREATE SYMMETRIC KEY MySalaryProtector
WITH ALGORITHM=AES_256
, IDENTITY_VALUE = 'Salary Protection Key'
, KEY_SOURCE = N'Keep this phrase a secr#t'
ENCRYPTION BY ASYMMETRIC KEY ReallyStrongSalaryKey;
GO






-- open the key
OPEN SYMMETRIC KEY MySalaryProtector
 DECRYPTION BY ASYMMETRIC KEY ReallyStrongSalaryKey;







-- Need the password
OPEN SYMMETRIC KEY MySalaryProtector
 DECRYPTION BY ASYMMETRIC KEY ReallyStrongSalaryKey WITH PASSWORD = 'Something4heC!#ntNeeds4Know'
 ;









-- encrypt the data
UPDATE
        dbo.Employees
    SET
        EncryptedSalary = ENCRYPTBYKEY(KEY_GUID('MySalaryProtector'),
                                       CAST(salary AS NVARCHAR));
 GO






-- check the data
SELECT
        id
      , firstname
      , lastname
      , title
      , salary
      , EncryptedSalary
    FROM
        dbo.Employees;
GO



-- decrypt the data
SELECT
        id
      , firstname
      , lastname
      , title
      , Salary
	  , DecryptedSalary = DECRYPTBYKEY(EncryptedSalary)
      , EncryptedSalary
    FROM
        dbo.Employees;
GO








-- decrypt the data, with the casting
SELECT
        id
      , firstname
      , lastname
      , title
	  , salary
      , DecryptedSalary = CAST(CAST(DECRYPTBYKEY(EncryptedSalary) AS NVARCHAR) AS NUMERIC(10,
                                                              2))
      , EncryptedSalary
    FROM
        dbo.Employees;
GO





-- no need to open the key
-- we will look at this in a minute


-- There's a problem:
-- Delaney accesses the table
update E 
 set EncryptedSalary = b.EncryptedSalary
 from Employees e, Employees b
 where E.ID = 2
 and b.ID = 1;


-- check the data:
select 
  id
, firstname
, lastname
, title
, salary
, DecryptedSalary = cast(cast(DecryptByKey(EncryptedSalary) as nvarchar) as numeric(10,2))
, EncryptedSalary
 from Employees
;
go










-- We have an attack without decryption.













-- add a new column
alter table Employees
 add rowguidID uniqueidentifier;
go

-- populate the data:
update Employees
 set rowguidID = NewID();
go




-- check
select 
  id
, firstname
, lastname
, title
, Salary
, rowguidID
 from Employees;
go






-- Now re-encrypt, with an authenicator
UPDATE
        dbo.Employees
    SET
        EncryptedSalary = ENCRYPTBYKEY(KEY_GUID('MySalaryProtector'),
                                       CAST(salary AS NVARCHAR), 1,
                                       CAST(rowguidid AS NVARCHAR(100)));
 GO


-- check the data again
SELECT
        id
      , title
	  , salary
      , DecryptedSalary = CAST(DECRYPTBYKEY(EncryptedSalary, 1,
                                   CAST(rowguidid AS NVARCHAR(100))) AS NVARCHAR(200))
      , rowguidID
      , firstname
      , lastname
    FROM
        dbo.Employees;
GO








-- attack again
UPDATE
        e
    SET
        e.EncryptedSalary = b.EncryptedSalary
    FROM
        dbo.Employees e
      , dbo.Employees b
    WHERE
        e.id = 2
        AND b.id = 1;










-- doesn't work
SELECT
        id
      , title
      , Salary
	  , DecryptedSalary = CAST(DECRYPTBYKEY(EncryptedSalary, 1,
                                   CAST(rowguidid AS NVARCHAR(100))) AS NVARCHAR)
      , rowguidID
      , firstname
      , lastname
      , EncryptedSalary
    FROM
        dbo.Employees;
GO

