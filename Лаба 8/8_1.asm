include \masm64\include64\masm64rt.inc
.data?
    hInstance dq ?
    hIcon     dq ?
    hBmp      dq ?
    hStatic   dq ?

    hKey      dd ?
    lpdwDisp  dd ?

.data
    icce INITCOMMONCONTROLSEX <>
    szREGSZ db 'REG_SZ',0
    setValue db "10",0
    ValSize1 db 4,0
    buf1 LPDWORD 128,0
    getKol LPBYTE "9",0
    buf3 LPDWORD 128,0
    error dd ?,0
    res1 dq 0
    szFileName db "vizitka8-1.exe",0   ; �������� ����� ��� ������ ����������

    key1 db "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",0
    valueName1 db "DisableTaskMgr ",0

    key2 db "SYSTEM\CurrentControlSet\Servises\i8042prt\Parameters",0
    valueName2 db "CrashOnCtrlScroll ",0

    buf dq 12 dup(0),0

.code
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
            .case 101   ; ���� ������ ����� ���������� � �������
                .data
                    txt2 db "����������� �������� � �������� ������ ������� �� ������������ ������.",
                    10,10,"�����:","  HKLM\SYSTEM\ControlSet001\Services\W32Time\TimeProviders\NtpClient",
                    10,"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ DateTime\Servers",
                    10,"HKCU\Control Panel\International",
                    10,10,"�����: SpecialPollInterval, sTimeFormat.",0
                    titl2 db "���������� � �������",0
                .code
                    invoke MsgboxI,hWin,ADDR txt2,ADDR titl2,MB_OK,10
                
            .case 102   ; ���� ������ ����� ���������� �� ������
                invoke WinExec,addr szFileName,SW_SHOW  ; ����� ������������ � ������� ����������

            .case 103
                .data
                    msg db "����� �� ���������.",0                  ; ����� ����������� � ������
                .code
                    invoke MsgboxI,hWin,ptr$(msg),"�����",MB_OK,10
                    rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0 ; ����������� ����

            .case 1001  ; �������� ����� � �������
                .code
                    invoke RegCreateKeyEx,\ ; �������� �������
                    HKEY_CURRENT_USER,ADDR key1,0,ADDR szREGSZ,REG_OPTION_VOLATILE,KEY_ALL_ACCESS,0,ADDR hKey,ADDR lpdwDisp;
                    cmp rax,0 ; �������� ������ �� ������
                    jne m11

                    cmp lpdwDisp,REG_OPENED_EXISTING_KEY            ; ��������� ������ 
                    je m21

                    invoke RegSetValueEx,\                          ; �������� ����� � ����������� ������
                    hKey,addr valueName1,0,REG_SZ,addr setValue,1   ; ������ ����� � ������
                    cmp rax,0 ; �������� �������� �� ���� 
                    jne m11

                    invoke MessageBox,0,chr$("���� 1 ������"),chr$("�������� �����"),MB_ICONINFORMATION
                    jmp m31

                m21:
                    invoke RegQueryValueEx,\    ; �������� �����, ���������� � ����������� �����
                    hKey,addr valueName1,0,addr buf1,addr getKol,addr buf3 ;
                    cmp getKol,"0"
                    je part2
                    dec getKol
                    invoke RegSetValueEx,\
                    hKey,addr valueName1,0,REG_SZ,addr getKol,1 ; ������ ����� � ������

                m31: ; �������� �������
                    invoke RegCloseKey,hKey ; ������������� ��������� ����� ��� ��������
                    jmp part2
                    
                m11: ; ����� ��������� �� ������
                    invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,\
                    NULL,rax,NULL,addr error,100,NULL
                    invoke MessageBox,0,addr error,chr$("������"),\
                    MB_ICONINFORMATION
                    jmp _end
                    
;===========================================================

                part2:
                    invoke RegCreateKeyEx,\ ; �������� �������
                    HKEY_LOCAL_MACHINE,ADDR key2,0,ADDR szREGSZ,REG_OPTION_VOLATILE,KEY_ALL_ACCESS,0,ADDR hKey,ADDR lpdwDisp;
                    cmp rax,0 ; �������� ������ �� ������
                    jne m12

                    cmp lpdwDisp,REG_OPENED_EXISTING_KEY            ; ��������� ������ 
                    je m22

                    invoke RegSetValueEx,\                          ; �������� ����� � ����������� ������
                    hKey,addr valueName2,0,REG_SZ,addr setValue,1   ; ������ ����� � ������
                    cmp rax,0 ; �������� �������� �� ���� 
                    jne m12

                    invoke MessageBox,0,chr$("���� 2 ������"),chr$("�������� �����"),MB_ICONINFORMATION
                    jmp m32

                m22:
                    invoke RegQueryValueEx,\    ; �������� �����, ���������� � ����������� �����
                    hKey,addr valueName2,0,addr buf1,addr getKol,addr buf3 ;
                    cmp getKol,"0"
                    je _end
                    dec getKol
                    invoke RegSetValueEx,\
                    hKey,addr valueName2,0,REG_SZ,addr getKol,1 ; ������ ����� � ������

                m32: ; �������� �������
                    invoke RegCloseKey,hKey ; ������������� ��������� ����� ��� ��������
                    jmp _end
                    
                m12: ; ����� ��������� �� ������
                    invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,\
                    NULL,rax,NULL,addr error,100,NULL
                    invoke MessageBox,0,addr error,chr$("������"),\
                    MB_ICONINFORMATION
                    
                _end:

                    
            .case 1003  ; �������� ����� �������
                    invoke RegDeleteKey,HKEY_LOCAL_MACHINE,chr$("SYSTEM\ControlSet001\Services\W32Time\TimeProviders\NtpClient2")
                    .if eax == ERROR_SUCCESS ;  ���� ������ ������� ?
                        invoke RegCloseKey,addr hKey ;�������� ����������� ����� � ��������� �������
                        invoke MessageBox,0,chr$("���� 1 ������� �����"),chr$("������"),MB_ICONINFORMATION
                    .else
                        invoke MessageBox,0,chr$("���� 1 �� �����"),chr$("������"),MB_ICONINFORMATION
                    .endif
                    
                    invoke RegDeleteKey,HKEY_LOCAL_MACHINE,chr$("SOFTWARE\Microsoft\Windows\CurrentVersion\ DateTime\Servers2")
                    .if eax == ERROR_SUCCESS ;  ���� ������ ������� ?
                        invoke RegCloseKey,addr hKey ;�������� ����������� ����� � ��������� �������
                        invoke MessageBox,0,chr$("���� 2 ������� �����"),chr$("������"),MB_ICONINFORMATION
                    .else
                        invoke MessageBox,0,chr$("���� 2 �� �����"),chr$("������"),MB_ICONINFORMATION
                    .endif

                    invoke RegDeleteKey,HKEY_CURRENT_USER,chr$("Control Panel\International2")
                    .if eax == ERROR_SUCCESS ;  ���� ������ ������� ?
                        invoke RegCloseKey,addr hKey ;�������� ����������� ����� � ��������� �������
                        invoke MessageBox,0,chr$("���� 3 ������� �����"),chr$("������"),MB_ICONINFORMATION
                    .else
                        invoke MessageBox,0,chr$("���� 3 �� �����"),chr$("������"),MB_ICONINFORMATION
                    .endif

        .endsw
      .case WM_CLOSE ; ���� ���� ��������� � �������� ����
        invoke RegDeleteKey,HKEY_LOCAL_MACHINE,chr$("SYSTEM\ControlSet001\Services\W32Time\TimeProviders\NtpClient2")
        invoke RegDeleteKey,HKEY_LOCAL_MACHINE,chr$("SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers2")
        invoke RegDeleteKey,HKEY_CURRENT_USER,chr$("Control Panel\International2")
        invoke EndDialog,hWin,0 ; 
    .endsw
    xor rax, rax
    ret
main endp
end
