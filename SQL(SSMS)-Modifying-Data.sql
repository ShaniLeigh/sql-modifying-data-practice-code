/*  Modifying Data 

	Insert function.
	Update and Delete data using functions
	Explain creating variables for use within SQl queries.
	Importance of comments to describe SQL code
	IF statements and loops in SQL queries
	Identity columns are the unique identifier columns, number sequenced rows(auto generated sequence of numbers)

*/
--Create a table for demo: TableName, (Column names , datatype, NUll or Not Null))--
CREATE TABLE SalesLT.CallLog(CallID int IDENTITY PRIMARY KEY NOT NULL, --value inserted auto, skipped when insert into values--
							 CallTime datetime NOT NULL DEFAULT GETDATE(), --defaults to current date and time, unless you change
							 SalesPerson nvarchar(256) NOT NULL,
							 CustomerID int NOT NULL REFERENCES [SalesLT].[Customer](CustomerID),
							 PhoneNumber nvarchar(25) NOT NULL,
							 Notes nvarchar(max) NULL);

							 
GO

--Insert a row
INSERT INTO SalesLT.CallLog
VALUES('2015-01-01T12:30:00', 'adventure-works\pamela0', 1, '245-555-0173', 'Returning call re: enquiry about...');

SELECT * FROM SalesLT.CallLog;

--Insert defaults and nulls
INSERT INTO SalesLT.CallLog
VALUES(DEFAULT, 'adventure-works\david8', 2, '170-555-0127', NULL);

SELECT * FROM SalesLT.CallLog;

--Insert a row with explicit columns
INSERT INTO SalesLT.CallLog(SalesPerson, CustomerID, PhoneNumber)
VALUES('adventure_works\jillian0', 3, '279-555-0130');
SELECT * FROM SalesLT.CallLog;

--Insert Multiple Rows; Each row is in  its own ()s 
INSERT INTO SalesLT.CallLog
VALUES(DATEADD(mi,-2, Getdate()), 'adventure-works\jillian0', 4, '710-555-0173', Null),
      (Default, 'adventure-works\shu0', 5, '828-555-0186', 'Called to arrange delivery of order 10987');
Select * from SalesLT.CallLog;

--Insert the results of a query
insert into SalesLT.CallLog(SalesPerson,CustomerID,PhoneNumber,Notes)
select SalesPerson, CustomerID, Phone, 'Sales promotion call'
from SalesLT.Customer
where CompanyName = 'Big-Time Bike Store';
Select * from SalesLT.CallLog;

--Retrieving inserted identity
INSERT INTO SalesLT.CallLog(SalesPerson,CustomerID,PhoneNumber)
Values('adventure-works\jose1', 10, '150-555-0127');
Select SCOPE_IDENTITY();
Select * From SalesLT.CallLog;

--Overriding Identity (can undo a previous deletion, etc.)
Set Identity_insert SalesLT.CallLog ON;

Insert Into SalesLT.CallLog(CallID,SalesPerson,CustomerID,PhoneNumber)
Values(12, 'adventure-works\jose1',11, '926-555-0159');
Set Identity_insert SalesLT.CallLog OFF;

/* Update and Delete commands

Updating Data in a Table(The UPDATE Statement)
	Updates all rows in a table or view
		SET can be filtered with a WHERE clause
		SET can be defined with a  FROM clause
		example:

			UPDATE Production.Product
			SET unitprice = (unitprice * 1.04)
			WHERE categoryid = 1 AND discontinued = 0;

	Only columns specified in the SET clause are modified

Updating Data in a Table(The MERGE Statement)
	MERGE modifies data based on a condition:
		When the source matches the target
		When the source has no match in th taget
		When the target has no match in the source
		example:

			MERGE INTO Production.Products as P
				USING Production.ProductsStaging as S
				ON P.ProductID = S.ProductID
			WHEN MATCHED THEN
				UPDATE SET
				P.UnitPrice = S.UnitPrice, P.Discontinued = S.Discontinued
			WHEN NOT MATCHED THEN
				INSERT(ProductName, CategoryID, UnitPrice, Discontinued)
				VALUES(S.ProcutName, S.CategoryID, S.UnitPrice, S.Discontinued);
Deleting Data From a Table commands:
	DELETE without a WHERE clause deletes all rows
		Use a WHERE clause to delete specific rows.
		example:

			DELETE FROM Sales.OrderDetails
			WHERE orderid = 10248;

	TRUNCATE TABLE clears the entire table
		Storage physically deallocated, rows not individually removed
		Minimally logged
		Can be rolled back if TRUNCATE issued within a transaction
		TRUNCATE TABLE will fail if the table is referred by a foriegn key constraint in another table
*/
--Update a table
UPDATE [SalesLT].[CallLog]
SET Notes = 'No Notes'  --change the NULL values to No Notes in the column
WHERE Notes IS NULL;  --condition needs to be met

SELECT * FROM [SalesLT].[CallLog];

--Update multiple columns
Update [SalesLT].[CallLog]
SET SalesPerson = '', PhoneNumber = '';

SELECT * FROM [SalesLT].[CallLog];

--Update from results of a query
UPDATE [SalesLT].[CallLog]
SET SalesPerson = c.SalesPerson, PhoneNumber = c.Phone
FROM SalesLT.Customer AS c
Where c.CustomerID = SalesLT.CallLog.CustomerID;
SELECT * FROM [SalesLT].[CallLog];

--Delete rows
DELETE FROM [SalesLT].[CallLog]
WHERE CallTime<DATEADD(dd,-7,GETDATE()); --getting rid of calls that happened 7 plus days ago

SELECT * FROM [SalesLT].[CallLog];

--Truncate the table
TRUNCATE TABLE [SalesLT].[CallLog]; --empties the table

SELECT * FROM [SalesLT].[CallLog];

/*Batches, Comments and Variables, Conditional Branching, Loops, Stored Procedures
	To separate statements into batches, use a separator:

		SQL Server tools use the GO keyword.
		GO is not a T-SQL command (the application you are using use the tool)
		Go[count] executes the batch, the specified(n) number of times
		example:
			SELECT * FROM Production.Product;
			SELECt * FROM Sales.Customer;

			GO --send everything you have so far

Comments (very important, people can't read your mind)
	Marks T-SQL code as a comment:
		For a block, enclose it between /* */
		For a line, double dashes --

Variables(Must be declared and given a data type)
	Variables are objects that allow storage of a value for use later in the same batch
	Variables ar defined with the DECLARE keyword
		Variables can be declared and initialized in the same statement
		example:
			--declare and initialize variables
			DECLARE @color nvarchar(15)='Black', @size nvarchar(5)='L';
			--use variables in statements
			SELECT * FROM Production.Product
			WHERE Color=@color and Size=@size;

			GO
In SQL Server (and Transact-SQL, its dialect), the @ symbol serves a specific purpose:
Prefix for Local Variables and Parameters: The primary use of the @ symbol is to denote local variables and parameters within
T-SQL code. When you declare a variable using DECLARE @variable_name data_type; or define a parameter for a stored procedure or function,
the @ symbol is a mandatory prefix. This helps SQL Server distinguish these elements from other database objects like tables, columns, or 
keywords.
example:

DECLARE @customerID INT;
SET @customerID = 123;

SELECT * FROM Customers WHERE CustomerID = @customerID;

Similarly, in a stored procedure:

CREATE PROCEDURE GetCustomerDetails
    @inputCustomerID INT
AS
BEGIN
    SELECT * FROM Customers WHERE CustomerID = @inputCustomerID;
END;

--Here, @inputCustomerID is a parameter for the GetCustomerDetails stored procedure.
--The @ symbol provides a clear visual cue and helps prevent naming conflicts with other database objects,
--improving code readability and maintainability.

In SQL Server's Transact-SQL (T-SQL), the double at sign (@@) prefix is used to denote system functions,
which were historically referred to as "global variables" in earlier versions. 
These are built-in functions provided by the SQL Server engine that return system-supplied values
or information about the current server instance or session.
*/
--DEMO Search a city using a variable
DECLARE @City varchar(20)='Toronto'
Set @City='Bellevue' --this changes the variable and will return results with on Bellevue as city (passing values into the query)
--remember that the keyword GO sends the code block. make sure declared variables are in each code block, if you are reusing them.

SELECT FirstName + ' '+LastName as [Name],AddressLine1 as Address,City
From [SalesLT].[Customer] as C
Join [SalesLT].[CustomerAddress] as CA
ON C.CustomerID=CA.CustomerID
Join SalesLT.Address as A
ON CA.AddressID=A.AddressID
Where City=@City

--use a variable as an output
DECLARE @Result money
SELECT @Result=Max(TotalDue)
FROM [SalesLT].[SalesOrderHeader]
PRINT @Result

/*Conditional Branching and Looping
	If...Else. If true, execute the code. If not true(false,or unknown), execute the else statement.
*/
--Simple Logic Test
If 'yes' = 'yes'
print 'true'
--Change code based on a  condition
UPDATE [SalesLT].[Product]
SET DiscontinuedDate=GETDATE()
WHERE ProductID=1;

If @@ROWCOUNT<1 --0 updates
BEGIN
	PRINT 'Product was not found'
END
ELSE
BEGIN
	PRINT 'Product Updated'
END

/*Looping(running through code multiple times, more efficient to work with sets)
	WHILE enables code to execute in a loop
	Statements in the WHILE block repeat as the predicate evaluates to TRUE
	The loop ends when the predicate evlautes to FALSE or UNKNOWN.
	Execution can be altered by BREAK or CONTINUE
*/
Create Table SalesLT.DemoTable(Description nvarchar(max) Null);  --had to create this table for exercise

DECLARE @Counter int=1 -- (declare/initialize before while loop,Must have a Begin and End.
WHILE @Counter <=5
BEGIN
	INSERT SalesLT.DemoTable
	VALUES ('ROW' + CONVERT(varchar(5),@Counter))
	SET @Counter=@Counter+1
END

SELECT Description FROM SalesLT.DemoTable

/*DECLARE @Counter int=1

DECLARE @Description int
SELECT @Description=MAX(ID)
FROM SalesLT.DemoTable

WHILE @Counter <5
BEGIN */

/*Stored Procedures: Named object/function/method
	Database objects that encapsulate Transact-SQl code.

	Can be parameterized: You can pass parameters through the procedure
		Input parameters
		Output parameter
		example:
*/
		CREATE PROCEDURE SalesLT.GetProductsByCategory(@CategoryID INT = NULL)
		AS
		IF @CategoryID IS NULL
			SELECT ProductID,Name,Color,Size,ListPrice
			FROM [SalesLT].[Product]
		ELSE
			SELECT ProductID,Name,Color,Size,ListPrice
			FROM [SalesLT].[Product]
			WHERE ProductCategoryID = @CategoryID;
--execute the procedure without a parameter
EXEC SalesLT.GetProductsByCategory; --best practice even if not the first batch. it's more clear

	--Executed with the EXECUTE command with a parameter.
		EXECUTE SalesLT.GetProductsByCategory 6; --same as EXEC


















	