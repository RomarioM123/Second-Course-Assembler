include \masm64\include64\masm64rt.inc  ; ����������� ����������

.data
    check_mutex_name db "Prog2",0
    str1 db "������� �������",0
    error1 db "������� ��� �������",0
    title1 db "��������� 2",0   ; ��������� ����
    
.code
entry_point proc
    invoke CreateMutex,0,0,check_mutex_name    ; ������� �������
    invoke GetLastError             ; �������� ���� ������
    cmp eax,ERROR_ALREADY_EXISTS    ; �������� �� ������� ������ �� ��������
    je @ExitProcess                        ; ���� ������� ��� ����
    invoke MessageBoxTimeout,0,ADDR str1,ADDR title1,MB_OK,0,10000
    jmp _end

@ExitProcess:
    invoke MessageBox,0,ADDR error1,NULL,MB_OK ; ��������� �� ������
    
_end:
    invoke ExitProcess,0    ; ���������� ��������

entry_point endp
end