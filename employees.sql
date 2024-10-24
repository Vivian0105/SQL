use employees;

######### Task1 ##########
######### average salary of employees who are not manager and average salary of managers ##########

# Firstly， have a look of how the salaries talbe and dept_manager tabel looks like. 
SELECT 
    *
FROM
    dept_manager
LIMIT 10;

SELECT 
    dept_no, COUNT(dept_no) as number_of_manager
FROM
    dept_manager
Group by 
	dept_no;
# There are in total 9 departments. For each department, there is a manager for a period of time. There are records of different managers in different periods of time. 

SELECT 
    *
FROM
    salaries s
        JOIN
    dept_manager d ON s.emp_no = d.emp_no;
# For each employee, there are several records of salary of diffferent time period.

# manager salary is the salary of the period in which an employee is department manager. 
select emp_manager_salary.position, round(avg(emp_manager_salary.salary))
  from 
  (select s.emp_no, s.salary, 
         case when (d.emp_no is not null) and (s.from_date>=d.from_date) and (s.to_date<=d.to_date) then 'manager'
         else 'employee'
         end as position
	from salaries s left join dept_manager d on s.emp_no=d.emp_no)
         as emp_manager_salary
group by emp_manager_salary.position;
# The result shows that the average salary for employee is 63761 and the average salary for manager is 67429
############### end of task1 ######################


####### Task 2 ########
####### Found employees are currently employeed and their departments ######

# Get most recent salaries of a current employee
select s1.emp_no, s1.salary, s1.from_date, s1.to_date
from salaries s1
join (select emp_no, max(from_date) as last_from_date from salaries group by emp_no) s2
on s1.emp_no=s2.emp_no and s1.from_date=s2.last_from_date
where s1.to_date>=SYSDATE();

# get most recent departments of a current employee
select d.*
from dept_emp d join 
(select emp_no, max(from_date) last_from_date from dept_emp group by emp_no) emp_last_dept
on d.emp_no=emp_last_dept.emp_no and d.from_date=emp_last_dept.last_from_date
where d.to_date>=SYSDATE();


# Get most current salaries of current employee and department
select current_dept.emp_no, current_dept.dept_no, current_dept.from_date as dept_from_date, current_salary.salary, current_salary.from_date as salary_from_date
from 
(select d.*
from dept_emp d join 
(select emp_no, max(from_date) last_from_date from dept_emp group by emp_no) emp_last_dept
on d.emp_no=emp_last_dept.emp_no and d.from_date=emp_last_dept.last_from_date
where d.to_date>=SYSDATE()) as current_dept 
left join 
(select s1.emp_no, s1.salary, s1.from_date, s1.to_date
from salaries s1
join (select emp_no, max(from_date) as last_from_date from salaries group by emp_no) s2
on s1.emp_no=s2.emp_no and s1.from_date=s2.last_from_date
where s1.to_date>=SYSDATE()) as current_salary
on current_dept.emp_no=current_salary.emp_no
where current_salary.salary is not null;



######## Task 3 #######
######## check the salary raise of each employee ##########
select e.first_name, e.last_name, max(s.salary)-min(s.salary) as diff_salary, 
    if(max(s.salary)-min(s.salary)>=30000, 'salary raise higher than 30000', 'salary raise lower than 30000') as salary_raise
    from employees e
    join salaries s
    on e.emp_no=s.emp_no
    group by e.emp_no;

######### Task 4 ########
######### Find out whehter a employee is still in the company or not ###########
select e.first_name, e.last_name, 
    case
    when max(s.to_date)>=SYSDATE() then 'Is still employed'
    else 'not an employee anymore'
    end as 'current_employee'
FROM employees e
join salaries s 
on e.emp_no=s.emp_no
group by e.emp_no
limit 50;

###############SQL WINDOW FUNCTIONS##############
select *,
       row_number() over(partition by emp_no order by salary desc) as row_num
from salaries;

select *,
       row_number() over w as row_num
from employees 
window w as (partition by first_name order by emp_no asc);

# find the second highest salary every empoyee ever signed a contract for
select e_s.emp_no, e_s.salary as second_highest_salary
from 
(select *,
        row_number() over w as row_num
 from salaries
 window w as (partition by emp_no order by salary desc)) as e_s
 where e_s.row_num=2;

