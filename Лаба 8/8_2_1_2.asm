include \masm64\include64\masm64rt.inc  ; подключение библиотеки

.data
    check_mutex_name db "Prog2",0
    str1 db "Процесс запущен",0
    error1 db "Процесс УЖЕ запущен",0
    title1 db "Программа 2",0   ; заголовок окна
    
.code
entry_point proc
    invoke CreateMutex,0,0,check_mutex_name    ; Создать мьютекс
    invoke GetLastError             ; проверка кода ошибки
    cmp eax,ERROR_ALREADY_EXISTS    ; проверка на наличие такого же мьютекса
    je @ExitProcess                        ; если мьютекс уже есть
    invoke MessageBoxTimeout,0,ADDR str1,ADDR title1,MB_OK,0,10000
    jmp _end

@ExitProcess:
    invoke MessageBox,0,ADDR error1,NULL,MB_OK ; сообщение об ошибке
    
_end:
    invoke ExitProcess,0    ; завершение процесса

entry_point endp
end