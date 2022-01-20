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

    ; 文字列を表示
    cdecl puts, .s0

    ; 数値を表示
    cdecl itoa, 8086, .s1, 8, 10, 0b0001 ; "    8086"
    cdecl puts, .s1

    cdecl itoa, 8086, .s1, 8, 10, 0b0011 ; "+   8086"
    cdecl puts, .s1

    cdecl itoa, -8086, .s1, 8, 10, 0b0001 ; "-   8086"
    cdecl puts, .s1

    cdecl itoa, -1, .s1, 8, 10, 0b0001 ; "-      1"
    cdecl puts, .s1

    cdecl itoa, -1, .s1, 8, 10, 0b0000 ; "   65535"
    cdecl puts, .s1

    cdecl itoa, -1, .s1, 8, 16, 0b0000 ; "    FFFF"
    cdecl puts, .s1

    cdecl itoa, 12, .s1, 8, 2, 0b0100 ; "00001100"
    cdecl puts, .s1

    jmp $

.s0 db "Booting...", 0x0A, 0x0D, 0 ; 0x0A = LF, 0x0D = CR
.s1 db "--------", 0x0A, 0x0D, 0


ALIGN 2, db 0
BOOT: ; ブートドライブに関する情報
    .DRIVE dw 0 ; ドライブ番号


; ****************************
; モジュール
; ****************************
%include "../modules/real/putc.s"
%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"

; ****************************
; ブートフラグ
; ****************************
    times 510 - ($ - $$) db 0x00
    db 0x55, 0xaa