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

### 7. Find the names, order ID, and price of orders for customers who have placed orders above the average total order price.
```sql
SELECT c_name, o_orderkey, o_totalprice
FROM customer
JOIN orders ON customer.c_custkey = orders.o_custkey
WHERE orders.o_totalprice > (
    SELECT AVG(o_totalprice)
    FROM orders
);
```



