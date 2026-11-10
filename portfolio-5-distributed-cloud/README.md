# Portfolio 5: Distributed and Cloud Database Exercise

**Status: proposed design and discussion. No replica set, sharding, failover or cloud deployment was implemented or tested.** If you do build or test any part, add that evidence and state exactly what you ran.

## Why distribution matters for the hospital

Appointment booking, prescriptions and lab results are needed all day. Downtime can delay care, and patient records are highly sensitive. The main concerns are availability, consistency of the booking rule, durability of records and data protection.

## Proposed design

```text
          PostgreSQL (appointments, prescriptions, lab results)
   Primary  ──streaming replication──►  Standby (different zone)
      │                                    └─ read-only reports
      └─ writes: bookings, diagnoses

          MongoDB replica set (visit records)
   Primary ──► Secondary 1 ──► Secondary 2     (three members, three zones)
```

### Replication

- **PostgreSQL:** one primary accepts writes; a standby in another zone receives changes by streaming replication. With asynchronous replication the standby can lag, so a failover could lose the last few seconds of writes. Synchronous replication reduces that risk but makes commits wait for the standby, which lowers write speed and availability if the standby is unreachable [1].
- **MongoDB:** three data-bearing members. If the primary fails, a majority elects a new one; writes pause briefly during the election. Write concern `majority` protects acknowledged writes, and reads from secondaries may be slightly stale [2].

### Consistency vs availability

Booking must be **consistent**: two receptionists must never confirm the same slot (Portfolio 3). So the booking path should read and write on the PostgreSQL primary. Reports and the visit-history screen can tolerate slightly stale data and may read from replicas or MongoDB secondaries. During a network partition the system would favour consistency for bookings, accepting that booking may be unavailable until a primary is reachable.

### Sharding

Sharding splits data across servers to handle volume. A single hospital's records fit comfortably on one replicated server, so **sharding is not justified**. It would become relevant for a multi-hospital network, where `hospital_id` plus patient ID could be a shard key; that adds routing and cross-shard query complexity.

### Cloud deployment considerations

- Managed services (for example managed PostgreSQL and MongoDB Atlas) reduce administration but need network restrictions, authentication and encryption in transit and at rest.
- Replication is **not** a backup. Deletions and corruptions replicate. Plan regular backups with tested restores and point-in-time recovery.
- Patient data is sensitive personal data. Check the data-protection and health-records rules that apply to the hospital (in Nigeria, the Nigeria Data Protection Act 2023) and where the cloud provider stores data. Verify the current legal requirements from the official source before citing them.
- Define recovery targets (how much data loss and downtime are acceptable) and test failover before relying on it.

## What I did and did not do

- Did: [describe what you read, designed or tried]
- Did not: implement replication, sharding or a cloud deployment [edit if this changes]

## References

[1] PostgreSQL Global Development Group. *PostgreSQL 16: High Availability, Load Balancing, and Replication*. https://www.postgresql.org/docs/16/high-availability.html
[2] MongoDB. *Replication*. https://www.mongodb.com/docs/manual/replication/
