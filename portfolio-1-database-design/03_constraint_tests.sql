-- Nine invalid inserts. EVERY one should fail with the error shown.
-- Run them one at a time. Screenshot or copy each error into evidence/.

-- T1: duplicate hospital number.
-- Expected: duplicate key value violates unique constraint "patient_hospital_number_key"
INSERT INTO public.patient (hospital_number, full_name, date_of_birth, phone)
VALUES ('P001', 'Duplicate Patient', DATE '1990-01-01', '08010000099');

-- T2: appointment for a patient that does not exist.
-- Expected: violates foreign key constraint "appointment_patient_fk"
INSERT INTO public.appointment (patient_id, doctor_id, scheduled_at, reason)
SELECT 999999, d.doctor_id, TIMESTAMPTZ '2026-11-20 08:00:00+00', 'Unknown patient'
FROM public.doctor d WHERE d.staff_number = 'D001';

-- T3: invalid status.
-- Expected: violates check constraint "appointment_status_valid"
INSERT INTO public.appointment (patient_id, doctor_id, scheduled_at, status, reason)
SELECT p.patient_id, d.doctor_id, TIMESTAMPTZ '2026-11-20 08:00:00+00', 'pending', 'Bad status'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.hospital_number = 'P001' AND d.staff_number = 'D003';

-- T4: a diagnosis on an appointment that is not completed.
-- Expected: violates check constraint "appointment_diagnosis_only_if_completed"
INSERT INTO public.appointment (patient_id, doctor_id, scheduled_at, status, reason, diagnosis)
SELECT p.patient_id, d.doctor_id, TIMESTAMPTZ '2026-11-20 08:00:00+00', 'scheduled', 'Early diagnosis', 'Flu'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.hospital_number = 'P001' AND d.staff_number = 'D003';

-- T5: double booking. Dr Bello (D002) already has 2026-11-12 11:00 scheduled.
-- Expected: duplicate key value violates unique constraint "doctor_one_booking_per_slot"
INSERT INTO public.appointment (patient_id, doctor_id, scheduled_at, reason)
SELECT p.patient_id, d.doctor_id, TIMESTAMPTZ '2026-11-12 11:00:00+00', 'Double booking'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.hospital_number = 'P002' AND d.staff_number = 'D002';

-- T6: prescription lasting zero days.
-- Expected: violates check constraint "prescription_duration_positive"
INSERT INTO public.prescription (appointment_id, medication_id, dosage, duration_days)
SELECT a.appointment_id, m.medication_id, '500 mg twice daily', 0
FROM public.appointment a
JOIN public.patient p ON p.patient_id = a.patient_id
CROSS JOIN public.medication m
WHERE p.hospital_number = 'P001' AND a.status = 'completed' AND m.name = 'Amoxicillin';

-- T7: lab result recorded before it was requested.
-- Expected: violates check constraint "lab_result_not_before_request"
INSERT INTO public.lab_result (appointment_id, test_name, requested_at, result_text, resulted_at)
SELECT a.appointment_id, 'Full blood count',
       TIMESTAMPTZ '2026-10-05 10:00:00+00', 'Normal', TIMESTAMPTZ '2026-10-05 09:00:00+00'
FROM public.appointment a JOIN public.patient p ON p.patient_id = a.patient_id
WHERE p.hospital_number = 'P001' AND a.status = 'completed';

-- T8: a result text without a result time.
-- Expected: violates check constraint "lab_result_text_and_time_together"
INSERT INTO public.lab_result (appointment_id, test_name, requested_at, result_text, resulted_at)
SELECT a.appointment_id, 'Full blood count', TIMESTAMPTZ '2026-10-05 09:30:00+00', 'Normal', NULL
FROM public.appointment a JOIN public.patient p ON p.patient_id = a.patient_id
WHERE p.hospital_number = 'P001' AND a.status = 'completed';

-- T9: impossible date of birth.
-- Expected: violates check constraint "patient_dob_plausible"
INSERT INTO public.patient (hospital_number, full_name, date_of_birth, phone)
VALUES ('P900', 'Too Old', DATE '1850-01-01', '08010000098');

-- After all nine: nothing may have been saved. Expected: 5 appointments, 3 patients.
SELECT (SELECT count(*) FROM public.appointment) AS appointments,
       (SELECT count(*) FROM public.patient)     AS patients;
