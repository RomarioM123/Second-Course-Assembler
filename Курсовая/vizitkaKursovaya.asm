include \masm64\include64\masm64rt.inc
    
IDI_ICON EQU 1001

.data?
    hInstance dq ? ; дескриптор програми
    hWnd      dq ? ; дескриптор окна
    hIcon     dq ? ; дескриптор иконки
    hCursor   dq ? ; дескриптор курсора
    sWid      dq ? ; ширина монитора (колич. пикселей по x)
    sHgt      dq ? ; высота монитора (колич. пикселей по y)
    hImage    dq ?
    hStatic   dq ?
   
.data
    spt1 RECT <62,3,354,70>     ; координати рамки 1 
    spt2 RECT <60,5,352,68>     ; координати рамки 2
      
    classname db "template_class",0
    caption db "                                                 ВИЗИТКА",0
    
    txt1 db "         Момот Роман ",0  
    txt2 db "               КІТ-119а ",0
    txt3 db "   Курсовая работа",0
    txt4 db "Написать программу шифрования",0
    txt5 db "  текста сообщения методом",0
    txt6 db "открытого ключа.",0
 
    hPen1 dd 0
    hRgn1 dd ?
    hRgn2 dd ?
 
.code
    entry_point proc
        GdiPlusBegin    ; initialise GDIPlus
            mov hInstance,rv(GetModuleHandle,0)          ; получение и сохранение дескрипторa програми
            mov hIcon, rv(LoadIcon,hInstance,10)         ; загрузка и сохранение дескрипторa иконки
            mov hCursor, rv(LoadCursor,0,IDC_ARROW)      ; загрузка курсора и сохранение
            mov sWid, rv(GetSystemMetrics,SM_CXSCREEN)   ; получение кол. пикселей по х монитора 
            mov sHgt, rv(GetSystemMetrics,SM_CYSCREEN)   ; получение кол. пикселей по y монитора
            mov hImage, rv(ResImageLoad,20)              ; макрос загрузки Bitmap
            call main
        GdiPlusEnd      ; GdiPlus cleanup
        invoke ExitProcess,0
ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX   ; объявление локальных переменных
    LOCAL lft :QWORD        ;  Лок. переменные содержатся в стеке 
    LOCAL top :QWORD        ; и существуют только во время вып. проц.
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
    mrm wc.hbrBackground,0              ; hBrush цвет окна
 
    mov wc.lpszClassName,ptr$(classname)    ; имя класса
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc          ; регистрация класса окна
    mov wid,415   ; ширина пользовательского окна в пикселях
    mov hgt,305   ; высота пользовательского окна в пикселях
    mov rax,sWid  ; колич. пикселей монитора по x
    sub rax,wid   ; дельта Х = Х(монитора) - х(окна пользователя)
    shr rax,1     ; получение середины Х
    mov lft,rax   ;

    mov rax, sHgt ; колич. пикселей монитора по y
    sub rax, hgt
    shr rax, 1
    mov top, rax
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
        ADDR classname,ADDR caption, \
        WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
        lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax ; сохранение дескриптора окна
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg :MSG
    LOCAL pmsg :QWORD
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

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
    LOCAL hdc:HDC           ; контекст
    LOCAL ps:PAINTSTRUCT    ; структура для малювання
    LOCAL rect:RECT         ; структура координат
    invoke RegisterHotKey,hWin,1,0,31h
.switch uMsg
    .case WM_PAINT
        @wmpaind:
            invoke GetDC,hWnd  ; отримати контекст за дескриптором
            mov hdc,rax        ; зберегти 
            invoke DrawIcon,hdc,180,90,hIcon
            invoke DrawEdge,hdc,ADDR spt1,EDGE_SUNKEN,BF_RECT   ; рисування рамки spt1
            invoke DrawEdge,hdc,ADDR spt2,EDGE_SUNKEN,BF_RECT   ; рисування рамки spt2
            invoke BeginPaint,hWnd, ADDR ps         ; початок рисування
            mov hdc,rax 
            invoke GetClientRect,hWnd, ADDR rect    ; витягує координати робочої області вікна
            invoke SelectObject,hdc,hPen1           ; вибір пера 
            invoke SetBkMode,hdc,0h                 ; встановити фон тексту
            invoke SetTextColor,hdc,0ff0000h        ; встановлення кольору тексту

            invoke TextOut,hdc,120,15,addr txt1,22  ; виведення тексту
            invoke TextOut,hdc,110,28,addr txt2,25  ; виведення тексту
            invoke TextOut,hdc,130,41,addr txt3,19  ; виведення тексту
            invoke TextOut,hdc,80,140,addr txt4,31
            invoke TextOut,hdc,100,160,addr txt5,27
            invoke TextOut,hdc,140,180,addr txt6,30
            invoke EndPaint,hWnd, ADDR ps           ; завершення рисування

    .case WM_LBUTTONDOWN
       invoke SendMessage,hWin,WM_DESTROY,0,0

    .case WM_CREATE
        invoke CreateEllipticRgn,60, 0 ,\ ; верхній лівий кут прямокутника
            350, 400  ; правий нижній кут прямокутника
        ; прикріплення регіону до вікна
        mov hWnd ,rax
 
        invoke SetWindowRgn, hWin,\ ; дескриптор вікна,яке буде змінюватися 
            eax,\ ; дескриптор регіону
            1 ; перерисування  
 
        mov hStatic,rax
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hImage; сообщение окну

        invoke LoadMenu,hInstance,100 ; загружает меню из exe-файла
        invoke SetMenu,hWin,rax ; связывает меню с окном
    
        mov hStatic,rax
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hImage; сообщение окну

    .case WM_CLOSE ;
        invoke SendMessage,hWin,WM_DESTROY,0,0
        
    .case WM_DESTROY ; 
        invoke PostQuitMessage,NULL
.endsw
    invoke DefWindowProc,hWin,uMsg,wParam,lParam
ret
WndProc endp
end