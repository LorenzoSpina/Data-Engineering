--Step 4 Skills demand mart (dimensional mart)

--Schema reset if it already exists (idempotency purpose)
DROP SCHEMA IF EXISTS skills_mart CASCADE;

--Schema creation
CREATE SCHEMA skills_mart;


--Creation of dimension tables

-- dim_skill table creation
CREATE TABLE skills_mart.dim_skills (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

INSERT INTO skills_mart.dim_skills (
    skill_id,
    skills,
    type
)
SELECT
    skill_id,
    skills,
    type
FROM skills_dim;


-- Date dimension table creation
CREATE TABLE skills_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    quarter_name VARCHAR,
    year_quarter VARCHAR
);

INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter 
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date)::INT AS year,
    EXTRACT(MONTH FROM job_posted_date)::INT AS month,
    EXTRACT(QUARTER FROM job_posted_date)::INT AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS year_quarter
FROM job_postings_fact
ORDER BY month_start_date;


--Creation of fact_skill_demand_monthly
CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    postings_count INTEGER,
    remote_postings_count INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_mention_postings_count INTEGER,

    PRIMARY KEY (skill_id, month_start_date, job_title_short),

    FOREIGN KEY (skill_id)
        REFERENCES skills_mart.dim_skills(skill_id),

    FOREIGN KEY (month_start_date)
        REFERENCES skills_mart.dim_date_month(month_start_date)
);
    INSERT INTO skills_mart.fact_skill_demand_monthly(
        skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_mention_postings_count
    
    )

WITH job_postings_prep AS(
SELECT
    sjd.skill_id,
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    jpf.job_title_short,
    CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END  AS is_remote,
    CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
    CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mentioned
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
ON sjd.job_id = jpf.job_id
)

SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS posting_count,
    SUM(is_remote) remote_postings_count,
    SUM(has_health_insurance) health_insurance_postings_count,
    SUM(no_degree_mentioned) no_degree_mention_postings_count
FROM
    job_postings_prep
GROUP BY ALL
ORDER BY skill_id, month_start_date, job_title_short;

--Mart creation verification
SELECT  'Skill Dimension' AS table_name, COUNT(*) as record_count FROM skills_mart.dim_skills
UNION ALL
SELECT 'Date Month Dimension', COUNT(*) FROM skills_mart.dim_date_month
UNION ALL
SELECT 'Skill Demand Fact', COUNT(*) FROM skills_mart.fact_skill_demand_monthly;

--Mart rows check
SELECT * FROM skills_mart.dim_skills LIMIT 10;

SELECT * FROM skills_mart.dim_date_month LIMIT 10;

SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 10;