<h1 align="center">💧 A Data-Driven Journey in Maji Ndogo</h1>

<p align="center">
  <em>Using SQL to explore, validate and clean a national water-access survey database</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SQL-MySQL-4479A1?logo=mysql&logoColor=white" alt="MySQL">
  <img src="https://img.shields.io/badge/Focus-Data%20Exploration%20%26%20Cleaning-0EA5E9" alt="Focus">
  <img src="https://img.shields.io/badge/Domain-Public%20Water%20Services-22C55E" alt="Domain">
  <img src="https://img.shields.io/badge/Part-1%20of%20Series-F59E0B" alt="Part 1">
</p>

---

## 🌍 The Story

Maji Ndogo is a nation facing a serious water crisis. Thousands of water sources across the country were surveyed by field workers, producing **tens of thousands of records** on water source types, queue times, water quality and well pollution.

Before any solution can be planned, the data has to be **understood and trusted**. In this first stage of the project, I acted as the data analyst on the ground: exploring the `md_water_services` database, investigating unusual patterns, and uncovering and correcting data-entry errors that could have led to unsafe water being labelled as clean.

> **Why it matters:** a single mislabelled record in a pollution table could mean a community keeps drinking contaminated water. Data quality here is a public health issue, not just a technical one.

---

## 🎯 Objectives

| # | Goal | What I did |
|:-:|---|---|
| 1 | **Understand the database** | Surveyed every table and read the data dictionary |
| 2 | **Profile water sources** | Identified the distinct types of water sources in the country |
| 3 | **Analyse visits and queues** | Found sources where people queued for more than 500 minutes |
| 4 | **Assess water quality** | Investigated suspicious quality scores on repeat visits |
| 5 | **Investigate pollution** | Detected wells wrongly marked "Clean" despite biological contamination |
| 6 | **Clean the data safely** | Corrected errors on a test copy before touching production data |

---

## 🗄️ Database Schema

The `md_water_services` database contains eight tables:

| Table | Contents |
|---|---|
| `data_dictionary` | Descriptions of every table and column |
| `employee` | Field surveyors who collected the data |
| `location` | Addresses, towns and provinces of each source |
| `water_source` | Source ID, type and number of people served |
| `visits` | Each visit to a source, including time spent in queue |
| `water_quality` | Subjective quality scores recorded by surveyors |
| `well_pollution` | Lab results for chemical and biological contamination |
| `global_water_access` | International benchmark data on water access |

---

## 🔍 Analysis Walkthrough

### 1️⃣ Getting to Know the Data
I started by listing all tables and previewing five rows from each, then read the full data dictionary to understand what every column means before writing any analytical queries.

```sql
SHOW TABLES;

SELECT *
FROM data_dictionary;
```

### 2️⃣ Types of Water Sources
Identifying the distinct categories of water sources gave a clear picture of the infrastructure people rely on.

```sql
SELECT DISTINCT type_of_water_source
FROM water_source;
```

### 3️⃣ Extreme Queue Times
Some citizens wait **more than 500 minutes (over 8 hours)** to collect water. I isolated these visits, then cross-referenced specific source IDs with the `water_source` table to see which types of sources caused the longest waits.

```sql
SELECT *
FROM visits
WHERE time_in_queue > 500;

SELECT *
FROM water_source
WHERE source_id IN ('AkKi00881224', 'SoRu37635224',
                    'SoRu36096224', 'HaZa21742224');
```

### 4️⃣ Questionable Quality Scores
Home taps are expected to score a perfect 10 and should not need repeat visits. Records showing a **score of 10 on a second visit** suggested possible surveyor errors and were flagged for auditing.

```sql
SELECT *
FROM water_quality
WHERE subjective_quality_score = 10
  AND visit_count = 2;
```

### 5️⃣ Uncovering Pollution Data Errors 🚨
This was the most critical finding. Some wells were recorded as **"Clean" even though their biological contamination reading was above the safe threshold of 0.01**. Further digging showed descriptions such as `Clean Bacteria: E. coli`, which contradict themselves.

```sql
-- Wells labelled Clean despite biological contamination
SELECT *
FROM well_pollution
WHERE results = 'Clean'
  AND biological > 0.01;

-- Descriptions that start with "Clean" followed by extra text
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%';
```

### 6️⃣ Cleaning the Data Safely
Rather than editing the live table directly, I followed a **test-first approach**: create a copy, apply the fixes, verify the results, then drop the copy once the logic was proven.

```sql
-- Create a test copy of the table
CREATE TABLE md_water_services.well_pollution_copy AS
SELECT * FROM md_water_services.well_pollution;

-- Fix contradictory descriptions
UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Reclassify contaminated wells
UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';

-- Verification: this should return zero rows
SELECT *
FROM well_pollution_copy
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);
```

---

## 💡 Key Findings

- 🕒 **Severe queue times:** some visits show waits of over 500 minutes, a clear sign that certain water sources are badly overloaded.
- 📝 **Survey reliability concerns:** perfect quality scores on repeat visits point to possible recording errors that warrant an audit.
- ☣️ **Mislabelled contaminated wells:** wells carrying E. coli and Giardia Lamblia were recorded as "Clean", a dangerous error with direct health consequences.
- ✅ **Errors corrected and verified:** every contradictory description and misclassified result was fixed, and a verification query confirmed no inconsistent records remained.

---

## 🧠 SQL Skills Demonstrated

| Data Exploration | Filtering & Logic | Data Cleaning |
|---|---|---|
| `SHOW TABLES`, `SELECT`, `LIMIT` | `WHERE` with `AND` / `OR` | `UPDATE ... SET ... WHERE` |
| `DISTINCT` | `IN` lists | Test tables with `CREATE TABLE ... AS` |
| Reading a data dictionary | Pattern matching with `LIKE` and wildcards | Verification queries and `DROP TABLE` |

**Professional practices:** testing changes on a copy before production, verifying every update, documenting each step with clear comments, and treating data quality as a real-world risk.

---

## 🚀 How to Run This Project

1. Install [MySQL Server](https://dev.mysql.com/downloads/) and [MySQL Workbench](https://dev.mysql.com/downloads/workbench/).
2. Load the `md_water_services` database.
3. Clone this repository:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   ```
4. Open `Data-driven_Journey_In_Maji_Ndogo project 1.sql` in MySQL Workbench.
5. Run the queries section by section to follow the analysis.

---

## 📂 Repository Contents

```
📁 maji-ndogo-sql-project
├── Data-driven_Journey_In_Maji_Ndogo project 1.sql   # All queries, organised by section
└── README.md                                          # Project documentation
```

---

## 🔭 What's Next

This is **Part 1** of the Maji Ndogo series. Upcoming stages will build on this clean foundation to:

- Analyse water access by province and town
- Evaluate employee survey performance
- Quantify the population affected by each source type
- Recommend and prioritise infrastructure improvements

---

## 👋 About Me

**Favour · Aspiring Data Analyst

I enjoy turning messy data into clear, trustworthy insights that help solve real problems.

[![LinkedIn](www.linkedin.com/in/favour-ntoimo-esq-09974a274)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?logo=github&logoColor=white)](https://github.com/your-username)
[![Email](https://img.shields.io/badge/Email-Contact-EA4335?logo=gmail&logoColor=white)](mailto:your.email@example.com)

<p align="center"><em>"Clean data saves lives, especially when it's about clean water."</em></p>
