-- ------------------------------------ SQL Portfolio Project " ONLINE BOOK STORE " -----------------------------------

CREATE DATABASE OnlineBookStore;

USE OnlineBookStore;

-- --------------------------------------- CREATE TABLES ---------------------------------------------

DROP TABLE IF EXISTS Books;
CREATE TABLE Books(
	Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR (100),
    Author VARCHAR (50),
    Genre VARCHAR (50),
    Published_Year INT,
    Price NUMERIC (10,2),
    Stock INT
);

DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers(
	Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR (50),
    Email VARCHAR (100),
    Phone INT,
    City VARCHAR (50),
    Country VARCHAR (100)
);

DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders(
	Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers (Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC (10,2)
);

SELECT * FROM Orders;
SELECT * FROM Customers;
SELECT * FROM Books;

-- ----------------------------- Steps of Importing File ------------------------------------------------------- 
-- Right-click on your database
-- Click Table Data Import Wizard
-- Select your CSV file
-- Choose Create new table OR Select existing table
-- Map columns correctly
-- Click Next → Import
-- Supports: CSV, JSON
-- ------------------------------------------------------------------------------------------------------------

-- Retrive all books in the "Fiction" genre :
SELECT * FROM Books;
SELECT * FROM Books WHERE Genre='Fiction';

-- Find books published after the year 1950 :
SELECT * FROM Books WHERE Published_Year >1950;

-- List all the customers from the Canada :
SELECT * FROM Customers;
SELECT * FROM customers WHERE Country='Canada';

-- Show orders placed in November 2023 :
SELECT * FROM orders;
SELECT * FROM orders WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- Retrieve the total stock of books available (no. of books avaliable) :
SELECT SUM(Stock) AS Total_Stock FROM books ;

-- Find the details of the most expensive book :
SELECT max(Price) FROM Books;
SELECT * FROM books ORDER BY Price DESC LIMIT 1;

-- Show all customers who ordered more than 1 quantity of book :
SELECT * FROM orders WHERE quantity>1;

-- Retrive all orders where total amount exceeds $20 :
SELECT * FROM orders WHERE Total_Amount > 20 ;

-- List all the genres available in books table :
SELECT DISTINCT Genre FROM books;

-- Find the book with lowest stock :
SELECT * FROM books order by Stock LIMIT 1;

-- Calculate total revenue generated from all orders :
SELECT sum(Total_amount) as revenue from orders;

-- Retrieve the total no. of books sold for each genre :
SELECT b.Genre, SUM(o.Quantity) AS Total_quantity_sold FROM 
books b join orders o ON o.Book_ID = b.Book_ID 
GROUP BY Genre ;

-- Find the average price of books in the "Fantasy" genre :
SELECT avg(PRICE) as ave_price FROM books where Genre = "Fantasy";

-- List customers who have placed at least 2 orders :
SELECT o.customer_ID , c.name, COUNT(o.Order_ID) AS Order_count FROM orders o JOIN customers c 
ON c.Customer_ID = o.Customer_ID 
GROUP BY o.Customer_ID, c.Name
HAVING Order_count >= 2 ;

-- Find the most frequently ordered book :
SELECT O.book_id, B.Title, count(O.Order_id) AS Order_Count FROM orders O JOIN books B
ON O.Book_ID = B.Book_ID
group by O.Book_ID 
order by Order_Count DESC LIMIT 1;

-- Show the top 3 most expensive books of "Fantacy" genre
SELECT * FROM books WHERE Genre="Fantasy" 
ORDER BY Price DESC LIMIT 3;

-- Retrive total quantity of books sold by each author :
SELECT b.author, SUM(o.quantity) AS Total_Books_Sold FROM 
orders o JOIN books b ON o.Book_ID = b.Book_ID
GROUP BY b.Author;

-- List the cities where customers who spend over $30 are located :
SELECT distinct(c.City), o.Total_Amount 
FROM orders o JOIN customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Total_Amount > 30 ;

-- Find the customer who spend most on the order :
SELECT c.Customer_ID, c.Name, sum(o.Total_Amount) as Total_spent
FROM customers c JOIN orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID ,c.NAME
ORDER BY Total_spent DESC;

-- Calculate the stock remaining after fulfilling the all order :

SELECT b.book_ID, b.title, b.stock, sum(o.Quantity) AS Unit_Sold, 
b.stock - sum(o.Quantity) AS Remaining_stock 				-- if Unit_Sold is null/0 then Remaining_stock becomes null
FROM books b LEFT JOIN orders o ON b.Book_ID = o.Book_ID	-- This is little bit wrong.
GROUP BY b.Book_ID ORDER BY b.Book_ID ;

SELECT b.book_ID, b.title, b.stock, sum(o.Quantity) AS Unit_Sold, 
b.stock - 
	CASE 						-- but in Unit_Sold, if the book did't sold the output becomes NULL insted of 0
    WHEN sum(o.Quantity) IS NULL THEN 0
    ELSE sum(o.Quantity)
    END AS Remaining_stock
FROM books b LEFT JOIN orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID 
ORDER BY b.Book_ID ;

SELECT b.book_ID, b.title, b.stock, ifnull(sum(o.Quantity),0) AS Unit_Sold, 
b.stock - IFNULL(sum(o.Quantity),0) AS Remaining_stock
FROM books b LEFT JOIN orders o ON b.Book_ID = o.Book_ID			-- IFNULL()
GROUP BY b.Book_ID ORDER BY b.Book_ID ;

SELECT b.book_ID, b.title, b.stock, COALESCE(sum(o.Quantity),0) AS Unit_Sold, 
b.stock - COALESCE(sum(o.Quantity),0) AS Remaining_stock			
FROM books b LEFT JOIN orders o ON b.Book_ID = o.Book_ID			-- COALESCE()
GROUP BY b.Book_ID ORDER BY b.Book_ID ;


-- ------------------------------------------* Insights & Predictions *---------------------------------------------

-- Insights -

-- Top-selling genres: Mystery, Science Fiction, and Fantasy show the highest demand.
-- Highest revenue genre: Romance earns the most revenue due to higher-priced orders.
-- Stock issue: Some popular books have negative remaining stock, indicating poor inventory planning.
-- Bestsellers: A few books contribute heavily to total sales and should always be in stock.
-- Customer behavior: Repeat purchases indicate stable customer demand.

-- Prediction

-- Demand for Mystery, Sci-Fi, and Fantasy will continue to grow.
-- Romance books will remain the biggest revenue driver.
-- Without better restocking, the store may lose sales due to stock-outs.

### ✅ One-Line Conclusion

-- 		Sales growth is strong in popular genres, but improving inventory management 
-- is essential to maximize future revenue.

