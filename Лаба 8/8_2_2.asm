include \masm64\include64\masm64rt.inc  ; подключение библиотеки
include \masm64\bin64\arrays.inc        ; подключение файла с массивами

.data
    titl1 db "Лабораторная работа 8-2-2. Процессы",0    ; заголовок окна
    buf1 dq 0,0             ; буфер для текста
    
    h1 dq ?                 ; идентификатор потока
    h2 dq ?                 ; идентификатор потока
    h3 dq ?                 ; идентификатор потока
    hEventStart HANDLE ?    ; хэндл события

    tFPU dq 0               ; время выполнения через FPU
    tSSE dq 0               ; время выполнения через SSE
    tAVX dq 0               ; время выполнения через AVX
    ifmt db "Время:",10,10,"FPU: %d",10,"SSE: %d",10,"AVX: %d",0    ; формат вывода результата

.code

FPU proc ; процедура FPU
    rdtsc           ; получаем время начала выполнения
    xchg r14,rax    ; обмен значений регистров
    finit           ; инициализация сопроцессора

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

    rdtsc           ; получаем время конца выполнения
    sub rax,r14     ; считаем время выполнения
    mov tFPU,rax    ; запись времени в результат
    ret
FPU endp

SSE proc ; процедура SSE
    rdtsc           ; получаем время начала выполнения
    xchg r14,rax    ; обмен значений регистров
    
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

    rdtsc           ; получаем время конца выполнения
    sub rax,r14     ; считаем время выполнения
    mov tSSE,rax    ; запись времени в результат
    ret
SSE endp

AVX proc ; процедура AVX
    rdtsc           ; получаем время начала выполнения
    xchg r14,rax    ; обмен значений регистров

    vsqrtpd YMM0, AVXarrB       ; Vb
    vmulpd  YMM0, YMM0,AVXarrA  ; aVb

    vmovupd YMM1, AVXarrC       ; c
    vdivpd  YMM1, YMM1,AVXarrD  ; c/d
    vmulpd  YMM1, YMM1,AVXarrE  ; c/d*e
    vaddpd  YMM0, YMM0,YMM1     ; aVb + c/de
    
    rdtsc           ; получаем время конца выполнения
    sub rax,r14     ; считаем время выполнения
    mov tAVX,rax    ; запись времени в результат
    ret
AVX endp

entry_point proc
    lea rax, FPU ; загрузка адреса процедуры FPU
    invoke CreateThread,0,0,rax,0,0,addr h1 ; создание процесса 1
     
    lea rax, SSE ; загрузка адреса процедуры SSE 
    invoke CreateThread,0,0,rax,0,0,addr h2 ; создание процесса 2
   
    lea rax, AVX ; загрузка адреса процедуры AVX
    invoke CreateThread,0,0,rax,0,0,addr h3 ; создание процесса 3


    invoke CreateEvent,0,FALSE,FALSE,0  ; создание события
    mov hEventStart,rax                 ; сохранение хендла события
    invoke WaitForSingleObject,hEventStart,1000

    invoke wsprintf,ADDR buf1,ADDR ifmt,tFPU,tSSE,tAVX  ; преобразование результата в текст
    invoke MessageBox,0,ADDR buf1,ADDR titl1,MB_ICONINFORMATION ; вывод результата на экран
    invoke ExitProcess,0    ; завершение процесса
entry_point endp
end