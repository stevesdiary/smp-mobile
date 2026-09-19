# Mobile App Implementation Plan

Parity target: match the parent portal in `smp-client/src/pages/parent/ParentPage.tsx`.

---

## Current State

| Layer | Done |
|---|---|
| Auth (login, token, tenant header) | ✅ |
| `ApiClient` + `ParentRepository` | ✅ |
| `Child` model | ✅ |
| `AttendanceRecord` + `AttendanceStats` models | ✅ |
| Attendance screen (stats card + record list) | ✅ |
| Home screen (hardcoded dummy data) | ⚠️ |
| Grades, Timetable, Payments | ❌ |
| Fees (opt-in, initiate payment) | ❌ |
| Profile screen | ❌ (stub) |
| Notifications screen | ❌ (stub) |

---

## Phase 1 — Data Layer

### 1.1 New models

| File | Fields |
|---|---|
| `lib/data/models/grade_model.dart` | `id`, `score`, `maxScore`, `subject` (`id`, `name`), `assignment` (`id`, `title`) |
| `lib/data/models/timetable_model.dart` | `id`, `dayOfWeek` (1–5), `startTime`, `endTime`, `subject` (`name`), `teacher` (`firstName`, `lastName`) |
| `lib/data/models/payment_model.dart` | `id`, `amount`, `status` (`SUCCESS`/`PENDING`/`FAILED`), `createdAt`, `fee` (`name`) |

### 1.2 Extend `ParentRepository`

Add to `lib/data/repositories/parent_repository.dart`:

```
getChildGrades(studentId)    → GET /parent/children/:id/grades
getChildTimetable(studentId) → GET /parent/children/:id/timetable
getChildPayments(studentId)  → GET /parent/children/:id/payments
```

---

## Phase 2 — Providers

### 2.1 `ChildDetailProvider`
`lib/ui/features/children/child_detail_provider.dart`

Single provider that owns the selected child and lazily loads all four data sets (attendance, grades, timetable, payments) when a child is selected. Replaces the current `AttendanceProvider` as the source of truth for child data.

State:
- `List<Child> children`
- `Child? selectedChild`
- `List<AttendanceRecord> attendance`
- `List<Grade> grades`
- `List<TimetableEntry> timetable`
- `List<Payment> payments`
- `AttendanceStats? stats`
- `bool loading` / `String? error`

Methods:
- `load()` — fetch children, auto-select first
- `selectChild(Child)`
- `loadTab(Tab)` — lazy-load per tab to avoid 4 parallel requests on open

### 2.2 Register in `main.dart`

Replace `AttendanceProvider` registration with `ChildDetailProvider`.

---

## Phase 3 — Screens

### 3.1 Home screen (wire up real data)
`lib/ui/features/home/home_screen.dart`

Replace hardcoded dummy data:
- Child summary cards → real children from `ChildDetailProvider`
- Attendance % on each card → computed from `AttendanceStats`
- Greeting → `Hello, ${auth.user.firstName}`
- Date → `DateTime.now()` formatted

### 3.2 Children / Detail screen
`lib/ui/features/children/children_screen.dart`

Mirrors `ParentPage.tsx` tab layout:

```
┌─────────────────────────────┐
│  Child selector chips       │  (horizontal scroll if > 1 child)
├─────────────────────────────┤
│  Stats row: Attendance %    │
│             Grades count    │
│             Payments count  │
├─────────────────────────────┤
│  TabBar: Attendance | Grades│
│          Timetable | Payments│
└─────────────────────────────┘
```

**Attendance tab** — reuse existing record list widget from `AttendanceScreen`

**Grades tab**
- Row per grade: subject name + assignment title on left, `score/maxScore` on right

**Timetable tab**
- Grouped by day (Mon–Fri)
- Each entry: `startTime–endTime · subject · teacher name`

**Payments tab**
- Row per payment: fee name + date on left, amount + status badge on right
- Status badge colours: SUCCESS=green, PENDING=amber, FAILED=red

### 3.3 Profile screen
`lib/ui/features/profile/profile_screen.dart`

- Display `AuthUser` fields: name, email, role
- Logout button → `AuthProvider.logout()` → router redirects to `/login`

### 3.4 Notifications screen
`lib/ui/features/notifications/notifications_screen.dart`

- Static empty state for now ("No notifications yet")
- Wire up real data in a later phase when the server notification endpoint is confirmed

---

## Phase 4 — Navigation wiring

Update `app.dart` router branches:

| Branch index | Path | Screen |
|---|---|---|
| 0 | `/home` | `HomeScreen` |
| 1 | `/children` | `ChildrenScreen` |
| 2 | `/notifications` | `NotificationsScreen` |
| 3 | `/profile` | `ProfileScreen` |

Update `main_shell.dart` nav bar icons to match (currently shows `/attendance` as branch 1 — replace with `/children`).

Remove the standalone `/attendance` route — attendance is now a tab inside `ChildrenScreen`.

---

## Phase 5 — Polish

- Pull-to-refresh on `ChildrenScreen`
- Empty states for each tab (no grades, no timetable, etc.)
- Error state with retry button
- Format currency as `₦ x,xxx` (Naira) to match web client's `formatCurrency`
- Format dates consistently: `dd MMM yyyy` using `intl` package

---

## File Checklist

```
lib/
  data/
    models/
      grade_model.dart          ← new
      timetable_model.dart      ← new
      payment_model.dart        ← new
    repositories/
      parent_repository.dart    ← extend (add 3 methods)
  ui/
    features/
      home/
        home_screen.dart        ← wire real data
      children/
        child_detail_provider.dart  ← new (replaces AttendanceProvider)
        children_screen.dart        ← rewrite (add tabs)
      profile/
        profile_screen.dart     ← implement
      notifications/
        notifications_screen.dart ← empty state
  app.dart                      ← update routes
  main.dart                     ← swap provider registration
```

---

## Out of Scope (this plan)

- Fees opt-in / payment initiation (requires Paystack integration)
- Push notifications
- Offline caching
