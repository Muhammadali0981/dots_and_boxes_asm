include irvine32.inc

.data
    ; Properly defined board using DB — broken down to avoid complex line error
    board BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0Ah
          BYTE ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah
          BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0Ah
          BYTE ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah
          BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0Ah
          BYTE ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah
          BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0

    ; Array to store line ownership (1 = Player1, 2 = Player2)
    lineOwnership BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0Ah
                  BYTE ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah
                  BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0Ah
                  BYTE ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah
                  BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0Ah
                  BYTE ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0Ah
                  BYTE '.', ' ', '.', ' ', '.', ' ', '.', 0

    ; User interface messages
    msgWelcome BYTE "Welcome to Dots and Boxes!", 0Ah, 0
    msgEnterFirst BYTE "Enter first dot (row col): ", 0
    msgEnterSecond BYTE "Enter second dot (row col): ", 0
    msgInvalidMove BYTE "Invalid move! Try again.", 0Ah, 0
    msgPlayer1 BYTE "Player 1's turn (Red)", 0Ah, 0
    msgPlayer2 BYTE "Player 2's turn (Blue)", 0Ah, 0
    msgWinner1 BYTE "Player 1 wins!", 0Ah, 0
    msgWinner2 BYTE "Player 2 wins!", 0Ah, 0
    msgScore1 BYTE "Player1 scores: ", 0
    msgScore2 BYTE "Player2 scores: ", 0
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
    boxCompleted BYTE 9 dup(0) ; Initialize all boxes as not completed (0)

.code

main PROC

gameLoop:
    ; Clear screen and display welcome message
    call Clrscr
    mov edx, OFFSET msgWelcome
    call WriteString
    call crlf

    ; Display current game board and whose turn it is
    call DisplayBoard
    mov edx, OFFSET msgScore1
    call WriteString
    mov eax, player1Score
    call WriteDec
    call crlf
    mov edx, OFFSET msgScore2
    call WriteString
    mov eax, player2Score
    call WriteDec
    call crlf
    call crlf
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
    mov eax, 3000
    call Delay
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
    mov esi, OFFSET board
    mov edi, OFFSET lineOwnership

    printLoop:
        movzx eax, byte ptr [esi]
        ;call writeint
        cmp eax, 0
        je doneDisplay          ;if 0 terminator then done

        cmp eax, 0Ah
        je printNewLine
        cmp eax, '.'
        je printDot
        cmp eax, ' '
        je printSpace
        cmp eax, '-'
        je colorLine
        cmp eax, '|'
        je colorLine

    colorLine:
         mov ebx, eax                               ;Save the character in ebx temporarily
         movzx edx, byte ptr [edi]      ;Get the owner of the line
         cmp edx, 1
         je player1Line
         mov eax, blue + (black * 16)
         call SetTextColor
         mov eax, ebx                               ;Restore the character
         call WriteChar
         jmp resetColor

         player1Line:
             mov eax, red + (black * 16)
             call SetTextColor
             mov eax, ebx
             call WriteChar
             jmp resetColor

    printNewLine:
         call crlf
         jmp nextChar

    printDot:
        mov ebx, eax
        mov eax, yellow + (black * 16)    
        call SetTextColor
        mov eax, ebx
        call WriteChar
        jmp resetColor

    printSpace:
        mov ebx, eax
        mov eax, white + (black * 16)    ; White for spaces
        call SetTextColor
        mov eax, ebx
        call WriteChar
        jmp resetColor

    resetColor:
        mov eax, white + (black * 16); Reset text color to white on black
        call SetTextColor
        jmp nextChar                ; Continue to the next character

   nextChar:
         inc esi
         inc edi
         jmp printLoop

    doneDisplay:
        ;reset color to white at the end
        mov eax, white + (black * 16)
        call SetTextColor
        call crlf
        call crlf
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
    ;imul eax, 2           ;committed this change for getting the correct position of rows
    mov firstRow, eax
    call ReadInt
    ;imul eax, 2          ;committed this change for getting the correct position of rows
    mov firstCol, eax

    ; Second dot input
    mov edx, OFFSET msgEnterSecond
    call WriteString
    call ReadInt
    ;imul eax, 2          ;committed this change for getting the correct position of rows
    mov secondRow, eax
    call ReadInt
    ;imul eax, 2          ;committed this change for getting the correct position of rows
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
    stc                     ; Invalid move -> set Carry Flag = 1
    ret
valid:
    clc                     ; Valid move -> clear Carry Flag = 0
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
    imul eax, 8               ; Multiply by row width 'changed by me'
    mov ebx, firstCol
    cmp ebx, secondCol
    jl skipSwap
    xchg ebx, secondCol         ; Ensure leftmost col is in ebx
skipSwap:
    imul ebx, 1                 ; Spaces between dots ;changed
    add eax, ebx
    add eax, 1
    mov esi, eax                ; Offset into board

    ; storing horizontal line
    cmp currentPlayer, 1
    je player1Line
    mov BYTE PTR [board + esi], '-'
    mov BYTE PTR [lineOwnership + esi], 2 ; Mark the line as owned by Player 2
    jmp drawDone

player1Line:
    mov BYTE PTR [board + esi], '-'
    mov BYTE PTR[lineOwnership + esi], 1 ; Mark the line as owned by Player 1
    jmp drawDone

drawVertical:
    ; Vertical line
    mov eax, firstRow
    cmp eax, secondRow
    jl skipSwap2
    xchg eax, secondRow
skipSwap2:
    imul eax, 8
    mov ebx, firstCol
    imul ebx, 1
    add eax, ebx
    add eax, 8                  ; Offset for vertical lines
    mov esi, eax

    ; storing the vertical line
    cmp currentPlayer, 1
    je player1VLine
    mov BYTE PTR [board + esi], '|'
    mov BYTE PTR [lineOwnership + esi], 2 ; Mark the line as owned by Player 2
    jmp drawDone

player1VLine:
    mov BYTE PTR [board + esi], '|'
    mov BYTE PTR [lineOwnership + esi], 1 ; Mark the line as owned by Player 1

drawDone:
    ret
DrawLine ENDP


; ======================
; Check if a box was completed
; ======================
CheckBoxCompletion PROC
    mov ebx, 0  ; Completed any box = 0

    ; Iterate all 3x3 box top-left coordinates
    mov esi, 0  ; Row index of top-left corner of the box

    nextBox:
        cmp esi, 3
        jge doneCheckingRows
        mov edi, 0  ; Column index of top-left corner of the box

    nextCol:
        cmp edi, 3
        jge nextRow

        ; Calculate the box index (0–8)
        mov eax, esi
        imul eax, 3          ; Multiply row index by 3
        add eax, edi         ; Add column index
        movzx ecx, byte ptr [boxCompleted + eax] ; Check if the box is already completed
        cmp cl, 1
        je skipBox           ; If already completed, skip this box

        ; Calculate offsets for the 4 sides of the box
        mov edx, esi         ; Save row index in EDX temporarily
        imul edx, 8          ; Row offset (8 bytes per row)
        imul edx, 2
        mov ecx, edi         ; Column offset (1 byte per column)
        imul ecx, 2

        ; Top: [edx + ecx + 1]
        movzx eax, BYTE PTR [board + edx + ecx + 1]
        cmp al, '-'
        jne skipBox

        ; Bottom: [edx + 16 + ecx + 1]
        movzx eax, BYTE PTR [board + edx + 16 + ecx + 1]
        cmp al, '-'
        jne skipBox

        ; Left: [edx + 8 + ecx]
        movzx eax, BYTE PTR [board + edx + 8 + ecx]
        cmp al, '|'
        jne skipBox

        ; Right: [edx + 8 + ecx + 2]
        movzx eax, BYTE PTR [board + edx + 8 + ecx + 2]
        cmp al, '|'
        jne skipBox

        ; All 4 sides exist -> box complete!
        inc ebx              ; Increment the count of completed boxes

        ;checking which player drew the last line to complete a single box
        cmp currentPlayer, 1
        jne boxGivenToPlayer2
        mov BYTE PTR [lineOwnership + edx + ecx + 1], 1         ;top of the box now belongs to player1
        mov BYTE PTR [lineOwnership + edx + 16 + ecx + 1], 1    ;bottom of the box now belongs to player1
        mov BYTE PTR [lineOwnership + edx + 8 + ecx], 1
        mov BYTE PTR [lineOwnership + edx + 8 + ecx + 2], 1

        continue_check:
            ; Mark the box as completed
            mov eax, esi         ; Recalculate box index
            imul eax, 3
            add eax, edi
            mov byte ptr [boxCompleted + eax], 1

            ; Increment the score for the current player
            cmp currentPlayer, 1
            je p1score
            inc player2Score
            jmp showMsg
    p1score:
        inc player1Score
    showMsg:
        mov edx, OFFSET msgBoxComplete
        call WriteString
        jmp skipBox

    boxGivenToPlayer2:
        mov BYTE PTR [lineOwnership + edx + ecx + 1], 2         ;top of the box now belongs to player2
        mov BYTE PTR [lineOwnership + edx + 16 + ecx + 1], 2    ;bottom of the box now belongs to player2
        mov BYTE PTR [lineOwnership + edx + 8 + ecx], 2
        mov BYTE PTR [lineOwnership + edx + 8 + ecx + 2], 2
        jmp continue_check

    skipBox:
        inc edi              ; Move to the next column
        jmp nextCol

    nextRow:
        inc esi             ; Move to the next row
        ;imul esi, 2
        jmp nextBox

    doneCheckingRows:
        cmp ebx, 0
        je noBox             ; No boxes were completed
        mov eax, 1           ; Return 1 to indicate at least one box was completed
        ret
    noBox:
        mov eax, 0           ; Return 0 to indicate no boxes were completed
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
