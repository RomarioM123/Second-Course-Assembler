include \masm64\include64\masm64rt.inc

.data?
    hInstance dq ?
    hIcon     dq ?
    hBmp      dq ?
    hStatic   dq ?

.data
    processInfo22 PROCESS_INFORMATION <> ; ���. � �������� � ��� ��������� ����
    programQeditor db "C:\masm64\qeditor.exe",0
    program3 db "8_2_1_3.exe",0
    title1 db "������",0
    error1 db "qeditor.exe �� ����� ���� ������� ������ 3 ��� ������������",0
	
    startInfo1 dd ?
    h1 dq ?
    count dq 0

.code
proc1 proc
    cmp count,2
    je OutputInfo2
    invoke GetStartupInfo,ADDR startInfo1
    invoke CreateProcess,ADDR programQeditor,0,0,0,FALSE,\
        NORMAL_PRIORITY_CLASS, 0,0,ADDR startInfo1,ADDR processInfo22
    invoke CloseHandle,processInfo22.hThread
    inc count
    invoke Sleep,5000
    dec count

    invoke TerminateProcess, processInfo22.hProcess 

    jmp _end

OutputInfo2:
    invoke MessageBox,0,addr error1, addr title1, MB_ICONINFORMATION

_end:

proc1 endp

;===============================================

proc2 proc
    inc count 
    invoke WinExec,addr program3,SW_SHOW ; ����� ���������� �����
    dec count
    ret
proc2 endp

;===============================================

entry_point proc

    GdiPlusBegin        ; ������������� GDIPlus
        mov hInstance, rv(GetModuleHandle,0)
        mov hIcon,rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)
        mov hBmp,rv(ResImageLoad,20)
        invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon
    GdiPlusEnd          ; GdiPlus �������
    
    invoke ExitProcess,0
    ret
entry_point endp

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
.switch uMsg
    .case WM_INITDIALOG ; ��������� � �������� ����. ����
        invoke SendMessage,hWin,WM_SETICON,1,lParam
        mov hStatic, rv(GetDlgItem,hWin,102)
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hBmp
        .return TRUE
        
    .case WM_COMMAND    ; ��������� �� ���� ��� ������
        .switch wParam
            .case 1001                
                .data  
                    program1 db "8_2_1_1.exe",0
                                        
                .code
                    invoke WinExec,addr program1,SW_SHOW ; ����� ���������� �����

                        
            .case 1002
                .data
                    xor rax, rax
                    program2 db "8_2_1_2.exe",0
                    
                .code
                    invoke WinExec,addr program2,SW_SHOW ; ����� ���������� �����

            .case 1003
                .code
                    cmp count, 3
                    je OutputInfo

                    xor rax, rax
                    lea rax, proc2 ; �������� ������ ���������
                    invoke CreateThread,0,0,rax,0,0,h1 ; ������� �������
                    jmp _end2

                OutputInfo:
                    invoke MessageBox,0,addr error1, addr title1, MB_ICONINFORMATION

                _end2:

            ;.case 101   ; ���� ������ ����� ���������� � �������        
                ;lea rax, proc1 ; �������� ������ ���������
                ;invoke CreateThread,0,0,rax,0,0,h1 ; ������� �������
     
            .case 103   ; ����� ����������
                .data
                    szFileName db "vizitka8-2-1.exe",0   ; �������� ����� ��� ������ ����������
                    
                .code
                    invoke WinExec,addr szFileName,SW_SHOW  ; ����� ������������ � ������� ����������

            .case 104  ; ���������� ���������
                rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0 ; ����������� ����
                
            .endsw
                
        .case WM_CLOSE ; ���� ���� ��������� � �������� ����
        invoke EndDialog,hWin,0 ; 
.endsw
xor rax, rax
ret
main endp
end
