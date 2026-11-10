-- Commit and rollback examples. Run after Portfolio 2.
-- These CHANGE the original data: appointment P001 / Dr Bello 2026-11-12 11:00 becomes completed.

-- ===== Example 1: COMMIT =====
-- Completing a visit must save the diagnosis and the prescription together.
BEGIN;

UPDATE public.appointment
SET status = 'completed', diagnosis = 'Hypertension, stable on treatment'
WHERE patient_id = (SELECT patient_id FROM public.patient WHERE hospital_number = 'P001')
  AND doctor_id  = (SELECT doctor_id  FROM public.doctor  WHERE staff_number = 'D002')
  AND scheduled_at = TIMESTAMPTZ '2026-11-12 11:00:00+00'
  AND status = 'scheduled';
-- Expected: UPDATE 1

INSERT INTO public.prescription (appointment_id, medication_id, dosage, duration_days)
SELECT a.appointment_id, m.medication_id, '5 mg once daily', 30
FROM public.appointment a CROSS JOIN public.medication m
WHERE a.patient_id = (SELECT patient_id FROM public.patient WHERE hospital_number = 'P001')
  AND a.doctor_id  = (SELECT doctor_id  FROM public.doctor  WHERE staff_number = 'D002')
  AND a.scheduled_at = TIMESTAMPTZ '2026-11-12 11:00:00+00'
  AND m.name = 'Amlodipine';
-- Expected: INSERT 0 1

COMMIT;

-- Repeat the same conditional UPDATE. It is no longer 'scheduled', so nothing changes.
-- Expected: UPDATE 0
UPDATE public.appointment
SET status = 'completed', diagnosis = 'Hypertension, stable on treatment'
WHERE patient_id = (SELECT patient_id FROM public.patient WHERE hospital_number = 'P001')
  AND doctor_id  = (SELECT doctor_id  FROM public.doctor  WHERE staff_number = 'D002')
  AND scheduled_at = TIMESTAMPTZ '2026-11-12 11:00:00+00'
  AND status = 'scheduled';

-- Confirm the saved result. Expected: completed | Hypertension, stable on treatment | Amlodipine
SELECT a.status, a.diagnosis, m.name AS medication
FROM public.appointment a
JOIN public.prescription pr ON pr.appointment_id = a.appointment_id
JOIN public.medication m ON m.medication_id = pr.medication_id
WHERE a.patient_id = (SELECT patient_id FROM public.patient WHERE hospital_number = 'P001')
  AND a.scheduled_at = TIMESTAMPTZ '2026-11-12 11:00:00+00';

-- ===== Example 2: ROLLBACK =====
-- Book a valid appointment, then hit an invalid lab request. Nothing should be kept.
BEGIN;

INSERT INTO public.appointment (patient_id, doctor_id, scheduled_at, reason)
SELECT p.patient_id, d.doctor_id, TIMESTAMPTZ '2026-11-13 10:00:00+00', 'Follow-up consultation'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.hospital_number = 'P003' AND d.staff_number = 'D003';
-- Expected: INSERT 0 1

-- Inside the transaction the new booking is visible. Expected: 1
SELECT count(*) AS booking_inside_transaction FROM public.appointment a
JOIN public.doctor d ON d.doctor_id = a.doctor_id
WHERE d.staff_number = 'D003' AND a.scheduled_at = TIMESTAMPTZ '2026-11-13 10:00:00+00';

-- Invalid: the result time is before the request time.
-- Expected: ERROR: new row for relation "lab_result" violates check constraint "lab_result_not_before_request"
INSERT INTO public.lab_result (appointment_id, test_name, requested_at, result_text, resulted_at)
SELECT a.appointment_id, 'Urine test',
       TIMESTAMPTZ '2026-11-13 10:30:00+00', 'Normal', TIMESTAMPTZ '2026-11-13 10:00:00+00'
FROM public.appointment a JOIN public.doctor d ON d.doctor_id = a.doctor_id
WHERE d.staff_number = 'D003' AND a.scheduled_at = TIMESTAMPTZ '2026-11-13 10:00:00+00';

-- The transaction is now aborted. Undo everything in it.
ROLLBACK;

-- The booking is gone. Expected: 0. The committed Example 1 changes remain.
SELECT count(*) AS booking_after_rollback FROM public.appointment a
JOIN public.doctor d ON d.doctor_id = a.doctor_id
WHERE d.staff_number = 'D003' AND a.scheduled_at = TIMESTAMPTZ '2026-11-13 10:00:00+00';
