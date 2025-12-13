/* 1. Use existing database */
USE sales_analysis_db;
GO

/* 2. Drop tables only if they exist (safe reset) */
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
GO

/* 3. Recreate tables */

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    product_id INT,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
GO
SELECT name FROM sys.tables;
USE sales_analysis_db;
GO
INSERT INTO Customers VALUES
(1, 'Rohit Sharma', 'Cricketer', 'Mumbai', 'Maharashtra'),
(2, 'Harmanpreeet Kaur', 'Cricketer', 'Punjab', 'Punjab'),
(3, 'Virat Kohli', 'Cricketer', 'Delhi', 'Delhi'),
(4, 'Kriti Sanon', 'Actress', 'Mumbai', 'Maharashtra'),
(5, 'Sanman Kadam', 'Corporate', 'Mumbai', 'Maharashtra');
INSERT INTO Products VALUES
(101, 'Laptop', 'Technology', 'Computers'),
(102, 'Printer', 'Technology', 'Accessories'),
(103, 'Office Chair', 'Furniture', 'Chairs'),
(104, 'Notebook', 'Office Supplies', 'Paper'),
(105, 'Smartphone', 'Technology', 'Mobiles');
INSERT INTO Orders VALUES
(1001, '2024-01-10', 1, 101, 55000, 1, 0.10, 8000),
(1002, '2024-01-15', 2, 103, 12000, 2, 0.05, 2500),
(1003, '2024-02-05', 3, 104, 500, 10, 0.00, 200),
(1004, '2024-02-20', 4, 102, 8000, 1, 0.15, 1000),
(1005, '2024-03-01', 5, 105, 30000, 1, 0.20, -2000);
SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT 
    SUM(sales) AS Total_Sales
FROM Orders;
SELECT 
    SUM(profit) AS Total_Profit
FROM Orders;
SELECT 
    COUNT(DISTINCT order_id) AS Total_Orders
FROM Orders;
SELECT 
    AVG(sales) AS Avg_Order_Value
FROM Orders;
SELECT 
    SUM(quantity) AS Total_Quantity
FROM Orders;
SELECT 
    (SUM(profit) / SUM(sales)) * 100 AS Profit_Margin_Percentage
FROM Orders;
SELECT 
    p.category,
    SUM(o.sales) AS Total_Sales
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY Total_Sales DESC;
SELECT 
    p.category,
    SUM(o.profit) AS Total_Profit
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY Total_Profit DESC;
SELECT 
    c.customer_name,
    SUM(o.sales) AS Total_Sales
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY Total_Sales DESC;
SELECT 
    c.state,
    SUM(o.sales) AS Total_Sales
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.state
ORDER BY Total_Sales DESC;
SELECT 
    YEAR(order_date) AS Year,
    MONTH(order_date) AS Month,
    SUM(sales) AS Monthly_Sales
FROM Orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY Year, Month;
SELECT 
    YEAR(order_date) AS Year,
    MONTH(order_date) AS Month,
    SUM(profit) AS Monthly_Profit
FROM Orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY Year, Month;
SELECT 
    p.product_name,
    SUM(o.sales) AS Total_Sales,
    RANK() OVER (ORDER BY SUM(o.sales) DESC) AS Sales_Rank
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.product_name;
SELECT 
    c.customer_name,
    SUM(o.sales) AS Customer_Sales,
    ROUND(
        SUM(o.sales) * 100.0 / SUM(SUM(o.sales)) OVER (), 2
    ) AS Contribution_Percentage
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name;
SELECT 
    discount,
    AVG(profit) AS Avg_Profit
FROM Orders
GROUP BY discount
ORDER BY discount;
SELECT * 
FROM Orders
WHERE sales IS NULL OR profit IS NULL;
SELECT * 
FROM Orders
WHERE profit < 0;
GO
CREATE OR ALTER VIEW vw_sales_summary AS
SELECT 
    c.state,
    p.category,
    SUM(o.sales) AS Total_Sales,
    SUM(o.profit) AS Total_Profit
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON o.product_id = p.product_id
GROUP BY c.state, p.category;
GO
SELECT * FROM vw_sales_summary;
GO
CREATE OR ALTER PROCEDURE sp_sales_by_state
AS
BEGIN
    SELECT 
        c.state,
        SUM(o.sales) AS Total_Sales,
        SUM(o.profit) AS Total_Profit
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    GROUP BY c.state
    ORDER BY Total_Sales DESC;
END;
GO
EXEC sp_sales_by_state;
GO
CREATE OR ALTER PROCEDURE sp_top_customers
    @TopN INT
AS
BEGIN
    SELECT TOP (@TopN)
        c.customer_name,
        SUM(o.sales) AS Total_Sales
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_name
    ORDER BY Total_Sales DESC;
END;
GO
EXEC sp_top_customers 3;
CREATE INDEX idx_orders_customer_id ON Orders(customer_id);
CREATE INDEX idx_orders_product_id ON Orders(product_id);
CREATE INDEX idx_orders_order_date ON Orders(order_date);
SELECT *
FROM Orders o
LEFT JOIN Customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
SELECT *
FROM Orders
WHERE discount > 0.15 AND profit < 0;



