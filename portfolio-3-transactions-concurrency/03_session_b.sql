-- Use TWO terminals. Do not run this whole file at once.

-- B1: Run only after Session A has inserted the booking but has NOT committed.
SET application_name = 'p3_session_b';
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;
-- The receptionist checks availability first.
SELECT count(*) AS visible_bookings FROM public.appointment a
JOIN public.doctor d ON d.doctor_id = a.doctor_id
WHERE d.staff_number = 'D001'
  AND a.scheduled_at = TIMESTAMPTZ '2026-11-13 10:00:00+00'
  AND a.status = 'scheduled';
-- Expected: 0. Session A's booking is not committed, so B cannot see it (isolation).
INSERT INTO public.appointment (patient_id, doctor_id, scheduled_at, reason)
SELECT p.patient_id, d.doctor_id, TIMESTAMPTZ '2026-11-13 10:00:00+00', 'Routine review'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.hospital_number = 'P003' AND d.staff_number = 'D001';
-- WAIT here. This statement blocks. Switch to Session A for A2 and COMMIT.
-- After A commits, expected: ERROR: duplicate key value violates unique constraint
-- "doctor_one_booking_per_slot"

-- B2: Clear the failed transaction.
ROLLBACK;
-- Exactly one booking remains, for Fatima Yusuf (P002), not Emeka Nwosu.
SELECT p.full_name, d.full_name AS doctor, a.scheduled_at, count(*) AS bookings
FROM public.appointment a
JOIN public.patient p ON p.patient_id = a.patient_id
JOIN public.doctor d ON d.doctor_id = a.doctor_id
WHERE d.staff_number = 'D001'
  AND a.scheduled_at = TIMESTAMPTZ '2026-11-13 10:00:00+00'
  AND a.status = 'scheduled'
GROUP BY p.full_name, d.full_name, a.scheduled_at;
-- Expected: Fatima Yusuf | Dr Amaka Obi | 2026-11-13 10:00:00+00 | 1
