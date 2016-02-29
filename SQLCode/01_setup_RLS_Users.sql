/*
End to End Encryption - RLS Demo
Login and user setup

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/


/*
Login and user setup. 
There are 2 logins and users for basic RLS functionality
There are 3 salespeople users to demonstrate how users can see limited data

create login RLSUser -- normal pwd

Create login RLSMgr -- normal pwd
*/
CREATE LOGIN sjones WITH PASSWORD = 'Enter@Passw0rd', CHECK_EXPIRATION =OFF, CHECK_POLICY = OFF, DEFAULT_DATABASE = EncryptionDemo;
CREATE LOGIN bsmith WITH PASSWORD = 'Enter@Passw0rd', CHECK_EXPIRATION =OFF, CHECK_POLICY = OFF, DEFAULT_DATABASE = EncryptionDemo;
CREATE LOGIN kjohnson WITH PASSWORD = 'Enter@Passw0rd', CHECK_EXPIRATION =OFF, CHECK_POLICY = OFF, DEFAULT_DATABASE = EncryptionDemo;


USE EncryptionDemo
GO
CREATE USER sjones FOR LOGIN sjones;
CREATE USER kjohnson FOR LOGIN kjohnson;
CREATE USER bsmith FOR LOGIN bsmith;
GO
ALTER ROLE SalesUsers ADD MEMBER sjones;
ALTER ROLE SalesUsers ADD MEMBER bsmith;
ALTER ROLE SalesUsers ADD MEMBER kjohnson;
GO

