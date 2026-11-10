# Oluwasinayomi Hospital ER Diagram

```mermaid
erDiagram
    direction LR
    department ||--o{ doctor : employs
    patient ||--o{ appointment : books
    doctor ||--o{ appointment : attends
    appointment ||--o{ prescription : includes
    medication ||--o{ prescription : "is prescribed in"
    appointment ||--o{ lab_result : requests

    department {
        bigint department_id PK
        varchar(80) name UK
    }
    doctor {
        bigint doctor_id PK
        varchar(20) staff_number UK
        varchar(120) full_name
        varchar(254) email UK
        bigint department_id FK
    }
    patient {
        bigint patient_id PK
        varchar(20) hospital_number UK
        varchar(120) full_name
        date date_of_birth
        varchar(20) phone
    }
    appointment {
        bigint appointment_id PK
        bigint patient_id FK
        bigint doctor_id FK
        timestamptz scheduled_at
        varchar(10) status
        varchar(200) reason
        varchar(300) diagnosis "Optional until completed"
    }
    medication {
        bigint medication_id PK
        varchar(100) name UK
    }
    prescription {
        bigint prescription_id PK
        bigint appointment_id FK
        bigint medication_id FK
        varchar(100) dosage
        int duration_days
    }
    lab_result {
        bigint lab_result_id PK
        bigint appointment_id FK
        varchar(100) test_name
        timestamptz requested_at
        varchar(300) result_text "Optional until resulted"
        timestamptz resulted_at "Optional until resulted"
    }
```

## Reading the diagram

- **PK** identifies one row. **FK** links to another table. **UK** means the value is unique.
- `||` means exactly one. `o{` means zero or many.
- A department employs many doctors; each doctor belongs to one department.
- A patient and a doctor can each have many appointments; each appointment has one patient and one doctor.
- An appointment can have many prescriptions and many lab results. A medication can appear in many prescriptions.

Rules not visible in the diagram: a doctor cannot have two **scheduled** appointments at the same time (partial unique index `doctor_one_booking_per_slot`); a diagnosis exists only on a completed appointment; a lab result's text and time are either both present or both empty.
