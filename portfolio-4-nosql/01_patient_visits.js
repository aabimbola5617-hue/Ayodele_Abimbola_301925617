// Run once in mongosh (local connection or Atlas). Select the MongoDB database,
// which is separate from the PostgreSQL database.
db = db.getSiblingDB("hospital_records");

// Stop rather than inserting a second copy of the exercise.
if (db.patient_visits.countDocuments() !== 0) {
    throw new Error("patient_visits already contains records. Check them before continuing.");
}

// One document per completed visit. Patient and doctor details are snapshots.
// Prescriptions and lab results are embedded because they are read with the visit.
// Vitals differ by visit: documents need not share the same fields.
printjson(db.patient_visits.insertMany([
    {
        _id: "V001",
        visited_at: ISODate("2026-10-05T09:00:00Z"),
        patient: { hospital_number: "P001", full_name: "Chinedu Okafor" },
        doctor: { staff_number: "D001", full_name: "Dr Amaka Obi", department: "General Medicine" },
        reason: "Fever and headache",
        vitals: { temperature_c: 38.9, blood_pressure: "120/80" },
        diagnosis: "Malaria (uncomplicated)",
        prescriptions: [
            { medication: "Paracetamol", dosage: "500 mg three times daily", duration_days: 5 }
        ],
        lab_results: [
            { test: "Malaria parasite test", status: "final", result: "Positive" }
        ]
    },
    {
        _id: "V002",
        visited_at: ISODate("2026-10-06T10:00:00Z"),
        patient: { hospital_number: "P002", full_name: "Fatima Yusuf" },
        doctor: { staff_number: "D002", full_name: "Dr Tunde Bello", department: "Cardiology" },
        reason: "Chest pain",
        vitals: { blood_pressure: "150/95", heart_rate_bpm: 88 },
        diagnosis: "Hypertension",
        prescriptions: [
            { medication: "Amlodipine", dosage: "5 mg once daily", duration_days: 30 }
        ],
        lab_results: [
            { test: "ECG", status: "pending", result: null }
        ]
    },
    {
        _id: "V003",
        visited_at: ISODate("2026-11-12T11:00:00Z"),
        patient: { hospital_number: "P001", full_name: "Chinedu Okafor" },
        doctor: { staff_number: "D002", full_name: "Dr Tunde Bello", department: "Cardiology" },
        reason: "Blood pressure check",
        vitals: { blood_pressure: "135/85" },
        diagnosis: "Hypertension, stable on treatment",
        prescriptions: [
            { medication: "Amlodipine", dosage: "5 mg once daily", duration_days: 30 }
        ],
        lab_results: []
    }
]));

// Index for the most common lookup: a patient's visits in date order.
printjson(db.patient_visits.createIndex({ "patient.hospital_number": 1, visited_at: 1 }));

// Q1: Three documents should have been saved. Expected: 3
printjson(db.patient_visits.countDocuments());

// Q2: Patient P001's visit history, oldest first. Expected: V001 then V003.
printjson(db.patient_visits.find(
    { "patient.hospital_number": "P001" },
    { _id: 1, visited_at: 1, diagnosis: 1, prescriptions: 1 }
).sort({ visited_at: 1 }).toArray());

// Q3: Search inside an embedded array. Expected: V001 only.
printjson(db.patient_visits.find(
    { "prescriptions.medication": "Paracetamol" },
    { _id: 1, "patient.full_name": 1, diagnosis: 1 }
).toArray());

// Q4: Visits with a lab result still pending. Expected: V002 only.
printjson(db.patient_visits.find(
    { "lab_results.status": "pending" },
    { _id: 1, "patient.full_name": 1, lab_results: 1 }
).toArray());

// Q5: Visits per department (aggregation). Expected: Cardiology 2, General Medicine 1.
printjson(db.patient_visits.aggregate([
    { $group: { _id: "$doctor.department", visits: { $sum: 1 } } },
    { $sort: { _id: 1 } }
]).toArray());
