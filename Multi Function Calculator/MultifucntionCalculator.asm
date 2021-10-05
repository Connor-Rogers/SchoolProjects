; Author: Connor Rogers, Alec Montesano 
; Date: 4/20/2022    
;    
;    Four-Function Calculator:
;
; Replace with Description
;

.ORIG x3000
; Define and Initialize Variable to store function
storeFunction   .FILL   #0
; Get Operaton    
    LEA R0, operatorPrompt
    PUTS
    GETC
    OUT
    ST R0, storeFunction
    AND R0, R0, #0
; Declare and Initailize Varibles for Inputs
    input_1        .FILL    #0
    input_2        .FiLL   #0
    temp           .FILL    #0

; Get the first number
    LEA R0, inputOnePrompt
    PUTS
    JSR handleInput
    LD R1, temp
    ST R1, input_1

; Reset Temporary Varible
    AND R0, R0, #0
    ST R0, temp

;Get the second number
    LEA R0, inputTwoPrompt
    PUTS
    JSR handleInput
    LD R2, temp
    ST R2, input_2
;Define Prompt Strings
operatorPrompt        .STRINGZ     "\nSelect a Function(+,-,*,/): "
inputOnePrompt        .STRINGZ     "\nEnter the first number: "
inputTwoPrompt        .STRINGZ    "\nEnter the second number: "    
anwserPrompt        .STRINGZ    "\nThe answer is: "
;Select function
        AND R0, R0, #0
    AND R6, R6, #0
        LD R0, storeFunction
    LD R1, input_1
        LD R2, input_2
  LEA R5, FunctionLookup    ; load codesArray address

      LDR R3, R5, #0        ; loads first symbol from R7 into R3
      ADD R4, R0, R3        ; add contents of R0 (user input) and R3
      BRz Addition

      LDR R3, R5, #1
      ADD R4, R0, R3
      BRz Subtract

      LDR R3, R5, #2
      ADD R4, R0, R3
      BRz Multiply

      LDR R3, R5, #3
      ADD R4, R0, R3
      BRz DivisionF
         
OpComplete
      LEA R0, anwserPrompt
      PUTS
      ADD R6, R6, #0
      Brn isNegative
      ST R6, result
      JSR DetermineSize
      JSR NumToASCII
      LEA R0, output
      PUTS
      ; End of program
        HALT


; Defines numerical values for acii characters for the four functions
FunctionLookup    .FILL     #-43  ; '+'
                    .FILL     #-45  ; '-'
                  .FILL     #-42  ; '*'
                  .FILL     #-47  ; '/'
;
; Subroutines
;
;Declare result
result    .FILL #0

handleInput
  ST R7, saveR7
  LEA R3, input           ; R3 is index
  AND R4, R4, #0          ; Set value of R4 to 0
  AND R5, R5, #0          ; Set value of R5 to 0

  inputLoop 
    GETC
    ADD R6, R0, #-10      ; Waits for  Enter Key
    BRz DoneReadInput
    OUT   
;Simulates for loop looping through array using R3 as a counter to hold the index
;Stores input values as it loops through the array         
    STR R0, R3, #0        
    ADD R4, R4, #1        
    ST R4, inputSize      
    ADD R3, R3, #1        
    ADD R5, R4, #-3       
    BRn inputLoop     

; Stores information about the number stored in the look and converts it to ASCII
;after the loop has completed
  DoneReadInput
    LEA R3, input   
    LEA R4, checkPowTen   
    LD R5, minus30        
    LD R6, inputSize     
    ADD R6, R6, #-1      

  inputLoop2
    LDR R1, R3, #0        
    ADD R1, R1, R5       
    ADD R2, R4, R6        
    LDR R2, R2, #0        
    JSR ReadInputExpand  
    LD R1, result          
    LD R0, temp      
    ADD R0, R0, R1        
    ST R0, temp       
    ADD R3, R3, #1        
    ADD R6, R6, #-1       
    BRzp inputLoop2   ;loop back and continue to multiply out
  LD R7, saveR7
  RET

ReadInputExpand
  ST R6, saveR6
  ST R4, saveR4
  AND R6, R6, #0
  AND R4, R4, #0
  ADD R4, R4, R2  ; duplicate R2 so it remains unchanged
  Mult

    ADD R6, R6, R1
    ADD R4, R4, #-1
  BRp Mult
  ST R6, result
  LD R4, saveR4
  LD R6, saveR6
  RET

minus30       .FILL     x-30
input    .BLKW     #3

NumToASCII ; prints number in R1
  ST R7, saveR7
  LD R3, outputSize       ; load array length into R3

  LEA R6, output     ; load address of output into R6
  
Convert_Loop
    LEA R5, checkPowTen    
    ADD R3, R3, #-1      
    ADD R5, R5, R3        ; R5 <- R5 + R3
    LDR R2, R5, #0       
    LD R1, result         ; load the number into R1
    ST R3, saveR3
    ST R4, saveR4
    ST R5, saveR5
    ST R6, saveR6
    JSR Division          ; divide
    LD R3, saveR3
    LD R4, saveR4
    LD R5, saveR5
    LD R6, saveR6
    LD R0, convert_quot   ; load direct quotient into R0
    LD R5, remainder  ; load direct remainder into R5
    LD R4, add30         ; load ASCII offset into R4
    ADD R0, R0, R4        ; Converts to ASCII
    STR R0, R6, #0         ; store R0 at R6,
    ADD R6, R6, #1        ; store R0 at R6,
    ADD R3, R3, #0        ; Increase index at R6
    ST R5, result
    BRp Convert_Loop
    ADD R0, R0, #0
    ST R0, outputSize
    LD R7, saveR7
    RET

add30        .FILL     x30

Addition
  ADD R6, R2, R1
  JSR OpComplete

Subtract
  NOT R2, R2
  ADD R2, R2, #1
  ADD R6, R1, R2
  JSR OpComplete

Multiply
  AND R6, R6, #0  ; Quotient
  AND R3, R3, #0  ; init Y
  ADD R3, R2, #0  ; add Y to R3
  Mul
    ADD R6, R6, R1
    ADD R3, R3, #-1
  Brp Mul
  JSR OpComplete

DivisionF
  JSR Division
  JSR OpComplete

Division
  AND R3, R3, #0  ; init R3
  ADD R3, R1, #0  ; add X to R3
  AND R4, R4, #0  ; init Y
  ADD R4, R2, #0  ; add Y to R4
  AND R6, R6, #0  ; Quotient
  NOT R4, R4
  ADD R4, R4, #1  ; Invert R4
  Div
    ADD R3, R3, R4  ; X = X - Y
    BRn EndDiv
    ADD R6, R6, #1
    ST R3, remainder
    Br Div
  EndDiv
    ST R6, convert_quot     ; special case
  RET

isNegative
  ST R7, saveR7
  NOT R6, R6
  ADD R6, R6, #1
  LEA R0, negSym
  PUTS
  LD R7, saveR7
  RET
negSym  .STRINGZ  "-"
output   .BLKW     #4

DetermineSize
  ST R7, saveR7
  LD R1, result          ; store R6 (number) into R1
  LEA R3, checkPowTen
  AND R4, R4, #0        ; R4 is going to be index
  ADD R4, R4, #3
  DetermineSizeLoop
    ADD R2, R3, R4        ; contains value from checkPowTen
    LDR R2, R2, #0
    ST R4, saveR4
    ST R3, saveR3
    JSR Division          ; divide Result and Const
    LD R4, saveR4
    LD R3, saveR3
    ADD R6, R6, #0        ; make R6 relative
    BRp SizeDetermined    ; if positive, we found size!
    ADD R4, R4, #-1       ; else decrement index
    BRnzp DetermineSizeLoop   ; try again
  SizeDetermined
    ADD R4, R4, #1        ; size = index + 1
    ST R4, outputSize
  LD R7, saveR7
  RET


size5         .FILL     #5

remainder .FILL     #0
inputSize     .FILL     #0
convert_quot  .FILL     #0
minus99       .FILL     #-99
minus999      .FILL     #-999
minus9999     .FILL     #-9999
saveR3        .FILL     #0
saveR4        .FILL     #0
saveR5        .FILL     #0
saveR6        .FILL     #0
saveR7        .FILL     #0
checkPowTen    .FILL     #1
              .FILL     #10
              .FILL     #100
              .FILL     #1000
outputSize    .FILL     #0
outputQuot    .FILL     #0



        .END

