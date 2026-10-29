# Exploratory Data Analysis with SQL: Data Engineer Job Market

<!-- ![Project overview](images/eda_overview.png) -->

An SQL project that analyzes the Data Engineer job market through three analytical queries, turning business questions into data-driven insights.

## Executive Summary

- **Project scope:** 3 analytical queries answering key questions about the Data Engineer job market.
- **Data modeling:** multi-table joins across fact, dimension and bridge tables to extract insights.
- **Analytics:** aggregations, filtering and sorting to find the top skills by demand, salary and overall value.
- **Outcomes:** actionable insights on SQL/Python dominance, cloud trends and salary patterns.

**Files in this project:**

- `1_EDA.sql`: demand analysis with multi-table joins
- `2_EDA.sql`: salary analysis with aggregations
- `3_EDA.sql`: combined demand/salary optimization query

## Problem & Context

The analysis aims to answer three questions:

- **Most in demand:** which skills are most requested for Data Engineers?
- **Highest paid:** which skills command the highest salaries?
- **Best trade-off:** which skill set best balances demand and compensation?

The analysis runs on a data warehouse with a star schema design.

<!-- ![Star schema](images/star_schema.png) -->

- **Fact table:** `job_postings_fact`, the central table with job posting details (titles, locations, salaries, dates, etc.)
- **Dimension tables:**
  - `company_dim`: company information linked to job postings
  - `skills_dim`: skills catalog with skill names and types
- **Bridge table:** `skills_job_dim`, which resolves the many-to-many relationship between job postings and skills

This model makes it possible to extract insights on skills, salaries and optimal skill combinations for Data Engineering roles.

## Tech Stack

| Area | Tool |
|---|---|
|  Query engine | DuckDB, for fast OLAP-style analytical queries |
|  Language | SQL (ANSI-style with analytical functions) |
|  Data model | Star schema with fact + dimension + bridge tables |
|  Development | VS Code for SQL editing + terminal for DuckDB CLI |
|  Version control | Git / GitHub |

## Repository Structure

```text
├── 1_EDA.sql     # demand analysis query
├── 2_EDA.sql     # salary analysis query
├── 3_EDA.sql     # combined demand/salary optimization
└── README.md     # you are here
```

## Analysis Overview

### Query Structure

1. **Top Demanded Skills:** identifies the 10 most in-demand skills for remote Data Engineer positions.
2. **Top Paying Skills:** analyzes the 25 highest-paying skills with salary and demand metrics.
3. **Optimal Skills:** computes an optimal score combining the natural log of demand with median salary, to identify the most valuable skills to learn.

### Key Insights

- **Core languages:** SQL and Python each appear in ~29,000 job postings, making them the most in-demand skills.
- **Cloud platforms:** AWS and Azure are critical for modern Data Engineering roles.
- **Infrastructure & tooling:** Kubernetes, Docker and Terraform are associated with premium salaries.
- **Big data tools:** Apache Spark shows strong demand with competitive compensation.

## SQL Skills Demonstrated

### Query Design & Optimization

- **Complex joins:** multi-table `INNER JOIN` across `job_postings_fact`, `skills_job_dim` and `skills_dim`
- **Aggregations:** `COUNT()`, `MEDIAN()`, `ROUND()` for statistical analysis
- **Filtering:** boolean logic with `WHERE` and multiple conditions (`job_title_short`, `job_work_from_home`, `salary_year_avg IS NOT NULL`)
- **Sorting & limiting:** `ORDER BY ... DESC` and `LIMIT` for top-N analysis

### Data Analysis Techniques

- **Grouping:** `GROUP BY` for categorical analysis by skill
- **Mathematical functions:** `LN()` to log-transform and normalize demand
- **Calculated metrics:** optimal score combining log-transformed demand with median salary
- **`HAVING` clause:** filtering aggregated results (skills with >= 100 postings)
- **NULL handling:** filtering out incomplete records (`salary_year_avg IS NOT NULL`)