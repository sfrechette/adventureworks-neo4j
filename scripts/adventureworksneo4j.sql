--Customers
SELECT	p.BusinessEntityID AS 'CustomerID',
		p.FirstName,
		p.LastName,
		p.FirstName + ' ' + LastName AS 'FullName'
FROM	Person.Person p
WHERE	p.BusinessEntityID IN (	SELECT	DISTINCT (p.BusinessEntityID)
								FROM	Sales.SalesOrderHeader oh JOIN
										Sales.Customer c ON oh.CustomerID = c.CustomerID JOIN
										Person.Person p ON c.PersonID = p.BusinessEntityID
								WHERE	oh.OnlineOrderFlag = 0)

--Product
SELECT	p.ProductID, 
		p.ProductNumber,
		p.Name AS 'ProductName',
		m.Name AS 'ModelName',
		p.MakeFlag,
		p.StandardCost,
		p.ListPrice,
		--p.Size,
		--p.Color,
		p.ProductSubcategoryID	
FROM	Production.Product p JOIN
		Production.ProductModel m ON p.ProductModelID = m.ProductModelID	
WHERE	p.ProductSubcategoryID IS NOT NULL

--ProductSubCategory
SELECT	ProductSubCategoryID AS 'SubCategoryID', 
		ProductCategoryID AS 'CategoryID',
		Name AS 'SubCategoryName'
FROM	Production.ProductSubcategory

--ProductCatetory
SELECT	ProductCategoryID AS 'CategoryID', 
		Name AS 'CategoryName'
FROM	Production.ProductCategory

--Vendor
SELECT	BusinessEntityID AS 'VendorID',
		Name AS 'VendorName', 
		AccountNumber,
		CreditRating,
		ActiveFlag
FROM	Purchasing.Vendor

--VendorProduct
SELECT	ProductID, 
		BusinessEntityID AS 'VendorID'
FROM	Purchasing.ProductVendor

--Employee
SELECT	p.BusinessEntityID AS 'EmployeeID',
		CASE 
			WHEN [Group] = 'North America' THEN 274
			WHEN [Group] = 'Pacific' THEN 285
			WHEN [Group] = 'Europe' THEN 287
		ELSE
			NULL 
		END 'ManagerID',
		p.FirstName, 
		p.LastName,
		p.FirstName + ' ' + LastName AS 'FullName',
		e.JobTitle,
		e.OrganizationLevel,
		e.MaritalStatus,
		e.Gender,
		t.Name AS 'Territory', 
		t.CountryRegionCode AS 'Country',
		t.[Group]
FROM	Person.Person p JOIN
		HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID JOIN
        Sales.SalesPerson s ON e.BusinessEntityID = s.BusinessEntityID LEFT JOIN
        Sales.SalesTerritory t ON s.TerritoryID = t.TerritoryID
WHERE	p.BusinessEntityID IN (	SELECT	DISTINCT(o.SalesPersonID) AS 'EmployeeID'
								FROM	Sales.SalesOrderHeader o
								WHERE	o.OnlineOrderFlag = 0)

--Sales
SELECT	oh.SalesOrderID,
		od.SalesOrderDetailID,
		CAST(oh.OrderDate AS DATE) AS 'OrderDate', 
		CAST(oh.DueDate AS DATE) AS 'DueDate', 
		CAST(oh.ShipDate AS DATE) AS 'ShipDate',
		oh.SalesPersonID AS 'EmployeeID',
		oh.CustomerID,
		oh.SubTotal,
		oh.TaxAmt,
		oh.Freight,
		oh.TotalDue,
		od.ProductID,
		od.OrderQty,
		od.UnitPrice,
		od.UnitPriceDiscount,
		od.LineTotal
FROM	Sales.SalesOrderHeader oh LEFT OUTER JOIN
		Sales.SalesOrderDetail od ON oh.SalesOrderID = od.SalesOrderID
WHERE	oh.OnlineOrderFlag = 0



