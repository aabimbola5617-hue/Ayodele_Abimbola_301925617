-- Fictional sample data for Oluwasinayomi Hospital. No real patients.
-- Run once after 01_schema.sql. Rows are linked by hospital/staff numbers,
-- so the script does not depend on generated ID values.
BEGIN;

INSERT INTO public.department (name) VALUES
    ('General Medicine'),
    ('Cardiology');

INSERT INTO public.doctor (staff_number, full_name, email, department_id)
SELECT v.staff_number, v.full_name, v.email, dep.department_id
FROM (VALUES
    ('D001', 'Dr Amaka Obi',   'amaka.obi@example.org',   'General Medicine'),
    ('D002', 'Dr Tunde Bello', 'tunde.bello@example.org', 'Cardiology'),
    ('D003', 'Dr Ngozi Eze',   'ngozi.eze@example.org',   'General Medicine')
) AS v(staff_number, full_name, email, department_name)
JOIN public.department dep ON dep.name = v.department_name;

INSERT INTO public.patient (hospital_number, full_name, date_of_birth, phone) VALUES
    ('P001', 'Chinedu Okafor', DATE '1985-03-12', '08010000001'),
    ('P002', 'Fatima Yusuf',   DATE '1992-07-30', '08010000002'),
    ('P003', 'Emeka Nwosu',    DATE '1978-11-05', '08010000003');

INSERT INTO public.medication (name) VALUES
    ('Paracetamol'),
    ('Amoxicillin'),
    ('Amlodipine');

-- Two completed, two scheduled and one cancelled appointment.
INSERT INTO public.appointment (patient_id, doctor_id, scheduled_at, status, reason, diagnosis)
SELECT p.patient_id, d.doctor_id, v.scheduled_at, v.status, v.reason, v.diagnosis
FROM (VALUES
    ('P001', 'D001', TIMESTAMPTZ '2026-10-05 09:00:00+00', 'completed', 'Fever and headache',   'Malaria (uncomplicated)'),
    ('P002', 'D002', TIMESTAMPTZ '2026-10-06 10:00:00+00', 'completed', 'Chest pain',           'Hypertension'),
    ('P002', 'D001', TIMESTAMPTZ '2026-10-14 14:00:00+00', 'cancelled', 'Follow-up',            NULL),
    ('P001', 'D002', TIMESTAMPTZ '2026-11-12 11:00:00+00', 'scheduled', 'Blood pressure check', NULL),
    ('P003', 'D001', TIMESTAMPTZ '2026-11-12 09:30:00+00', 'scheduled', 'Routine check-up',     NULL)
) AS v(hospital_number, staff_number, scheduled_at, status, reason, diagnosis)
JOIN public.patient p ON p.hospital_number = v.hospital_number
JOIN public.doctor  d ON d.staff_number    = v.staff_number;

-- Prescriptions for the two completed appointments.
INSERT INTO public.prescription (appointment_id, medication_id, dosage, duration_days)
SELECT a.appointment_id, m.medication_id, v.dosage, v.duration_days
FROM (VALUES
    ('P001', TIMESTAMPTZ '2026-10-05 09:00:00+00', 'Paracetamol', '500 mg three times daily', 5),
    ('P002', TIMESTAMPTZ '2026-10-06 10:00:00+00', 'Amlodipine',  '5 mg once daily',          30)
) AS v(hospital_number, scheduled_at, medication_name, dosage, duration_days)
JOIN public.patient p ON p.hospital_number = v.hospital_number
JOIN public.appointment a ON a.patient_id = p.patient_id AND a.scheduled_at = v.scheduled_at
JOIN public.medication m ON m.name = v.medication_name;

-- One finished lab test and one still pending.
INSERT INTO public.lab_result (appointment_id, test_name, requested_at, result_text, resulted_at)
SELECT a.appointment_id, v.test_name, v.requested_at, v.result_text, v.resulted_at
FROM (VALUES
    ('P001', TIMESTAMPTZ '2026-10-05 09:00:00+00', 'Malaria parasite test',
        TIMESTAMPTZ '2026-10-05 09:15:00+00', 'Positive', TIMESTAMPTZ '2026-10-05 10:00:00+00'),
    ('P002', TIMESTAMPTZ '2026-10-06 10:00:00+00', 'ECG',
        TIMESTAMPTZ '2026-10-06 10:15:00+00', NULL::varchar, NULL::timestamptz)
) AS v(hospital_number, scheduled_at, test_name, requested_at, result_text, resulted_at)
JOIN public.patient p ON p.hospital_number = v.hospital_number
JOIN public.appointment a ON a.patient_id = p.patient_id AND a.scheduled_at = v.scheduled_at;

COMMIT;

-- Check the counts. Expected: 2, 3, 3, 3, 5, 2, 2.
SELECT (SELECT count(*) FROM public.department)   AS departments,
       (SELECT count(*) FROM public.doctor)       AS doctors,
       (SELECT count(*) FROM public.patient)      AS patients,
       (SELECT count(*) FROM public.medication)   AS medications,
       (SELECT count(*) FROM public.appointment)  AS appointments,
       (SELECT count(*) FROM public.prescription) AS prescriptions,
       (SELECT count(*) FROM public.lab_result)   AS lab_results;
