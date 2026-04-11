# Project Overview

The **Complaints Management System** is a responsive, cross-platform application (desktop + mobile) built with Flutter and Supabase. It allows students to submit, track, and discuss issues related to campus facilities, IT, or billing, while providing administrators with a professional dashboard to manage and resolve these requests.

The application relies heavily on `shadcn_ui` (Flutter port) for robust, modern components and uses state management to handle role-based theming (e.g., resolving immediately to a dark professional theme for admins and a warm light theme for students without visual flickering).

### Target Users
- **Students**: End-users who report issues, communicate with admins regarding the issues, and track the status of their complaints.
- **Administrators**: Staff who oversee system metrics, manage the lifecycle of complaints, update statuses, and communicate with students.

### Core Features
1. Role-based Access Control (Admin vs. Student).
2. Theming based on roles (Admin: Dark, Student: Light).
3. Complaint submission, tracking, and management.
4. Two-way commentary/discussion threads on complaints.
5. Notification timeline/activity feed.
6. Admin metrics dashboard.

---

# User Flow

### 1. Authentication Flow
- All users arrive at a unified **Login Screen**.
- Upon successful login, the application resolves the user's role and redirects them to their respective portal, switching the global theme context accordingly. 
- (Also includes **Registration** and **Forgot Password** flows).

### 2. Student Flow (Academic Portal)
- Lands on **My Complaints** (List view of active requests).
- Can create a **New Request** via a Floating Action Button (Mobile) or direct navigation.
- Views complaint details to see current status via a step indicator, read admin comments, reply, or withdraw the request if pending.
- Navigates to **Activity Feed** to see a chronological timeline of interactions/status changes.

### 3. Admin Flow (Management Console)
- Lands on **Dashboard** (System overview with real-time metrics).
- Navigates to **All Complaints** to search, filter, and select a ticket.
- Opens **Complaint Details** to view user information, change ticket status, and reply to the student.
- Navigates to **Activity Feed** or **Reports** for administrative oversight.

---

# Navigation Structure

The application adopts a **Responsive Navigation Shell** that adapts to screen size:

- **Desktop (>768px)**: Uses a persistent left-hand Sidebar displaying navigation items, a user profile snippet at the bottom, and a logout button. Screens render in the main expanded area alongside it.
- **Mobile (<768px)**: Uses a top App Bar with a hamburger menu that opens a sliding navigation Drawer. Notifications are accessible via a badge icon in the App Bar.

### Student Navigation Links
1. **My Complaints** (Home)
2. **History** (Resolved/Closed issues)
3. **Activity Feed** (Notifications)
4. **Profile** 

### Admin Navigation Links
1. **Dashboard** (Home)
2. **All Complaints** 
3. **Activity Feed** (Notifications)
4. **Reports**

---

# Screens

## Auth Screens
### Login Screen
- **Description**: Unified login gateway for all users.
- **Components**: Logo/Icon, Title ("Welcome Back"), Email Input, Password Input, Login Button, "Forgot Password" link, "Register" link.
- **Notes for Designer**: Should remain neutral and clean since role isn't determined yet. Currently uses a single centered card/form on desktop.

## Admin Screens
### Admin Dashboard Screen
- **Description**: Landing page for administrators showing real-time metrics.
- **Components**: `_AdminStatCard` (Total, Pending, In Progress, Resolved).
- **Layout**: Grid layout on mobile (2 columns), Wrap/Row on desktop.
- **Notes for Designer**: Focus on readability of numbers. Differentiate metrics via color (e.g., orange for pending, green for resolved).

### Admin Complaints Screen
- **Description**: Master list of all system complaints.
- **Components**: Search Bar, Status Filter Dropdown (`ShadSelect`), `ComplaintCard` list items.
- **Interactions**: Admins can search by text or filter by status. Tapping a card opens the detail view.

### Admin Complaint Detail Screen
- **Description**: Detailed management view of a single complaint.
- **Layout**: 
  - **Desktop**: 2-column layout (Main info & Discussion left, Actions Sidebar right). 
  - **Mobile**: 1-column layout (Actions stack on top of info).
- **Components**: Main Info Block (Title, Category, ID, Description), Discussion Thread (`CommentList`, `CommentInput`), `_AdminActionsSidebar` (Status indicators, action buttons, student ID info).
- **Notes for Designer**: The actions sidebar is critical for workflow. Changing status (Pending, In Progress, Resolved, Rejected) is the primary admin action on this screen.

## Student Screens
### Student Complaints Screen
- **Description**: Landing page for students showing their active requests.
- **Components**: Top right Floating Action Button (Mobile only), Filter Action Chips (All, Pending, In Progress), List of `ComplaintCard` elements.
- **Notes for Designer**: Needs to feel approachable and reassuring. The visual distinction between active issues and history should be clear.

### Student Complaint Form Screen
- **Description**: Form to report a new issue.
- **Components**: Top header context ("What do you need help with?"), Text inputs (Title, Category), Textarea (Description), Large Submit Button.
- **Notes for Designer**: Simplify data entry. We currently have "Category" as a free-text input, but visually it should probably be a dropdown or button group for better UX.

### Student Complaint Detail Screen
- **Description**: View of a single submitted request for the student.
- **Components**: `_StudentStatusStepper` (Visual timeline of Submitted -> Reviewed -> Resolved/Rejected), Main Info Block, Withdraw Button (Only if pending), Discussion Thread (`CommentList`, `CommentInput`).
- **Notes for Designer**: The `_StudentStatusStepper` is very important for user peace of mind. It should be visually distinct and clear. 

### Activity Feed Screen (Student & Admin)
- **Description**: Chronological timeline of updates.
- **Components**: `_StudentActivityTimelineItem` (Timeline nodes connecting events).
- **Interactions**: Unread items have visual borders/highlights. Tapping an item navigates to the associated complaint.
- **Notes for Designer**: Distinguish between "Status Changes" and "New Comments" using varied icons, colors, or node shapes in the timeline.

---

# Components & Widgets

## Reusable Elements
### ComplaintCard
- **Type**: Shared Component
- **Purpose**: Displays a summary of a complaint in lists.
- **Usage**: Used in both Admin and Student complaint listing screens.
- **Behavior**: Shows Title, Status Badge, truncated Description preview, and Category.
- **Design Recommendations**: Standardize elevation and hover states representing "clickability."

### CommentList & CommentInput
- **Type**: Composite Widget
- **Purpose**: Render the two-way discussion thread for a complaint.
- **Data handled**: Chronological list of chat bubbles (Author, Timestamp, Message).
- **Behavior**: Identifies "You", "Admin", or "Student" depending on the viewer's role to keep context simple.

### AsyncValueWidget
- **Type**: Utility Wrapper
- **Purpose**: Standard UI wrapper for handling asynchronous Riverpod data.
- **Behavior**: Controls the global look of "Loading" (Spinners) and "Error" (Retry button) states across lists, details, and dashboards.

### Status Badge
- **Type**: UI Element
- **Purpose**: Small pill/chip indicating state.
- **Behavior**: Pending (Orange), In Progress (Blue), Resolved (Green), Rejected (Red).

---

# Design Recommendations

1. **Role-based Theming Strategy**: 
   - Since the application supports two starkly different themes (Dark/Slate for Admin, Light/Warm for Student), ensure color tokens scale perfectly across both modes. The admin portal should feel high-density and "command center" like, whereas the student portal should feel modern, airy, and simple.

2. **Typography & Hierarchy**: 
   - Emphasize system IDs (`#complaint-id`) using monospace fonts to feel transactional.
   - Use bold h2/h3 tags for complaint titles. The description should have high readability (e.g., `height: 1.6` line spacing).

3. **Micro-interactions**: 
   - The timeline `Activity Feed` should have subtle entry animations or hover states on unread items.
   - Chat bubbles in `CommentList` should have a distinct alignment or color variance (e.g., your messages on the right, replies on the left) which is currently a simple block layout.

---

# Gaps & Suggestions

- **"Category" Input on Forms**: The student new complaint form has a text input for category. Providing a predefined Select/Dropdown component (Facilities, IT, Setup, Billing) will drastically improve data consistency and UX.
- **Empty States**: Most screens have structural empty states (e.g., "No complaints match filters", "No updates yet" with a muted icon), but they could benefit from high-quality illustrations or clearer call-to-actions.
- **Chat Layout**: The `CommentList` currently renders comments in stacked blocks. Adapting this to a standard messaging layout (e.g., right-aligned for self, left-aligned for messages from others) would increase familiarity for mobile users.
- **Profile / History**: Structural screens like "Student Profile" or "Admin Reports" currently exist in routing but lack detailed component definitions in the immediate flow, meaning they require a baseline layout (e.g., settings lists, chart spaces).
