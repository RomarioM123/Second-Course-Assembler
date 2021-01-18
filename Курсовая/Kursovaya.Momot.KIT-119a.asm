include \masm64\include64\mylibrary.inc  ; подключение своей библиотеки

.data?
    hInstance dq ?
    hIcon     dq ?
    hBmp      dq ?
    hStatic   dq ?

.data 
    fName db "Momot.KIT-119A.txt",0                             ; название файла для вывода
    fName2 db "notepad Momot.KIT-119A.txt",0                    ; BYTE -> db
    fHandle dq ?                                                ; дескриптор файла
    cWritten dq ?                                               ; ячейки для адреса символов вывода
    fmt1 db "Зашифрованный текст: %s | Внутренний ключ - %d",0  ; текст для вывода в файл
    
    intKeyVar db 2
    txtBuf db 100 dup(0),0
    size_of_buffer equ 45	; максимальное количество символов для текста
    size_of_key equ 10		; максимальное количество символов для ключа

    arr1 db 50 dup(0),0
    buf1 db 50 dup(0),0		; буфер для ключа
    txt1 db "%s",0
    txt2 db "%d %d",0

    inf1 db "Шифрование успешно",0      ; уведомление об успешном шифровании
    titl1 db "Сообщение о завершении",0 ; название окна с уведомлением

    txtE db "%s",0                      ; формат вывода зашифрованного текста в файл
    txtD db "Внешний ключ :  %d",0      ; формат вывода ключа в файл
   
.code                           ; секция кода
entry_point proc
    GdiPlusBegin                ; инициализация GDIPlus
        mov hInstance, rv(GetModuleHandle,0)
        mov hIcon,rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)
        mov hBmp,rv(ResImageLoad,20)
        invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon
    GdiPlusEnd                  ; GdiPlus очистка
        invoke ExitProcess,0    ; выход из программы
    ret
entry_point endp

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
.switch uMsg
    .case WM_INITDIALOG ; создание диалогового окна
        invoke SendMessage,hWin,WM_SETICON,1,lParam
        mov hStatic, rv(GetDlgItem,hWin,102)
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hBmp
        
    .case WM_LBUTTONDOWN    ; обработка нажатия левой кнопки мыши
        invoke SendMessage,hWin,WM_NCLBUTTONDOWN, HTCAPTION,0   ; перемещение окна
        
.case WM_COMMAND    ; обработка команд
    .switch wParam
        .case 101   ; если выбрана зашифровка текста
        .data       ; секция данных
            txt3 db "Error",0   ; текст с текстом ошибки
            ten db 10
            buf2 db 50 dup(0),0 ; буфер для хранения текста
            
        .code
            invoke GetDlgItemText,hWin,104,addr buf2,size_of_buffer ; получение текста для шифрования
            invoke GetDlgItemText,hWin,108,addr buf1,size_of_key    ; получение ключа для шифрования
        
            xor rbx, rbx            ; очистка регистра RBX
            lea rax, buf1           ; установка указателя в начало буфера с ключом
            mov rcx, size_of_key    ; запись в RCX длину ключа
           
        keyLen:             ; цикл определения длинны ключа
            inc rbx         ; инкремент регистра RBX
            add rax,1       ; инкремент регистра RAX
            dec rcx         ; декремент регистра RCX

            mov rsi, [rax]  ; перемещение элемента из буфера в регистр RSI
            cmp rsi, 0      ; если достигнут конец ключа
            je firstNumCheck
            jnz keyLen      ; переход в начало цикла

        firstNumCheck:		; цикл определения правильности введенного ключа 1
            xor rax, rax    ; очистка регистра RAX
            mov rcx, rbx    ; rbx - счётчик
            lea rax, buf1   ; установка указателя в начало буфера с ключом
            mov r13, [rax]  ; получение элемента буфера в регистр R13
            mov r14b, r13b
            cmp r14, 49     ; проверка символа ключа
            jb _Wrong       ; если 1 символ неправильный
            cmp r14, 57     ; проверка символа ключа
            ;ja _Wrong

            dec rcx         ; декремент количества переменных
            jz next         ; переход на следующий этап
            add rax, 1      ; перемещение на следующий символ буфера

        restNumCheck:		; цикл определения правильности введенного ключа 2
            xor r13, r13    ; очистка регистра R13
            xor r14, r14    ; очистка регистра R14
            mov r13, [rax]  ; получение символа из буфера ключа
            mov r14b, r13b
            cmp r14, 47     ; проверка на правильность ключа
            ja restNumCheck2
            jmp _Wrong      ; если символ неверный

        restNumCheck2:		; цикл определения правильности введенного ключа 3
            cmp r14, 58     ; проверка символа
            jae _Wrong      ; если символ неправильный
            add rax, 1      ; переход на следующий символ
            dec rcx         ; декремент количества циклов
            jnz restNumCheck
        
        next:
            xor rax, rax    ; очистка регистра RAX
            xor r13, r13    ; очистка регистра R13
            xor r14, r14    ; очистка регистра R14
            mov rcx, rbx    ; запись значения RBX в RCX

            sub rcx,1       ; декремент переменной RCX
            mov rax, 1
            cmp rcx, 0
            ja MultT
            jmp getNum
    
        MultT:		; преобразование ключа из текста в целочисленный тип
            mul ten
            dec rcx
            jnz MultT

        getNum:		; преобразование ключа из текста в целочисленный тип 2
            mov r15, rax
            lea r10, buf1    
            mov rcx, rbx
            xor r12, r12    ; очистка регистра R12

        getOneNum:	; преобразование ключа из текста в целочисленный тип 3
            mov r13, [r10]
            mov r14b, r13b
            mov rsi, 48
            xor rdi, rdi    ; очистка регистра RDI
            xor r11, r11    ; очистка регистра R11

        toBin:		; преобразование ключа из текста в целочисленный тип 4
            cmp rsi, r14
            je Ivander
            inc rsi         ; инкремент RSI
            inc r11         ; инкремент R11
            jmp toBin

        Ivander:    ; преобразование ключа из текста в целочисленный тип 5
            mov rax, r11    ; перемещение данных из R11 в RAX  
            mul r15
            add r12, rax
            mov rax, r15    ; перемещение данных из R15 в RAX
            div ten
            mov r15, rax    ; перемещение данных из RAX в R15
            add r10,1       ; инкремент R10
            dec rcx         ; декремент RCX
            jnz getOneNum

            xor r15, r15    ; очистка регистра R15
            add r15, rbx
            xor rbx, rbx    ; очистка регистра RBX

            xor rax, rax    ; очистка регистра RAX
            mov rax, r12
            mul intKeyVar
            mov r12, rax

            xor rax, rax    ; очистка регистра RAX
            xor r10, r10    ; очистка регистра R10
            xor r11, r11    ; очистка регистра R11
            xor r13, r13    ; очистка регистра R13
            xor r14, r14    ; очистка регистра R14

            lea rax, buf2           ; установка указателя в начало буфера с текстом
            mov rcx, size_of_buffer ; установка количества итераций цикла

        cycle: 		
            inc r10         ; инкремент R10
            add rax, 1
            dec rcx         ; декремент RCX
       
            mov rsi, [rax]  ; получение символа из буфера с текстом
            cmp rsi, 0      ; если символ - ноль
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

        _print:                                 ; вывод результата работы программы
            add r15, r10
            add r15, 50

            lea rsi, txtBuf                     ; переписывание адреса для последующего обращения
            invoke wsprintf, ADDR txtBuf, ADDR fmt1, addr arr1, r12     ; преобразование res1

            xor rax,rax                         ; очистка регистра RAX
            invoke CreateFile,ADDR fName,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0
            mov fHandle,rax                     ; сохранение дескриптора файла
            invoke WriteFile,fHandle,ADDR txtBuf,r15,ADDR cWritten,0    ; чтение файла
            invoke CloseHandle,fHandle          ; закрыть дескриптор файла (обязательно) 
    
            invoke MessageBoxTimeout,0,addr inf1,addr titl1,MB_OK,0,1500
            invoke WinExec,addr fName2,SW_SHOW  ; открытие файла с результатом
            jmp _end    ; переход в конец программы

        _Wrong:         ; если данные неправильные
            invoke MsgboxI,hWin,ptr$(txt3),"Неверно",MB_OK,10   ; вывод уведомления об ошибке

        _end:       
            ;invoke wsprintf,ADDR txtBuf,ADDR txt2, rdi, r12
            ;invoke MessageBox,0,ADDR txtBuf,ADDR titl1,MB_ICONINFORMATION

        .case 105   ; если выбрана дешифровка текста
            invoke GetDlgItemText,hWin,104,addr buf2,size_of_buffer     ; получение текста
            invoke GetDlgItemText,hWin,108,addr buf1,size_of_key        ; получение ключа
        
            xor rbx, rbx            ; очистка регистра RBX
            lea rax, buf1           ; установка указателя в начало буфера с ключом
            mov rcx, size_of_key    ; запись в RCX длину ключа
           
        keyLen1:            ; цикл определения длинны ключа
            inc rbx         ; инкремент регистра RBX
            add rax,1       ; инкремент регистра RAX
            dec rcx         ; декремент регистра RCX

            mov rsi, [rax]  ; перемещение элемента из буфера в регистр RSI
            cmp rsi, 0      ; если достигнут конец ключа
            je firstNumCheck1
            jnz keyLen1     ; переход в начало цикла

        firstNumCheck1:
            xor rax, rax    ; очистка регистра RAX
            mov rcx, rbx    ; rbx - счётчик
            lea rax, buf1   ; установка указателя в начало буфера с ключом
            mov r13, [rax]  ; получение элемента буфера в регистр R13
            mov r14b, r13b
            cmp r14, 49     ; проверка символа ключа
            jb _Wrong1      ; если 1 символ неправильный
            cmp r14, 57     ; проверка символа ключа
            ;ja _Wrong1

            dec rcx         ; декремент количества переменных
            jz next1        ; переход на следующий этап
            add rax, 1      ; перемещение на следующий символ буфера ключа

        restNumCheck1:
            xor r13, r13    ; очистка регистра R13
            xor r14, r14    ; очистка регистра R14
            mov r13, [rax]  ; получение символа из буфера ключа
            mov r14b, r13b
            cmp r14, 47     ; проверка на правильность ключа
            ja restNumCheck21
            jmp _Wrong1     ; если символ неверный

        restNumCheck21:
            cmp r14, 58     ; проверка символа
            jae _Wrong1     ; если символ неправильный
            add rax, 1      ; переход на следующий символ
            dec rcx         ; декремент количества циклов
            jnz restNumCheck1
        
        next1:
            xor rax, rax    ; очистка регистра RAX
            xor r13, r13    ; очистка регистра R13
            xor r14, r14    ; очистка регистра R14
            mov rcx, rbx    ; запись значения RBX в RCX

            sub rcx,1       ; декремент переменной RCX
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
            xor r12, r12    ; очистка регистра R12

        getOneNum1:
            mov r13, [r10]
            mov r14b, r13b
            mov rsi, 48
            xor rdi, rdi    ; очистка регистра RDI
            xor r11, r11    ; очистка регистра R11
            
        toBin1:
            cmp rsi, r14
            je Ivander1
            inc rsi
            inc r11
            jmp toBin1
            
        Ivander1:    
            mov rax, r11    ; перемещение данных из R11 в RAX  
            mul r15
            add r12, rax
            mov rax, r15    ; перемещение данных из R15 в RAX
            div ten
            mov r15, rax    ; перемещение данных из RAX в R15
            add r10,1       ; инкремент R10
            dec rcx         ; декремент RCX
            jnz getOneNum1

            xor r15, r15    ; очистка регистра R15
            add r15, rbx    ; сложение регистров R15 и RBX
            xor rbx, rbx    ; очистка регистра RBX

            xor rax, rax    ; очистка регистра RAX
            xor r10, r10    ; очистка регистра R10
            xor r11, r11    ; очистка регистра R11
            xor r13, r13    ; очистка регистра R13
            xor r14, r14    ; очистка регистра R14

            lea rax, buf2   ; установка указателя в начало буфера с текстом
            mov rcx, size_of_buffer ; установка количества итераций цикла

        cycle1: 
            inc r10         ; инкремент R10
            add rax, 1
            dec rcx         ; декремент RCX
       
            mov rsi, [rax]  ; получение символа из буфера с текстом
            cmp rsi, 0      ; если символ - ноль
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
            dec rcx         ; уменьшение количества циклов
            jnz decyphering

        _print1:        ; вывод данных на экран
            invoke wsprintf, ADDR txtBuf, ADDR txtE, addr arr1      ; преобразование данных в строку
            invoke MsgboxI,hWin,ptr$(txtBuf),"Дешифровка",MB_OK,10  ; вывод строки с результатом
            jmp _end1   ; переход в конец программы

        _Wrong1:        ; если были введены неправильные данные
            invoke MsgboxI,hWin,ptr$(txt3),"Неверно",MB_OK,10   ; вывод окна с ошибкой
            
        _end1:          ; конец программы

        .case 10002     ; если выбран вывод информации об авторе
            .data
                szFileName db "vizitkaKursovaya.exe",0   ; название визитки
            .code
                invoke WinExec,addr szFileName,SW_SHOW  ; вызов подпрограммы с выводом информации

        .case 10003     ; если выбран выход из программы
            rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0                     ; закрытие окна
        .endsw
        
        .case WM_CLOSE  ; если выбрано закрытие окна
            invoke EndDialog,hWin,0 ; exit from system menu
    .endsw
    
xor rax, rax
ret
main endp
end
