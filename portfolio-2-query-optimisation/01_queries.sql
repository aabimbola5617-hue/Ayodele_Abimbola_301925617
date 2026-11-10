-- Four hospital queries. Run after Portfolio 1 sample data, BEFORE Portfolio 3.
-- Expected results describe the original sample data.

-- Q1: Upcoming (scheduled) appointments with patient and doctor.
-- Expected: 2 rows. 2026-11-12 09:30 Emeka Nwosu with Dr Amaka Obi, then
--           2026-11-12 11:00 Chinedu Okafor with Dr Tunde Bello.
SELECT a.scheduled_at, p.hospital_number, p.full_name AS patient,
       d.full_name AS doctor, a.reason
FROM public.appointment a
JOIN public.patient p ON p.patient_id = a.patient_id
JOIN public.doctor  d ON d.doctor_id  = a.doctor_id
WHERE a.status = 'scheduled'
ORDER BY a.scheduled_at, d.full_name;

-- Q2: Patient history for P001, with any prescription (LEFT JOIN keeps visits without one).
-- Expected: 2 rows. 2026-10-05 completed, Malaria (uncomplicated), Paracetamol;
--           2026-11-12 scheduled, no diagnosis, no medication.
SELECT a.scheduled_at, a.status, d.full_name AS doctor, a.diagnosis,
       m.name AS medication, pr.dosage
FROM public.appointment a
JOIN public.patient p ON p.patient_id = a.patient_id
JOIN public.doctor  d ON d.doctor_id  = a.doctor_id
LEFT JOIN public.prescription pr ON pr.appointment_id = a.appointment_id
LEFT JOIN public.medication   m  ON m.medication_id   = pr.medication_id
WHERE p.hospital_number = 'P001'
ORDER BY a.scheduled_at;

-- Q3: Appointments per doctor, all statuses. LEFT JOIN keeps doctors with none.
-- Expected: D001 Dr Amaka Obi (General Medicine) 3; D002 Dr Tunde Bello (Cardiology) 2;
--           D003 Dr Ngozi Eze (General Medicine) 0.
SELECT d.staff_number, d.full_name, dep.name AS department,
       count(a.appointment_id) AS appointments
FROM public.doctor d
JOIN public.department dep ON dep.department_id = d.department_id
LEFT JOIN public.appointment a ON a.doctor_id = d.doctor_id
GROUP BY d.staff_number, d.full_name, dep.name
ORDER BY appointments DESC, d.staff_number;

-- Q4: Lab tests still waiting for a result.
-- Expected: 1 row. P002 Fatima Yusuf, ECG, requested 2026-10-06 10:15.
SELECT p.hospital_number, p.full_name, l.test_name, l.requested_at
FROM public.lab_result l
JOIN public.appointment a ON a.appointment_id = l.appointment_id
JOIN public.patient p ON p.patient_id = a.patient_id
WHERE l.resulted_at IS NULL
ORDER BY l.requested_at;
