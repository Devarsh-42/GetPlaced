# 💼 GetPlaced - Job Finder App

An internship assignment project for The Lokal App, built using **Flutter**, that allows users to browse and bookmark jobs using a clean, intuitive UI.

---

## 📱 Features

- 🔍 **Job Search** – Fetch job listings from an API and filter/search through them easily.
- 🔁 **Infinite Scrolling** – Seamless infinite scroll for loading more jobs on demand.
- 🧾 **Detailed Job View** – Tap a job card to view full details including contact info, salary, and location.
- 📌 **Bookmarks** – Save jobs for later using the Bookmarks tab.
- 📦 **Offline Access** – Bookmarked jobs are stored locally using **SQLite** for offline viewing.
- 📤 **WhatsApp Navigation** – Instantly reach out to job contacts on WhatsApp directly from the app.
- 📋 **Copy to Clipboard** – Copy job details to the clipboard with a single tap.
- 🚦 **Smart State Handling** – Full state management including loading, error, and empty states.

---

## 🖥️ Screens Overview

### 1. **Bottom Navigation**
Two main tabs:
- `Jobs` – Main screen to browse and search jobs.
- `Bookmarks` – Offline-accessible list of saved jobs.

### 2. **Jobs Screen**
- Displays job cards with:
  - `Title`
  - `Location`
  - `Salary`
  - `Phone`
- Fetches from API with pagination and infinite scroll.

### 3. **Job Details Screen**
- More info about the selected job.
- Buttons to:
  - **Bookmark**
  - **Open WhatsApp**
  - **Copy details**

### 4. **Bookmarks Screen**
- Displays locally saved jobs using **SQLite**.
- Persistent across app restarts.

---

## 📸 Preview

<!-- Replace the below link with your actual YouTube video demo link -->
📹 **Demo Video**: [Watch on YouTube](https://youtube.com/shorts/hRQHwr4zZUE?si=Z4iLU87O5lKcebWV)

---

## 🛠️ Tech Stack

- **Flutter** 🐦
- **SQLite** (via `sqflite`)
- **State Management**: `Provider`
- **HTTP**: `http` package
- **URL Launcher** for WhatsApp and sharing
- **Clean architecture using separate widgets and screens**

---

## 🚀 Getting Started

1. Clone this repo:
   ```bash
   git clone https://github.com/yourusername/getplaced.git
   cd getplaced
2. Install dependencies:
    '''bash
    flutter pub get
3. Run the App:
    '''bash
    flutter run

🤝 Made By
Devarsh Mehta
3rd Year ICT Student
Email: [devarshmehta.42@gmail.com]
LinkedIn: [linkedin.com/in/devarsh-mehta-6670581b8/]

