Below is a clean, minimal project specification for your **Student Complaints Management System** with a few practical improvements added for usability and structure.

---

## 1. Core Concept

Two user roles:

* **Student**
* **Admin**

Both can:

* Register / Login
* Access role-specific dashboards

---

## 2. Suggested Improvements (Light polish)

Added for realism but still simple:

* Complaint **status** (Pending, In Review, Resolved)
* Timestamp (date submitted)
* Admin response field
* Optional category (Academic, Hostel, Finance, etc.)
* Basic validation (required fields)

---

## 3. Features Breakdown

### A. Authentication (Both)

* Login (email + password)
* Register (basic info)
* Role-based access (student/admin)

---

### B. Student Side

#### 1. Dashboard

* Welcome message
* Quick stats:

  * Total complaints
  * Pending
  * Resolved

#### 2. Submit Complaint

Form fields:

* Full Name
* Email
* Index Number
* Phone Number
* Complaint Title
* Complaint Description
* Category (optional dropdown)

Button: **Submit**

---

#### 3. Complaint History

* List of submitted complaints
* Each item shows:

  * Title
  * Status
  * Date
* Click → view details:

  * Full complaint
  * Admin response (if any)

---

### C. Admin Side

#### 1. Dashboard

* Overview cards:

  * Total complaints
  * Pending
  * In Review
  * Resolved

* Recent complaints list

---

#### 2. Complaints Management

List of all complaints:

* Student Name
* Index Number
* Title
* Status
* Date

Click → Complaint Details:

* Full student info
* Complaint message
* Admin actions:

  * Update status
  * Add response/note

---

#### 3. Notifications / Activity

* List of recent actions:

  * "Kelvin submitted a complaint"
  * "Complaint #23 updated"

(Simple list sorted by time)

---

## 4. Data Model (Simple)

### User

```
id
name
email
password
role (student/admin)
```

### Complaint

```
id
studentId
name
email
indexNumber
phone
title
description
category
status (pending/in_review/resolved)
adminResponse
createdAt
updatedAt
```

---

## 5. Tech Stack Suggestion (Fits you)

Since you’re a Flutter dev:

* **Frontend:** Flutter
* **State Management:** Riverpod
* **Backend:** Supabase

---

## 6. Screen List (Simple Navigation)

### Student

* Login / Register
* Dashboard
* Submit Complaint
* Complaint History
* Complaint Details

### Admin

* Login / Register
* Dashboard
* All Complaints
* Complaint Details
* Notifications

---

## 7. UI Style (Modern but Simple)

* Clean cards layout
* Soft colors (blue / purple primary)
* Status badges:

  * Pending → Orange
  * In Review → Blue
  * Resolved → Green

---

## 8. Optional (Only if you want later)

* Search/filter complaints (admin)
* File/image attachment
* Push notifications
* Dark mode

---

## 9. Clarifications (only if needed)

3. Do you want real-time updates (live dashboard)?
Yes
4. Is this for mobile only or web + mobile?
Yes mobile and web.
