; get_mem_info
; メモリー情報を取得する
; @params
; @returns
; @examples
;   call get_mem_info

get_mem_info:

    ; レジスタの保存
    push eax
    push ebx
    push ecx
    push edx
    push si
    push di
    push bp

    cdecl puts, .s0

    mov bp, 0 ; lines = 0
    mov ebx, 0 ; index = 0

.10L:
    
    ; INT 0x15 (AX = 0xE820)
    ; 0x0010_0000 より上位にあるメモリ領域の情報を取得する
    ; @params
    ;   AX = 0xE820
    ;   EBX = インデックス(初回は0)
    ;   ES:DI = 情報書込み先 (ベースアドレス8バイト、長さ8バイト、タイプ4バイト)
    ;       タイプ
    ;           1. AddressRangeMemory 使用可能
    ;           2. AddressRangeReserved 使用不可
    ;           3. AddressRangeACPI ACPIテーブル参照可能
    ;           4. AddressRangeNVS 使用不可
    ;   ECX = 書込み先バイト数(20 bytes)
    ;   EDX = 0x534D4150
    ; @returns
    ;   CF: 成功？
    ;   EAX: 0x534D4150
    ;   ECX: 書込みバイト数
    ;   EBX: インデックス（0の時は最終データ）

    mov eax, 0x0000E820
    mov ecx, E820_RECORD_SIZE
    mov edx, 'PAMS'
    mov di, .b0
    int 0x15

    cmp eax, 'PAMS'
    je .12E ; メモリ取得コマンドに対応している
    jmp .10E ; 対応していないときは関数を終了

.12E:
    ; メモリ取得コマンドに対応している時の処理
    jnc .14E ; コマンド実行に失敗していなければ14Eに飛ぶ
    jmp .10E ; コマンドの実行に終了したので関数を終了

.14E:
    cdecl put_mem_info, di ; 1レコードぶんのメモリ情報を表示

    mov eax, [di + 16] ; タイプを取得
    cmp eax, 3
    jne .15E
    ; EAX = 3だったら
    mov eax, [di + 0] ; eax = ベースアドレス
    mov [ACPI_DATA.adr], eax
    
    mov eax, [di + 8] ; eax = 長さ
    mov [ACPI_DATA.len], eax

.15E:

    cmp ebx, 0
    jz .16E

    inc bp ; lines++
    and bp, 0x07 ; lines &= 0x07
    jnz .16E
    ; 8行分表示したら
    cdecl puts, .s2
    mov ah, 0x10
    int 0x16

    ; 中断メッセージを消去
    cdecl puts, .s3

.16E:
    cmp ebx, 0
    jne .10L

.10E:
    ; 関数終了
    cdecl puts, .s1

    pop bp
    pop di
    pop si
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret

.s0:
    db " E820 Memory Map:", 0x0A, 0x0D
    db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:
    db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:
    db " <more...>", 0
.s3:
    db 0x0D, "                    ", 0x0D, 0

ALIGN 4, db 0
.b0:
    times E820_RECORD_SIZE db 0


; put_mem_info
; @params
;   adr: メモリ情報を参照するアドレス
; @returns
; @example
;   cdecl put_mem_info, MEMORY_INFO_ADDR

put_mem_info:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; + 4 | メモリ情報を参照するアドレス
    ; + 2 | IP
    ; + 0 | BP

    ; レジスタの保存
    push bx
    push si

    mov si, [bp + 4]

    ; Base(8 bytes)
    cdecl itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100 ; itoa は2バイトずつしか変換できない
    cdecl itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
    cdecl itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

    ; Length(8 bytes)
    cdecl itoa, word [si + 14], .p4 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 12], .p4 + 4, 4, 16, 0b0100
    cdecl itoa, word [si + 10], .p5 + 0, 4, 16, 0b0100
    cdecl itoa, word [si +  8], .p5 + 4, 4, 16, 0b0100    

    ; Type(4 bytes)
    cdecl itoa, word [si + 18], .p6 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 16], .p6 + 4, 4, 16, 0b0100

    cdecl puts, .s1

    mov bx, [si + 16]
    and bx, 0x07 ; BX = Type(0~5)
    shl bx, 1 ; BX *= 2 ; .t0配列の該当タイプへのインデックスに変換
    ; .t0は1要素2バイトなので2倍してやる
    add bx, .t0
    cdecl puts, word [bx]

    ; レジスタの復元
    pop si
    pop bx

    ; スタックフレームの破棄
    mov sp, bp
    pop bp
    ret
    
.s1:
    db " "
.p2:
    db "ZZZZZZZZ_"
.p3:
    db "ZZZZZZZZ "
.p4:
    db "ZZZZZZZZ_"
.p5:
    db "ZZZZZZZZ "
.p6:
    db "ZZZZZZZZ", 0

.s4: db "(Unknown)", 0x0A, 0x0D, 0
.s5: db "(usable)", 0x0A, 0x0D, 0
.s6: db "(reserved)", 0x0A, 0x0D, 0
.s7: db "(ACPI data)", 0x0A, 0x0D, 0
.s8: db "(ACPI NVS)", 0x0A, 0x0D, 0
.s9: db "(bad memory)", 0x0A, 0x0D, 0

.t0: dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4