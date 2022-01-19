; memcpy(src0 (2 bytes), src1, (2 bytes), size (2 bytes))
    ; return 0(一致), -1(不一致)
memcmp:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; BP + 8 | バイト数
    ; BP + 6 | アドレス1
    ; BP + 4 | アドレス0
    ----------------
    ; BP + 2 | IP
    ; BP + 0 | BP

    ; レジスタの保存
    push bx
    push cx
    push dx
    push si
    push di

    ; 引数の取得
    cld ; DF = 0
    mov si, [bp + 4] ; アドレス0
    mov di, [bp + 6] ; アドレス1
    mov cx, [bp + 8] ; バイト数

    ; バイト単位での比較
    repe cmpsb ; CX = 0(コピーが終了し終えた) | ZF = 0(バイトでの比較で一致しなかった)
    jnz .10F
    mov ax, 0
    jmp .10E

.10F:
    mov ax, -1

.10E:
    ; レジスタの復元
    pop di
    pop si
    pop dx
    pop cx
    pop bx

    ; スタックフレーム破棄
    mov sp, bp
    pop bp

    ret