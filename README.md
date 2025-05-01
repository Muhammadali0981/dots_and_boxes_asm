# 🎮 Dots and Boxes - Assembly Edition
*A classic strategy game built in x86 Assembly with Irvine32*

![Gameplay Demo](demo.mp4)


## 🌟 Key Features
- **Color-coded** game board (Red vs Blue)
- **Turn-based** two-player system
- **Real-time score tracking**
- **Input validation** for all moves
- **Automatic box completion** detection
- **Win condition** checking

## 🏗️ Code Architecture
```mermaid
graph TD
    A[Main Game Loop] --> B[Display Board]
    A --> C[Get Player Move]
    C --> D[Validate Move]
    D -->|Valid| E[Draw Line]
    E --> F[Check Box Completion]
    F -->|Box Made| G[Update Score]
    F -->|No Box| H[Switch Player]
