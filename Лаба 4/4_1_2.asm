include \masm64\include64\masm64rt.inc

Computer STRUCT
    serialNum1 dq ?
    price1 dq ?    
    name1 dd ?
    ownerSurname1 dd ?
    size1 dq ?    
Computer ENDS

IDI_ICON EQU 1001
MSGBOXPARAMSA STRUCT    ; объявление системной структуры
    cbSize DWORD ?,?
    hwndOwner QWORD ?
    hInstance QWORD ?
    lpszText QWORD ?
    lpszCaption QWORD ?
    dwStyle DWORD ?,?
    lpszIcon QWORD ?
    dwContextHelpId QWORD ?
    lpfnMsgBoxCallback QWORD ?
    dwLanguageId DWORD ?,?
MSGBOXPARAMSA ENDS

.data		; секция переменных
    params MSGBOXPARAMSA <>     ; инициализация системной структуры
    PC1 Computer <1,2,"Best PC","Momot",5>    
    PC2 Computer <5,4,"123","Efremov",4>
    PC3 Computer <3,3,"142","Ivanov",1>

    num1 dq 3 	; переменная константа
    res1 dq ? 	; переменная результата

    title1 db "Лабораторная работа 4_1_2. Структуры",0  ; заголовок окна вывода
    txt1 db "Задана последовательность структур. Структура содержит поля данные о компьютере: серийный номер, цена, название, фамилия владельца, размер монитора в дюймах. Вычислить среднюю цену компьютера.",10,10,			; вывод выражения 
    "Результат: %d",10,         ; вывод результата и адреса переменной
    "Автор: Момот Р.Е.",0
    buf1 dq 3 dup(0),0

.code                   ; секция кода
    entry_point proc    ; точка входа
    xor rax,rax         ; очистка регистра RAX
    mov rax,PC1.price1  ; запись суммы первого ПК
    add rax,PC2.price1  ; прибавление цены второго ПК
    add rax,PC3.price1  ; прибавление цены третьего ПК

    xor rdx,rdx  	      ; очистка регистра RDX
    div num1            ; /3
 
    mov res1,rax	      ; запись результата в переменную результата

    ;invoke wsprintf,ADDR buf1,ADDR text1,res1,ADDR res1     ; преобразование данных в строку
    ;invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; вызов функции окна
    ;invoke ExitProcess,0

    invoke wsprintf,ADDR buf1,ADDR txt1,res1
    mov params.cbSize,SIZEOF MSGBOXPARAMSA  ; размер структуры
    mov params.hwndOwner,0                  ; дескриптор окна владельца
    invoke GetModuleHandle,0                ; получение дескриптора программы
    mov params.hInstance,rax                ; сохранение дескриптора программы
    lea rax, buf1                           ; адрес сообщения
    mov params.lpszText,rax
    lea rax,title1                          ; адрес заглавия окна
    mov params.lpszCaption,rax
    mov params.dwStyle,MB_USERICON          ; стиль окна
    mov params.lpszIcon,IDI_ICON            ; ресурс значка
    mov params.dwContextHelpId,0            ; контекст справки
    mov params.lpfnMsgBoxCallback,0
    mov params.dwLanguageId,LANG_NEUTRAL    ; язык сообщения
    lea rcx,params
    invoke MessageBoxIndirect   ; вызов окна с результатом работы и иконкой
    invoke ExitProcess,0

entry_point endp	; точка выхода
end