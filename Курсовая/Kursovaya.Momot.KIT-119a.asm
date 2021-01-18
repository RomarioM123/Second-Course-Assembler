include \masm64\include64\mylibrary.inc  ; ����������� ����� ����������

.data?
    hInstance dq ?
    hIcon     dq ?
    hBmp      dq ?
    hStatic   dq ?

.data 
    fName db "Momot.KIT-119A.txt",0                             ; �������� ����� ��� ������
    fName2 db "notepad Momot.KIT-119A.txt",0                    ; BYTE -> db
    fHandle dq ?                                                ; ���������� �����
    cWritten dq ?                                               ; ������ ��� ������ �������� ������
    fmt1 db "������������� �����: %s | ���������� ���� - %d",0  ; ����� ��� ������ � ����
    
    intKeyVar db 2
    txtBuf db 100 dup(0),0
    size_of_buffer equ 45	; ������������ ���������� �������� ��� ������
    size_of_key equ 10		; ������������ ���������� �������� ��� �����

    arr1 db 50 dup(0),0
    buf1 db 50 dup(0),0		; ����� ��� �����
    txt1 db "%s",0
    txt2 db "%d %d",0

    inf1 db "���������� �������",0      ; ����������� �� �������� ����������
    titl1 db "��������� � ����������",0 ; �������� ���� � ������������

    txtE db "%s",0                      ; ������ ������ �������������� ������ � ����
    txtD db "������� ���� :  %d",0      ; ������ ������ ����� � ����
   
.code                           ; ������ ����
entry_point proc
    GdiPlusBegin                ; ������������� GDIPlus
        mov hInstance, rv(GetModuleHandle,0)
        mov hIcon,rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)
        mov hBmp,rv(ResImageLoad,20)
        invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon
    GdiPlusEnd                  ; GdiPlus �������
        invoke ExitProcess,0    ; ����� �� ���������
    ret
entry_point endp

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
.switch uMsg
    .case WM_INITDIALOG ; �������� ����������� ����
        invoke SendMessage,hWin,WM_SETICON,1,lParam
        mov hStatic, rv(GetDlgItem,hWin,102)
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hBmp
        
    .case WM_LBUTTONDOWN    ; ��������� ������� ����� ������ ����
        invoke SendMessage,hWin,WM_NCLBUTTONDOWN, HTCAPTION,0   ; ����������� ����
        
.case WM_COMMAND    ; ��������� ������
    .switch wParam
        .case 101   ; ���� ������� ���������� ������
        .data       ; ������ ������
            txt3 db "Error",0   ; ����� � ������� ������
            ten db 10
            buf2 db 50 dup(0),0 ; ����� ��� �������� ������
            
        .code
            invoke GetDlgItemText,hWin,104,addr buf2,size_of_buffer ; ��������� ������ ��� ����������
            invoke GetDlgItemText,hWin,108,addr buf1,size_of_key    ; ��������� ����� ��� ����������
        
            xor rbx, rbx            ; ������� �������� RBX
            lea rax, buf1           ; ��������� ��������� � ������ ������ � ������
            mov rcx, size_of_key    ; ������ � RCX ����� �����
           
        keyLen:             ; ���� ����������� ������ �����
            inc rbx         ; ��������� �������� RBX
            add rax,1       ; ��������� �������� RAX
            dec rcx         ; ��������� �������� RCX

            mov rsi, [rax]  ; ����������� �������� �� ������ � ������� RSI
            cmp rsi, 0      ; ���� ��������� ����� �����
            je firstNumCheck
            jnz keyLen      ; ������� � ������ �����

        firstNumCheck:		; ���� ����������� ������������ ���������� ����� 1
            xor rax, rax    ; ������� �������� RAX
            mov rcx, rbx    ; rbx - �������
            lea rax, buf1   ; ��������� ��������� � ������ ������ � ������
            mov r13, [rax]  ; ��������� �������� ������ � ������� R13
            mov r14b, r13b
            cmp r14, 49     ; �������� ������� �����
            jb _Wrong       ; ���� 1 ������ ������������
            cmp r14, 57     ; �������� ������� �����
            ;ja _Wrong

            dec rcx         ; ��������� ���������� ����������
            jz next         ; ������� �� ��������� ����
            add rax, 1      ; ����������� �� ��������� ������ ������

        restNumCheck:		; ���� ����������� ������������ ���������� ����� 2
            xor r13, r13    ; ������� �������� R13
            xor r14, r14    ; ������� �������� R14
            mov r13, [rax]  ; ��������� ������� �� ������ �����
            mov r14b, r13b
            cmp r14, 47     ; �������� �� ������������ �����
            ja restNumCheck2
            jmp _Wrong      ; ���� ������ ��������

        restNumCheck2:		; ���� ����������� ������������ ���������� ����� 3
            cmp r14, 58     ; �������� �������
            jae _Wrong      ; ���� ������ ������������
            add rax, 1      ; ������� �� ��������� ������
            dec rcx         ; ��������� ���������� ������
            jnz restNumCheck
        
        next:
            xor rax, rax    ; ������� �������� RAX
            xor r13, r13    ; ������� �������� R13
            xor r14, r14    ; ������� �������� R14
            mov rcx, rbx    ; ������ �������� RBX � RCX

            sub rcx,1       ; ��������� ���������� RCX
            mov rax, 1
            cmp rcx, 0
            ja MultT
            jmp getNum
    
        MultT:		; �������������� ����� �� ������ � ������������� ���
            mul ten
            dec rcx
            jnz MultT

        getNum:		; �������������� ����� �� ������ � ������������� ��� 2
            mov r15, rax
            lea r10, buf1    
            mov rcx, rbx
            xor r12, r12    ; ������� �������� R12

        getOneNum:	; �������������� ����� �� ������ � ������������� ��� 3
            mov r13, [r10]
            mov r14b, r13b
            mov rsi, 48
            xor rdi, rdi    ; ������� �������� RDI
            xor r11, r11    ; ������� �������� R11

        toBin:		; �������������� ����� �� ������ � ������������� ��� 4
            cmp rsi, r14
            je Ivander
            inc rsi         ; ��������� RSI
            inc r11         ; ��������� R11
            jmp toBin

        Ivander:    ; �������������� ����� �� ������ � ������������� ��� 5
            mov rax, r11    ; ����������� ������ �� R11 � RAX  
            mul r15
            add r12, rax
            mov rax, r15    ; ����������� ������ �� R15 � RAX
            div ten
            mov r15, rax    ; ����������� ������ �� RAX � R15
            add r10,1       ; ��������� R10
            dec rcx         ; ��������� RCX
            jnz getOneNum

            xor r15, r15    ; ������� �������� R15
            add r15, rbx
            xor rbx, rbx    ; ������� �������� RBX

            xor rax, rax    ; ������� �������� RAX
            mov rax, r12
            mul intKeyVar
            mov r12, rax

            xor rax, rax    ; ������� �������� RAX
            xor r10, r10    ; ������� �������� R10
            xor r11, r11    ; ������� �������� R11
            xor r13, r13    ; ������� �������� R13
            xor r14, r14    ; ������� �������� R14

            lea rax, buf2           ; ��������� ��������� � ������ ������ � �������
            mov rcx, size_of_buffer ; ��������� ���������� �������� �����

        cycle: 		
            inc r10         ; ��������� R10
            add rax, 1
            dec rcx         ; ��������� RCX
       
            mov rsi, [rax]  ; ��������� ������� �� ������ � �������
            cmp rsi, 0      ; ���� ������ - ����
            je _work
            jnz cycle

        _work:
            lea rsi, buf2
            lea rdi, arr1
            mov rcx, r10

        cyphering:
            mov rax, [rsi]
            mov bl, al
            add rbx, r12

            mov [rdi], rbx
            add rsi, 1
            add rdi, 1
            dec rcx  
            jnz cyphering

        _print:                                 ; ����� ���������� ������ ���������
            add r15, r10
            add r15, 50

            lea rsi, txtBuf                     ; ������������� ������ ��� ������������ ���������
            invoke wsprintf, ADDR txtBuf, ADDR fmt1, addr arr1, r12     ; �������������� res1

            xor rax,rax                         ; ������� �������� RAX
            invoke CreateFile,ADDR fName,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0
            mov fHandle,rax                     ; ���������� ����������� �����
            invoke WriteFile,fHandle,ADDR txtBuf,r15,ADDR cWritten,0    ; ������ �����
            invoke CloseHandle,fHandle          ; ������� ���������� ����� (�����������) 
    
            invoke MessageBoxTimeout,0,addr inf1,addr titl1,MB_OK,0,1500
            invoke WinExec,addr fName2,SW_SHOW  ; �������� ����� � �����������
            jmp _end    ; ������� � ����� ���������

        _Wrong:         ; ���� ������ ������������
            invoke MsgboxI,hWin,ptr$(txt3),"�������",MB_OK,10   ; ����� ����������� �� ������

        _end:       
            ;invoke wsprintf,ADDR txtBuf,ADDR txt2, rdi, r12
            ;invoke MessageBox,0,ADDR txtBuf,ADDR titl1,MB_ICONINFORMATION

        .case 105   ; ���� ������� ���������� ������
            invoke GetDlgItemText,hWin,104,addr buf2,size_of_buffer     ; ��������� ������
            invoke GetDlgItemText,hWin,108,addr buf1,size_of_key        ; ��������� �����
        
            xor rbx, rbx            ; ������� �������� RBX
            lea rax, buf1           ; ��������� ��������� � ������ ������ � ������
            mov rcx, size_of_key    ; ������ � RCX ����� �����
           
        keyLen1:            ; ���� ����������� ������ �����
            inc rbx         ; ��������� �������� RBX
            add rax,1       ; ��������� �������� RAX
            dec rcx         ; ��������� �������� RCX

            mov rsi, [rax]  ; ����������� �������� �� ������ � ������� RSI
            cmp rsi, 0      ; ���� ��������� ����� �����
            je firstNumCheck1
            jnz keyLen1     ; ������� � ������ �����

        firstNumCheck1:
            xor rax, rax    ; ������� �������� RAX
            mov rcx, rbx    ; rbx - �������
            lea rax, buf1   ; ��������� ��������� � ������ ������ � ������
            mov r13, [rax]  ; ��������� �������� ������ � ������� R13
            mov r14b, r13b
            cmp r14, 49     ; �������� ������� �����
            jb _Wrong1      ; ���� 1 ������ ������������
            cmp r14, 57     ; �������� ������� �����
            ;ja _Wrong1

            dec rcx         ; ��������� ���������� ����������
            jz next1        ; ������� �� ��������� ����
            add rax, 1      ; ����������� �� ��������� ������ ������ �����

        restNumCheck1:
            xor r13, r13    ; ������� �������� R13
            xor r14, r14    ; ������� �������� R14
            mov r13, [rax]  ; ��������� ������� �� ������ �����
            mov r14b, r13b
            cmp r14, 47     ; �������� �� ������������ �����
            ja restNumCheck21
            jmp _Wrong1     ; ���� ������ ��������

        restNumCheck21:
            cmp r14, 58     ; �������� �������
            jae _Wrong1     ; ���� ������ ������������
            add rax, 1      ; ������� �� ��������� ������
            dec rcx         ; ��������� ���������� ������
            jnz restNumCheck1
        
        next1:
            xor rax, rax    ; ������� �������� RAX
            xor r13, r13    ; ������� �������� R13
            xor r14, r14    ; ������� �������� R14
            mov rcx, rbx    ; ������ �������� RBX � RCX

            sub rcx,1       ; ��������� ���������� RCX
            mov rax, 1
            cmp rcx, 0
            ja MultT1
            jmp getNum1
    
        MultT1:
            mul ten
            dec rcx
            jnz MultT1

        getNum1:
            mov r15, rax
            lea r10, buf1    
            mov rcx, rbx
            xor r12, r12    ; ������� �������� R12

        getOneNum1:
            mov r13, [r10]
            mov r14b, r13b
            mov rsi, 48
            xor rdi, rdi    ; ������� �������� RDI
            xor r11, r11    ; ������� �������� R11
            
        toBin1:
            cmp rsi, r14
            je Ivander1
            inc rsi
            inc r11
            jmp toBin1
            
        Ivander1:    
            mov rax, r11    ; ����������� ������ �� R11 � RAX  
            mul r15
            add r12, rax
            mov rax, r15    ; ����������� ������ �� R15 � RAX
            div ten
            mov r15, rax    ; ����������� ������ �� RAX � R15
            add r10,1       ; ��������� R10
            dec rcx         ; ��������� RCX
            jnz getOneNum1

            xor r15, r15    ; ������� �������� R15
            add r15, rbx    ; �������� ��������� R15 � RBX
            xor rbx, rbx    ; ������� �������� RBX

            xor rax, rax    ; ������� �������� RAX
            xor r10, r10    ; ������� �������� R10
            xor r11, r11    ; ������� �������� R11
            xor r13, r13    ; ������� �������� R13
            xor r14, r14    ; ������� �������� R14

            lea rax, buf2   ; ��������� ��������� � ������ ������ � �������
            mov rcx, size_of_buffer ; ��������� ���������� �������� �����

        cycle1: 
            inc r10         ; ��������� R10
            add rax, 1
            dec rcx         ; ��������� RCX
       
            mov rsi, [rax]  ; ��������� ������� �� ������ � �������
            cmp rsi, 0      ; ���� ������ - ����
            je _work1
            jnz cycle1

        _work1:
            lea rsi, buf2
            lea rdi, arr1
            mov rcx, r10

        decyphering:
            mov rax, [rsi]
            mov bl, al
            sub rbx, r12

            mov [rdi], rbx
            add rsi, 1
            add rdi, 1
            dec rcx         ; ���������� ���������� ������
            jnz decyphering

        _print1:        ; ����� ������ �� �����
            invoke wsprintf, ADDR txtBuf, ADDR txtE, addr arr1      ; �������������� ������ � ������
            invoke MsgboxI,hWin,ptr$(txtBuf),"����������",MB_OK,10  ; ����� ������ � �����������
            jmp _end1   ; ������� � ����� ���������

        _Wrong1:        ; ���� ���� ������� ������������ ������
            invoke MsgboxI,hWin,ptr$(txt3),"�������",MB_OK,10   ; ����� ���� � �������
            
        _end1:          ; ����� ���������

        .case 10002     ; ���� ������ ����� ���������� �� ������
            .data
                szFileName db "vizitkaKursovaya.exe",0   ; �������� �������
            .code
                invoke WinExec,addr szFileName,SW_SHOW  ; ����� ������������ � ������� ����������

        .case 10003     ; ���� ������ ����� �� ���������
            rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0                     ; �������� ����
        .endsw
        
        .case WM_CLOSE  ; ���� ������� �������� ����
            invoke EndDialog,hWin,0 ; exit from system menu
    .endsw
    
xor rax, rax
ret
main endp
end
