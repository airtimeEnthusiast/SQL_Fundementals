WITH customer_orders AS (
    SELECT
        c.c_name,
        o.o_orderkey,
        o.o_orderdate,
        o.o_totalprice,
        LAG(o.o_totalprice) OVER (
            PARTITION BY c.c_custkey
            ORDER BY o.o_orderdate
        ) AS prev_price
    FROM
        customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
),
increasing_flags AS (
    SELECT *,
        CASE
            WHEN o_totalprice > prev_price THEN 1
            ELSE 0
        END AS is_increasing
    FROM customer_orders
),
grouped_sequences AS (
    SELECT *,
        SUM(CASE WHEN is_increasing = 0 THEN 1 ELSE 0 END)
        OVER (PARTITION BY c_name ORDER BY o_orderdate ROWS UNBOUNDED PRECEDING) AS sequence_group
    FROM increasing_flags
),
numbered_sequences AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY c_name, sequence_group
            ORDER BY o_orderdate
        ) AS increase_streak_rank
    FROM grouped_sequences
),
final AS (
    SELECT *
    FROM numbered_sequences
    WHERE is_increasing = 1
)
SELECT *
FROM final
WHERE c_name IN (
    SELECT c_name
    FROM final
    GROUP BY c_name, sequence_group
    HAVING COUNT(*) >= 2  -- means 3 orders total: 2 increases
)
ORDER BY c_name, o_orderdate;
