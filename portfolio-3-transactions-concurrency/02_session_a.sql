-- Use TWO terminals. Do not run this whole file at once.
-- Scenario: two receptionists try to book Dr Amaka Obi (D001) for 2026-11-13 10:00.

-- A1: First terminal, after 01_transactions.sql.
SET application_name = 'p3_session_a';
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;
INSERT INTO public.appointment (patient_id, doctor_id, scheduled_at, reason)
SELECT p.patient_id, d.doctor_id, TIMESTAMPTZ '2026-11-13 10:00:00+00', 'Chest review'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.hospital_number = 'P002' AND d.staff_number = 'D001';
-- STOP. Leave this transaction OPEN. Run B1 in the second terminal now.

-- A2: After Session B's INSERT is waiting, run this in Session A.
SELECT application_name, wait_event_type FROM pg_stat_activity
WHERE application_name = 'p3_session_b';
-- Expected: p3_session_b | Lock. Take the screenshot, then continue.
COMMIT;
-- Switch to Session B: its INSERT should now fail on doctor_one_booking_per_slot.
