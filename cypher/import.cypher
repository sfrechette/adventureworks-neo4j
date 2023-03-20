// Create indexes for faster lookup
CREATE INDEX Category_categoryName FOR (c:Category) ON (c.categoryName);
CREATE INDEX SubCategory_subCategoryName FOR (s:SubCategory) ON (s.subCategoryName);
CREATE INDEX Vendor_vendorName FOR (v:Vendor) ON (v.vendorName);
CREATE INDEX Product_productName FOR (p:Product) ON (p.productName);

// Create constraints
CREATE CONSTRAINT Order_orderId IF NOT EXISTS FOR (o:Order) REQUIRE o.orderId IS NODE KEY;
CREATE CONSTRAINT Product_productId IF NOT EXISTS FOR (p:Product) REQUIRE p.productId IS NODE KEY;
CREATE CONSTRAINT Category_categoryId IF NOT EXISTS FOR (c:Category) REQUIRE c.categoryId IS NODE KEY;
CREATE CONSTRAINT Subcategory_subcategoryId IF NOT EXISTS FOR (s:SubCategory) REQUIRE s.subCategoryId IS NODE KEY;
CREATE CONSTRAINT Employee_employeeId IF NOT EXISTS FOR (e:Employee) REQUIRE e.employeeId IS NODE KEY;
CREATE CONSTRAINT Vendor_vendorId IF NOT EXISTS FOR (v:Vendor) REQUIRE v.vendorId IS NODE KEY;
CREATE CONSTRAINT Customer_customerId IF NOT EXISTS FOR (c:Customer) REQUIRE c.customerId IS NODE KEY;

// Create products
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/products.csv" as row
CALL {
	WITH row
	CREATE (:Product {productName: row.ProductName, productNumber: row.ProductNumber, productId: row.ProductID, modelName: row.ProductModelName, standardCost: row.StandardCost, listPrice: row.ListPrice})
} IN TRANSACTIONS OF 1000 ROWS

// Create vendors
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/vendors.csv" as row
CALL {
	WITH row
	CREATE (:Vendor {vendorName: row.VendorName, vendorNumber: row.AccountNumber, vendorId: row.VendorID, creditRating: row.CreditRating, activeFlag: row.ActiveFlag})
} IN TRANSACTIONS OF 1000 ROWS

// Create employees
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/employees.csv" as row
CALL {
	WITH row
	CREATE (:Employee {firstName: row.FirstName, lastName: row.LastName, fullName: row.FullName, employeeId: row.EmployeeID, jobTitle: row.JobTitle, organizationLevel: row.OrganizationLevel, maritalStatus: row.MaritalStatus, gender: row.Gender, territory: row.Territory, country: row.Country, group: row.Group})
} IN TRANSACTIONS OF 1000 ROWS

// Create customers
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/customers.csv" as row
CALL {
	WITH row
	CREATE (:Customer {firstName: row.FirstName, lastName: row.LastName, fullName: row.FullName, customerId: row.CustomerID})
} IN TRANSACTIONS OF 1000 ROWS

// Create categories
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/productcategories.csv" as row
CALL {
	WITH row
	CREATE (:Category {categoryName: row.CategoryName, categoryId: row.CategoryID})
} IN TRANSACTIONS OF 1000 ROWS

// Create sub-categories
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/productsubcategories.csv" as row
CALL {
	WITH row
	CREATE (:SubCategory {subCategoryName: row.SubCategoryName, subCategoryId: row.SubCategoryID})
} IN TRANSACTIONS OF 1000 ROWS

// Prepare orders
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/orders.csv" as row
CALL {
	WITH row
	MERGE (order:Order {orderId: row.SalesOrderID}) ON CREATE SET order.orderDate =  row.OrderDate
} IN TRANSACTIONS OF 1000 ROWS

// Create relationships: Order to Product
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/orders.csv" as row
CALL {
	WITH row
	MATCH (order:Order {orderId: row.SalesOrderID})
	MATCH (product:Product {productId: row.ProductID})
	MERGE (order)-[pu:PRODUCT]->(product)
	ON CREATE SET pu.unitPrice = toFloat(row.UnitPrice), pu.quantity = toFloat(row.OrderQty)
} IN TRANSACTIONS OF 1000 ROWS

// Create relationships: Order to Employee
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/orders.csv" as row
CALL {
	WITH row
    MATCH (order:Order {orderId: row.SalesOrderID})
    MATCH (employee:Employee {employeeId: row.EmployeeID})
    MERGE (employee)-[:SOLD]->(order)
} IN TRANSACTIONS OF 1000 ROWS

// Create relationships: Order to Customer
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/orders.csv" as row
CALL {
	WITH row
    MATCH (order:Order {orderId: row.SalesOrderID})
    MATCH (customer:Customer {customerId: row.CustomerID})
    MERGE (customer)-[:PURCHASED]->(order)
} IN TRANSACTIONS OF 1000 ROWS

// Create relationships: Product to Vendor
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/vendorproduct.csv" as row
CALL {
	WITH row
    MATCH (product:Product {productId: row.ProductID})
    MATCH (vendor:Vendor {vendorId: row.VendorID})
    MERGE (vendor)-[:SUPPLIES]->(product)
} IN TRANSACTIONS OF 1000 ROWS

// Create relationships: Product to SubCategory
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/products.csv" as row
CALL {
	WITH row
    MATCH (product:Product {productId: row.ProductID})
    MATCH (subcategory:SubCategory {subCategoryId: row.SubCategoryID})
    MERGE (product)-[:PART_OF_SUBCAT]->(subcategory)
} IN TRANSACTIONS OF 1000 ROWS

// Create relationships: SubCategory to Category
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/productsubcategories.csv" as row
CALL {
	WITH row
    MATCH (subcategory:SubCategory {subCategoryId: row.SubCategoryID})
    MATCH (category:Category {categoryId: row.CategoryID})
    MERGE (subcategory)-[:PART_OF_CAT]->(category)
} IN TRANSACTIONS OF 1000 ROWS

// Create relationship for employee reporting structure
:auto
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sfrechette/adventureworks-neo4j/master/data/employees.csv" as row
CALL {
	WITH row
    MATCH (employee:Employee {employeeId: row.EmployeeID})
    MATCH (manager:Employee {employeeId: row.ManagerID})
    MERGE (employee)-[:REPORTS_TO]->(manager)
} IN TRANSACTIONS OF 1000 ROWS
