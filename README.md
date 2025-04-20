```asm
INCLUDE Irvine32.inc

.data
    ; Initial board setup (4x4 dots) with placeholders for lines
    board BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0Ah,
           ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah,
           '.', ' ', '.', ' ', '.', ' ', '.', 0Ah,
           ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah,
           '.', ' ', '.', ' ', '.', ' ', '.', 0Ah,
           ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah,
           '.', ' ', '.', ' ', '.', ' ', '.', 0

    ; User interface messages
    msgWelcome BYTE "Welcome to Dots and Boxes!", 0Ah, 0
    msgEnterFirst BYTE "Enter first dot (row col): ", 0
    msgEnterSecond BYTE "Enter second dot (row col): ", 0
    msgInvalidMove BYTE "Invalid move! Try again.", 0Ah, 0
    msgPlayer1 BYTE "Player 1's turn (Red)", 0Ah, 0
    msgPlayer2 BYTE "Player 2's turn (Blue)", 0Ah, 0
    msgWinner1 BYTE "Player 1 wins!", 0Ah, 0
    msgWinner2 BYTE "Player 2 wins!", 0Ah, 0
    msgDraw BYTE "It's a draw!", 0Ah, 0
    msgBoxComplete BYTE "Box completed! Player gains a point!", 0Ah, 0

    ; Game state variables
    firstRow DWORD ?
    firstCol DWORD ?
    secondRow DWORD ?
    secondCol DWORD ?
    currentPlayer DWORD 1       ; 1 = Player 1, 2 = Player 2
    player1Score DWORD 0
    player2Score DWORD 0
    totalBoxes DWORD 9          ; 3x3 boxes = 9 total

.code

main PROC
    ; Clear screen and display welcome message
    call Clrscr
    mov edx, OFFSET msgWelcome
    call WriteString

gameLoop:
    ; Display current game board and whose turn it is
    call DisplayBoard
    call ShowPlayerTurn

    ; Get move input from player
    call GetMove
    call ValidateMove
    jnc invalidMove             ; If invalid (Carry Flag set), jump

    ; Apply the move
    call DrawLine
    call CheckBoxCompletion     ; Checks if move completed a box
    cmp eax, 0
    jne checkTotalBoxes         ; If a box was completed, don't switch player

    ; Switch current player (toggle between 1 and 2)
    xor currentPlayer, 3
    jmp gameLoop

checkTotalBoxes:
    ; Check if all boxes have been completed
    mov eax, player1Score
    add eax, player2Score
    cmp eax, totalBoxes
    jl gameLoop                 ; Continue if not all boxes are done
    jmp exitGame

invalidMove:
    ; Invalid move message
    mov edx, OFFSET msgInvalidMove
    call WriteString
    jmp gameLoop

exitGame:
    ; Game is over — show board and announce winner
    call DisplayBoard
    call AnnounceWinner
    exit
main ENDP

; ======================
; Display the board array
; ======================
DisplayBoard PROC
    mov edx, OFFSET board
    call WriteString
    ret
DisplayBoard ENDP

; ======================
; Show the current player
; ======================
ShowPlayerTurn PROC
    cmp currentPlayer, 1
    je player1Msg
    mov edx, OFFSET msgPlayer2
    jmp displayTurn
player1Msg:
    mov edx, OFFSET msgPlayer1
displayTurn:
    call WriteString
    ret
ShowPlayerTurn ENDP

; ======================
; Read coordinates of the move from player
; ======================
GetMove PROC
    ; First dot input
    mov edx, OFFSET msgEnterFirst
    call WriteString
    call ReadInt
    mov firstRow, eax
    call ReadInt
    mov firstCol, eax

    ; Second dot input
    mov edx, OFFSET msgEnterSecond
    call WriteString
    call ReadInt
    mov secondRow, eax
    call ReadInt
    mov secondCol, eax
    ret
GetMove ENDP

; ======================
; Validate if move is adjacent and legal
; ======================
ValidateMove PROC
    ; Calculate the difference between rows and columns
    mov eax, firstRow
    sub eax, secondRow
    mov ebx, firstCol
    sub ebx, secondCol

    ; Sum of absolute differences must be 1 (i.e., adjacent dot)
    add eax, ebx
    cmp eax, 1
    je valid
    cmp eax, -1
    je valid
    stc                     ; Invalid move -> set Carry Flag
    ret
valid:
    clc                     ; Valid move -> clear Carry Flag
    ret
ValidateMove ENDP

; ======================
; Draw the line for the move
; ======================
DrawLine PROC
    ; Check if move is horizontal
    mov eax, firstRow
    cmp eax, secondRow
    jne drawVertical

    ; Horizontal line
    mov eax, firstRow
    imul eax, 16                ; Multiply by row width
    mov ebx, firstCol
    cmp ebx, secondCol
    jl skipSwap
    xchg ebx, secondCol         ; Ensure leftmost col is in ebx
skipSwap:
    imul ebx, 2                 ; Spaces between dots
    add eax, ebx
    add eax, 1
    mov esi, eax                ; Offset into board

    ; Draw horizontal line in red or blue
    cmp currentPlayer, 1
    je player1Line
    mov eax, blue + (black * 16)
    call SetTextColor
    mov BYTE PTR [board + esi], '-'
    jmp drawDone

player1Line:
    mov eax, red + (black * 16)
    call SetTextColor
    mov BYTE PTR [board + esi], '-'
    jmp drawDone

drawVertical:
    ; Vertical line
    mov eax, firstRow
    cmp eax, secondRow
    jl skipSwap2
    xchg eax, secondRow
skipSwap2:
    imul eax, 16
    mov ebx, firstCol
    imul ebx, 2
    add eax, ebx
    add eax, 8                  ; Offset for vertical lines
    mov esi, eax

    ; Draw vertical line in red or blue
    cmp currentPlayer, 1
    je player1VLine
    mov eax, blue + (black * 16)
    call SetTextColor
    mov BYTE PTR [board + esi], '|'
    jmp drawDone

player1VLine:
    mov eax, red + (black * 16)
    call SetTextColor
    mov BYTE PTR [board + esi], '|'

drawDone:
    ; Reset text color
    mov eax, white + (black * 16)
    call SetTextColor
    ret
DrawLine ENDP

; ======================
; Check if a box was completed
; ======================
CheckBoxCompletion PROC
    mov ebx, 0  ; Completed any box = 0

    ; Iterate all 3x3 box top-left coordinates
    mov esi, 0
nextBox:
    cmp esi, 3
    jge doneCheckingRows
    mov edi, 0
nextCol:
    cmp edi, 3
    jge nextRow

    ; Calculate offsets for the 4 sides of box
    ; Each dot line: 16 chars wide
    mov eax, esi
    imul eax, 16
    mov ecx, edi
    imul ecx, 2

    ; Top: [eax + ecx + 1]
    movzx edx, BYTE PTR [board + eax + ecx + 1]
    cmp dl, '-'
    jne skipBox

    ; Bottom: [eax + 32 + ecx + 1]
    movzx edx, BYTE PTR [board + eax + 32 + ecx + 1]
    cmp dl, '-'
    jne skipBox

    ; Left: [eax + 8 + ecx]
    movzx edx, BYTE PTR [board + eax + 8 + ecx]
    cmp dl, '|'
    jne skipBox

    ; Right: [eax + 8 + ecx + 2]
    movzx edx, BYTE PTR [board + eax + 8 + ecx + 2]
    cmp dl, '|'
    jne skipBox

    ; All 4 sides exist -> box complete!
    inc ebx
    cmp currentPlayer, 1
    je p1score
    inc player2Score
    jmp showMsg
p1score:
    inc player1Score
showMsg:
    mov edx, OFFSET msgBoxComplete
    call WriteString

skipBox:
    inc edi
    jmp nextCol
nextRow:
    inc esi
    jmp nextBox
doneCheckingRows:
    cmp ebx, 0
    je noBox
    mov eax, 1
    ret
noBox:
    mov eax, 0
    ret
CheckBoxCompletion ENDP

; ======================
; Announce winner
; ======================
AnnounceWinner PROC
    mov eax, player1Score
    mov ebx, player2Score
    cmp eax, ebx
    ja p1Wins
    jb p2Wins

    ; Draw
    mov edx, OFFSET msgDraw
    call WriteString
    ret

p1Wins:
    mov edx, OFFSET msgWinner1
    call WriteString
    ret

p2Wins:
    mov edx, OFFSET msgWinner2
    call WriteString
    ret
AnnounceWinner ENDP

END main
```
