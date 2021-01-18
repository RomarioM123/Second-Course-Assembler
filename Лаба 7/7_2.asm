include \masm64\include64\masm64rt.inc

.data
    hInstance dq ? ; дескриптор програми
    hWnd      dq ? ; дескриптор окна
    hIcon     dq ? ; дескриптор иконки
    hCursor   dq ? ; дескриптор курсора
    sWid      dq ? ; ширина монитора (колич. пикселей по x)
    sHgt      dq ? ; высота монитора (колич. пикселей по y)

    wid       dq ?
    hgt       dq ?
    lft       dq ? ; лок. переменные содержатся в стеке 
    top       dq ? ; и существуют только во время вып. проц. 

    classname db "template_class",0
    caption db "Лабораторная работа 7-2",0
    AppName db "Щелчок правой кнопкой в неклиентской области окна приводит к его перемещению в цикле в горизонтальном направлении влево и вправо до тех пор, пока не будет нажата определенная клавиша",0

.code
entry_point proc
    mov hInstance,rv(GetModuleHandle,0)       ; получение и сохранение дескрипторa програми
    mov hIcon,  rv(LoadIcon,hInstance,10)     ; загрузка и сохранение дескрипторa иконки
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)    ; загрузка курсора и сохранение
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN) ; получение кол. пикселей по х монитора
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN) ; получение кол. пикселей по y монитора
    call main
    invoke ExitProcess,0
    ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX               ; объявление локальных переменных
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; колич. байтов структуры
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; стиль окна
    mov wc.lpfnWndProc,ptr$(WndProc)    ; адрес процедуры WndProc
    mov wc.cbClsExtra,0                 ; количество байтов для структуры класса
    mov wc.cbWndExtra,0                 ; количество байтов для структуры окна
    mrm wc.hInstance,hInstance          ; заполнение полЯ дескриптора в структуре
    mrm wc.hIcon,  hIcon                ; хэндл иконки
    mrm wc.hCursor,hCursor              ; хэндл курсора
    mrm wc.hbrBackground,0              ; цвет окна
    mov wc.lpszMenuName,0               ; заполнение поля в структуре с именем ресурса меню
    mov wc.lpszClassName,ptr$(classname); имя класса
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; регистрация класса окна
    mov wid, 500                        ; ширина пользовательского окна в пикселях
    mov hgt, 320                        ; высота пользовательского окна в пикселях
    mov rax,sWid                        ; колич. пикселей монитора по x
    sub rax,wid                         ; дельта • = •(монитора) - х(окна пользователя)
    shr rax,1                           ; получение середины •
    mov lft,rax 

    mov rax, sHgt                       ; колич. пикселей монитора по y
    sub rax, hgt ;
    shr rax, 1 ;
    mov top, rax ;
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
        ADDR classname,ADDR caption, \
        WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
        lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax ; сохранение дескриптора окна
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg  :MSG
    LOCAL pmsg :QWORD
    mov pmsg,ptr$(msg)                  ; получение адреса структуры сообщениЯ
    jmp gmsg                            ; jump directly to GetMessage()
  mloop:
    invoke TranslateMessage,pmsg
    invoke DispatchMessage,pmsg         ; отправка на обслуживание к WndProc
  gmsg:
    test rax, rv(GetMessage,pmsg,0,0,0) ; пока GetMessage не вернет ноль
    jnz mloop
    ret
msgloop endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
LOCAL hdc:HDC                           ; резервирование стека для дескриптора окна
LOCAL ps:PAINTSTRUCT                    ; для структуры PAINTSTRUCT
LOCAL rect:RECT                         ; для структуры координат RECT

.switch uMsg
    .case WM_DESTROY ; если есть сообщение про уничтожение окна
        invoke PostQuitMessage,NULL

    .case WM_NCRBUTTONDOWN          ; сообщение от правой части в неклиентской области
        m1:
            invoke Sleep, 1
        .case WM_CHAR               ; задержка
            push wParam
            cmp wParam,97
            jae Move
            jmp _end
            jmp m1
            
        Move:
            add lft, 20
            invoke MoveWindow,hWin,lft,top,wid,hgt,TRUE

            _end:
            
    .endsw
    
invoke DefWindowProc,hWin,uMsg,wParam,lParam
ret
WndProc endp
end
