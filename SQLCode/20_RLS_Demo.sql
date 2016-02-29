/*
End to End Encryption - RLS Demo
RLS Setup and demo

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/

/*
The security predicate function is used to determine if a user can access particular rows of data.

In this case, our predicate looks at the SalesPeople table and joins this with the Orders table to check access. 
Salespeople can only see their own orders. Managers can see all orders.
*/
create function dbo.RLS_SalesPerson_OrderCheck (@salespersonid int)
returns table
with schemabinding
as
return select 1 as [RLS_SalesPerson_OrderCheck_Result]
       from dbo.salespeople sp
	   where (@salespersonid = sp.salespersonid or sp.IsManager = 1)
	   and user_name() = sp.username


/*
The security policy maps the function to a particular table. 
*/
create security policy dbo.RLS_SalesPeople_Orders_Policy
add filter predicate dbo.RLS_SalesPerson_OrderCheck(salespersonid)
on dbo.OrderHeader


setuser 'sjones'
go
select * from OrderHeader
go
setuser
go
select * from OrderHeader


select IS_SRVROLEMEMBER('sysadmin')
