# Portfolio 4: NoSQL and Advanced Data Models

## Model

**Type:** document database (MongoDB). **Database:** `hospital_records`. **Collection:** `patient_visits`.

Each document is one completed visit and embeds the doctor, the prescriptions and the lab results that belong to it. The shape follows how clinicians read a record: the visit and everything attached to it, in one read [1].

| PostgreSQL (Portfolio 1) | MongoDB document |
| --- | --- |
| appointment, patient, doctor, department | top-level fields and embedded `patient` and `doctor` objects |
| prescription rows | `prescriptions` array |
| lab_result rows | `lab_results` array |

## Why a document model suits this part of the hospital

- A visit record is read as a whole, so embedding avoids joins.
- Visit details vary: V001 records temperature, V002 records heart rate. Documents can hold different `vitals` fields without changing a schema.
- Prescription and lab arrays grow per visit and are not shared across visits.

## Where it does not suit

- Patient and doctor details are **snapshots**. A later name change is not applied to old documents (which can be correct for history, but must be intentional).
- The rules that prevent double booking and invalid lab times stay in PostgreSQL. MongoDB here holds a read-optimised copy of completed visits, not the system of record, and this exercise does not synchronise the two automatically.

## Implementation ([01_patient_visits.js](01_patient_visits.js))

```bash
mongosh --file 01_patient_visits.js
```

The script inserts three visits, creates an index on `patient.hospital_number` and `visited_at`, and runs five queries.

| Query | Purpose | Expected |
| --- | --- | --- |
| Q1 | Count documents | 3 |
| Q2 | History for P001 in date order | V001, then V003 |
| Q3 | Visits prescribing Paracetamol | V001 |
| Q4 | Visits with a pending lab result | V002 |
| Q5 | Visits per department (aggregation) | Cardiology 2, General Medicine 1 |

V003 matches the appointment completed in Portfolio 3, so run Portfolio 3 first if you want both databases to agree.

## My results

| Item | Evidence file |
| --- | --- |
| mongosh connection / insert acknowledgement | `evidence/[file name]` |
| Q1-Q5 outputs | `evidence/[file name]` |
| Index creation output | `evidence/[file name]` |

## Reference

[1] MongoDB. *Data Modeling*. https://www.mongodb.com/docs/manual/data-modeling/
