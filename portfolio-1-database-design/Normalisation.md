# Normalisation: from a paper visit sheet to third normal form

## Starting point (unnormalised)

The hospital's paper visit sheet repeats patient, doctor and department details on every row, and packs several medicines and tests into single cells:

| appointment_no | patient_no | patient_name | date_of_birth | doctor_no | doctor_name | department | scheduled_at | diagnosis | medicines | lab_tests |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | P001 | Chinedu Okafor | 1985-03-12 | D001 | Dr Amaka Obi | General Medicine | 2026-10-05 09:00 | Malaria | Paracetamol 500 mg x5 days | Malaria parasite test |
| 2 | P002 | Fatima Yusuf | 1992-07-30 | D002 | Dr Tunde Bello | Cardiology | 2026-10-06 10:00 | Hypertension | Amlodipine 5 mg x30 days; Aspirin 75 mg x30 days | ECG; Lipid profile |

Problems: several values in one cell, patient and doctor details copied on every visit (update anomalies), and a department name that depends on the doctor rather than the visit.

## First normal form (1NF): one value per cell

Split the repeating `medicines` and `lab_tests` into separate rows. Key: (appointment_no, medicine) for medicines and (appointment_no, test) for tests.

| appointment_no | medicine | dosage | duration_days | (appointment, patient, doctor details repeated) |
| --- | --- | --- | --- | --- |
| 2 | Amlodipine | 5 mg once daily | 30 | ... |
| 2 | Aspirin | 75 mg once daily | 30 | ... |

## Second normal form (2NF): remove partial dependencies

In the medicine rows, patient, doctor, date and diagnosis depend on `appointment_no` alone, not on the whole key (appointment_no, medicine). Move them into an **appointment** table. Dosage and duration depend on the whole key, so they stay in **prescription**. Lab tests move to **lab_result** in the same way.

- appointment(appointment_no, patient_no, patient_name, date_of_birth, doctor_no, doctor_name, department, scheduled_at, diagnosis)
- prescription(appointment_no, medicine, dosage, duration_days)
- lab_result(appointment_no, test, requested_at, result)

## Third normal form (3NF): remove transitive dependencies

In **appointment**, `patient_no` determines patient name and date of birth, and `doctor_no` determines doctor name and department. These depend on appointment_no only through another non-key column. Move them out:

- **patient**(hospital_number, full_name, date_of_birth, phone)
- **doctor**(staff_number, full_name, email, department)
- **department**(name): the department name is stored once.
- **medication**(name): medicine names are stored once and referenced by prescriptions.

## Result

Seven tables: department, doctor, patient, appointment, medication, prescription, lab_result. Each fact is stored once. For example, correcting a patient's phone number changes one row, and a doctor moving department changes one row. Surrogate keys (`*_id`) are used for joins, while natural identifiers (hospital_number, staff_number) remain unique.

Design trade-off: the diagnosis is one text column on the appointment. A coded diagnosis table (for example ICD codes) would support better reporting and several diagnoses per visit, but would add complexity beyond this assessment.
