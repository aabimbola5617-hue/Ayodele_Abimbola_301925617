# MIT 8103 Advanced Database Systems: Portfolio Summary

**Oluwasinayomi Hospital Records System** | [YOUR NAME] | Student ID: [YOUR STUDENT ID]

GitHub: [YOUR PRIVATE REPOSITORY URL] (access granted to the assessor)

> Draft. Items in [square brackets] must be replaced with your own results, reflection and declaration. Remove this note and check the exported PDF is 2-3 pages.

## Case study

Oluwasinayomi Hospital is a simulated general hospital with outpatient clinics. Receptionists book appointments, doctors record diagnoses and prescriptions, and laboratory staff record test results. The database stores departments, doctors, patients, appointments, medications, prescriptions and lab results, using fictional data. PostgreSQL holds the transactional records; MongoDB holds a read-oriented copy of completed visits.

## Portfolio 1: Database Design and Modelling

The relational design has seven tables: department, doctor, patient, appointment, medication, prescription and lab_result. Each table has a primary key, and foreign keys connect appointments to patients and doctors, and prescriptions and lab results to appointments. Unique constraints cover hospital numbers, staff numbers, emails and medication names. Check constraints restrict appointment status, require a positive prescription duration, and stop a lab result being recorded before it was requested. A partial unique index allows only one scheduled appointment per doctor and time [1]. Normalisation moved a paper visit sheet into third normal form by separating repeating medicines and tests (1NF), visit details (2NF) and patient, doctor and department details (3NF). [Nine invalid inserts were rejected by the intended rules: replace with your result.]

![ER diagram](ER_diagram_screenshot.png)

Figure 1. The seven tables and their relationships. PK = primary key, FK = foreign key, UK = unique value.

## Portfolio 2: Query Processing and Optimisation

Four queries retrieve upcoming appointments, a patient's history with prescriptions, appointments per doctor, and pending lab tests. [State your actual results, for example the number of rows each returned.] A separate table of 100,000 generated appointments tested an index on scheduled_at. The same date query returned [24] rows before and after the index. EXPLAIN (ANALYZE, BUFFERS) recorded each plan [2].

| Measurement | Before index | After index |
| --- | --- | --- |
| Plan node | [your plan] | [your plan] |
| Median execution time (3 runs) | [x ms] | [y ms] |
| Shared buffer hits | [n] | [n] |

[Explain what the numbers show.] These cached, shared-environment measurements do not predict every workload, and an index adds storage and write cost.

## Portfolio 3: Transactions and Concurrency

A visit was completed by updating the appointment and inserting a prescription in one transaction, then saved with COMMIT. Repeating the conditional update changed [0] rows. In a second transaction a valid booking was followed by an invalid lab result; ROLLBACK removed the booking. Two sessions then tried to book the same doctor slot under READ COMMITTED [3]. Session A inserted a booking without committing. Session B could not see it, and its insert waited. After A committed, B received a duplicate-key error on doctor_one_booking_per_slot and rolled back, leaving one booking. [Confirm this matches your run.] This shows that checking availability first is not enough: the unique index enforces the rule when sessions overlap.

## Portfolio 4: NoSQL and Advanced Data Models

MongoDB stores completed visits in hospital_records.patient_visits. Each document embeds the doctor, prescriptions and lab results, so a visit is read in one query [4]. [Insert acknowledged for three visits; count three.] Queries returned a patient's visits in date order, visits prescribing Paracetamol, visits with a pending lab result, and visits per department by aggregation. [Confirm your results.] Documents can hold different vital signs without a schema change. Patient and doctor details are snapshots, and PostgreSQL remains responsible for booking rules. The two databases were populated separately, not synchronised automatically.

## Portfolio 5: Distributed and Cloud Database Exercise

This is a proposed design, not an implementation. PostgreSQL would use a primary with a standby in another zone; MongoDB would use a three-member replica set across zones [5]. Asynchronous replication risks losing recent writes at failover, while synchronous replication slows commits. Booking should stay on the primary for consistency; reports could use replicas. Sharding is not justified for one hospital. A cloud deployment would also need access control, encryption, tested backups and a check of data-protection requirements. No replica set, sharding or failover test was performed.

## Evidence

[P1 design and tests]([link]), [P2 plans and timings]([link]), [P3 transactions]([link]), [P4 NoSQL]([link]), [P5 proposal]([link]). Earlier screenshots show earlier database states; Portfolio 3 changes one appointment.

## Individual reflection

[Write your own: one design choice, one difficulty, what you did about it and what you learned. Use only what you actually experienced.]

## References

[1] PostgreSQL Global Development Group. PostgreSQL 16: Constraints. https://www.postgresql.org/docs/16/ddl-constraints.html
[2] PostgreSQL Global Development Group. PostgreSQL 16: Using EXPLAIN. https://www.postgresql.org/docs/16/using-explain.html
[3] PostgreSQL Global Development Group. PostgreSQL 16: Transaction Isolation. https://www.postgresql.org/docs/16/transaction-iso.html
[4] MongoDB. Data Modeling. https://www.mongodb.com/docs/manual/data-modeling/
[5] MongoDB. Replication. https://www.mongodb.com/docs/manual/replication/

Accessed [DATE]. The hospital data is fictional; benchmark rows are generated by the saved SQL.

## AI-use declaration

[Complete this honestly. State (i) the AI tool used, (ii) what it was used for, and (iii) how you reviewed, ran, corrected or verified the output. Do not claim checks you did not perform.]
