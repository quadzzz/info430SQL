/*
1. a). Focusing on FactResellerSales and the associated dimension tables, write a SQL query
that Leverages ROLLUP function to return SalesTerritoryRegion AS Region,
EnglishProductCategoryName AS [Category Name], EnglishProductName AS [Product
Name], and the total sales for U.S. regions. The Excerpt below shows sample output (hint:
there should be altogether 1248 rows)
*/

SELECT 
    dst.SalesTerritoryRegion AS Region,
    dpc.EnglishProductCategoryName AS [Category Name],
    dp.EnglishProductName AS [Product Name],
    SUM(fr.SalesAmount) AS [Total Sales]
FROM 
    FactResellerSales fr
JOIN 
    DimSalesTerritory dst ON fr.SalesTerritoryKey = dst.SalesTerritoryKey
JOIN 
    DimProduct dp ON fr.ProductKey = dp.ProductKey
JOIN 
    DimProductSubCategory dpsc on dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
JOIN 
    DimProductCategory dpc on dpsc.ProductCategoryKey = dpc.ProductCategoryKey
JOIN 
    DimGeography dg ON dst.SalesTerritoryKey = dg.SalesTerritoryKey
WHERE 
    dg.CountryRegionCode = 'US'
GROUP BY 
    ROLLUP(dst.SalesTerritoryRegion, dpc.EnglishProductCategoryName, dp.EnglishProductName)
HAVING 
    SUM(fr.SalesAmount) IS NOT NULL
ORDER BY 
    dst.SalesTerritoryRegion, dpc.EnglishProductCategoryName, dp.EnglishProductName;


/*
b). Once of the main advantages of OLAP is that we can perform multidimensional analysis more
efficiently. Copy the code of your query from a) above and convert it into a temporary table.
Leverage ROLLUP results from the temporary table to return regional sales, grand sales, and
percentage shared of each region’s sales in grand total sales. Return total sales formatted as U.S.
dollar amounts. Order the results by percentage sales share (hint: you may need to use COALESCE
and FORMAT functions to present the results in a format showed below).
*/
-- Step 1: Create a temporary table to store the intermediate results
WITH SalesCTE AS (
    SELECT 
        dst.SalesTerritoryRegion AS Region,
        SUM(fr.SalesAmount) AS TotalSales
    FROM 
        FactResellerSales fr
    JOIN 
        DimSalesTerritory dst ON fr.SalesTerritoryKey = dst.SalesTerritoryKey
    JOIN 
        DimProduct dp ON fr.ProductKey = dp.ProductKey
    JOIN 
        DimProductSubCategory dpsc ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
    JOIN 
        DimProductCategory dpc ON dpsc.ProductCategoryKey = dpc.ProductCategoryKey
    JOIN 
        DimGeography dg ON dst.SalesTerritoryKey = dg.SalesTerritoryKey
    WHERE 
        dg.CountryRegionCode = 'US'
    GROUP BY 
        ROLLUP(dst.SalesTerritoryRegion)
    HAVING 
        SUM(fr.SalesAmount) IS NOT NULL
)
SELECT 
    COALESCE(Region, 'Grand Total') AS Region,
    FORMAT(TotalSales, 'C', 'en-US') AS [Total Sales],
    FORMAT(100.0 * TotalSales / 
        (SELECT SUM(TotalSales) FROM SalesCTE WHERE Region IS NULL), 'N2') AS [Pct. Sales Share]
FROM 
    SalesCTE
ORDER BY 
    CASE WHEN Region IS NULL THEN 1 ELSE 0 END, [Pct. Sales Share] DESC;


/*
2. Again, focusing on FactResellerSales, the associated dimension tables and the U.S. only,
write a SQL query to return SalesTerritoryRegion AS Region, EnglishProductCategoryName
AS [Category Name], EnglishProductName AS [Product Name], the total sales for each
product, and sales rank for the top 5 products sold in each region based on total sales.
Again, return total sales formatted as U.S. dollar amounts. Your output should look the excerpt
below (hint: there should be 100 rows in total)
*/
-- Step 1: Create a temporary table to store the intermediate results
WITH SalesCTE AS (
    SELECT 
        dst.SalesTerritoryRegion AS Region,
        dpc.EnglishProductCategoryName AS [Category Name],
        dp.EnglishProductName AS [Product Name],
        SUM(fr.SalesAmount) AS TotalSales
    FROM 
        FactResellerSales fr
    JOIN 
        DimSalesTerritory dst ON fr.SalesTerritoryKey = dst.SalesTerritoryKey
    JOIN 
        DimProduct dp ON fr.ProductKey = dp.ProductKey
    JOIN 
        DimProductSubCategory dpsc ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
    JOIN 
        DimProductCategory dpc ON dpsc.ProductCategoryKey = dpc.ProductCategoryKey
    JOIN 
        DimGeography dg ON dst.SalesTerritoryKey = dg.SalesTerritoryKey
    WHERE 
        dg.CountryRegionCode = 'US'
    GROUP BY 
        dst.SalesTerritoryRegion, dpc.EnglishProductCategoryName, dp.EnglishProductName
    HAVING 
        SUM(fr.SalesAmount) IS NOT NULL
),
RankedSales AS (
    SELECT 
        Region,
        [Category Name],
        [Product Name],
        TotalSales,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY TotalSales DESC) AS SalesRank
    FROM 
        SalesCTE
)
SELECT 
    Region,
    [Category Name],
    [Product Name],
    FORMAT(TotalSales, 'C', 'en-US') AS Sales,
    SalesRank AS Ranking
FROM 
    RankedSales
WHERE 
    SalesRank <= 5
ORDER BY 
    Region, SalesRank;


/*
3. a). Again, focusing on FactResellerSales and the associated dimension tables, write a SQL
query that Leverages CUBE function to return SalesTerritoryRegion AS Region,
EnglishProductCategoryName AS [Category Name], EnglishProductName AS [Product
Name], and the total sales for U.S. regions. Save/store the results of this query in a
temporary table (hint: the temporary table should have 2972 rows in total).
*/ 
-- Step 1: Create a temporary table to store the intermediate results
CREATE TABLE #SalesCube (
    Region NVARCHAR(50),
    [Category Name] NVARCHAR(50),
    [Product Name] NVARCHAR(100),
    TotalSales MONEY
);

-- Step 2: Insert the results of the CUBE operation into the temporary table
INSERT INTO #SalesCube
SELECT 
    dst.SalesTerritoryRegion AS Region,
    dpc.EnglishProductCategoryName AS [Category Name],
    dp.EnglishProductName AS [Product Name],
    SUM(fr.SalesAmount) AS TotalSales
FROM 
    FactResellerSales fr
JOIN 
    DimSalesTerritory dst ON fr.SalesTerritoryKey = dst.SalesTerritoryKey
JOIN 
    DimProduct dp ON fr.ProductKey = dp.ProductKey
JOIN 
    DimProductSubCategory dpsc ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
JOIN 
    DimProductCategory dpc ON dpsc.ProductCategoryKey = dpc.ProductCategoryKey
JOIN 
    DimGeography dg ON dst.SalesTerritoryKey = dg.SalesTerritoryKey
WHERE 
    dg.CountryRegionCode = 'US'
GROUP BY 
    CUBE(dst.SalesTerritoryRegion, dpc.EnglishProductCategoryName, dp.EnglishProductName)
HAVING 
    SUM(fr.SalesAmount) IS NOT NULL;

-- Verify the number of rows inserted
SELECT COUNT(*) FROM #SalesCube;


/*
b). Leveraging OLAP CUBE results from the temporary table in a) above write a query to
return Region product name and sales (once again, sales should be formatted as U.S. dollar
values) for the Central U.S. region only. The last row should display regional total for the
Central region. The excerpt below shows the last 10 rows of results (hint: may have to use
CASE statement to display the results in the format shown for the regional total row) .
*/ 
-- Step 1: Query to get the sales data for the Central region
SELECT 
    COALESCE(Region, '-') AS Region,
    [Product Name],
    FORMAT(TotalSales, 'C', 'en-US') AS [Total Sales],
    0 AS SortOrder
FROM 
    #SalesCube
WHERE 
    Region = 'Central'

UNION ALL

-- Step 2: Add the regional total for the Central region
SELECT 
    '-', 
    'Region Total',
    FORMAT(SUM(TotalSales), 'C', 'en-US') AS [Total Sales],
    1 AS SortOrder
FROM 
    #SalesCube
WHERE 
    Region = 'Central'

-- Order the results
ORDER BY 
    SortOrder, 
    [Product Name];

-- Clean up the temporary table
DROP TABLE #SalesCube;


/*
4. Leveraging the FactInternetSales table and the relevant dimensions, write a query to return
EnglishProductSubCategoryName AS [Subcategory Name] and the average percentage change in
CalendarQuarter Sales. Note: Use OrderDateKey in the FactInternetSales table for join operation
involving Date dimension. Sort the results in descending order of the average percentage change in
CalendarQuarter Sales and limit the output to only product subcategories with average percentage
change in CalendarQuarter Sales of at least 5 percent. The output for the average percentage
change in CalendarQuarter Sales should be displayed rounded to 2 decimal places. Your output
should be as shown in the table below
*/ 
WITH QuarterlySales AS (
    SELECT 
        dpsc.EnglishProductSubCategoryName AS [Subcategory Name],
        dd.CalendarQuarter,
        SUM(fis.SalesAmount) AS TotalSales
    FROM 
        FactInternetSales fis
    JOIN 
        DimProduct dp ON fis.ProductKey = dp.ProductKey
    JOIN 
        DimProductSubCategory dpsc ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
    JOIN 
        DimDate dd ON fis.OrderDateKey = dd.DateKey
    GROUP BY 
        dpsc.EnglishProductSubCategoryName, dd.CalendarQuarter
),
QuarterlyChange AS (
    SELECT 
        [Subcategory Name],
        CalendarQuarter,
        TotalSales,
        LAG(TotalSales) OVER (PARTITION BY [Subcategory Name] ORDER BY CalendarQuarter) AS PrevTotalSales
    FROM 
        QuarterlySales
),
PercentageChange AS (
    SELECT 
        [Subcategory Name],
        CalendarQuarter,
        ((TotalSales - PrevTotalSales) / PrevTotalSales) * 100.0 AS PctChange
    FROM 
        QuarterlyChange
    WHERE 
        PrevTotalSales IS NOT NULL
),
AveragePctChange AS (
    SELECT 
        [Subcategory Name],
        AVG(PctChange) AS avg_pct_chg_qtry_sales
    FROM 
        PercentageChange
    GROUP BY 
        [Subcategory Name]
)
SELECT 
    [Subcategory Name],
    ROUND(avg_pct_chg_qtry_sales, 2) AS avg_pct_chg_qtry_sales
FROM 
    AveragePctChange
WHERE 
    avg_pct_chg_qtry_sales >= 5
ORDER BY 
    avg_pct_chg_qtry_sales DESC;
