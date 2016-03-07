CREATE TABLE MyTable
( MySSN VARCHAR (10) MASKED WITH (FUNCTION = 'default()') DEFAULT ('0000000000' )
, MyName VARCHAR (200) DEFAULT ( ' ')
, MyEmail VARCHAR (250) DEFAULT ( '')
, MyInt int
)
GO
INSERT dbo. MyTable
    ( MySSN , MyName, MyEmail , MyInt)
  VALUES
    ( '1234567890', 'Steve Jones', 'SomeSteve@SomeDomain.com', 10 )
GO
SELECT * FROM dbo.MyTable
GO

CREATE USER mytest WITHOUT LOGIN
GRANT SELECT ON mytable TO mytest

GO
EXECUTE AS USER = 'mytest'
GO
SELECT * FROM dbo .MyTable AS mt
GO
REVERT

ALTER TABLE dbo.MyTable
 ALTER COLUMN MyName VARCHAR(200) MASKED WITH (FUNCTION='default()')

ALTER TABLE dbo.MyTable
 ADD MyDate DATETIME2(3) MASKED WITH (FUNCTION='default()')

INSERT dbo.MyTable
        ( MySSN, MyName, MyEmail, MyInt, Mydate )
    VALUES
        ( '9876543210', 'Bill Gates', 'billg@microsoft.com', 11, '20160101' )
GO
EXECUTE AS USER = 'mytest'
GO
SELECT * FROM dbo .MyTable AS mt
GO
REVERT



ALTER TABLE dbo.MyTable
 ADD MyNickName VARCHAR(200) MASKED WITH (FUNCTION='default()') DEFAULT ('Jonesey') 

ALTER TABLE dbo.MyTable
 ADD MyInt10 AS (MyInt * 10) MASKED WITH (FUNCTION='default()')

ALTER TABLE dbo.MyTable
 ADD MyInt10 AS (MyInt * 10)

ALTER TABLE dbo.MyTable
 ADD MyInt10Again AS (MyInt * 10) PERSISTED MASKED WITH (FUNCTION='default()')
ALTER TABLE dbo.MyTable DROP COLUMN myint10


CREATE TABLE MyNewTable
( MyPrice INT
, MyDiscount TINYINT
, MySecretPrice AS (MyPrice * MyDiscount * .01)
)

CREATE TABLE MyFirstTable
( MyPrice INT
, MyDiscount TINYINT MASKED WITH (FUNCTION='default()')
, MySecretPrice AS (MyPrice * MyDiscount * .01)
)

CREATE TABLE MyFirstTable
( MyPrice INT
, MyDiscount TINYINT MASKED WITH (FUNCTION='default()')
, MySecretPrice AS (MyPrice * MyDiscount * .01) MASKED WITH (FUNCTION='default()')
)


CREATE TABLE MySecondTable (
  MyEmail VARCHAR(250) MASKED WITH (FUNCTION='email()')
, MySSN VARCHAR(10) MASKED WITH (FUNCTION='default()')
, MyID INT MASKED WITH (FUNCTION='random(1,4)')
)
GO
INSERT MySecondTable
 VALUES
   ( 'myname@mydomain.com', '1234567890', 100)
 , ( 'abrother@mycorp.com', '0123456789', 555)
 , ( 'somesister@somecompany.org', '9876543210', 999)

GRANT SELECT ON mysecondtable TO mytest
GRANT SELECT ON mytable TO mytester

d

CREATE USER mytester WITHOUT LOGIN
GO
GRANT SELECT ON dbo.MySecondTable TO mytester
GO

GRANT UNMASK TO mytester
go
EXECUTE AS USER = 'mytester'
GO
SELECT * FROM dbo.MySecondTable
GO
REVERT


ALTER TABLE dbo.MySecondTable
 ALTER COLUMN MySSN DROP MASKED;

dd
EXECUTE AS USER = 'mytester'
GO
SELECT * FROM dbo.MyTable
GO
REVERT





CREATE ROLE Myusers
ALTER ROLE myusers ADD MEMBER mytest
ALTER ROLE myusers ADD MEMBER mytester


CREATE TABLE MyTaxpayers (
  SSN VARCHAR(10) MASKED WITH (FUNCTION='default()') NOT NULL PRIMARY KEY
, MyName VARCHAR(200)
);
go
ALTER TABLE dbo.MyTaxpayers ADD PRIMARY KEY (ssn)


GO
--  dROP TABLE MyTaxpayers 
