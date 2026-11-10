# Portfolio 3: Transactions and Concurrency

Run after Portfolio 2. Example 1 **changes the original data**: the appointment for Chinedu Okafor with Dr Bello on 2026-11-12 11:00 becomes completed.

## Part A: Commit and rollback ([01_transactions.sql](01_transactions.sql))

**Commit.** Completing a visit updates the appointment (status and diagnosis) and inserts a prescription in one transaction. Both changes are saved together with `COMMIT`. Repeating the conditional update changes 0 rows because the appointment is no longer `scheduled`.

**Rollback.** A valid booking is inserted for Emeka Nwosu with Dr Eze, then an invalid lab result (result time before request time) fails the check constraint. `ROLLBACK` removes the booking. The count is 1 inside the transaction and 0 afterwards, and Example 1's committed changes remain.

## Part B: Isolation and concurrency ([Session A](02_session_a.sql), [Session B](03_session_b.sql))

**Scenario:** two receptionists try to book Dr Amaka Obi for the same 2026-11-13 10:00 slot at once.

Open two terminals and follow the order A1, B1, A2 (commit), B2. Use `READ COMMITTED`, PostgreSQL's default [1].

| Step | Session | What happens (expected) |
| --- | --- | --- |
| A1 | A | Inserts the booking for Fatima Yusuf; does not commit |
| B1 | B | Availability check shows 0 bookings (A's row is uncommitted, so invisible); then B's insert for Emeka Nwosu **waits** |
| A2 | A | `pg_stat_activity` shows B waiting on a `Lock`; A commits |
| B2 | B | Insert fails with a duplicate-key error on `doctor_one_booking_per_slot`; B rolls back |

**Result:** one booking remains for the slot, Fatima Yusuf's. Checking availability first is not enough, because both sessions can see the slot as free. The partial unique index enforces the rule inside the database, and the second writer is made to wait and then fail.

**Control mechanism:** unique index plus a retry in the application. After the error, the receptionist's screen should offer another slot.

## My results

| Item | Evidence file |
| --- | --- |
| Commit example (UPDATE 1, INSERT 0 1, then UPDATE 0) | `evidence/[file name]` |
| Rollback example (count 1 then 0, constraint error) | `evidence/[file name]` |
| Session B waiting and `Lock` row in `pg_stat_activity` | `evidence/[file name]` |
| Session B duplicate-key error and final single booking | `evidence/[file name]` |

Write 3-4 sentences in your own words on what you saw and why it matters. If your output differs from the expected results above, describe what you observed instead.

## Reference

[1] PostgreSQL Global Development Group. *PostgreSQL 16: Transaction Isolation*. https://www.postgresql.org/docs/16/transaction-iso.html
