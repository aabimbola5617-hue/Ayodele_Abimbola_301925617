-- Speed test. Run each section in order. The real hospital tables are not changed.
-- Test data lives in a separate schema called p2_benchmark.
CREATE SCHEMA p2_benchmark;

-- 100,000 made-up appointment records, one per hour from 2000-01-01.
-- All use existing patient P001 and doctor D001. Test data only.
CREATE TABLE p2_benchmark.appointment_history AS
SELECT g AS appointment_id, p.patient_id, d.doctor_id,
       TIMESTAMPTZ '2000-01-01 00:00:00+00' + g * INTERVAL '1 hour' AS scheduled_at,
       'completed'::varchar(10) AS status
FROM generate_series(1, 100000) AS g
CROSS JOIN public.patient p CROSS JOIN public.doctor d
WHERE p.hospital_number = 'P001' AND d.staff_number = 'D001';

-- Let PostgreSQL collect statistics so it can choose a plan.
ANALYZE p2_benchmark.appointment_history;

-- Check the data. Expected: 100000 rows, then 24 appointments on 1 Jan 2005
-- (one per hour for 24 hours).
SELECT count(*) AS test_rows FROM p2_benchmark.appointment_history;
SELECT count(*) AS appointments_on_day FROM p2_benchmark.appointment_history
WHERE scheduled_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND scheduled_at <  TIMESTAMPTZ '2005-01-02 00:00:00+00';

-- BEFORE: run this EXPLAIN four times. Ignore the first (warm-up).
-- Record the Execution Time and shared-buffer hits of runs 2, 3 and 4.
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) AS appointments_on_day FROM p2_benchmark.appointment_history
WHERE scheduled_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND scheduled_at <  TIMESTAMPTZ '2005-01-02 00:00:00+00';

-- Add only this index. Rows and query stay the same.
CREATE INDEX appointment_history_scheduled_at_idx
    ON p2_benchmark.appointment_history (scheduled_at);

-- Update statistics and the visibility map so an index-only scan is possible.
-- (Run on its own, outside any transaction block.)
VACUUM (ANALYZE) p2_benchmark.appointment_history;

-- AFTER: run the identical EXPLAIN four times, ignore the first, record three.
-- Expected: the count is still 24 and the plan uses the new index
-- (Index Only Scan, Index Scan or Bitmap Heap Scan). Record YOUR plan name.
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) AS appointments_on_day FROM p2_benchmark.appointment_history
WHERE scheduled_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND scheduled_at <  TIMESTAMPTZ '2005-01-02 00:00:00+00';
