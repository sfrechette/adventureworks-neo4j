MATCH (p:Product)-->(s:SubCategory)-->(c:Category)
RETURN p, s, c;

MATCH (s:SubCategory)-->(c:Category)
RETURN s, c;

MATCH (o:Order)-[r:PRODUCT]->(p:Product {productName: "Long-Sleeve Logo Jersey, L"})
RETURN COUNT(o.orderId) as Count;

MATCH (o:Order)-[r:PRODUCT]->(p:Product) 
WHERE p.productName = "Long-Sleeve Logo Jersey, L"
RETURN COUNT(o.orderId) as Count;

//
MATCH  (e:Employee)<-[:REPORTS_TO]-(sub)
RETURN sub.fullName AS Employee, e.fullName AS Manager;

//
MATCH (e:Employee)
OPTIONAL MATCH (e)<-[:REPORTS_TO*0..]-(sub)-[:SOLD]->(order)
RETURN e.fullName as Employee, [x IN COLLECT(DISTINCT sub.fullName) WHERE x <> e.fullName] AS Reports, COUNT(distinct order) AS TotalOrders
ORDER BY TotalOrders DESC;



// List the product subcategories and categories provided by each supplier.
MATCH (v:Vendor)-->(:Product)-->(s:SubCategory)-->(c:Category)
RETURN v.vendorName as Vendor, collect(distinct s.subCategoryName) as SubCategories, collect(distinct c.categoryName) as Categories;

// List the total products purchased for a given product for each customer
MATCH (c:Customer)-[:PURCHASED]->(:Order)-[o:PRODUCT]->(p:Product {productName: "Sport-100 Helmet, Black"})
RETURN DISTINCT c.fullName as Customer, SUM(o.quantity) AS TotalProductsPurchased
ORDER BY TotalProductsPurchased DESC;

// List the total products purchased for a given subcategory for each customer
MATCH (c:Customer)-[:PURCHASED]->(:Order)-[o:PRODUCT]->(p:Product),
      (p)-[:PART_OF_SUBCAT]->(s:SubCategory {subCategoryName:"Mountain Bikes"})
RETURN DISTINCT c.fullName as Customer, SUM(o.quantity) AS TotalProductsPurchased
ORDER BY TotalProductsPurchased DESC;

// List the total products purchased for a given category for each customer
MATCH (c:Customer)-[:PURCHASED]->(:Order)-[o:PRODUCT]->(p:Product),
      (p)-[:PART_OF_SUBCAT]->(:SubCategory)-[:PART_OF_CAT]->(cat:Category {categoryName:"Components"})
RETURN DISTINCT c.fullName as Customer, SUM(o.quantity) AS TotalProductsPurchased
ORDER BY TotalProductsPurchased DESC;

// Which Employee had the Highest Cross-Selling Count of 'AWC Logo Cap' and Which Product?
MATCH (p:Product {productName:'AWC Logo Cap'})<-[:PRODUCT]-(:Order)<-[:SOLD]-(employee),
      (employee)-[:SOLD]->(o2)-[:PRODUCT]->(other:Product)
RETURN employee.fullName as Employee, other.productName as Product, count(distinct o2) as Count
ORDER BY Count DESC
LIMIT 5;
