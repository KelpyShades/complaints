# 📋 Complaints Management System

A modern, real-time complaint management system built with Flutter and Supabase. Designed for students to voice concerns and administrators to resolve them efficiently.

![Project Banner](web/og-image.png)
*Professional Open Graph images included for all platforms (Generic, Twitter, and Square).*

## 🌟 Overview

The **Complaints Management System** is a robust platform that streamlines the process of submitting, tracking, and resolving complaints. It features a clean, responsive UI and a powerful backend powered by Supabase, ensuring real-time updates and secure data management.

## 🚀 Key Features

### 👨‍🎓 For Students
- **Submit Complaints**: Easy-to-use form with support for image attachments.
- **Track Progress**: Real-time status updates on submitted complaints.
- **Role-Based Views**: Clean dashboard showing only relevant information.
- **Real-time Notifications**: Get notified as soon as an admin takes action.

### 👩‍💼 For Administrators
- **Comprehensive Dashboard**: Overview of all complaints with filtering and sorting.
- **Complaint Management**: Update status, add comments, and resolve issues.
- **Analytics & Reports**: Generate detailed reports (Excel) for complaint trends.
- **Secure Access**: Role-based access control (RBAC) to ensure data integrity.

## 🛠 Tech Stack

- **Frontend**: Flutter (Web & Mobile)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Supabase (Auth, Database, Storage)
- **UI Components**: Shadcn UI (Flutter port)
- **Icons**: Lucide Icons
- **Real-time**: Supabase Realtime

## 📁 Project Structure

```text
lib/
├── components/      # Reusable UI components
├── features/        # Feature-based logic (Auth, Complaints, Admin)
├── models/          # Data models
├── providers/       # Riverpod providers
├── services/        # Backend service integrations
├── core/            # App constants, themes, and utilities
└── main.dart        # Entry point
```

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- A Supabase account and project

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/kelpyshades/complaints.git
   cd complaints
   ```

2. **Set up environment variables**:
   Create a `.env` file in the root directory and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run -d chrome
   ```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
