
# MoodScribe: An AI-Powered Journaling Companion 🧠✨

An intelligent mental wellness companion that analyzes stress from journal entries and provides personalized recommendations to improve your well-being.

# Table of Contents

- [Overview](#Overview)

- Key Features

- Screenshots

- Tech Stack & Architecture

- Deployment

- Related Repositories

- Getting Started

- License

- Acknowledgements


# Overview
**MoodScribe** is a mobile application built with Flutter that serves as an intelligent mental wellness companion. It leverages AI and Natural Language Processing (NLP) to monitor emotional health through journaling. The app detects user stress levels from diary entries, provides psychological insights, and offers personalized lifestyle recommendations—books, music, movies, and exercises—to improve mental well-being.

# Key Features

- **🤖 AI-Powered Journaling & Stress Analysis:** Classifies entries into "Stress" or "No Stress" and identifies the specific aspect of stress (e.g., Relationships, Financial).

- **💡 Personalized AI Recommendations:** A LangChain-powered AI agent suggests movies, books, music, and habits based on your emotional history and mood trends.

- **✅ Wellness-Centric To-Do List:** Build good habits with a smart to-do list that reinforces daily actions for mental well-being, with smart reminders and AI categorization.

- **📊 User Profile & Mood Insights:** A personal dashboard with stats like your current streak, mood visualizations via pie charts, and a hub for your bookmarked favorites.

- **🗓️ Activity Tracking Heatmap:** A calendar heatmap visually tracks your journaling consistency, motivating you to build a strong daily habit.

- **📝 Personalized AI Suggestions:** A LangChain-powered AI agent provides personalized suggestions based on your emotional history and mood trends. 

# System Architecture
<img width="4940" height="7180" alt="Image" src="https://github.com/user-attachments/assets/f068639e-3d54-415f-bd3a-0afebda032a4" />

# Tech Stacks
- Frontend: **Flutter (Dart)**

- Backend APIs: **Python (FastAPI)**

- AI Agent Framework: **LangChain**

- ML Model: **Custom Ensemble Model (GAN + BiLSTM)**

- Database: **Firebase Firestore**

- Deployment: **Render (Backend), GitHub Actions CI/CD (Frontend)**

# Deployment

- **Backend Services:** The AI Agent and the Stress Model are each deployed as separate FastAPI web services on Render, providing scalable and secure API endpoints.

- **Frontend Application:** The Flutter app is built and released automatically using a CI/CD pipeline configured with GitHub Actions. Every push to the main branch triggers a workflow that builds, signs, and attaches a release-ready APK to a new GitHub Release.
