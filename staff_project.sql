select * from staff;
select * from company_divisions;
select * from company_regions;

--Number of staff at company
select count(distinct(id)) from staff;

--Distribution of gender
select
	gender,
	count(*)
from staff
group by 1;

--Distribution of gender by department
select
	department,
	sum(case when gender='Male' then 1 else 0 end)*100/count(*) as male_percentage
from staff
group by 1
order by 2 desc;


--Total salaries of all employee
select sum(salary) from staff;

--Distibution of salary by gender
select
	gender,
	min(salary),
	round(avg(salary),2) as mean,
	max(salary),
	max(salary)-min(salary) as range
from staff
group by 1;

--Distribution of salary by department
select
	department,
	min(salary),
	round(avg(salary),2) as mean,
	max(salary),
	max(salary)-min(salary) as range
from staff
group by 1
order by 3 desc;


--Distribution of salary by region
select
	r.company_regions,
	r.country,
	count(s.id) as no_employees,
	min(s.salary),
	round(avg(s.salary),2) as mean,
	max(s.salary),
	max(s.salary)-min(s.salary) as range
from staff as s
left join company_regions as r
	on s.region_id = r.region_id
group by 1,2
order by mean desc;


--Highest and lowest paying job in each department
with temp_table1 as (
		select
			*,
			rank() over(partition by department order by salary desc) as rn
		from staff
	),
	temp_table2 as (
		select
			*,
			rank() over(partition by department order by salary) as rn
		from staff
	)
select
	t1.department,
	t1.job_title as highest_paying_job,
	t1.salary as highest_salary,
	t2.job_title as lowest_paying_job,
	t2.salary as lowest_salary
from temp_table1 as t1
join temp_table2 as t2
	on t1.department = t2.department
where t1.rn=1 and t2.rn=2
;

--Group staff by how long they have been at the company
select
	case when start_date < '2004-12-31' then 'long_term'
		 when start_date between '2005-01-01' and '2009-12-31' then 'mid_term'
		 else 'short_term'
	end Tenure,
	count(*),
	round(avg(salary),2) as mean_salary
from staff
group by 1;

--Total number of unique jobs
select count(distinct(job_title)) from staff;

--Total number of staff for each unique job
select
	job_title,
	count(*)
from staff
group by 1
order by 2 desc;



--Total number of engineers and their average salary
select
	count((job_title)) as Number_engineers,
	round(avg(salary),2) as avg_salary
from staff
where job_title like '%Engineer%'
;

--Average salary for each type of engineer
select 
	distinct(job_title),
	round(avg(salary) over(partition by job_title),2) as avg_salary
from staff
where job_title like '%Engineer%'
order by 1
;

--Total number of assistants and their average salary
select
	count((job_title)) as Number_assistants,
	round(avg(salary),2) as avg_salary
from staff
where job_title like '%Assistant%'
;

--Average salary for each type of assistants
select 
	distinct(job_title),
	round(avg(salary) over(partition by job_title),2) as avg_salary
from staff
where job_title like '%Assistant%'
order by 1;



--Total number of managers and their average salary
select
	count((job_title)) as Number_managers,
	round(avg(salary),2) as avg_salary
from staff
where job_title like '%Manager%'
;

--Average salary for each type of managers
select 
	distinct(job_title),
	round(avg(salary) over(partition by job_title),2) as avg_salary
from staff
where job_title like '%Manager%'
order by 1;

--Comparing salaries of all managers
select
	id,
	last_name,
	job_title,
	department,
	region_id,
	salary,
	(lag(salary) over(order by salary desc)) - salary
from staff
where job_title like '%Manager%'
order by salary desc;





--Number of employees and average salary from each division
select
	company_division,
	count(*),
	round(avg(salary),2) as avg_salary
from staff as s
left join company_divisions as d
	on s.department = d.department
group by 1
order by 3 desc;


--Which department is not part of a division
select
	distinct(s.department),
	d.company_division
from staff as s
left join company_divisions as d
 on s.department = d.department
where company_division is null
;


--Every employee that earns more than the average salary in their division
select * from
(
select
	s.id,
	s.last_name,
	s.salary,
	s.department,
	d.company_division,
	round(avg(s.salary) over(partition by d.company_division),2) as division_avg_salary
from staff as s
join company_divisions as d
	on s.department = d.department
order by 1
)
where salary > division_avg_salary;
	
--Comparing salaries of managers in each division
select
	d.company_division,
	min(s.salary),
	round(avg(s.salary),2) as mean,
	max(s.salary)
from (select * from staff where job_title like '%Manager%') as s
join company_divisions as d
	on s.department = d.department
group by 1;


--Top 3 highest earning staff in each region
select * from (
select
	r.company_regions,
	s.id,
	s.last_name,
	s.salary,
	s.job_title,
	s.department,
	rank() over(partition by r.company_regions order by s.salary desc)
from staff as s
join company_regions as r
	on s.region_id = r.region_id
order by 1,7)
where rank < 4
;

--All employees who are in the top 1% of earners within the company
select *
from staff
where salary>(select
				percentile_disc(0.99) within group(order by salary)
			  from staff)
;

