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
    szFileName db "vizitka8-1.exe",0   ; название файла для вызова информации

    key1 db "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",0
    valueName1 db "DisableTaskMgr ",0

    key2 db "SYSTEM\CurrentControlSet\Servises\i8042prt\Parameters",0
    valueName2 db "CrashOnCtrlScroll ",0

    buf dq 12 dup(0),0

.code
entry_point proc
    GdiPlusBegin        ; инициализация GDIPlus
        mov hInstance, rv(GetModuleHandle,0)
        mov hIcon,rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)
        mov hBmp,rv(ResImageLoad,20)
        invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon
    GdiPlusEnd          ; GdiPlus очистка
        invoke ExitProcess,0
    ret
entry_point endp

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
.switch uMsg
    .case WM_INITDIALOG ; сообщение о создании диал. окна
        invoke SendMessage,hWin,WM_SETICON,1,lParam
        mov hStatic, rv(GetDlgItem,hWin,102)
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hBmp
        .return TRUE
    .case WM_COMMAND    ; сообщение от меню или кнопки
        .switch wParam
            .case 101   ; если выбран вывод информации о задании
                .data
                    txt2 db "Реализовать создание и удаление ключей реестра по определённому адресу.",
                    10,10,"Ветки:","  HKLM\SYSTEM\ControlSet001\Services\W32Time\TimeProviders\NtpClient",
                    10,"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ DateTime\Servers",
                    10,"HKCU\Control Panel\International",
                    10,10,"Ключи: SpecialPollInterval, sTimeFormat.",0
                    titl2 db "Информация о задании",0
                .code
                    invoke MsgboxI,hWin,ADDR txt2,ADDR titl2,MB_OK,10
                
            .case 102   ; если выбран вывод информации об авторе
                invoke WinExec,addr szFileName,SW_SHOW  ; вызов подпрограммы с выводом информации

            .case 103
                .data
                    msg db "Выход из программы.",0                  ; вывод уведомления о выходе
                .code
                    invoke MsgboxI,hWin,ptr$(msg),"Выход",MB_OK,10
                    rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0 ; уничтожение окна

            .case 1001  ; Создание ключа в реестре
                .code
                    invoke RegCreateKeyEx,\ ; создание раздела
                    HKEY_CURRENT_USER,ADDR key1,0,ADDR szREGSZ,REG_OPTION_VOLATILE,KEY_ALL_ACCESS,0,ADDR hKey,ADDR lpdwDisp;
                    cmp rax,0 ; проверка создан ли раздел
                    jne m11

                    cmp lpdwDisp,REG_OPENED_EXISTING_KEY            ; проверяем раздел 
                    je m21

                    invoke RegSetValueEx,\                          ; создание ключа и записывание данных
                    hKey,addr valueName1,0,REG_SZ,addr setValue,1   ; размер ключа в байтах
                    cmp rax,0 ; проверка создался ли ключ 
                    jne m11

                    invoke MessageBox,0,chr$("Ключ 1 создан"),chr$("Создание ключа"),MB_ICONINFORMATION
                    jmp m31

                m21:
                    invoke RegQueryValueEx,\    ; открытие ключа, считывание и записывание новых
                    hKey,addr valueName1,0,addr buf1,addr getKol,addr buf3 ;
                    cmp getKol,"0"
                    je part2
                    dec getKol
                    invoke RegSetValueEx,\
                    hKey,addr valueName1,0,REG_SZ,addr getKol,1 ; размер ключа в байтах

                m31: ; закрытие раздела
                    invoke RegCloseKey,hKey ; идентификация открытого ключа для закрытия
                    jmp part2
                    
                m11: ; вывод сообщения об ошибке
                    invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,\
                    NULL,rax,NULL,addr error,100,NULL
                    invoke MessageBox,0,addr error,chr$("Ошибка"),\
                    MB_ICONINFORMATION
                    jmp _end
                    
;===========================================================

                part2:
                    invoke RegCreateKeyEx,\ ; создание раздела
                    HKEY_LOCAL_MACHINE,ADDR key2,0,ADDR szREGSZ,REG_OPTION_VOLATILE,KEY_ALL_ACCESS,0,ADDR hKey,ADDR lpdwDisp;
                    cmp rax,0 ; проверка создан ли раздел
                    jne m12

                    cmp lpdwDisp,REG_OPENED_EXISTING_KEY            ; проверяем раздел 
                    je m22

                    invoke RegSetValueEx,\                          ; создание ключа и записывание данных
                    hKey,addr valueName2,0,REG_SZ,addr setValue,1   ; размер ключа в байтах
                    cmp rax,0 ; проверка создался ли ключ 
                    jne m12

                    invoke MessageBox,0,chr$("Ключ 2 создан"),chr$("Создание ключа"),MB_ICONINFORMATION
                    jmp m32

                m22:
                    invoke RegQueryValueEx,\    ; открытие ключа, считывание и записывание новых
                    hKey,addr valueName2,0,addr buf1,addr getKol,addr buf3 ;
                    cmp getKol,"0"
                    je _end
                    dec getKol
                    invoke RegSetValueEx,\
                    hKey,addr valueName2,0,REG_SZ,addr getKol,1 ; размер ключа в байтах

                m32: ; закрытие раздела
                    invoke RegCloseKey,hKey ; идентификация открытого ключа для закрытия
                    jmp _end
                    
                m12: ; вывод сообщения об ошибке
                    invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,\
                    NULL,rax,NULL,addr error,100,NULL
                    invoke MessageBox,0,addr error,chr$("Ошибка"),\
                    MB_ICONINFORMATION
                    
                _end:

                    
            .case 1003  ; Удаление ключа реестра
                    invoke RegDeleteKey,HKEY_LOCAL_MACHINE,chr$("SYSTEM\ControlSet001\Services\W32Time\TimeProviders\NtpClient2")
                    .if eax == ERROR_SUCCESS ;  ключ создан успешно ?
                        invoke RegCloseKey,addr hKey ;закрытие дескриптора ключа в системном реестре
                        invoke MessageBox,0,chr$("Ключ 1 успешно удалён"),chr$("Реестр"),MB_ICONINFORMATION
                    .else
                        invoke MessageBox,0,chr$("Ключ 1 не удалён"),chr$("Ошибка"),MB_ICONINFORMATION
                    .endif
                    
                    invoke RegDeleteKey,HKEY_LOCAL_MACHINE,chr$("SOFTWARE\Microsoft\Windows\CurrentVersion\ DateTime\Servers2")
                    .if eax == ERROR_SUCCESS ;  ключ создан успешно ?
                        invoke RegCloseKey,addr hKey ;закрытие дескриптора ключа в системном реестре
                        invoke MessageBox,0,chr$("Ключ 2 успешно удалён"),chr$("Реестр"),MB_ICONINFORMATION
                    .else
                        invoke MessageBox,0,chr$("Ключ 2 не удалён"),chr$("Ошибка"),MB_ICONINFORMATION
                    .endif

                    invoke RegDeleteKey,HKEY_CURRENT_USER,chr$("Control Panel\International2")
                    .if eax == ERROR_SUCCESS ;  ключ создан успешно ?
                        invoke RegCloseKey,addr hKey ;закрытие дескриптора ключа в системном реестре
                        invoke MessageBox,0,chr$("Ключ 3 успешно удалён"),chr$("Реестр"),MB_ICONINFORMATION
                    .else
                        invoke MessageBox,0,chr$("Ключ 3 не удалён"),chr$("Ошибка"),MB_ICONINFORMATION
                    .endif

        .endsw
      .case WM_CLOSE ; если есть сообщение о закрытии окна
        invoke RegDeleteKey,HKEY_LOCAL_MACHINE,chr$("SYSTEM\ControlSet001\Services\W32Time\TimeProviders\NtpClient2")
        invoke RegDeleteKey,HKEY_LOCAL_MACHINE,chr$("SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers2")
        invoke RegDeleteKey,HKEY_CURRENT_USER,chr$("Control Panel\International2")
        invoke EndDialog,hWin,0 ; 
    .endsw
    xor rax, rax
    ret
main endp
end
