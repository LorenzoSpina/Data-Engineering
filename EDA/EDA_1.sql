SELECT 
sd.skills,
COUNT(jpf.*)
FROM job_postings_fact AS jpf 

INNER JOIN skills_job_dim as sjd
  ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
  ON sd.skill_id = sjd.skill_id
  
WHERE jpf.job_title_short = 'Data Engineer' AND jpf.job_work_from_home IS TRUE
GROUP by sd.skills
ORDER BY  COUNT(jpf.*) DESC
LIMIT 10