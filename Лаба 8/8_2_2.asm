include \masm64\include64\masm64rt.inc  ; ����������� ����������
include \masm64\bin64\arrays.inc        ; ����������� ����� � ���������

.data
    titl1 db "������������ ������ 8-2-2. ��������",0    ; ��������� ����
    buf1 dq 0,0             ; ����� ��� ������
    
    h1 dq ?                 ; ������������� ������
    h2 dq ?                 ; ������������� ������
    h3 dq ?                 ; ������������� ������
    hEventStart HANDLE ?    ; ����� �������

    tFPU dq 0               ; ����� ���������� ����� FPU
    tSSE dq 0               ; ����� ���������� ����� SSE
    tAVX dq 0               ; ����� ���������� ����� AVX
    ifmt db "�����:",10,10,"FPU: %d",10,"SSE: %d",10,"AVX: %d",0    ; ������ ������ ����������

.code

FPU proc ; ��������� FPU
    rdtsc           ; �������� ����� ������ ����������
    xchg r14,rax    ; ����� �������� ���������
    finit           ; ������������� ������������

    fld FPUarr+8    ; b
    fsqrt           ; Vb
    fld FPUarr      ; a
    fmul            ; aVb

    fld FPUarr+16   ; c
    fld FPUarr+24   ; d
    fdiv            ; c/d
    fld FPUarr+32   ; e
    fmul            ; c/d*e

    fadd            ; aVb + c/de

    rdtsc           ; �������� ����� ����� ����������
    sub rax,r14     ; ������� ����� ����������
    mov tFPU,rax    ; ������ ������� � ���������
    ret
FPU endp

SSE proc ; ��������� SSE
    rdtsc           ; �������� ����� ������ ����������
    xchg r14,rax    ; ����� �������� ���������
    
    movsd XMM0, SSEarr+8
    sqrtpd XMM0, XMM0
    movsd XMM1, SSEarr
    mulsd XMM0, XMM1

    movsd XMM1,SSEarr+16
    movsd XMM2,SSEarr+24
    divsd XMM1,XMM2
    movsd XMM2,SSEarr+32
    mulsd XMM1,XMM2

    addsd XMM0,XMM1

    rdtsc           ; �������� ����� ����� ����������
    sub rax,r14     ; ������� ����� ����������
    mov tSSE,rax    ; ������ ������� � ���������
    ret
SSE endp

AVX proc ; ��������� AVX
    rdtsc           ; �������� ����� ������ ����������
    xchg r14,rax    ; ����� �������� ���������

    vsqrtpd YMM0, AVXarrB       ; Vb
    vmulpd  YMM0, YMM0,AVXarrA  ; aVb

    vmovupd YMM1, AVXarrC       ; c
    vdivpd  YMM1, YMM1,AVXarrD  ; c/d
    vmulpd  YMM1, YMM1,AVXarrE  ; c/d*e
    vaddpd  YMM0, YMM0,YMM1     ; aVb + c/de
    
    rdtsc           ; �������� ����� ����� ����������
    sub rax,r14     ; ������� ����� ����������
    mov tAVX,rax    ; ������ ������� � ���������
    ret
AVX endp

entry_point proc
    lea rax, FPU ; �������� ������ ��������� FPU
    invoke CreateThread,0,0,rax,0,0,addr h1 ; �������� �������� 1
     
    lea rax, SSE ; �������� ������ ��������� SSE 
    invoke CreateThread,0,0,rax,0,0,addr h2 ; �������� �������� 2
   
    lea rax, AVX ; �������� ������ ��������� AVX
    invoke CreateThread,0,0,rax,0,0,addr h3 ; �������� �������� 3


    invoke CreateEvent,0,FALSE,FALSE,0  ; �������� �������
    mov hEventStart,rax                 ; ���������� ������ �������
    invoke WaitForSingleObject,hEventStart,1000

    invoke wsprintf,ADDR buf1,ADDR ifmt,tFPU,tSSE,tAVX  ; �������������� ���������� � �����
    invoke MessageBox,0,ADDR buf1,ADDR titl1,MB_ICONINFORMATION ; ����� ���������� �� �����
    invoke ExitProcess,0    ; ���������� ��������
entry_point endp
end