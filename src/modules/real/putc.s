; putc
; 一文字表示する
; @params ch (2 bytes) 文字コード
; @returns void
; @example
;   cdecl putc 'A' ; 'A'
putc:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ;+ 4 | 出力文字
    ;+ 2 | IP
    ;+ 0 | BP

    ; レジスタの保存
    push ax
    push bx

    mov al, [bp + 4]
    mov ah, 0x0e
    mov bx, 0x0000
    int 0x10

    ; レジスタの復帰
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret