# Portfolio 2: Query Processing and Optimisation

Same hospital database as Portfolio 1. Run these scripts **before** Portfolio 3.

## Queries ([01_queries.sql](01_queries.sql))

| Query | Purpose | Expected result (original sample data) |
| --- | --- | --- |
| Q1 | Upcoming scheduled appointments with patient and doctor | 2 rows: Emeka Nwosu with Dr Obi at 09:30, Chinedu Okafor with Dr Bello at 11:00, both on 2026-11-12 |
| Q2 | History of patient P001 with prescriptions (LEFT JOIN) | 2 rows: the completed malaria visit with Paracetamol, and the scheduled visit with no medication |
| Q3 | Appointments per doctor, all statuses | Dr Obi 3, Dr Bello 2, Dr Eze 0 (LEFT JOIN keeps the doctor with none) |
| Q4 | Lab tests still pending | 1 row: Fatima Yusuf, ECG |

## Optimisation experiment ([02_optimisation.sql](02_optimisation.sql))

**Question:** does an index on `scheduled_at` speed up counting the appointments on one day?

The hospital tables hold only five appointments, so any plan would be fast. A separate table, `p2_benchmark.appointment_history`, holds 100,000 generated appointments (one per hour). The real tables are unchanged. The query counts appointments on 1 January 2005 and should return **24** before and after the index.

Method: run `EXPLAIN (ANALYZE, BUFFERS)` four times, ignore the first (warm-up) run, record the next three; then add the index, `VACUUM (ANALYZE)`, and repeat.

## My results

Fill this table from your own runs. Do not copy another student's numbers.

| Measurement | Before index | After index |
| --- | --- | --- |
| Rows returned | [your result] | [your result] |
| Plan node (for example Seq Scan, Index Only Scan) | [your plan] | [your plan] |
| Execution time, runs 2/3/4 (ms) | [t2 / t3 / t4] | [t2 / t3 / t4] |
| Median execution time (ms) | [median] | [median] |
| Shared buffer hits, run 4 | [hits] | [hits] |

## Performance analysis (write in your own words after your runs)

Cover: (1) what changed in the plan, (2) how the time and buffer numbers changed and why, (3) limits of the measurement (cached data, shared Codespace, three runs only, one query), (4) cost of the index (extra storage, slower inserts and updates).

Points worth checking against your numbers:

- PostgreSQL does not create indexes on foreign-key columns automatically. In a larger hospital database, `appointment (patient_id)` would be a candidate index for the patient-history query (Q2).
- An index on a column the query does not filter by brings no benefit and only adds write cost.

## Evidence to save in `evidence/`

Query outputs for Q1-Q4; both full EXPLAIN outputs (before and after); the three-run timing notes.

## Reference

PostgreSQL Global Development Group. *PostgreSQL 16: Using EXPLAIN*. https://www.postgresql.org/docs/16/using-explain.html
