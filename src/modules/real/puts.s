; puts
; 文字列を表示する
; @params address (2 bytes) 表示文字列へのアドレス
; @returns void
; @example
; cdecl puts, .s0

puts:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; + 4 | 文字列へのアドレス
    ; + 2 | IP
    ; + 0 | BP
    
    ; レジスタの保存
    push ax
    push bx
    push si

    ; save arguments
    mov si, [bp + 4]

    mov ah, 0x0e   ; テレタイプ式1文字出力
    mov bx, 0x0000 ; ページ番号と文字色を0に設定
    cld ; DF = 0

.10L:
    lodsb ; al = *si++;

    cmp al, 0
    je .10E

    int 0x10
    jmp .10L

.10E:

    ; restore registers
    pop si
    pop bx
    pop ax

    ; discard stack frame

    mov sp, bp
    pop bp

    ret