
# MoodScribe: An AI-Powered Journaling Companion 🧠✨

An intelligent mental wellness companion that analyzes stress from journal entries and provides personalized recommendations to improve your well-being.

1. [Overview](#overview)  
2. [Key Features](#key-features)  
3. [Screenshots](#screenshots)  
4. [Tech Stack & Architecture](#tech-stack--architecture)  
5. [Deployment](#deployment)  
6. [Related Repositories](#related-repositories)  
7. [Getting Started](#getting-started)  
8. [License](#license)  
9. [Acknowledgements](#acknowledgements)


# Overview
**MoodScribe** is a mobile application built with Flutter that serves as an intelligent mental wellness companion. It leverages AI and Natural Language Processing (NLP) to monitor emotional health through journaling. The app detects user stress levels from diary entries, provides psychological insights, and offers personalized lifestyle recommendations—books, music, movies, and exercises—to improve mental well-being.

# Key Features

- **🤖 AI-Powered Journaling & Stress Analysis:** Classifies entries into "Stress" or "No Stress" and identifies the specific aspect of stress (e.g., Relationships, Financial).


- **💡 Personalized AI Recommendations:** A LangChain-powered AI agent suggests movies, books, music, and habits based on your emotional history and mood trends.


- **✅ Wellness-Centric To-Do List:** Build good habits with a smart to-do list that reinforces daily actions for mental well-being, with smart reminders and AI categor
- ization.

- **📊 User Profile & Mood Insights:** A personal dashboard with stats like your current streak, mood visualizations via pie charts, and a hub for your bookmarked favorites.

- **🗓️ Activity Tracking Heatmap:** A calendar heatmap visually tracks your journaling consistency, motivating you to build a strong daily habit.

- **📝 Personalized AI Suggestions:** A LangChain-powered AI agent provides personalized suggestions based on your emotional history and mood trends. 

# System Architecture
<img src="https://github.com/user-attachments/assets/f068639e-3d54-415f-bd3a-0afebda032a4" width="400"/>

# Tech Stacks
- Frontend: **Flutter (Dart)**

- Backend APIs: **Python (FastAPI)**

- AI Agent Framework: **LangChain**

- ML Model: **Custom Ensemble Model (GAN + BiLSTM)**

- Database: **Firebase Firestore**

- Deployment: **Render (Backend), GitHub Actions CI/CD (Frontend)**
  
# Screenshots

<table>
<tr>
<td><img src="https://github.com/user-attachments/assets/839b95e8-6822-493d-8c06-d4dee43c60b5" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/299fd4c0-6bac-45c0-9128-80aee2091b6f" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/166d97da-124c-480c-bebf-c3ea371d47bd" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/d3cd054d-367f-438b-80e8-4d544f6d622b" width="200"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/dd77bca1-b42a-4880-a376-f4111cc095c2" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/a2d9ba7e-071b-4f5e-89da-2cfc227decc2" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/e7e7a8fc-956b-497d-be2e-1b211c3c0906" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/2bb4da48-1f0e-4383-9f66-ba1735ae30d0" width="200"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/e80bc5f1-415f-488a-bbe3-973ffcae59d3" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/cfc700e7-0ab6-4b57-a45f-01dc150509f9" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/59f1b6ff-42ae-43da-ad50-7558e7b867cc" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/2c5fa6ed-a353-4a23-8ce8-965008a10965" width="200"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/f8003089-0775-45bc-8950-42293d3dec28" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/120ac191-0023-407c-bad3-f9bf66aa923f" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/204c2738-ef9c-4d1d-b8a4-319aa976b016" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/4a31de75-dca4-4ec7-bec2-b364af508fa8" width="200"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/45c2c2c0-5464-41dc-9ee2-aa2294e44c7c" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/530dac9f-c412-4f1b-b01c-60dec8e729a3" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/578e3a2c-c8d6-455e-bb3b-9f924f5ea40f" width="200"/></td>
<td><img src="https://github.com/user-attachments/assets/fd6fb34d-de79-4584-b4e9-c6d228f8c418" width="200"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/750363e7-ce73-4221-b3b8-adf4ed7ebaab" width="200"/></td>
</tr>
</table>


# Deployment

- **Backend Services:** The AI Agent and the Stress Model are each deployed as separate FastAPI web services on Render, providing scalable and secure API endpoints.

- **Frontend Application:** The Flutter app is built and released automatically using a CI/CD pipeline configured with GitHub Actions. Every push to the main branch triggers a workflow that builds, signs, and attaches a release-ready APK to a new GitHub Release.


# Related Repository

__1. MoodScribe AI Agent__
- **Description:** This repository contains the LangChain-powered AI agent responsible for generating personalized recommendations. It's built with Python and deployed as a FastAPI service on Render.

- [MoodScribe Ai Agent](https://github.com/Efty34/MoodScribe_Ai_Agent)


__2. MoodScribe Stress Model__
- **Description:** This repository contains the custom-trained ensemble machine learning model (GAN + BiLSTM) used for stress detection and classification. It is also deployed as a FastAPI service on Render.

- [MoodScribe Ai Agent](https://github.com/Efty34/MoodScribe_Ai_Agent)


## Getting Started

To get a local copy up and running, follow these simple steps.

## Prerequisites
- Flutter SDK installed

- An editor like VS Code or Android Studio

## Installation

1.Clone the repo

```bash
  git clone <Repository_Link>
```
    
2.Install Flutter packages

```bash
  flutter pub get
```

1.Run the app
```bash
  flutter run
```
## Acknowledgements

 - [Kazi Tasrif](https://github.com/kaizen2112)



