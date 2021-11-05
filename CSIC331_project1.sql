--simple 
--1 What is the unit price of products with the category 1

use Northwinds2020TSQLV6
go
select CategoryName,Description,UnitPrice,SupplierId,Production.Category.CategoryId
from Production.Category inner join Production.Product on Production.Category.CategoryId = Production.Product.CategoryId


-- 2 What is the sales territory key of "better Bike shop 
use AdventureWorksDW2017
go

select ResellerName,AddressLine1,SalesTerritoryKey,dbo.FactResellerSales.ResellerKey
from dbo.DimReseller inner join dbo.FactResellerSales on dbo.DimReseller.ResellerKey = dbo.FactResellerSales.ResellerKey



--3 what stock group name has the 10% of 1st quater 
use WideWorldImporters
go
select *
from Sales.SpecialDeals 
inner join Warehouse.StockGroups on warehouse.stockgroups.StockGroupID= Sales.SpecialDeals.StockGroupID



--4 what city key number is attached to pennslyvania 
use WideWorldImportersDW
go
select*
from Fact.[Order] left join Dimension.City on Dimension.City.[City Key]= fact.[Order].[city key]


--5 what  is the country region code and currency code 


use AdventureWorks2017
go
select*

from Person.CountryRegion left join Sales.CountryRegionCurrency on Sales.CountryRegionCurrency.CountryRegionCode=Person.CountryRegion.CountryRegionCode

--Medium querys 


--1 what is the average total of top product 
with cte_ProductCategoryAvgTotals as
(
	select ProductCategory, AVG(LineTotal) as Avg_Total
	from (
		select (
			select PC.Name 
			from Production.ProductCategory PC JOIN Production.ProductSubcategory PS ON PC.ProductCategoryID = PS.ProductCategoryID
			where PS.ProductSubcategoryID = P.ProductSubcategoryID) as ProductCategory, 
			SO.LineTotal
		from Production.Product P 
			JOIN Sales.SalesOrderDetail SO ON SO.ProductID = P.ProductID) x
	group by ProductCategory )
select ProductCategory, Avg_total
from cte_ProductCategoryAvgTotals
where Avg_total = (
	select max(Avg_total)
	from cte_ProductCategoryAvgTotals)

	

--2 which vendor buys the most product 

with cte_vendorproduct as
(
	select v.Name as vendorname, count(p.ProductID) as productcount
	from Production.Product p 
		join Purchasing.ProductVendor pv on p.ProductID=pv.ProductID
		join Purchasing.Vendor v on  v.BusinessEntityID = pv.BusinessEntityID
	group by v.Name
)
select vendorname, productcount
from cte_vendorproduct
where productcount= (
	select max(productcount)
	from cte_vendorproduct)


--3  what is the average list price of each category

select color, categoryName, count(*) as count, round(avg(ListPrice),1) as listprice
from (
	select Color,
		(select ps.Name from Production.ProductSubcategory ps where ps.ProductSubcategoryID = p.ProductSubcategoryID) as categoryName,
		ListPrice
	from Production.Product p) X
group by color, categoryName




--4 what the max rate per department 
select DepartmentID, Dept_name, max(rate) as max_rate
from (
	select DepartmentID, 
		(select name from HumanResources.Department where DepartmentID = HumanResources.EmployeeDepartmentHistory.DepartmentID) Dept_name,
		rate
	from HumanResources.EmployeeDepartmentHistory 
		inner join HumanResources.EmployeePayHistory 
		on HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID) X
group by DepartmentID, Dept_name
order by DepartmentID

--5

select Person.CountryRegion.CountryRegionCode,person.CountryRegion.Name,StateProvinceCode,TerritoryID
from Person.CountryRegion inner join Person.StateProvince on Person.CountryRegion.CountryRegionCode=Person.StateProvince.CountryRegionCode
group by person.CountryRegion.CountryRegionCode,CountryRegion.Name,StateProvinceCode,TerritoryID


select *
from Person.CountryRegion inner join Person.StateProvince on Person.CountryRegion.CountryRegionCode=Person.StateProvince.CountryRegionCode


--6 what country has the lowest total sales 

with cte_totalsales as 
(
	select CountryRegionCode, sum(linetotal) as totalsales
	from (
		select st.CountryRegionCode ,sod.LineTotal 
		from person.Person p 
			join Sales.SalesPerson sp on p.BusinessEntityID = sp.BusinessEntityID
			join Sales.SalesOrderHeader soh on p.BusinessEntityID = soh.SalesPersonID
			join Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID
			join Sales.SalesTerritory st on soh.TerritoryID= st.TerritoryID) x 
	group by x.CountryRegionCode
)
select CountryRegionCode, totalsales 
from cte_totalsales
where totalsales = (
	select min(totalsales)
	from cte_totalsales)

--6 what prodcuct is the best seller and whats the worst 

select ProductCategory, AVG(LineTotal) as Avg_Total, MAX(LineTotal) as Max_total, MIN(LineTotal) as Min_total
from (
	select (select PC.Name from Production.ProductCategory PC where PC.ProductCategoryID = P.ProductSubcategoryID) as ProductCategory, 
		SO.LineTotal
	from Production.Product P 
		JOIN Sales.SalesOrderDetail SO ON SO.ProductID = P.ProductID) x
group by ProductCategory 

--7 who is the worst seller 

with cte_totalsales as 
(
	select firstname, lastname, sum(linetotal) as totalsales
	from (
		select p.FirstName, p.LastName, sod.LineTotal
		from person.Person p 
			join Sales.SalesPerson sp on p.BusinessEntityID = sp.BusinessEntityID
			join Sales.SalesOrderHeader soh on p.BusinessEntityID = soh.SalesPersonID
			join Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID) x 
	group by firstname, lastname
)
select firstname, lastname, totalsales 
from cte_totalsales
where totalsales = (
	select min(totalsales)
	from cte_totalsales)

	--8  what is the total ammount of order and how much profit

	SELECT SUM(TotalDue) AS "Total Order Dollars", COUNT(*) AS "Total Number Orders"
FROM Sales.SalesOrderHeader Header INNER JOIN Sales.SalesOrderDetail Detail 
ON Header.SalesOrderID = Detail.SalesOrderID
WHERE UnitPrice = 
(SELECT MAX(UnitPrice) 
FROM Sales.SalesOrderDetail)

---9
SELECT Header.SalesOrderID, Header.SalesPersonID
FROM Sales.SalesOrderHeader Header INNER JOIN Sales.SalesOrderDetail Detail 
ON Header.SalesOrderID = Detail.SalesOrderID
WHERE Header.SalesPersonID is not null and UnitPrice = 
(SELECT MAX(UnitPrice) 
FROM Sales.SalesOrderDetail)

select Sales.SalesOrderHeader.SalesPersonID, count(*) from Sales.SalesOrderHeader  group by salespersonid 
--complex
--1) what is the average rate of each department 

select DepartmentID,JobTitle,avg(rate) as avg_rate,rate,
	dbo.f_getDeptName(DepartmentID) dept_name
	
from HumanResources.EmployeeDepartmentHistory 
	inner join HumanResources.EmployeePayHistory 
	on HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID inner join HumanResources.Employee on HumanResources.EmployeePayHistory.BusinessEntityID= HumanResources.Employee.BusinessEntityID
	group by DepartmentID,Rate,JobTitle,Rate

	
CREATE FUNCTION f_getDeptName(
    @deptID INT
)
RETURNS VARCHAR(50)
AS 

BEGIN
	DECLARE @deptName VARCHAR(50);
	select @deptName = name from HumanResources.Department where DepartmentID = @deptID;
	RETURN @deptName;
END;


--2) what is the top sales peron and what territory are they from

SELECT CONCAT(Person.FirstName, ' ', Person.LastName) AS "SalesPerson Full Name", dbo.GetTerritoryName(SalesPerson.TerritoryID) AS "Territory Name", SalesPerson.SalesYTD AS "Individual Sales YTD", Territory.SalesYTD AS "Territory Sales YTD"
FROM HumanResources.Employee Emp INNER JOIN Person.Person Person ON Emp.BusinessEntityID = Person.BusinessEntityID
INNER JOIN Sales.SalesPerson SalesPerson ON SalesPerson.BusinessEntityID = Emp.BusinessEntityID
INNER JOIN Sales.SalesTerritory Territory ON Territory.TerritoryID = SalesPerson.TerritoryID
WHERE Territory.SalesYTD = 
(SELECT MAX(SalesYTD) FROM Sales.SalesTerritory)

CREATE FUNCTION dbo.GetTerritoryName(@TerritoryID int) 
RETURNS NVARCHAR(100)
AS 
BEGIN  
    DECLARE @TerritoryName NVARCHAR(100);
    SELECT @TerritoryName = CONCAT(Name, ' ', CountryRegionCode)
    FROM Sales.SalesTerritory 
    WHERE TerritoryID = @TerritoryID;
IF (@TerritoryName IS NULL)
RETURN CAST('INVALID TERRITORY ID' AS INT);
    RETURN @TerritoryName;
END;


--3
what is the average total of the top product 

CREATE FUNCTION f_getProdCategoryInventoryCount(
    @productCategoryID INT
)
RETURNS INTEGER
AS 

BEGIN
	DECLARE @productCount INTEGER;
	select @productCount = 
				sum(PI.Quantity) 
				from Production.Product P
					join Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
					join Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
					join Production.ProductInventory PI ON pi.ProductID = p.ProductID
				where pc.ProductCategoryID = @productCategoryID;
	RETURN @productCount;
END;

with cte_ProductCategoryAvgTotals as
(
	select ProductCategory, Avg_total, DBO.f_getProdCategoryInventoryCount(ProductCategoryID) as Inventory
	from (
	   select ProductCategoryID, ProductCategory, AVG(LineTotal) as Avg_Total
		from (
			select PC.ProductCategoryID, PC.Name as ProductCategory, SO.LineTotal
			from Production.Product P
				join Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
				join Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
				join Production.ProductInventory PI ON pi.ProductID = p.ProductID
				JOIN Sales.SalesOrderDetail SO ON SO.ProductID = P.ProductID) X
		group by ProductCategoryID, ProductCategory ) r
)
select ProductCategory, Avg_total, Inventory
from cte_ProductCategoryAvgTotals
where Avg_total = (
	select max(Avg_total)
	from cte_ProductCategoryAvgTotals)

--4 find the top 5 sellers and make a function that gives thems 5% pay increase



select *
from  Sales.SalesPerson s inner join HumanResources.

CREATE FUNCTION f_givepay_raise(
    @CRATE DECIMAL(9,2)
)
RETURNS INTEGER
AS 
BEGIN
	DECLARE @RETURN_VALUE DECIMAL(9,2);
	SET @RETURN_VALUE = @CRATE + (@CRATE*0.05);
	RETURN @RETURN_VALUE
END;


select TOP (5) A.BusinessEntityID,
				D.FIRSTNAME,
				D.LASTNAME,
				RATE, 
				FORMAT(SALESQUOTA,'C') AS 'SALES QUOTA', 
				FORMAT(SalesYTD,'C') AS 'SALES YTD',
				F_GIVEPAY_RAISE(RATE) AS 'NEW RATE'
from HumanResources.employeepayhistory A,
	 (select distinct BusinessEntityID, max(modifieddate) as max_date
		from HumanResources.EmployeePayHistory
		group by BusinessEntityID) B,
	 SALES.SALESPERSON C,
	 PERSON.PERSON D
WHERE A.BusinessEntityID = B.BusinessEntityID
  AND A.ModifiedDate = B.max_date
  AND A.BusinessEntityID = C.BusinessEntityID
  AND C.SALESYTD >= SALESQUOTA
  AND D.BusinessEntityID = A.BusinessEntityID
ORDER BY SALESYTD DESC
;



--5 write a function that gives the top 5 sales person a  * .05 pay increase if they meet their quota

CREATE FUNCTION f_givepay_raise2(
    @CRATE DECIMAL(9,2)
)
RETURNS INTEGER
AS 
BEGIN
	DECLARE @RETURN_VALUE DECIMAL(9,2);
	SET @RETURN_VALUE = @CRATE + (@CRATE*0.05);
	RETURN @RETURN_VALUE
END;
GO
select TOP (5)  A.BusinessEntityID,
				D.FIRSTNAME,
				D.LASTNAME,
				RATE, 
				FORMAT(SALESQUOTA,'C') AS 'SALES QUOTA', 
				FORMAT(SalesYTD,'C') AS 'SALES YTD',
				DBO.f_givepay_raise2(RATE) AS 'NEW RATE'
from HumanResources.employeepayhistory A,
	 (select distinct BusinessEntityID, max(modifieddate) as max_date
		from HumanResources.EmployeePayHistory
		group by BusinessEntityID) B,
	 SALES.SALESPERSON C,
	 PERSON.PERSON D
WHERE A.BusinessEntityID = B.BusinessEntityID
  AND A.ModifiedDate = B.max_date
  AND A.BusinessEntityID = C.BusinessEntityID
  AND C.SALESYTD >= SALESQUOTA
  AND D.BusinessEntityID = A.BusinessEntityID
ORDER BY SALESYTD DESC
;

--6 create a function that decrease the pay rate of the top 3 less sales person


CREATE FUNCTION f_givepay_decrease(
    @CRATE DECIMAL(9,2)
)
RETURNS INTEGER
AS 
BEGIN
	DECLARE @RETURN_VALUE DECIMAL(9,2);
	SET @RETURN_VALUE = @CRATE - (@CRATE*0.05);
	RETURN @RETURN_VALUE
END;
GO
select  A.BusinessEntityID,
				D.FIRSTNAME,
				D.LASTNAME,
				RATE, 
				FORMAT(SALESQUOTA,'C') AS 'SALES QUOTA', 
				FORMAT(SalesYTD,'C') AS 'SALES YTD',
				DBO.f_givepay_decrease(RATE) AS 'NEW RATE'
from HumanResources.employeepayhistory A,
	 (select distinct BusinessEntityID, max(modifieddate) as max_date
		from HumanResources.EmployeePayHistory
		group by BusinessEntityID) B,
	 SALES.SALESPERSON C,
	 PERSON.PERSON D
WHERE A.BusinessEntityID = B.BusinessEntityID
  AND A.ModifiedDate = B.max_date
  AND A.BusinessEntityID = C.BusinessEntityID
  AND C.SALESYTD < 1000000
  --AND C.SALESYTD < SALESQUOTA
  AND D.BusinessEntityID = A.BusinessEntityID
ORDER BY SALESYTD 
;

--7 find all the workers who stayed in the department for more than one year and give them a  .05 pay increase

CREATE FUNCTION f_empCurrentRate(
    @BusinessEntityID INTEGER
)
RETURNS DECIMAL(9,2)
AS 
BEGIN
	DECLARE @RETURN_VALUE DECIMAL(9,2);

	SELECT @RETURN_VALUE = eph.rate 
	FROM HumanResources.EmployeePayHistory EPH
	WHERE EPH.BusinessEntityID = @BusinessEntityID
	AND eph.RateChangeDate = (
		select max(RateChangeDate)
		from HumanResources.EmployeePayHistory EPH2
		where eph2.BusinessEntityID = eph.BusinessEntityID);

	RETURN @RETURN_VALUE
END;


with cte_empDeptStartDt as
(
	SELECT ed.BusinessEntityID, p.FirstName, p.LastName, ed.StartDate, ed.DepartmentID, d.Name as deptName
	from HumanResources.EmployeeDepartmentHistory ed 
		join HumanResources.Employee e on ed.BusinessEntityID = e.BusinessEntityID 
		join Person.Person P ON p.BusinessEntityID = e.BusinessEntityID
		join HumanResources.Department D ON d.DepartmentID = ed.DepartmentID
)
select BusinessEntityID, FirstName, LastName, StartDate, DepartmentID, deptName,
	CurrentRate, CurrentRate + (CurrentRate * .05) as payIncrease
from (
	select BusinessEntityID, FirstName, LastName, StartDate, DepartmentID, deptName, 
		dbo.f_empCurrentRate (C.BusinessEntityID) as CurrentRate	
	from cte_empDeptStartDt c
	where StartDate = (
		select max(StartDate)
		from cte_empDeptStartDt c2
		where c.BusinessEntityID = c2.BusinessEntityID)) x
where datediff(day, StartDate, getdate()) > 365


