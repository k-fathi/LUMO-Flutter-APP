```mermaid
graph LR
    %% Styling and Themes
    classDef mobile fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#000,rx:10,ry:10
    classDef backend fill:#FFF3E0,stroke:#E65100,stroke-width:2px,color:#000,rx:10,ry:10
    classDef robot fill:#FCE4EC,stroke:#C2185B,stroke-width:2px,color:#000,rx:10,ry:10
    classDef ai fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px,color:#000,rx:10,ry:10
    classDef internal fill:#ffffff,stroke:#9E9E9E,stroke-width:1px,color:#000,rx:5,ry:5

    %% Components
    subgraph Mobile ["📱 Mobile Application (Flutter)"]
        direction TB
        DoctorApp["👨‍⚕️ Doctor App"]:::internal
        ParentApp["👨‍👩‍👦 Parent App"]:::internal
    end
    class Mobile mobile

    subgraph BackendSys ["⚙️ Backend Server & DB<br/>(Node.js / Firebase)"]
        direction TB
        Hub["Central Hub & Database"]:::internal
    end
    class BackendSys backend

    subgraph Robot ["🤖 LUMO Robot (Hardware & GUI)"]
        direction TB
        Hardware["Hardware (Camera, Mic, Motors)"]:::internal
        GUI["GUI (Screen Interface)"]:::internal
    end
    class Robot robot

    subgraph AIServer ["🧠 AI Models Server (Python)"]
        direction TB
        Emotion["Emotion Intelligence"]:::internal
        Eye["Eye Tracking"]:::internal
        Voice["Voice Flow"]:::internal
        RAG["Autism RAG Expert"]:::internal
    end
    class AIServer ai

    %% Data Flow: Mobile <--> Backend
    Mobile -- "API: Send Session Config<br/>(Games/Stories Duration, Patient_ID)" --> Hub
    Hub -- "API: Send Auth Data &<br/>Session Reports" --> Mobile
    Hub -- "JSON: Session Analysis<br/>(Scores, Emotion %, Focus %)" --> Mobile

    %% Data Flow: Mobile <--> AI Server
    ParentApp -- "API: Text Queries" --> RAG
    RAG -- "JSON: Medical Text Responses" --> ParentApp

    %% Data Flow: Backend <--> Robot
    Hub -- "API: Auth Token &<br/>Session Triggers" --> Robot
    GUI -- "API: Game Scores &<br/>Level Progress" --> Hub

    %% Data Flow: Robot <--> AI Server
    Hardware -- "Stream: Live Frames<br/>(48x48 Grayscale & Eye Regions)" --> Eye
    Hardware -- "Stream: Live Audio" --> Voice
    Emotion -- "Hardware Cmds:<br/>(Motor actions - e.g., Step back)" --> Hardware
    Voice -- "Hardware Cmds:<br/>(Voice Eval T/F, MP3 Replies)" --> Hardware

    %% Data Flow: AI Server <--> Backend
    Emotion -- "JSON: AI Analysis Outputs<br/>(6 Emotions)" --> Hub
    Eye -- "JSON: AI Analysis Outputs<br/>(Focus = True/False)" --> Hub