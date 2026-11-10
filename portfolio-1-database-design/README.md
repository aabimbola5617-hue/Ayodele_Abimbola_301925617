# Portfolio 1: Database Design and Modelling

## Case study

Oluwasinayomi Hospital outpatient records. See the [case study statement](../README.md).

## What was designed

- [ER diagram](ER_Diagram.md): seven entities and their relationships.
- [Normalisation explanation](Normalisation.md): paper visit sheet to 3NF.
- [Schema script](01_schema.sql), [sample data](02_sample_data.sql) and [constraint tests](03_constraint_tests.sql).

## Keys and constraints

| Table | Primary key | Foreign keys | Other rules |
| --- | --- | --- | --- |
| department | department_id | none | name unique |
| doctor | doctor_id | department_id | staff_number and email unique |
| patient | patient_id | none | hospital_number unique; date of birth not before 1900 |
| appointment | appointment_id | patient_id, doctor_id | status in (scheduled, completed, cancelled); diagnosis only when completed; one scheduled booking per doctor per time (partial unique index) |
| medication | medication_id | none | name unique |
| prescription | prescription_id | appointment_id, medication_id | duration greater than 0; one row per medicine per appointment |
| lab_result | lab_result_id | appointment_id | result not before request; result text and time both present or both empty |

## Design choices

- **Partial unique index for double booking.** The rule applies only to `scheduled` rows, so cancelled and completed appointments stay as history and a cancelled slot can be rebooked.
- **Medication as its own table.** Names and spelling are stored once.
- **Lab results as their own table.** A visit can have several tests, and a pending test has no result yet.

## How to run

```bash
createdb oluwasinayomi_hospital        # or create it in your PostgreSQL client
psql -d oluwasinayomi_hospital -f 01_schema.sql
psql -d oluwasinayomi_hospital -f 02_sample_data.sql
```

Then run each statement in `03_constraint_tests.sql` and save the error messages.

## Expected results (from the script design; confirm against your own run)

- Sample data counts: 2 departments, 3 doctors, 3 patients, 3 medications, 5 appointments, 2 prescriptions, 2 lab results.
- Each of the nine invalid inserts is rejected with the constraint named in the script. After all nine, the counts are unchanged (5 appointments, 3 patients).

## My results

Replace this section with your own evidence.

| Item | Evidence file |
| --- | --- |
| `\dt` list of tables | `evidence/[file name]` |
| Sample data counts | `evidence/[file name]` |
| Constraint test errors T1-T9 | `evidence/[file name]` |
