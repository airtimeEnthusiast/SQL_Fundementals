### QUIZ: 
#### Question 1. Top Performing Regions
- Given the following tables: 
    *orders(order_id, customer_id, order_date, total_amount)*
    *customers(customer_id, name, region)*
 - Write a SQL query to return the top 2 regions by total sales in the last 6 months.
```sql
SELECT 
  customers.region,
  SUM(orders.total_amount) AS total_sales
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.order_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY customers.region
ORDER BY total_sales DESC
LIMIT 2;
```

#### Question 2: Order Health Check
- Find any orders where: The total_amount is NULL or less than 0 OR the customer_id does not exist in the customers table

- Return: order_id, order_date, total_amount, and a new column called issue that labels the problem (e.g., 'Missing Customer' or 'Invalid Amount')

- LEFT JOIN allows you to catch rows where the customer_id in orders doesn't match any in customers

```sql
SELECT 
  o.order_id, 
  o.order_date, 
  o.total_amount,
  CASE 
    WHEN c.customer_id IS NULL THEN 'Missing Customer'
    WHEN o.total_amount IS NULL OR o.total_amount < 0 THEN 'Invalid Amount'
    ELSE 'Valid'
  END AS issue
FROM 
  orders o
LEFT JOIN 
  customers c ON o.customer_id = c.customer_id
WHERE 
  c.customer_id IS NULL 
  OR o.total_amount IS NULL 
  OR o.total_amount < 0;

```

#### Question 3: Monthly Revenue Trends
- Using a CTE and a window function, return for each month:
month
total_revenue
revenue_change (the difference in revenue from the previous month)
Assume the orders table has order_date and total_amount.

```sql
WITH total_revenue AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS month, 
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY FORMAT(order_date, 'yyyy-MM')
),

revenue_change AS (
    SELECT 
        month, 
        revenue, 
        LAG(revenue) OVER (ORDER BY month) AS previous_revenue
    FROM total_revenue
)

SELECT 
    month, 
    revenue, 
    revenue - previous_revenue AS revenue_change
FROM revenue_change;

```

#### Question 4: Top 3 orders
Find customers who placed at least 3 orders where the total order value increased each time (i.e., each order was higher than the previous one).

```sql
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
```

### Part 2: PowerShell Scripting

#### Question 4: File Watcher Script
Write a PowerShell script that:
Looks for .csv files in C:\Reports\Pending
Moves them to C:\Reports\Archived with today’s date appended to the filename
Logs the filename and timestamp to C:\Reports\log.txt
```powershell

$targetPath = "C:\Reports\Pending"
$destinationPath = "C:\Reports\Archived"
$logfilePath = "C:\Logs\output.txt"  -Value "Appended line at $(Get-Date)"

# Check if log file already exists — once
$logExists = Test-Path $logfilePath

$files = Get-ChildItem -Path $targetPath -File

# Output each file name
foreach ($file in $files) {
    Write-Output "Found file: $($file.FullName)"
    if ($file.Extension -eq ".csv") {
        Write-Output "This is a CSV file."

        # Get base name (without extension)
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

        # Get the extension
        $ext = $file.Extension

        # Get current date as string
        $dateStamp = Get-Date -Format "yyyy-MM-dd"

        # Build the new filename with date appended
        $newFileName = "$baseName`_$dateStamp$ext"  # use backtick (`) to escape underscore
        
        # Combine with destination path
        $destination = Join-Path $destinationPath $newFileName

        # Move and rename
        Move-Item -Path $file.FullName -Destination $destination

        # Create or append to log file based on $logExists
        $logMessage = "[$(Get-Date)] Moved: $($file.Name) to $newFileName"
        if (-not $logExists) {
            Set-Content -Path $logfilePath -Value $logMessage
            $logExists = $true  # Update flag after creating the file
        }
        else {
            Add-Content -Path $logfilePath -Value $logMessage
        }
    }
}
```


#### Question 5: SQL Automation
Using PowerShell, write a snippet to:
Connect to a SQL Server database
Run a stored procedure called usp_GetFailedJobs
Export the results to a .csv file in C:\Logs
```powershell
# Define connection string
$connectionString = "Server=YourServerName\InstanceName;Database=YourDatabaseName;User ID=YourUsername;Password=YourPassword;"

# Create and open SQL connection
$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = $connectionString
$conn.Open()

# Create SQL command to execute stored procedure
$cmd = $conn.CreateCommand()
$cmd.CommandText = "usp_GetFailedJobs"
$cmd.CommandType = [System.Data.CommandType]::StoredProcedure

# Execute the command and load results
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
$table = New-Object System.Data.DataTable
$adapter.Fill($table) | Out-Null

$conn.Close()

# Export results to CSV
$logPath = "C:\Logs\FailedJobs_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$table | Export-Csv -Path $logPath -NoTypeInformation

Write-Host "Export complete: $logPath"
```

### Part 3: REST API & Postman

#### Question 6: API Scenario
You are provided with an API: https://api.company.com/users/{id}
It returns JSON like:
{
  "id": 123,
  "name": "Jane Doe",
  "email": "jane@example.com",
  "status": "active"
}
Tasks:
In Postman, describe how you would:
Test if the API is reachable
Validate that the response contains email and status
Write a PowerShell snippet to:
Make a GET request to this endpoint
Extract the status field and display it

```powershell
# Define the API URL and headers
$id = '1'
$apiUrl = "https://api.company.com/users/$id"
$headers = @{
    "Authorization" = "Bearer your_token_here"
    "Accept" = "application/json"
}

# Make the GET request with headers
$response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers

# Print the JSON response
$response | ConvertTo-Json -Depth 10

```