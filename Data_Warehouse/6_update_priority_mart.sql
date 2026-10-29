--Update Priority roles mart(incremental update)

---update existing priority roles, created in step 5
UPDATE priority_mart.priority_roles
SET priority_lvl = 1
WHERE role_name = 'Data Engineer';

--added new priority roles
INSERT INTO priority_mart.priority_roles(role_id, role_name, priority_lvl)
VALUES (4, 'Data Scientist', 3);

--check insertion
SELECT * FROM priority_mart.priority_roles;





--creation of temporary table used as source table for merge operation
CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs AS
SELECT
jpf.job_id,
jpf.job_title_short,
cd.name AS company_name,
jpf.job_posted_date,
jpf.salary_year_avg,
r.priority_lvl,
CURRENT_TIMESTAMP AS updated_at
FROM 

job_postings_fact as jpf
LEFT JOIN company_dim AS cd
        ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles AS r
        ON jpf.job_title_short = r.role_name;

--Merge into the target table taking new results from source table
MERGE INTO priority_mart.priority_jobs_snapshot AS tgt
USING src_priority_jobs AS src
ON tgt.job_id = src.job_id
 --If match then just update the priority level if they differ
WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
UPDATE SET  
    priority_lvl = src.priority_lvl,
    updated_at = src.updated_at

--if there is no record in tgt, then a row is added
WHEN NOT MATCHED THEN

INSERT(
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
VALUES(
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
)

--the row is deleted in tgt if there is no row in src
WHEN NOT MATCHED BY SOURCE THEN DELETE;


-- Verify mart updating
SELECT 'Priority Roles Dimension' AS table_name, COUNT(*) as record_count FROM priority_mart.priority_roles
UNION ALL
SELECT 'Priority Jobs Snapshot', COUNT(*) FROM priority_mart.priority_jobs_snapshot;

-- Show sample from tables
SELECT * FROM priority_mart.priority_roles;


 SELECT 
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;