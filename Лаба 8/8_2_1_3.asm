include \masm64\include64\masm64rt.inc  ; ����������� ����������

.data
    processInfo PROCESS_INFORMATION <> ; ���. � �������� � ��� ��������� ����
    progName db "C:\masm64\qeditor.exe",0
    startInfo dd ?

.code
entry_point proc   
    invoke GetStartupInfo,ADDR startInfo
    invoke CreateProcess,ADDR progName,0,0,0,FALSE,\
        NORMAL_PRIORITY_CLASS, 0,0,ADDR startInfo,ADDR processInfo
    invoke Sleep,10000  ; �������� �������� � 10000 �����������
    invoke TerminateProcess, processInfo.hProcess, 0 

    invoke ExitProcess,0
entry_point endp
end