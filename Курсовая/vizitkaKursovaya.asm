include \masm64\include64\masm64rt.inc
    
IDI_ICON EQU 1001

.data?
    hInstance dq ? ; ���������� ��������
    hWnd      dq ? ; ���������� ����
    hIcon     dq ? ; ���������� ������
    hCursor   dq ? ; ���������� �������
    sWid      dq ? ; ������ �������� (�����. �������� �� x)
    sHgt      dq ? ; ������ �������� (�����. �������� �� y)
    hImage    dq ?
    hStatic   dq ?
   
.data
    spt1 RECT <62,3,354,70>     ; ���������� ����� 1 
    spt2 RECT <60,5,352,68>     ; ���������� ����� 2
      
    classname db "template_class",0
    caption db "                                                 �������",0
    
    txt1 db "         ����� ����� ",0  
    txt2 db "               ʲ�-119� ",0
    txt3 db "   �������� ������",0
    txt4 db "�������� ��������� ����������",0
    txt5 db "  ������ ��������� �������",0
    txt6 db "��������� �����.",0
 
    hPen1 dd 0
    hRgn1 dd ?
    hRgn2 dd ?
 
.code
    entry_point proc
        GdiPlusBegin    ; initialise GDIPlus
            mov hInstance,rv(GetModuleHandle,0)          ; ��������� � ���������� ����������a ��������
            mov hIcon, rv(LoadIcon,hInstance,10)         ; �������� � ���������� ����������a ������
            mov hCursor, rv(LoadCursor,0,IDC_ARROW)      ; �������� ������� � ����������
            mov sWid, rv(GetSystemMetrics,SM_CXSCREEN)   ; ��������� ���. �������� �� � �������� 
            mov sHgt, rv(GetSystemMetrics,SM_CYSCREEN)   ; ��������� ���. �������� �� y ��������
            mov hImage, rv(ResImageLoad,20)              ; ������ �������� Bitmap
            call main
        GdiPlusEnd      ; GdiPlus cleanup
        invoke ExitProcess,0
ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX   ; ���������� ��������� ����������
    LOCAL lft :QWORD        ;  ���. ���������� ���������� � ����� 
    LOCAL top :QWORD        ; � ���������� ������ �� ����� ���. ����.
    LOCAL wid :QWORD
    LOCAL hgt :QWORD
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; �����. ������ ���������
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; ����� ����
    mov wc.lpfnWndProc,ptr$(WndProc)    ; ����� ��������� WndProc
    mov wc.cbClsExtra,0                 ; ���������� ������ ��� ��������� ������
    mov wc.cbWndExtra,0                 ; ���������� ������ ��� ��������� ����
    mrm wc.hInstance,hInstance          ; ���������� ���� ����������� � ���������
    mrm wc.hIcon,  hIcon                ; ����� ������
    mrm wc.hCursor,hCursor              ; ����� �������
    mrm wc.hbrBackground,0              ; hBrush ���� ����
 
    mov wc.lpszClassName,ptr$(classname)    ; ��� ������
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc          ; ����������� ������ ����
    mov wid,415   ; ������ ����������������� ���� � ��������
    mov hgt,305   ; ������ ����������������� ���� � ��������
    mov rax,sWid  ; �����. �������� �������� �� x
    sub rax,wid   ; ������ � = �(��������) - �(���� ������������)
    shr rax,1     ; ��������� �������� �
    mov lft,rax   ;

    mov rax, sHgt ; �����. �������� �������� �� y
    sub rax, hgt
    shr rax, 1
    mov top, rax
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
        ADDR classname,ADDR caption, \
        WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
        lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax ; ���������� ����������� ����
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg :MSG
    LOCAL pmsg :QWORD
    mov pmsg, ptr$(msg) ; ��������� ������ ��������� ���������
    jmp gmsg            ; jump directly to GetMessage()
    
mloop:
    invoke TranslateMessage,pmsg
    invoke DispatchMessage,pmsg
    
gmsg:
    test rax, rv(GetMessage,pmsg,0,0,0) ; ���� GetMessage �� ������ ����
    jnz mloop
    ret
msgloop endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
    LOCAL hdc:HDC           ; ��������
    LOCAL ps:PAINTSTRUCT    ; ��������� ��� ���������
    LOCAL rect:RECT         ; ��������� ���������
    invoke RegisterHotKey,hWin,1,0,31h
.switch uMsg
    .case WM_PAINT
        @wmpaind:
            invoke GetDC,hWnd  ; �������� �������� �� ������������
            mov hdc,rax        ; �������� 
            invoke DrawIcon,hdc,180,90,hIcon
            invoke DrawEdge,hdc,ADDR spt1,EDGE_SUNKEN,BF_RECT   ; ��������� ����� spt1
            invoke DrawEdge,hdc,ADDR spt2,EDGE_SUNKEN,BF_RECT   ; ��������� ����� spt2
            invoke BeginPaint,hWnd, ADDR ps         ; ������� ���������
            mov hdc,rax 
            invoke GetClientRect,hWnd, ADDR rect    ; ������ ���������� ������ ������ ����
            invoke SelectObject,hdc,hPen1           ; ���� ���� 
            invoke SetBkMode,hdc,0h                 ; ���������� ��� ������
            invoke SetTextColor,hdc,0ff0000h        ; ������������ ������� ������

            invoke TextOut,hdc,120,15,addr txt1,22  ; ��������� ������
            invoke TextOut,hdc,110,28,addr txt2,25  ; ��������� ������
            invoke TextOut,hdc,130,41,addr txt3,19  ; ��������� ������
            invoke TextOut,hdc,80,140,addr txt4,31
            invoke TextOut,hdc,100,160,addr txt5,27
            invoke TextOut,hdc,140,180,addr txt6,30
            invoke EndPaint,hWnd, ADDR ps           ; ���������� ���������

    .case WM_LBUTTONDOWN
       invoke SendMessage,hWin,WM_DESTROY,0,0

    .case WM_CREATE
        invoke CreateEllipticRgn,60, 0 ,\ ; ������ ���� ��� ������������
            350, 400  ; ������ ����� ��� ������������
        ; ����������� ������ �� ����
        mov hWnd ,rax
 
        invoke SetWindowRgn, hWin,\ ; ���������� ����,��� ���� ���������� 
            eax,\ ; ���������� ������
            1 ; �������������  
 
        mov hStatic,rax
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hImage; ��������� ����

        invoke LoadMenu,hInstance,100 ; ��������� ���� �� exe-�����
        invoke SetMenu,hWin,rax ; ��������� ���� � �����
    
        mov hStatic,rax
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hImage; ��������� ����

    .case WM_CLOSE ;
        invoke SendMessage,hWin,WM_DESTROY,0,0
        
    .case WM_DESTROY ; 
        invoke PostQuitMessage,NULL
.endsw
    invoke DefWindowProc,hWin,uMsg,wParam,lParam
ret
WndProc endp
end