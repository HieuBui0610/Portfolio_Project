/* Bài 1: 
With hay as (SELECT factin.ProductKey 
,dimp.EnglishProductName as ProductName
,dimp.Color as ProductColor
,Month(factin.shipdate) as monthship
,YEAR(factin.ShipDate) as yearship
,dimp.ProductSubcategoryKey
,factin.OrderQuantity
,factin.CustomerKey
from FactInternetSales as factin
LEFT join DimProduct as dimp on dimp.ProductKey = factin.ProductKey
Where Month(factin.ShipDate) IN ('1','2','3') and YEAR(factin.ShipDate) LIKE '2013'
AND dimp.Color NOT LIKE 'Silver' AND dimp.ProductSubcategoryKey NOT LIKE '20')

select hay.ProductKey, hay.ProductName, hay.ProductColor
,sum(hay.OrderQuantity) as No_Order
,COUNT(hay.CustomerKey) as No_Customer
from hay
GROUP by hay.ProductKey,hay.ProductName,hay.ProductColor

Bai 2: 

With inre as(
SELECT factin.ShipDate  
,YEAR(factin.ShipDate) as YearReport
,MONTH(factin.ShipDate) as MonthReport
,dimps.EnglishProductSubcategoryName as ProductSubcategoryName
,Sum(factin.SalesAmount) as intersale
,sum(factin.OrderQuantity) as NoOrder
,COUNT(factin.CustomerKey) as NoCustomer
from FactInternetSales as factin
LEFT JOIN FactResellerSales as factre on factre.ProductKey = factin.ProductKey
LEFT JOIN DimProduct as dimp on dimp.ProductKey = factin.ProductKey
LEFT JOin DimProductSubcategory as dimps on dimps.ProductSubcategoryKey = dimp.ProductSubcategoryKey
GROUP By YEAR(factin.ShipDate)
,MONTH(factin.ShipDate)
,dimps.EnglishProductSubcategoryName,factin.ShipDate

UNION all 

SELECT factre.ShipDate 
,YEAR(factre.ShipDate) as YearReport
,Month(factre.ShipDate) as MonthReport
,dimps.EnglishProductSubcategoryName as ProductSubcategoryName
,Sum(factre.SalesAmount) as resale
,sum(factre.OrderQuantity) as NoOrder
,COUNT(factre.CustomerPONumber) as NoCustomer
from FactResellerSales as factre
LEFT JOIN FactInternetSales as factin on factre.ProductKey = factin.ProductKey
LEFT JOIN DimProduct as dimp on dimp.ProductKey = factre.ProductKey
LEFT JOin DimProductSubcategory as dimps on dimps.ProductSubcategoryKey = dimp.ProductSubcategoryKey
group by YEAR(factre.ShipDate)
,Month(factre.ShipDate)
,dimps.EnglishProductSubcategoryName
,factre.ShipDate
)
, interet as (
    SELECT YearReport
    ,dimps.EnglishProductSubcategoryName
    , SUM(factin2.SalesAmount) as InternetTotalsales
    from inre as inree
    LEFT JOIN FactInternetSales as factin2 on factin2.ShipDate = inree.ShipDate
    LEFT JOIN DimProduct as dimp on dimp.ProductKey = factin2.ProductKey
LEFT JOin DimProductSubcategory as dimps on dimps.ProductSubcategoryKey = dimp.ProductSubcategoryKey
    GROUP By YearReport,dimps.EnglishProductSubcategoryName
)
, reseller as (
    SELECT YearReport
    ,dimps.EnglishProductSubcategoryName
    , SUM(factre2.SalesAmount) as ResellerTotalsales
    from inre as inree
    LEFT JOIN FactResellerSales as factre2 on factre2.ShipDate = inree.ShipDate
    LEFT JOIN DimProduct as dimp on dimp.ProductKey = factre2.ProductKey
LEFT JOin DimProductSubcategory as dimps on dimps.ProductSubcategoryKey = dimp.ProductSubcategoryKey
    GROUP By YearReport,dimps.EnglishProductSubcategoryName
)

SELECT inreee.YearReport
,inreee.MonthReport
,inreee.ProductSubcategoryName
,inter.InternetTotalsales
,rese.ResellerTotalsales
,inreee.NoOrder
,inreee.NoCustomer
from inre as inreee
LEFT JOIN interet as inter on inter.YearReport = inreee.YearReport and inter.EnglishProductSubcategoryName = inreee.ProductSubcategoryName
LEFT JOIN reseller as rese on rese.YearReport = inreee.YearReport and rese.EnglishProductSubcategoryName = inreee.ProductSubcategoryName
ORDER by YearReport DEsc, MonthReport DESC

Bai 5: 

WITH allsale as (

select YEAR(OrderDate) as yearorder
,MONTH(OrderDate) as monthorder
,'Internet' as SalesChannel
,COUNT(FactInternetSales.OrderDate) as NewOrder
,count(FactInternetSales.ShipDate) as ShipedOrder
,sum(FactInternetSales.SalesAmount) as total_sales
,SUM(FactInternetSales.DiscountAmount) as total_discount
,SUM(FactInternetSales.totalProductcost) as total_cost
from FactInternetSales 
GROUP By YEAR(OrderDate)
,MONTH(OrderDate) 

UNION all 

select YEAR(OrderDate) as yearorder
,MONTH(OrderDate) as monthorder
,'Reseller' as SalesChannel
,COUNT(FactResellerSales.OrderDate) as NewOrder
,count(FactResellerSales.ShipDate) as ShipedOrder
,sum(FactResellerSales.SalesAmount) as total_sales
,SUM(FactResellerSales.DiscountAmount) as total_discount
,sum(FactResellerSales.totalProductcost) as total_cost
from FactResellerSales 
GROUP By YEAR(OrderDate)
,MONTH(OrderDate)  
)

SELECT yearorder
,monthorder
,SalesChannel
,NewOrder
,ShipedOrder
,FORMAT(total_discount/total_sales,'P') as DiscountPercentage
,(total_sales-total_cost)/total_sales as Profitmargin
,row_number() Over(PARTITION By yearorder,SalesChannel order by total_sales DESC) as SalesAmountRankingByYear
From allsale
order by yearorder DESC, monthorder DESC

Bai 3:

With intersale as (
SELECT CONVERT(VARCHAR(10),orderdate,23) as OrderDate
,case orderdate 
when 'DD'-'MM' IN ('22-12','05-01') then '0' ELSE '1' end as Isworkingday
,Sum(salesamount) as InternetSalestotal
,Count(OrderQuantity) as InternetNoOrder
from FactInternetSales
GROUP By CONVERT(VARCHAR(10),orderdate,23)
)

, reseller as (
SELECT CONVERT(VARCHAR(10),FactResellerSales.orderDate,23) as OrderDate
,when 'DD'-'MM' IN ('22-12','05-01') then '0' ELSE '1' end as Isworkingday
,Sum(salesamount) as ResellerSalestotal
,Count(OrderQuantity) as ResellerNoOrder
from FactResellerSales
GROUP By CONVERT(VARCHAR(10),orderdate,23)
)

SELECT inter.orderdate
, Isworkingday
,inter.InternetSalestotal
,inter.internetNoOrder
,resell.ResellerSalestotal
,resell.ResellerNoOrder
from intersale as inter 
Full OUTER JOIN reseller as resell on resell.orderdate = inter.orderdate

*/
