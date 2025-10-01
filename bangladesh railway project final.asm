.MODEL SMALL

.STACK 100H

.DATA

;1--------------------------------
welcome_msg db 0Dh, 0Ah, "Welcome to Bangladesh Railway Service $", 0Dh, 0Ah


menu_hdr db 0Dh,0Ah,"Select Your Destination:",0Dh,0Ah,"(Press '*' to exit)",0Dh,0Ah,"$"
dot_space db ". $"
dash_str db " - $"
tk_str db " tk$"         


; Welcome Page Data  

welcome_page_line_1 db 10,13, ' ****$'
welcome_page_line_2 db 10,13, ' ** Welcome **$'
welcome_page_line_3 db 10,13, ' ** **$'
welcome_page_line_4 db 10,13, ' ** To **$'
welcome_page_line_5 db 10,13, ' ** **$'
welcome_page_line_6 db 10,13, ' ** Bangladesh Rail Service **$'
welcome_page_line_7 db 10,13, ' ** **$'
welcome_page_line_9 db 10,13, ' ***$'
welcome_page_line_10 db 10,13, ' __________________________________$'
welcome_page_line_11 db 10,13, '$'
;1--------------------------------
                           
                           
                           
; Client messages
discount_msg db 0Dh, 0Ah, "Congratulations! You have earned a 5% discount on your total.$", 0Dh, 0Ah
prompt_dest db 0Dh, 0Ah, "Enter destination number (1-10) or * to exit: $"
prompt_ticket db 0Dh, 0Ah, "Enter number of tickets (1-9): $"
invalid_msg db 0Dh, 0Ah, "Invalid selection. Try again.$", 0Dh, 0Ah
total_msg db 0Dh, 0Ah, "Your total is: $"
money_prompt db 0Dh, 0Ah, "Enter money received: $"
insufficient_money_msg db 0Dh, 0Ah, "Insufficient amount.$", 0Dh, 0Ah
change_returned_msg db 0Dh, 0Ah, "Change to be returned: $"
thank_you_msg db 0Dh, 0Ah, "Thank you Have a nice day$", 0Dh, 0Ah
goodbye_msg db 0Dh, 0Ah, "Thank you for using Metro Station! Goodbye!$", 0Dh, 0Ah
tickets_left_msg db 0Dh, 0Ah, "Tickets left: $", 0Dh, 0Ah
no_tickets_available_msg db 0Dh, 0Ah, "No tickets available.$", 0Dh, 0Ah
newline db 0Dh, 0Ah, "$"
day_prompt db 0Dh, 0Ah, "Enter the day (1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat): $"
friday_discount_msg db 0Dh, 0Ah, "You selected Friday! Additional 10% discount applied!$", 0Dh, 0Ah
shortfall_msg db 0Dh, 0Ah, "The amount is $ short. You need to give $ more: $", 0Dh, 0Ah, "$"
prices db 20, 30, 40, 50, 60, 70, 80, 90, 100
; Runtime totals
total dw 0
money_received dw 0
change dw 0
discount dw 0
tickets_available db 50
price_per_ticket dw 0




;2--------------------------------
; Login prompt
login_prompt db 0Dh,0Ah,"Login: press C for Client, A for Admin: $"
invalid_login db 0Dh,0Ah,"Invalid choice. Try again.$"
;2--------------------------------


; -------- Admin panel data --------
admin_title db 0Dh,0Ah,"--- Admin Control Panel ---$",0Dh,0Ah
admin_menu db 0Dh,0Ah,"A) Add/Update Destination",0Dh,0Ah
db "D) Delete Destination",0Dh,0Ah
db "M) Modify Destination Price",0Dh,0Ah
db "B) Back to Login$"
prompt_index db 0Dh,0Ah,"Enter destination number (1-10): $"
prompt_price db 0Dh,0Ah,"Enter price (1-999): $"
prompt_name db 0Dh,0Ah,"Enter short name (max 10 chars, Enter to finish): $"
ok_msg db 0Dh,0Ah,"Saved.$",0Dh,0Ah
del_msg db 0Dh,0Ah,"Deleted.$",0Dh,0Ah
bad_msg db 0Dh,0Ah,"Invalid choice or out of range.$",0Dh,0Ah 





; -------- Admin editable storage (prepopulated with your 9 defaults) --------
max_destinations EQU 10
dest_prices dw 20,30,40,50,60,70,80,90,100,0
dest_active db 1,1,1,1,1,1,1,1,1,0           


dest_names db 'Barishal',0,0,0 
db 'Rangpur',0,0,0,0 
db 'Khulna',0,0,0,0,0 
db 'Ctg',0,0,0,0,0,0,0,0 
db 'Noakhali',0,0 
db 0
db 'Sylhet',0,0,0,0,0 
db 'Rajshahi',0,0 
db 0
db 'Cumilla',0,0,0 
db 0
db 'Gazipur',0,0,0 
db 0         
db 'Rangamati',0,0 

max_coupons EQU 5
coupon_pct db 5 dup(0)
coupon_count db 0          



; Buffered input buffer for names (DOS 0Ah)
name_buf_max EQU 10
name_inp db name_buf_max
name_cnt db 0
name_buf db name_buf_max dup(0)



.CODE
MAIN PROC

; initialize DS
MOV AX,@DATA
MOV DS,AX


MOV ES, AX       
MOV SS, AX
MOV SP, 100H
CLD              




;3--------------------------------
; -------- Login selection screen --------
LoginSelect:
    LEA DX, login_prompt
    MOV AH, 09h
    INT 21h
    MOV AH, 01h
    INT 21h       
    MOV BL, AL
    AND BL, 11011111b ; uppercase
    CMP BL, 'C'
    JE ClientStart
    CMP BL, 'A'
    JE AdminPanel
    LEA DX, invalid_login
    MOV AH, 09h
    INT 21h
    JMP LoginSelect
;3--------------------------------





; ----------------- Admin Control Panel -----------------
AdminPanel:
    LEA DX, admin_title
    MOV AH, 09h
    INT 21h
AdminMenu:
    LEA DX, admin_menu
    MOV AH, 09h
    INT 21h
    MOV AH, 01h
    INT 21h
    MOV BL, AL
    AND BL, 11011111b
    CMP BL, 'A'
    JE AdminAddOrUpdate
    CMP BL, 'D'
    JE AdminDelete
    CMP BL, 'M'
    JE AdminModify
    CMP BL, 'B'
    JE LoginSelect
    LEA DX, bad_msg
    MOV AH, 09h
    INT 21h
    JMP AdminMenu

; Add or update a destination: index, name, price
AdminAddOrUpdate:
    LEA DX, prompt_index
    MOV AH, 09h
    INT 21h
    CALL ReadNumber      
    CMP AX, 1
    JL BadAdmin
    CMP AX, max_destinations
    JG BadAdmin
    DEC AX
    MOV BX, AX            ; BX=0..9 (save the index)

    ; Read name via buffered input (DOS 0Ah)
    LEA DX, prompt_name
    MOV AH, 09h
    INT 21h
    MOV BYTE PTR name_cnt, 0
    LEA DX, name_inp
    MOV AH, 0Ah
    INT 21h

 
    MOV AX, BX
    MOV CX, 11
    MUL CX               ; AX = BX*11
    MOV DI, AX
    ADD DI, OFFSET dest_names

    
    MOV CX, 11
    MOV AL, 0
    PUSH DI
    REP STOSB          
    POP DI

    ; Copy the new name from name_buf to the slot
    MOV CL, name_cnt
    MOV CH, 0
    JCXZ SkipCopy        ; If no characters entered, skip
    LEA SI, name_buf    

CopyName:
    LODSB                
    STOSB                
    LOOP CopyName
SkipCopy:

    ; Get price
    LEA DX, prompt_price
    MOV AH, 09h
    INT 21h
    CALL ReadNumber      ; AX=price

    ; Store price: dest_prices[BX] = AX
    MOV CX, BX
    SHL CX, 1            ; CX = BX * 2 (word offset)
    LEA DI, dest_prices
    ADD DI, CX
    MOV [DI], AX         

    ; Mark as active
    MOV dest_active[BX], 1

   
    LEA DX, ok_msg
    MOV AH, 09h
    INT 21h
    JMP AdminMenu

; Delete destination
AdminDelete:
    LEA DX, prompt_index
    MOV AH, 09h
    INT 21h
    CALL ReadNumber
    CMP AX, 1
    JL BadAdmin
    CMP AX, max_destinations
    JG BadAdmin
    DEC AX
    MOV BX, AX          

    MOV dest_active[BX], 0

    MOV CX, BX
    SHL CX, 1
    LEA DI, dest_prices
    ADD DI, CX
    MOV WORD PTR [DI], 0 

    
    MOV AX, BX
    MOV CX, 11
    MUL CX
    MOV DI, AX
    ADD DI, OFFSET dest_names
    MOV CX, 11
    MOV AL, 0

DelClr:
    STOSB
    LOOP DelClr

    LEA DX, del_msg
    MOV AH, 09h
    INT 21h
    JMP AdminMenu

; Modify price only (must be active)
AdminModify:
    LEA DX, prompt_index
    MOV AH, 09h
    INT 21h
    CALL ReadNumber
    CMP AX, 1
    JL BadAdmin
    CMP AX, max_destinations
    JG BadAdmin
    DEC AX
    MOV BX, AX
    CMP dest_active[BX], 1
    JNE BadAdmin

    LEA DX, prompt_price
    MOV AH, 09h
    INT 21h
    CALL ReadNumber

    MOV CX, BX
    SHL CX, 1
    LEA DI, dest_prices
    ADD DI, CX
    MOV [DI], AX

    LEA DX, ok_msg
    MOV AH, 09h
    INT 21h
    JMP AdminMenu

BadAdmin:
    LEA DX, bad_msg
    MOV AH, 09h
    INT 21h
    JMP AdminMenu
                     
                     
                     
;4--------------------------------                     
; ----------------- Client flow -----------------
ClientStart:
displaying:
    mov ah, 09
    lea dx, welcome_page_line_1
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_2
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_3
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_4
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_5
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_6
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_7
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_9
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_10
    int 21h

    mov ah, 09
    lea dx, welcome_page_line_11
    int 21h

display_welcome:
    LEA DX, welcome_msg
    MOV AH, 09H
    INT 21H

menu_display:
    MOV [total], 0
    MOV [money_received], 0
    MOV [change], 0
    MOV [discount], 0
    CALL ShowDynamicMenu
;4--------------------------------



;5--------------------------------
destination_input:
    LEA DX, prompt_dest
    MOV AH, 09H
    INT 21H

    MOV AH, 01h
    INT 21h
    CMP AL, '*'
    JE exit_program
    CMP AL, 0Dh
    JE invalid_selection

    ; Build number in CX starting with first digit
    MOV CX, 0
    CMP AL, '0'
    JB invalid_selection
    CMP AL, '9'
    JA invalid_selection
    SUB AL, '0'
    MOV CL, AL

read_more_digits:
    MOV AH, 01h
    INT 21h
    CMP AL, 0Dh
    JE got_number 
    
    CMP AL, '0'
    JB invalid_selection
    CMP AL, '9'
    JA invalid_selection
    
    SUB AL, '0'      
    MOV DL, AL       

    MOV AX, CX
    MOV BX, 10
    MUL BX           ; AX = CX * 10
    MOV CX, AX

    ADD CX, DX       ; CX = CX*10 + digit
           
    JMP read_more_digits

got_number:
    MOV AX, CX             ; AX = chosen number
    CMP AX, 1
    JL invalid_selection
    CMP AX, max_destinations
    JG invalid_selection
    
    DEC AX                ; 0-based index
    MOV SI, AX
    CMP dest_active[SI], 1  ;checking in the array if destinatin active or not
    JNE invalid_selection


;----------------------------------------------
    ; price_per_ticket = dest_prices[SI]
    MOV BX, SI
    SHL BX, 1
    LEA DI, dest_prices
    ADD DI, BX
    MOV AX, [DI]
    MOV [price_per_ticket], AX

ticket_input:
    LEA DX, prompt_ticket
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV CL, AL
    CMP CL, 1
    JL invalid_selection
    CMP CL, 9
    JG invalid_selection
    
    ;Check availability of tickets
    
    MOV AL, [tickets_available]
    CMP AL, CL
    JL no_tickets_available
    SUB [tickets_available], CL   ;available ticket-=purchased ticket

    LEA DX, tickets_left_msg
    MOV AH, 09H
    INT 21H
    MOV AL, [tickets_available]
    MOV AH,0
    CALL DisplayNumber
    LEA DX, newline
    MOV AH, 09H
    INT 21H
;5--------------------------------
                                   
                                   
                                   
                                   


calculate_total:
    ; total = price_per_ticket * CL
    MOV AX, [price_per_ticket]
    XOR DX, DX
    MOV BL, CL
    XOR BH, BH
    MUL BX                   
    MOV [total], AX

    CMP CL, 5
    JL no_discount
    LEA DX, discount_msg
    MOV AH, 09H
    INT 21H
    MOV AX, [total]
    MOV BX, 5
    MUL BX
    MOV CX, 100
    DIV CX
    MOV [discount], AX
    MOV AX, [total]
    SUB AX, [discount]
    MOV [total], AX

no_discount:
    LEA DX, day_prompt
    MOV AH, 09H
    INT 21H
    CALL ReadNumber
    MOV BL, AL
    CMP BL, 6
    JNE no_friday_discount
    LEA DX, friday_discount_msg
    MOV AH, 09H
    INT 21H
    MOV AX, [total]
    MOV BX, 10
    MUL BX
    MOV CX, 100
    DIV CX
    SUB [total], AX

no_friday_discount:
display_total:
    LEA DX, total_msg
    MOV AH, 09H
    INT 21H
    MOV AX, [total]
    CALL DisplayNumber
    LEA DX, newline
    MOV AH, 09H
    INT 21H

money_input:
    LEA DX, money_prompt
    MOV AH, 09H
    INT 21H
    CALL ReadNumber
    MOV [money_received], AX

compare_amounts:
    MOV BX, [money_received]
    MOV AX, [total]
    CMP BX, AX
    JL insufficient_money
    JG calculate_change
    JMP exact_payment

insufficient_money:
    LEA DX, insufficient_money_msg
    MOV AH, 09H
    INT 21H
    MOV AX, [total]
    SUB AX, [money_received]
    MOV BX, AX
    LEA DX, shortfall_msg
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL DisplayNumber
    LEA DX, money_prompt
    MOV AH, 09H
    INT 21H
    CALL ReadNumber
    MOV [money_received], AX
    CMP [money_received], BX
    JL insufficient_money1
    JG calculate_change1
    JMP exact_payment1

insufficient_money1:
    LEA DX, insufficient_money_msg
    MOV AH, 09h
    INT 21h
    JMP menu_display

calculate_change:
    SUB BX, AX
    MOV [change], BX
    LEA DX, change_returned_msg
    MOV AH, 09H
    INT 21H
    MOV AX, [change]
    CALL DisplayNumber
    LEA DX, thank_you_msg
    MOV AH, 09H
    INT 21H
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    JMP menu_display

calculate_change1:
    MOV AX, [money_received]
    SUB AX, BX
    MOV [change], AX
    LEA DX, change_returned_msg
    MOV AH, 09H
    INT 21H
    MOV AX, [change]
    CALL DisplayNumber
    LEA DX, thank_you_msg
    MOV AH, 09H
    INT 21H
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    JMP menu_display

exact_payment1:
    LEA DX, thank_you_msg
    MOV AH, 09H
    INT 21H
    JMP menu_display

exact_payment:
    LEA DX, thank_you_msg
    MOV AH, 09H
    INT 21H
    JMP menu_display




;------------------------feature 2------------------------- 
no_tickets_available:
    LEA DX, no_tickets_available_msg
    MOV AH, 09H
    INT 21H
    JMP menu_display

invalid_selection:
    LEA DX, invalid_msg
    MOV AH, 09H
    INT 21H
    JMP menu_display                                       
;------------------------feature 2-------------------------                         
 
 
                        
exit_program:
    LEA DX, goodbye_msg
    MOV AH, 09H
    INT 21H

    ;exit to DOS
    MOV AX,4C00H
    INT 21H

MAIN ENDP   





; -------- Helpers --------
; Print a string at DX terminated by '$'
PrintStr PROC
    MOV AH, 09h
    INT 21h
    RET
PrintStr ENDP
                
                
                
                                
                       
                             
;6-------------------------------- 

ShowDynamicMenu PROC   ;prints the current active destinations with numbers, names, and prices
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA DX, menu_hdr
    CALL PrintStr

    MOV SI, 0
    MOV CX, max_destinations
SDM_Loop:
    CMP dest_active[SI], 1
    JNE SDM_Next

    ; print (SI+1)
    MOV AX, SI
    INC AX
    CALL DisplayNumber

    ; print ". "
    LEA DX, dot_space
    CALL PrintStr

    ; print name (up to 10 chars or until 0)
    PUSH SI
    MOV AX, SI
    MOV DX, 11
    MUL DX
    MOV DI, AX
    POP SI
    LEA BX, dest_names
    ADD DI, BX

    MOV DX, 0          
    MOV BP, 10         ; max 10 characters
SDM_PrintName:
    MOV AL, [DI]
    CMP AL, 0
    JE SDM_AfterName
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    INC DI
    DEC BP
    JNZ SDM_PrintName
SDM_AfterName:
    ; print " - "
    LEA DX, dash_str
    CALL PrintStr

    ; print price
    MOV BX, SI
    SHL BX, 1
    LEA DI, dest_prices
    ADD DI, BX
    MOV AX, [DI]
    CALL DisplayNumber

    ; print " tk" and newline
    LEA DX, tk_str
    CALL PrintStr
    LEA DX, newline
    CALL PrintStr
SDM_Next:
    INC SI
    LOOP SDM_Loop

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ShowDynamicMenu ENDP
;6-------------------------------- 







ReadNumber PROC
    PUSH BX
    PUSH CX
    PUSH DX
    MOV CX, 0
    MOV BX, 10
read_loop:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH
    JE read_done
    SUB AL, '0'
    MOV AH, 0
    PUSH AX
    MOV AX, CX
    MUL BX
    MOV CX, AX
    POP AX
    ADD CX, AX
    JMP read_loop
read_done:
    MOV AX, CX
    POP DX
    POP CX
    POP BX
    RET
ReadNumber ENDP

DisplayNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV CX, 0
    MOV BX, 10
    CMP AX, 0
    JNE dn_div
    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    JMP dn_end
dn_div:
divide_loop:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE divide_loop
display_loop:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP display_loop
dn_end:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DisplayNumber ENDP

END MAIN
