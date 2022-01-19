; void memcpy(dst (2bytes), src (2bytes), size (2 bytes))
; srcからdstにsizeバイトだけコピーする

memcpy:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; BP + 8| バイト数
    ; BP + 6| コピー元
    ; BP + 4| コピー先
    ; -----------------
    ; BP + 2| 戻り番地
    ; BP + 0| BP

    ; バイト単位でのコピー
    cld ; 次のアドレスは＋方向
    mov di, [bp + 4] ; コピー先
    mov si, [bp + 6] ; コピー元
    mov cx, [bp + 8] ; バイト数

    rep movsb

    ; レジスタの復帰
    pop di
    pop si
    pop cx

    ; スタックフレームの破棄
    mov sp, bp
    mov bp
    ret