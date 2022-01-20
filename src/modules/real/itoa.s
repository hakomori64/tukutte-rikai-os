; itoa
; @params
;   num: 変換する値
;   buff: 保存先アドレス
;   size: 保存先バッファサイズ
;   radix: 基数(2 or 8 or 10 or 16)
;   flags: ビット定義のフラグ
;       B2: 空白を0で埋める
;       B1: '+/-'記号を付加する
;       B0: 値を符号付き変数として扱う
; @example
;   cdecl, itoa, 8086, .s1, 8, 10, 0b0001 ; "    8086"

itoa:
    ; stack frame
    push bp
    mov bp, sp

    ; + 12 | flags
    ; + 10 | 基数
    ; +  8 | 保存先バッファサイズ
    ; +  6 | 保存先アドレス
    ; +  4 | 変換する値
    ; +  2 | IP
    ; +  0 | BP

    ; save registers
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; 引数を取得
    mov ax, [bp + 4]
    mov si, [bp + 6]
    mov cx, [bp + 8]

    mov di, si
    add di, cx ; dst = &dst[size - 1]
    dec di

    mov bx, word [bp + 12] ; flags = オプション

    ; 符号付き数値として扱うかを判定する
    ; もし負の数だったらB1をtrueにする
    test bx, 0b0001
.10Q:
    je .10E ; ZF = 0(先のtest演算の結果が0になっていたら、つまり、オプションが無効であればスキップ)
    cmp ax, 0 ; if num < 0
    jge .12E
    or bx, 0b0010 ; flags |= 2
.12E:
.10E:

    ; 符号を出力するか判定する
    test bx, 0b0010
.20Q:
    je .20E
    cmp ax, 0 ; if num < 0
.22Q:
    jge .22F
    neg ax ; num *= -1
    mov [si], byte '-' ; 符号を表示する
    jmp .22E
.22F:
    mov [si], byte '+'    
.22E:
    dec cx ; size--
.20E:


    ; ASCII変換
    mov bx, [bp + 10] ; 基数
.30L:
    mov dx, 0
    ; div
    ; AX = DX:AX / 基数
    ; DX = DX:AX % 基数
    div bx

    mov si, dx ; si = 余り
    mov dl, byte [.ascii + si] ; 変換テーブルから、余り(数値)を文字に変換

    mov [di], dl
    dec di

    cmp ax, 0
    loopnz .30L ; ax != 0なら.30Lに戻る
.30E:


    ; 空欄を埋める
    cmp cx, 0
.40Q:
    je .40E
    mov al, ' '
    cmp [bp + 12], word 0b0100
    jne .42E
    mov al, '0'
.42E:
    std ; DF = 1 (マイナス方向に伸ばしていく)
    rep stosb ; while (cx > 0) { [di] = al; di--; cx--; }
.40E:

    ; レジスタの復元
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret

.ascii db "0123456789ABCDEF"