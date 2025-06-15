# SalaryHistoryInsights

## Project Overview
This project analyzes employee salary history data to generate a comprehensive report with key metrics. The SQL solution calculates multiple matrices in a single query using advanced techniques like window functions and conditional aggregation. Further I have also optimized the query
- **Initial Solution**: Used 10+ CTEs and 6 joins (~75 lines)
- **Optimized Solution**: Reduced to 3 CTE and 2 joins (~50% shorter)


## Tables Used
1. **`employees`**:
   - `employee_id`
   - `name`
   - `join_date`
   - `department`

2. **`salary_history`**:
   - `employee_id`
   - `change_date`
   - `salary`
   - `promotion` (Yes/No)
   ![Table screenshot](https://github.com/user-attachments/assets/d8cc4aa8-c475-41fb-aaec-b690b4a3b2aa)


## Key Metrics Calculated
1. Latest salary for each employee
2. Number of promotions received
3. Maximum salary hike percentage between consecutive changes
4. Whether salary never decreased (Yes/No)
5. Average months between salary changes
6. Growth-based ranking (from first to last salary)

## Non optimized query output
![not_optimized_query_output](https://github.com/user-attachments/assets/5b1c6026-1cd6-44f6-afdc-2f73c5d839d0)

## Optimized query output
![optimized_query_output](https://github.com/user-attachments/assets/2b6b5264-139f-4b63-b532-f721e078979d)

