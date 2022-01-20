; get_font_adr
; @params
;   adr: フォントアドレス格納位置
; @returns
; @example
;   cdecl get_font_adr, FONT_ADDRESS

get_font_adr:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; + 4 | フォントアドレス格納位置
    ; + 2 | IP
    ; + 0 | BP

    ; レジスタの保存
    push ax
    push bx
    push si
    push es
    push bp

    mov si, [bp + 4]

    ; INT 0x10(AX = 0x1130)
    ; @params
    ;   AX = 1130
    ;   BH = フォントタイプ
    ;       0x00 8x8
    ;       0x02 8x14
    ;       0x03 8x8
    ;       0x05 9x14
    ;       0x06 8x16
    ;       0x07 9x16
    ; @returns
    ;   CF: 成功？
    ;   ES:BP フォントアドレス
    ;   CX スキャンライン
    ;   DL 文字の高さ(ドット単位)

    mov ax, 0x1130 ; フォントアドレスの取得
    mov bh, 0x06 ; 8x16 font
    int 10h

    mov [si + 0], es
    mov [si + 2], bp

    ; レジスタの復帰
    pop bp
    pop es
    pop si
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret