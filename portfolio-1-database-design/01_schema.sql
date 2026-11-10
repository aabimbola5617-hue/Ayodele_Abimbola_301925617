-- Oluwasinayomi Hospital: relational schema (7 tables, third normal form).
-- Run once in the empty oluwasinayomi_hospital database.
BEGIN;

-- Each department has one unique name.
CREATE TABLE public.department (
    department_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE
);

-- Doctors belong to one department. Staff number and email are unique.
CREATE TABLE public.doctor (
    doctor_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    staff_number VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    department_id BIGINT NOT NULL,
    CONSTRAINT doctor_department_fk
        FOREIGN KEY (department_id) REFERENCES public.department (department_id)
);

-- The hospital number identifies a patient across visits.
CREATE TABLE public.patient (
    patient_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_number VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    date_of_birth DATE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    CONSTRAINT patient_dob_plausible CHECK (date_of_birth >= DATE '1900-01-01')
);

-- One appointment links one patient to one doctor at one time.
-- The diagnosis is only stored once the appointment is completed.
CREATE TABLE public.appointment (
    appointment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    doctor_id BIGINT NOT NULL,
    scheduled_at TIMESTAMPTZ NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'scheduled',
    reason VARCHAR(200) NOT NULL,
    diagnosis VARCHAR(300),
    CONSTRAINT appointment_patient_fk
        FOREIGN KEY (patient_id) REFERENCES public.patient (patient_id),
    CONSTRAINT appointment_doctor_fk
        FOREIGN KEY (doctor_id) REFERENCES public.doctor (doctor_id),
    CONSTRAINT appointment_status_valid
        CHECK (status IN ('scheduled', 'completed', 'cancelled')),
    CONSTRAINT appointment_diagnosis_only_if_completed
        CHECK (diagnosis IS NULL OR status = 'completed')
);

-- A doctor cannot have two SCHEDULED appointments at the same time.
-- Completed and cancelled rows are kept as history and do not block a slot.
CREATE UNIQUE INDEX doctor_one_booking_per_slot
    ON public.appointment (doctor_id, scheduled_at)
    WHERE status = 'scheduled';

-- Medicine details are stored once, however often they are prescribed.
CREATE TABLE public.medication (
    medication_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- One row per medicine prescribed at an appointment.
CREATE TABLE public.prescription (
    prescription_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id BIGINT NOT NULL,
    medication_id BIGINT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    duration_days INTEGER NOT NULL,
    CONSTRAINT prescription_appointment_fk
        FOREIGN KEY (appointment_id) REFERENCES public.appointment (appointment_id),
    CONSTRAINT prescription_medication_fk
        FOREIGN KEY (medication_id) REFERENCES public.medication (medication_id),
    CONSTRAINT prescription_duration_positive CHECK (duration_days > 0),
    CONSTRAINT prescription_one_per_medicine UNIQUE (appointment_id, medication_id)
);

-- A lab request is pending while result_text and resulted_at are both empty.
CREATE TABLE public.lab_result (
    lab_result_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id BIGINT NOT NULL,
    test_name VARCHAR(100) NOT NULL,
    requested_at TIMESTAMPTZ NOT NULL,
    result_text VARCHAR(300),
    resulted_at TIMESTAMPTZ,
    CONSTRAINT lab_result_appointment_fk
        FOREIGN KEY (appointment_id) REFERENCES public.appointment (appointment_id),
    CONSTRAINT lab_result_not_before_request
        CHECK (resulted_at IS NULL OR resulted_at >= requested_at),
    CONSTRAINT lab_result_text_and_time_together
        CHECK ((result_text IS NULL) = (resulted_at IS NULL))
);

COMMIT;
