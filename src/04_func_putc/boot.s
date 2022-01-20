; エントリーポイント

BOOT_LOAD equ 0x7c00

org BOOT_LOAD

; ****************************
; マクロ
; ****************************
%include "../include/macro.s"

; ****************************
; エントリーポイント
; ****************************
entry:
    jmp ipl

    ; ---------
    ; BPB (BIOS Parameter Block)
    ; ---------
    times 90 - ($ - $$) db 0x90

    ; ---------
    ; IPL(Initial Program Loader)
    ; --------- 

ipl:
    ; BIOSが利用した時の値がそのまま残っているので、セグメントやスタックの値を設定しなおす
    cli ; セグメントの初期化や割り込みの設定時に割り込みが呼ばれてほしくないので、いったん止める

    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_LOAD ; スタックはブートローダーが読み込まれた場所から上に伸びていく

    sti ; 割り込みのうけつけを再開する

    mov [BOOT.DRIVE], dl ; ドライブ番号の保存

    cdecl putc, word 'X'
    cdecl putc, word 'Y'
    cdecl putc, word 'Z'

    jmp $


ALIGN 2, db 0
BOOT: ; ブートドライブに関する情報
    .DRIVE dw 0 ; ドライブ番号

; ****************************
; モジュール
; ****************************
%include "../modules/real/putc.s"

; ****************************
; ブートフラグ
; ****************************
    times 510 - ($ - $$) db 0x00
    db 0x55, 0xaa