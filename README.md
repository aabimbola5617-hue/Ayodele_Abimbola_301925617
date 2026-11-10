# MIT 8103 Advanced Database Systems: Portfolio

**Student:** [AYODELE ABIMBOLA ROTIMI] | **Student ID:** [301925617 ]
**Case study:** Oluwasinayomi Hospital (simulated organisation, fictional data)

## Case study statement

| Item | Description |
| --- | --- |
| Organisation | Oluwasinayomi Hospital, a simulated general hospital with outpatient clinics. All people and records are fictional. |
| Nature of the system | A patient-care records system for outpatient visits: appointments, diagnoses, prescriptions and laboratory tests. |
| Users | Receptionists (book and cancel appointments), doctors (record diagnoses and prescriptions), laboratory staff (record test results), administrators (reports). |
| Major data | Departments, doctors, patients, appointments, medications, prescriptions and lab results. |
| Key operations | Book an appointment, prevent a doctor being double-booked, complete a visit with diagnosis and prescription, retrieve a patient's history, track pending lab results, report appointments per doctor. |

The same hospital is used in all five portfolios.

## Portfolio map

| Portfolio | Technology | Folder |
| --- | --- | --- |
| 1. Database Design and Modelling | PostgreSQL | [portfolio-1-database-design](portfolio-1-database-design/) |
| 2. Query Processing and Optimisation | PostgreSQL | [portfolio-2-query-optimisation](portfolio-2-query-optimisation/) |
| 3. Transactions and Concurrency | PostgreSQL | [portfolio-3-transactions-concurrency](portfolio-3-transactions-concurrency/) |
| 4. NoSQL and Advanced Data Models | MongoDB | [portfolio-4-nosql](portfolio-4-nosql/) |
| 5. Distributed and Cloud Database Exercise | Discussion and proposed design | [portfolio-5-distributed-cloud](portfolio-5-distributed-cloud/) |

Final 2-3 page summary: [FinalSummary.md](FinalSummary.md)

## Run order

The scripts depend on each other. Run them in this order, in a database named `oluwasinayomi_hospital`:

1. `portfolio-1-database-design/01_schema.sql`, `02_sample_data.sql`, then `03_constraint_tests.sql`
2. `portfolio-2-query-optimisation/01_queries.sql`, then `02_optimisation.sql`
3. `portfolio-3-transactions-concurrency/01_transactions.sql`, then the two-terminal session scripts
4. `portfolio-4-nosql/01_patient_visits.js` in `mongosh`

Portfolio 2 expected results describe the data **before** Portfolio 3, which changes one appointment.

## Evidence

Each portfolio has an `evidence/` folder for your own screenshots and copied outputs. Commit after each portfolio so the Git history shows progressive work.
