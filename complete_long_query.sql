with latest_salary_cte as(
select employee_id, salary,RANK() over(partition by employee_id order by change_date desc) rn
from salary_history)
-----
,latest_salary as(
SELECT employee_id,salary as latest_salary
from latest_salary_cte
where rn=1)
-------------------------------------------------------------------------------------------------------------------------
,total_promotion_cte as(
select employee_id,count(1) as total_promotion
from salary_history
where promotion='Yes'
group by employee_id)
-------------------------------------------------------------------------------------------------------------------------
,hike_cte as(
select *,CAST((LEAD(salary)over(partition by employee_id order by change_date) - salary)/salary*100 AS decimal(10,2)) as hike
from salary_history)
-----
,hike_percentage as(
select employee_id, MAX(hike) max_hike
from hike_cte
group by employee_id)
-------------------------------------------------------------------------------------------------------------------------
--Here sal_always_increased --> (1:always inc , 0: for null case , -1: decreased once)
,salary_increased_cte as(
select *,LEAD(salary)over(partition by employee_id order by change_date) as next_sal, CASE 
																						WHEN LEAD(salary)over(partition by employee_id order by change_date) > salary then 1 
																						WHEN LEAD(salary)over(partition by employee_id order by change_date) <= salary then -1
																						ELSE 0	END as sal_always_increased
from salary_history)
-----
, salary_increased as(
select employee_id
from salary_increased_cte
group by employee_id
having MIN(sal_always_increased)<>-1)
-------------------------------------------------------------------------------------------------------------------------
,promotion_in_month_cte as(
select *, DATEDIFF(MONTH,change_date,
LEAD(change_date)over(partition by employee_id order by change_date)) diff_in_months_between_promotion
from salary_history)
-----
,promotion_in_month as(
select employee_id,AVG(diff_in_months_between_promotion) average_months_for_promotion
from promotion_in_month_cte
group by employee_id)
-------------------------------------------------------------------------------------------------------------------------
, salary_growth_cte as(
select *,
rank()over(partition by employee_id order by change_date asc) first_salary_order,
rank()over(partition by employee_id order by change_date desc) last_salary_order
from salary_history)
-----
, salary_growth_cte_2 as(
select employee_id
,max(CASE WHEN last_salary_order=1 then salary END) / max(CASE WHEN first_salary_order=1 then salary END) as salary_ratio
,min(change_date) as join_date
from salary_growth_cte
group by employee_id)
-----
,salary_growth as(
select employee_id,
rank()over(order by salary_ratio desc,join_date asc ) as rank_by_salary_ratio
from salary_growth_cte_2)
-------------------------------------------------------------------------------------------------------------------------
select e.employee_id,e.name , ls.latest_salary , isnull(p.total_promotion,0) as total_promotion , h.max_hike 
,(CASE WHEN si.employee_id IS NOT NULL THEN 'YES' ELSE 'NO' END) AS sal_inc_or_not, pm.average_months_for_promotion,sg.rank_by_salary_ratio
from employees e
left join latest_salary ls on e.employee_id=ls.employee_id
left join total_promotion_cte p on p.employee_id=ls.employee_id
left join hike_percentage h on h.employee_id=ls.employee_id
left join salary_increased si on si.employee_id=ls.employee_id 
left join promotion_in_month pm on pm.employee_id=ls.employee_id
left join salary_growth sg on sg.employee_id=ls.employee_id

