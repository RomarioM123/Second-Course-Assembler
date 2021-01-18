include \masm64\include64\masm64rt.inc

Computer STRUCT
    serialNum1 dq ?
    price1 dq ?    
    name1 dd ?
    ownerSurname1 dd ?
    size1 dq ?    
Computer ENDS

.data
hInstance dq ?  ; дескриптор програми
hWnd      dq ?  ; дескриптор окна
hIcon     dq ?  ; дескриптор иконки
hCursor   dq ?  ; дескриптор курсора
sWid      dq ?  ; ширина монитора (колич. пикселей по x)
sHgt      dq ?  ; высота монитора (колич. пикселей по y) 
classname db "template_class",0
caption db "Лабораторная работа 4-1-2. Структуры",0

.code
entry_point proc
    mov hInstance,rv(GetModuleHandle,0)         ; получение и сохранение дескрипторa програми
    mov hIcon,  rv(LoadIcon,hInstance,10)       ; загрузка и сохранение дескрипторa иконки
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)      ; загрузка курсора и сохранение
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN)   ; получение кол. пикселей по х монитора 
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN)   ; получение кол. пикселей по y монитора
    call main                                   ; вызов процедуры main
    invoke ExitProcess,0
    ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX               ; объявление локальных переменных
    LOCAL lft :QWORD                    ;  Лок. переменные содержатся в стеке 
    LOCAL top :QWORD                    ; и существуют только во время вып. проц.
    LOCAL wid :QWORD
    LOCAL hgt :QWORD
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; колич. байтов структуры
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; стиль окна
    mov wc.lpfnWndProc,ptr$(WndProc)    ; адрес процедуры WndProc
    mov wc.cbClsExtra,0                 ; количество байтов для структуры класса
    mov wc.cbWndExtra,0                 ; количество байтов для структуры окна
    mrm wc.hInstance,hInstance          ; заполнение поля дескриптора в структуре
    mrm wc.hIcon,  hIcon                ; хэндл иконки
    mrm wc.hCursor,hCursor              ; хэндл курсора
    mrm wc.hbrBackground,0              ; цвет окна
    mov wc.lpszMenuName,0               ; заполнение поля в структуре с именем ресурса меню
    mov wc.lpszClassName,ptr$(classname); имя класса
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; регистрация класса окна
    mov wid, 900                        ; ширина пользовательского окна в пикселях
    mov hgt, 300                        ; высота пользовательского окна в пикселях
    mov rax,sWid                        ; колич. пикселей монитора по x
    sub rax,wid                         ; дельта Х = Х(монитора) - х(окна пользователя)
    shr rax,1                           ; получение середины Х
    mov lft,rax                         ;

    mov rax, sHgt       ; колич. пикселей монитора по y
    sub rax, hgt ;
    shr rax, 1 ;
    mov top, rax ;
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
    ADDR classname,ADDR caption, \
    WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
    lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax        ; сохранение дескриптора окна
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg    :MSG
    LOCAL pmsg   :QWORD
    mov pmsg, ptr$(msg) ; получение адреса структуры сообщения
    jmp gmsg            ; jump directly to GetMessage()
    mloop:
    invoke TranslateMessage,pmsg
    invoke DispatchMessage,pmsg
    
    gmsg:
    test rax, rv(GetMessage,pmsg,0,0,0) ; пока GetMessage не вернет ноль
    jnz mloop
    ret
msgloop endp

.data		; секция переменных
    task db "Задана последовательность структур. Структура содержит поля данные о компьютере: серийный номер, цена, название,",0
    task1 db "фамилия владельца, размер монитора в дюймах. Вычислить среднюю цену компьютера.",0

    inf db "  Название           Цена",0    ; информация о структурах
    inf1 db "Компьютер 1           2",0
    inf2 db "Компьютер 2           4",0
    inf3 db "Компьютер 3           3",0

    buf dq 30 dup(?),0      ; буффер для вывода
    buf1 db 80 dup(?),0     ; буффер для вывода
    buf2 db 80 dup(?),0     ; буффер для вывода
    buf3 db 80 dup(?),0     ; буффер для вывода
    buf4 db 80 dup(?),0     ; буффер для вывода
    buf5 db 200 dup(?),0    ; буффер для вывода
    buf6 db 150 dup(?),0    ; буффер для вывода
    ifmt db "Средняя цена компьютеров: %d",0

    PC1 Computer <1,2,"Best PC","Momot",5>    
    PC2 Computer <5,7,"123","Efremov",4>
    PC3 Computer <3,3,"142","Ivanov",1>

    num1 dq 3 	; переменная константа
    res1 dq ? 	; переменная результата

.code                   ; секция кода
    WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
    LOCAL hdc:HDC                   ; резервирование стека для дескриптора окна
    LOCAL ps:PAINTSTRUCT            ; для структуры PAINTSTRUCT
    LOCAL rect:RECT                 ; для структуры координат RECT
    LOCAL leng:QWORD
    .switch uMsg
    .case WM_DESTROY
    invoke PostQuitMessage,NULL
    .case WM_PAINT                  ; если есть смс о перерисовании
    invoke BeginPaint,hWnd, ADDR ps ; вызов подготовительной процедуры
    mov hdc,rax                     ; сохранение контекста

    xor rax,rax         ; очистка регистра RAX
    mov rax,PC1.price1  ; запись суммы первого ПК
    add rax,PC2.price1  ; прибавление цены второго ПК
    add rax,PC3.price1  ; прибавление цены третьего ПК
    xor rdx,rdx         ; очистка регистра RDX
    div num1            ; /3
    mov res1,rax        ; запись результата в переменную результата
	
    invoke wsprintf,ADDR buf5,ADDR task         ; преобразование данных в текст
    invoke wsprintf,ADDR buf6,ADDR task1        ; преобразование данных в текст
    invoke wsprintf,ADDR buf,ADDR ifmt,res1   	; преобразование данных в текст
    invoke wsprintf,ADDR buf1,ADDR inf          ; преобразование данных в текст
    invoke wsprintf,ADDR buf2,ADDR inf1         ; преобразование данных в текст
    invoke wsprintf,ADDR buf3,ADDR inf2         ; преобразование данных в текст
    invoke wsprintf,ADDR buf4,ADDR inf3         ; преобразование данных в текст

    invoke TextOut,hdc,20,0,addr buf5,112       ; вывод текста в окно
    invoke TextOut,hdc,20,20,addr buf6,140      ; вывод текста в окно
    invoke TextOut,hdc,20,60,addr buf1,30       ; вывод текста в окно
    invoke TextOut,hdc,20,80,addr buf2,30       ; вывод текста в окно
    invoke TextOut,hdc,20,100,addr buf3,30      ; вывод текста в окно
    invoke TextOut,hdc,20,120,addr buf4,30      ; вывод текста в окно
    invoke TextOut,hdc,20,160,addr buf,60       ; вывод текста в окно
    invoke TextOut,hdc,20,200,chr$("Автор: Момот Роман, КИТ-119а"),28   ; выводим текст в окно
    invoke EndPaint, hWnd, ADDR ps
    .endsw                                      ; иначе обработка по умолчанию
    invoke DefWindowProc,hWin,uMsg,wParam,lParam

ret
WndProc endp
end