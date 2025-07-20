# 📚 Studying SQL: TPC-H Database Query Review

Comprehensive review on SQL queries using the [TPC-H](https://www.tpc.org/tpch/) benchmark database in PostgreSQL.

---

## 📑 Table of Contents
1. [TPC-H Database Schema](#tpc-h-database-schema)
2. [Why TPC-H?](#why-tpc-h)
3. [SQL Primer](#sql-primer)
4. [Practice Exam](#practice-exam)
5. [Query Log](#query-log)

---

## 🗂️ TPC-H Database Schema
![TPC-H Schema](./sample-data-tpch-schema.png)

![Actual Schema](./actual-schema.png)


---

## ✨ Why TPC-H?

The TPC-H database is a standard for benchmarking decision support systems. Its schema and data are ideal for practicing complex SQL queries, including joins, aggregations, and subqueries.

---

## 📘 SQL Primer


# SQL Primer: Concepts & Fundamentals

Structured Query Language (SQL) is used for managing and querying relational databases.

## 🧱 Tables
A table is a collection of related data stored in rows and columns.
- **Rows (Records):** Individual entries.
- **Columns (Attributes):** Data fields of specific types (e.g., INTEGER, TEXT).

## 🔑 Keys

### Primary Key
- Uniquely identifies each row in a table.
- Only one primary key per table.
- Cannot contain NULL values.

### Foreign Key
- A field (or combination) in one table that refers to the primary key in another.
- Maintains referential integrity between tables.

## 🧾 SQL Query Types

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

## 🧠 Joins
Used to combine rows from multiple tables.
- **INNER JOIN:** Only matching rows.
- **LEFT JOIN:** All from left, matching from right.
- **RIGHT JOIN:** All from right, matching from left.
- **FULL OUTER JOIN:** All rows with matches where possible.

## 🧮 Aggregate Functions
Used for calculations on data:
- `COUNT()`, `SUM()`, `AVG()`, `MAX()`, `MIN()`

## 🧱 Constraints
- `NOT NULL`: Disallows null values.
- `UNIQUE`: Disallows duplicate values.
- `CHECK`: Ensures conditions.
- `DEFAULT`: Sets a default value.

---

## 📝 Practice Exam

### 🟢 Easy

1. **List all customers in the `CUSTOMER` table.**
```sql
SELECT * FROM CUSTOMER;
```

2. **Get the name and phone of all suppliers in the `SUPPLIER` table.**
```sql
SELECT S_NAME, S_PHONE FROM SUPPLIER;
```

3. **Find all parts with a size greater than 30.**
```sql
SELECT P_NAME, P_SIZE FROM PART WHERE P_SIZE > 30;
```

### 🟡 Intermediate

4. **Count the number of orders per customer.**
```sql
SELECT O_CUSTKEY, COUNT(*) AS OrderCount
FROM ORDERS
GROUP BY O_CUSTKEY;
```

5. **Find the average account balance by nation.**
```sql
SELECT N.N_NAME, AVG(C.C_ACCTBAL) AS AvgBalance
FROM CUSTOMER C
JOIN NATION N ON C.C_NATIONKEY = N.N_NATIONKEY
GROUP BY N.N_NAME;
```

6. **List all parts supplied by suppliers from 'UNITED STATES'.**
```sql
SELECT DISTINCT P.P_NAME
FROM PART P
JOIN PARTSUPP PS ON P.P_PARTKEY = PS.PS_PARTKEY
JOIN SUPPLIER S ON PS.PS_SUPPKEY = S.S_SUPPKEY
JOIN NATION N ON S.S_NATIONKEY = N.N_NATIONKEY
WHERE N.N_NAME = 'UNITED STATES';
```

### 🔴 Advanced

7. **Find the top 5 customers who placed the highest total price orders.**
```sql
SELECT O.O_CUSTKEY, SUM(O.O_TOTALPRICE) AS TotalSpent
FROM ORDERS O
GROUP BY O.O_CUSTKEY
ORDER BY TotalSpent DESC
LIMIT 5;
```

8. **Determine the most frequently shipped mode in LINEITEM.**
```sql
SELECT L_SHIPMODE, COUNT(*) AS Frequency
FROM LINEITEM
GROUP BY L_SHIPMODE
ORDER BY Frequency DESC
LIMIT 1;
```

9. **Calculate the revenue (extended price * (1 - discount)) for each nation.**
```sql
SELECT N.N_NAME, SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS Revenue
FROM LINEITEM L
JOIN ORDERS O ON L.L_ORDERKEY = O.O_ORDERKEY
JOIN CUSTOMER C ON O.O_CUSTKEY = C.C_CUSTKEY
JOIN NATION N ON C.C_NATIONKEY = N.N_NATIONKEY
GROUP BY N.N_NAME
ORDER BY Revenue DESC;
```

10. **Find suppliers who supply more than 1000 different parts.**
```sql
SELECT PS.PS_SUPPKEY, COUNT(DISTINCT PS.PS_PARTKEY) AS PartsSupplied
FROM PARTSUPP PS
GROUP BY PS.PS_SUPPKEY
HAVING COUNT(DISTINCT PS.PS_PARTKEY) > 1000;
```

---

## 📝 Query Log

Below, add your queries as you study. For each, include:

- **Query Name/Goal**
- **SQL Statement**
- **Explanation/Notes**
- **Results/Observations**

---

### Example

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
 * Aggregate functions are not allowed in GROUP BY because they are calculated after that phase.*
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


