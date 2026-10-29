
--Step 2 load the data warehouse using csv files as data source.

--Load the company_dim table first (no FK dependencies issues)
INSERT INTO company_dim(
    company_id,
    name
)
SELECT company_id, name
FROM read_csv('https://storage.googleapis.com/sql_de/company_dim.csv',
 AUTO_DETECT = true);


--Load the skills_dim table right after (no FK dependencies issues)
INSERT INTO skills_dim (
    skill_id,
    skills,
    type
)
SELECT skill_id,skills,type
FROM read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv',
 AUTO_DETECT = true);

-- Load the fact table (after the loading of the dimension tables)
 INSERT INTO job_postings_fact (
    job_id ,
   company_id    ,
   job_title_short  ,
   job_title ,
   job_location ,
   job_via ,
   job_schedule_type ,
   job_work_from_home ,
   search_location ,
   job_posted_date ,
   job_no_degree_mention ,
   job_health_insurance ,
   job_country ,
   salary_rate ,
   salary_year_avg ,
   salary_hour_avg
 )
 SELECT     
 job_id ,
   company_id    ,
   job_title_short  ,
   job_title ,
   job_location ,
   job_via ,
   job_schedule_type ,
   job_work_from_home ,
   search_location ,
   job_posted_date ,
   job_no_degree_mention ,
   job_health_insurance ,
   job_country ,
   salary_rate ,
   salary_year_avg ,
   salary_hour_avg

FROM read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv',
 AUTO_DETECT = true);

--Load the bridge table skills_job_dim last (double FK references)
 INSERT INTO skills_job_dim(skill_id, job_id)
 SELECT skill_id, job_id
 FROM read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv',
 AUTO_DETECT = true);


---Useful for checking the loaded number of rows
SELECT 'Company Dim' AS table_name, COUNT(*) as record_count
FROM company_dim,
UNION ALL
SELECT 'SKIlls DIM',COUNT(*) FROM skills_dim
UNION ALL
SELECT 'job posting facts', COUNT(*), from job_postings_fact
UNION ALL
SELECT 'skills job dim', COUNT(*), FROM skills_job_dim;

--Check if the referential integrity is good (if there are no missing references between tables, result should be 0)
SELECT 'Orphaned company_ids in job_postings_fact' as check_type,
    COUNT(*) AS orphaned_count
FROM job_postings_fact
WHERE company_id NOT IN (SELECT company_id FROM company_dim);

SELECT 'Orphaned skill_ids in skills_job_dim' as check_type,
    COUNT(*) AS orphaned_count
FROM skills_job_dim
WHERE skill_id NOT IN (SELECT skill_id FROM skills_dim);

SELECT 'Orphaned job_ids in skills_job_dim' as check_type,
    COUNT(*) AS orphaned_count
FROM skills_job_dim
WHERE job_id NOT IN (SELECT job_id FROM job_postings_fact);


---Useful for checking what was previously loaded inside a table 
SELECT * FROM job_postings_fact LIMIT 10;

SELECT * FROM skills_dim LIMIT 10;

SELECT * FROM company_dim LIMIT 10;

SELECT * FROM skills_job_dim LIMIT 10;

