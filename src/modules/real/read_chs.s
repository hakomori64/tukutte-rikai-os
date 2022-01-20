; read_chs
; @params
;   drive: drive構造体のアドレス
;   sect: 読み出しセクタ数
;   dst: 読み出し先アドレス
; @returns
;   ax: 読み出したセクタ数
; @example
;   cdecl read_chs, read_chs, BOOT + drive, BOOT_SECT - 1, BOOT_LOAD + SECT_SIZE

read_chs:
    ; スタックフレームの構築

    push bp
    mov bp, sp
    push 3 ; リトライ回数
    push 0 ; 読み込みセクタ数

    ;+ 8 | 読み出し先アドレス
    ;+ 6 | 読み出しセクタ数
    ;+ 4 | drive構造体のアドレス
    ;+ 2 | IP
    ;+ 0 | BP
    ;- 2 | リトライ回数
    ;- 4 | 読み込みセクタ数

    ; レジスタの保存
    push bx
    push cx
    push dx
    push es
    push si

    ; 処理の開始
    mov si, [bp + 4] ;si = ドライブ構造体のアドレス

    mov ch, [si + drive.cyln + 0] ; シリンダ番号の下位バイト
    mov cl, [si + drive.cyln + 1] ; シリンダ番号の上位バイト
    shl cl, 6
    or cl, [si + drive.sect]

    ; セクタ読み込み
    mov dh, [si + drive.head]
    mov dl, [si + drive.no]
    mov ax, 0x0000
    mov es, ax
    mov bx, [bp + 8] ; es(0x0000):bx(読み込み先アドレス)に読み込み

.10L:
    mov ah, 0x02
    mov al, [bp + 6]

    int 0x13
    jnc .11E ; if failed: al = 0 && break

    mov al, 0
    jmp .10E

.11E:
    cmp al, 0 ; if 読み出したセクタ数 == 0
    jne .10E

    mov ax, 0
    dec word [bp - 2]
    jnz .10L ; リトライ回数だけリトライ

.10E:
    mov ah, 0 ; ステータスは破棄

    ; レジスタの復帰
    pop si
    pop es
    pop dx
    pop cx
    pop bx

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret