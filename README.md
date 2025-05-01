# 🎮 Dots and Boxes - Assembly Edition
*A classic strategy game built in x86 Assembly with Irvine32*

[![Google Drive Video](https://img.shields.io/badge/📺_Watch_on_Google_Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)](https://drive.google.com/file/d/1_gIJvexgny9oFP3o6imk7Dh_Uan1IjQ8/view?usp=sharing)


## 🌟 Key Features
- **Color-coded** game board (Red vs Blue)
- **Turn-based** two-player system
- **Real-time score tracking**
- **Input validation** for all moves
- **Automatic box completion** detection
- **Win condition** checking

## Built With
<img src="https://cdn-icons-png.flaticon.com/512/6132/6132222.png" width="20"> MASM Assembler

<img src="https://i.imgur.com/JQ6o9y2.png" width="20"> Irvine32 Library

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Visual_Studio_Icon_2022.svg/1200px-Visual_Studio_Icon_2022.svg.png" width="20"> Visual Studio

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
```

<div align="center"> 
    <br> <strong>EL2003 - Computer Organziation and Assembly Language</strong> <br> <em>FAST NUCES, 2025</em> 
</div> 
