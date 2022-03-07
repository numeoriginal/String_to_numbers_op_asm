%include "includes/io.inc"
extern getAST
extern freeAST

section .bss
    root: resd 1
    
section .text
global main

atoi_functionf_function:
    push ebp
    mov ebp, esp
    xor edi, edi
    xor ecx, ecx
    xor esi, esi
    
    mov edi, dword [ebp + 8]                        
    movzx esi, byte [edi]
    xor eax, eax            ; initializa registrului de stocare la 0 a numarului ce urmeaza sa fie convertit
    cmp esi, 45             ;verificare daca este numar negativ
    jne convert
    inc ecx                 ;o valoare de modelul true/false pentru a afla daca e nagativ sau nu la final
    inc edi
      
convert:
    movzx esi, byte [edi]   ; take byte by byte
    test esi, esi           ; check if null
    je end_conversion
       
    sub esi, 48             
    imul eax, 10            ;Construirea numarului
    add eax, esi             
    
    inc edi                 ; move adress to next byte
    jmp convert             

end_conversion: 

    cmp ecx , 1             ; check if negative number is true
    jne leave_atoi_functionf_function
    neg eax                 ; transform number in negative
    
leave_atoi_functionf_function:
    leave
    ret
  

    
mul_function:
    ;fuctia prevazuta pentru calcularea inmultirii 
    push ebp
    mov ebp, esp
    xor eax, eax ; better safe then sorry
    xor ebx, ebx
    
    mov eax, dword [ebp + 8]
    mov ebx, dword [ebp + 12]
    
    imul eax, ebx
    ;rezultatu este stoact default in eax conform standartelor NASM
    leave
    ret


add_function:
    ;functia prevazuta pentru calcularea sumei
    xor eax, eax ; par redundante dar am avut probleme
    xor ebx, ebx
    
    push ebp
    mov ebp, esp
    mov eax, dword [ebp + 8]
    mov ebx, dword [ebp + 12]
    
    add eax, ebx

    leave
    ret


sub_function:
    ;functia prevazuta pentru calculul diferentei 
    push ebp
    mov ebp, esp
    xor eax, eax ;par redundante dar am avut probleme 
    xor ebx, ebx
    mov eax, dword [ebp + 8]
    mov ebx, dword [ebp + 12]
    
    sub eax, ebx

    leave
    ret

tree_traversal:
    push ebp
    mov ebp, esp
    xor eax, eax
      
    mov eax, [ebp + 8]  ;Nodul curent
    cmp eax, 0          ;verifica daca este NULL
    je end_node
     
    mov ecx, [eax]
    cmp dword [ecx], 48 ;verificam daca valoarea din arbore este un operand
    jl symbol           
    push ecx
    call atoi_functionf_function
   ;in eax rezultatul functiei de atoi

node_value:
    ; valoarea daca e frunza
    jmp end_node

symbol:
    mov eax, [ebp + 8]
    mov ebx,dword [eax+4]  ;traversare nod stanga
    push ecx
    push ebx
    call tree_traversal   ;apelare recursiva pentru nedul stang
    pop ecx               ;pentru a regla stiva
    pop ecx               ;pentru a lua valuare lui ecx care ne intereseaza
    
    mov edx, eax    
    push edx    ;Pastrez in edx valoare operatiilor efectuate in subarborele stang
                
    
    mov eax, [ebp + 8]
    mov ebx, dword [eax+8]
    push ecx
    push ebx
    call tree_traversal   ;traversare nod dreapta
    pop ecx
    pop ecx
    
    pop edx     ;Returnez in edx valoarea operatiilor efectuate in subarborele stang
    
    mov ecx, [ecx]
    
    cmp ecx, 0x2A        ;verific daca este operandul *
    je multiplication
    
    cmp ecx, 0x2F        ;verific daca este operandul /
    je division
       
    cmp ecx, 0x2B        ;verific daca este operandul +
    je suma
    
    cmp ecx, 0x2D        ;verific daca este operandul -
    je scadere
    

    jmp end_node
    
suma:
    push edx
    push eax
    call add_function
    add esp, 8   
    ;adun la eax, edx
    jmp end_node    
    
scadere:
    push eax
    push edx
    call sub_function
    add esp, 8       
    jmp end_node
    
multiplication:
    push eax
    push edx
    call mul_function
    add esp, 8       
    jmp end_node
    
division: 
 
    mov ebx,edx     
    xchg eax,ebx
    cdq
    idiv ebx        
    ;operatia idiv returneaza catul in eax    
    jmp end_node
    
end_node:
    leave   ;iesirea din nod
    ret

main:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    
    call getAST
    mov [root], eax ; in root se pute adresa de la radacina arborelui
    
    ;Rezolvarea :
    mov eax,[root]
    ;Parsam adresa root-ului
    push eax
    call tree_traversal
    add esp,4
    
    PRINT_DEC 4, eax    ;Rezultatul final
    

    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    ;mov esp, ebp
    xor eax, eax
    leave
    ret
