SELECT 
sd.skills,
ROUND(MEDIAN(jpf.salary_year_avg)) AS median_salary_per_skill,
COUNT(jpf.*) AS number_of_job

FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim as sjd
  ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
  ON sd.skill_id = sjd.skill_id

WHERE jpf.job_title_short = 'Data Engineer' AND jpf.job_work_from_home IS TRUE AND jpf.salary_year_avg IS NOT NULL

GROUP BY sd.skills
HAVING COUNT(sd.skills) >=100
ORDER BY median_salary_per_skill DESC
LIMIT 20