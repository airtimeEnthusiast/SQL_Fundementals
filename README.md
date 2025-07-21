# 📚 Studying SQL: TPC-H Database Query Review

Comprehensive review on SQL queries using the [TPC-H](https://www.tpc.org/tpch/) benchmark database in PostgreSQL.

---

## 📑 Table of Contents
1. [TPC-H Database Schema](#tpc-h-database-schema)
2. [Why TPC-H?](#why-tpc-h)
3. [SQL Primer](#sql-primer)
4. [Examples](#examples)

---

## TPC-H Database Schema
![TPC-H Schema](./sample-data-tpch-schema.png)

![Actual Schema](./actual-schema.png)


---

## Why TPC-H?

The TPC-H database is a standard for benchmarking decision support systems. Its schema and data are ideal for practicing complex SQL queries, including joins, aggregations, and subqueries.

---

## SQL Primer


# SQL Primer: Concepts & Fundamentals

Structured Query Language (SQL) is used for managing and querying relational databases.

## Tables
A table is a collection of related data stored in rows and columns.
- **Rows (Records):** Individual entries.
- **Columns (Attributes):** Data fields of specific types (e.g., INTEGER, TEXT).

## Keys

### Primary Key
- Uniquely identifies each row in a table.
- Only one primary key per table.
- Cannot contain NULL values.

### Foreign Key
- A field (or combination) in one table that refers to the primary key in another.
- Maintains referential integrity between tables.

## SQL Query Types

### 1. Data Query Language (DQL)
Used for querying data:
```sql
SELECT * FROM customers;
```

### 2. Data Definition Language (DDL)
Used for defining structure:
```sql
CREATE TABLE, ALTER TABLE, DROP TABLE
```

### 3. Data Manipulation Language (DML)
Used for inserting, updating, and deleting data:
```sql
INSERT INTO, UPDATE, DELETE
```

### 4. Data Control Language (DCL)
Used for permissions:
```sql
GRANT, REVOKE
```

## Joins
Used to combine rows from multiple tables.
- **INNER JOIN:** Only matching rows.
- **LEFT JOIN:** All from left, matching from right.
- **RIGHT JOIN:** All from right, matching from left.
- **FULL OUTER JOIN:** All rows with matches where possible.

## Aggregate Functions
Used for calculations on data:
- `COUNT()`, `SUM()`, `AVG()`, `MAX()`, `MIN()`

## Constraints
- `NOT NULL`: Disallows null values.
- `UNIQUE`: Disallows duplicate values.
- `CHECK`: Ensures conditions.
- `DEFAULT`: Sets a default value.

## Examples

* Some attribute names might differ *

#### 1. Grant Bob access to read and write data?
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON customer TO bob;
```

#### 2. Return the name, address, and phone number of all suppliers whose account balance is lower than 0:
```sql
SELECT s_name, s_address, s_phone
FROM supplier
WHERE s_acctbal < 0 
```

### 3. List the names of customers who have placed at least 5 orders, along with the total amount they have spent (sum of o_totalprice) and their nation name. Order the results by total spent in descending order.
- Query result should include:
  - c_name (customer name)
  - n_name (nation name)
  - order_count (number of orders placed)
  - total_spent (total amount spent by the customer)
- Aggregate functions are not allowed in GROUP BY because they are calculated after that phase.
```sql
SELECT customer.c_name, nation.n_name AS nation_name,
       COUNT(orders.o_orderkey) AS order_count,
       SUM(orders.o_totalprice) AS total_spent

FROM customer

JOIN orders ON customer.c_custkey = orders.o_custkey
JOIN nation ON customer.c_nationkey = nation.n_nationkey

GROUP BY c_name, nation.n_name,
HAVING COUNT(orders.o_orderkey) >= 5
ORDER BY total_spent DESC;

```

### 4. Find the top 10 suppliers who have supplied the largest total quantity of parts, and list their name, the total quantity supplied, and their nation name.

*The JOIN clause starts with the table you're adding*

```sql
SELECT s_name, 
       n_name,
       SUM(lineitem.l_quantity) AS total_quantity

FROM supplier

JOIN nation ON supplier.s_nationkey = nation.n_nationkey
JOIN lineitem ON supplier.s_suppkey = lineitem.l_suppkey

GROUP BY s_name, n_name
LIMIT 10;
```

### 5. Find the names of parts that cost more than $100 (based on p_retailprice), along with their part type and size, sorted by price in descending order.

*GROUP BY is used when you want to aggregate data — that is, to compute a value per group of rows.*

```sql

SELECT p_name, p_type, p_size, p_retailprice

FROM part

WHERE part.p_retailprice > 100
ORDER BY part.p_retailprice DESC;
```

### 6. Find the total revenue (l_extendedprice * (1 - l_discount)) for each nation, and list them sorted by revenue in descending order.

- Since the revenue in TPC-H is based on customer purchases *(orders + lineitems)* — not supplier costs or inventory. We use the following join sequence.
  - *lineitem → orders → customer → nation*
- Do not do an *implicit join* EVER!!
    ```sql
      FROM lineitem, orders, customer, nation
    ```
    - As it will be inefficient and create a Cartesian product on the tables.
- *Explicit joins* are more structured, safer, and easier to maintain.
```sql
SELECT n_name, SUM(l_extendedprice * ( 1 - l_discount)) AS revenue

-- Explicit Join on *lineitem → orders → customer → nation*
FROM lineitem
 
JOIN orders ON lineitem.l_orderkey = orders.o_orderkey
JOIN customer ON orders.o_custkey = customer.c_custkey
JOIN nation ON customer.c_nationkey = nation.n_nationkey

GROUP BY n_name
ORDER BY revenue DESC
```

### 7. Find the names, order ID, and price of the order for customers who have placed an order above the average total order price.
```sql
SELECT c_name, o_orderkey, o_totalprice
FROM customer
JOIN orders ON customer.c_custkey = orders.o_custkey
-- Nested query to calculate the average
WHERE orders.o_totalprice > (
    SELECT AVG(o_totalprice)
    FROM orders
);
```

### 8. For each customer, show their name and the total number of orders they’ve placed.
- Uses a setbased operation instead of a nested query for optimization
```sql
  SELECT c_name, HAVING COUNT(o_orderkey) > 0 AS order_count
  FROM customer
  JOIN orders ON customer.c_custkey = orders.o_custkey
  GROUP BY c_name
  ORDER BY order_count DESC
```

### 9. Top Orders per Customer with Revenue Rank & Change
```sql
WITH
    ranked_orders AS (
        -- Select customer name, order key, and total price
        SELECT
            c.c_name,
            o.o_orderkey,
            o.o_totalprice,
            c.c_custkey,
            -- Calculate the rank of each order based on total price for each customer
            ROW_NUMBER() OVER (
                PARTITION BY
                    c_custkey
                ORDER BY
                    o_totalprice DESC
            ) AS ranking,
            -- Get the previous order's total price for each customer
            LAG (o_totalprice) OVER (
                PARTITION BY
                    c_custkey
                ORDER BY
                    o_orderkey DESC
            ) AS prev_price
        FROM
            customer c
            JOIN orders o ON c.c_custkey = o.o_custkey
    )
-- Compute the difference between the current order's total price and the previous order's total price
SELECT
    c_name,
    o_orderkey, 
    ROUND(o_totalprice,1) AS total_price,
    ROUND(o_totalprice - prev_price,1) AS price_diff,
    CONCAT (
        ROUND((o_totalprice - prev_price) / prev_price * 100),
        '%'
    ) AS percent_change
FROM
    ranked_orders
WHERE
    ranking <= 3
    AND prev_price IS NOT NULL
```
#### 🧠 Step-by-Step Analysis

#### 1. 🧱 CTE: `ranked_orders`

This **Common Table Expression** prepares a ranked list of orders per customer along with their previous order’s price.

```sql
WITH ranked_orders AS (
  ...
)
```
##### Inside the CTE:
  - c.c_name, o.o_orderkey, o.o_totalprice, c.c_custkey are selected.
  - ROW_NUMBER() ranks each customer's orders from highest to    - lowest total price.
  - LAG(o_totalprice) retrieves the previous order's total price, ordered by o_orderkey DESC.

#### 2. 🧾 Main Query
After the CTE, the outer query looks like:
```sql
SELECT ...
FROM ranked_orders
WHERE ranking <= 3 AND prev_price IS NOT NULL;
```
##### What it does:
  - Filters to show only the top 3 orders per customer (ranking <= 3)
  - Excludes the first order (since it has no prev_price)
  - Calculates:
    - price_diff: Difference between current and previous order price
    - percent_change: Percentage change from the previous order's price

