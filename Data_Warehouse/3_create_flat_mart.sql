
--Step 3 create flat mart table (denormalized dw)
--For better organization, we put the mart inside a new schema. For idempotency purposes we drop the schema first
DROP SCHEMA IF EXISTS flat_mart CASCADE;

--New schema creation
CREATE SCHEMA flat_mart;


--SELECT '===Loading Flat Mart === ' AS info;
--Creation of a flat table where a row represents a job posting + its dimensions.
CREATE OR REPLACE TABLE flat_mart.job_postings AS

SELECT

   jpf.job_id ,
   jpf.company_id    ,
   jpf.job_title_short  ,
   jpf.job_title ,
   jpf.job_via ,
   jpf.job_schedule_type ,
   jpf.job_work_from_home ,
   jpf.search_location ,
   jpf.job_posted_date ,
   jpf.job_no_degree_mention ,
   jpf.job_health_insurance ,
   jpf.job_country ,
   jpf.salary_rate ,
   jpf.salary_year_avg ,
   jpf.salary_hour_avg,
   cd.company_id,
   cd.name AS company_name,
   --Skills and type skill aggregation
   ARRAY_AGG(
        STRUCT_PACK(
            type:= sd.type,
            name:=sd.skills
        )
   ) AS skills_and_types

   FROM 
   job_postings_fact AS jpf
   LEFT JOIN company_dim as cd 
        ON jpf.company_id = cd.company_id

    LEFT JOIN skills_job_dim AS sjd
        ON jpf.job_id = sjd.job_id
    LEFT JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
    GROUP BY ALL;
    --Flat mart creation verification
    SELECT 'Flat Mart Job Posting' AS table_name,  COUNT(*) AS record_count FROM flat_mart.job_postings;

    --SELECT '=== Flat Mart Simple ===' AS info;

    --Verify table population
    SELECT * FROM flat_mart.job_postings LIMIT 10;