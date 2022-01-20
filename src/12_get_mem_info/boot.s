; ****************************
; マクロ
; ****************************
%include "../include/define.s"
%include "../include/macro.s"

org BOOT_LOAD

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

    mov [BOOT + drive.no], dl ; ドライブ番号の保存

    ; 文字列を表示
    cdecl puts, .s0

    ; ハードディスクから、512~を読み出す
    mov bx, BOOT_SECT - 1 ; 残りのブートセクタ数
    mov cx, BOOT_LOAD + SECT_SIZE ; 次にロードされるべきアドレス

    cdecl read_chs, BOOT + drive, bx, cx

    cmp ax, bx
.10Q:
    jz .10E ; 指定したサイズだけ読み出しができていればよし
.10T:
    ; そうでなかったら再起動
    cdecl puts, .e0
    call reboot
.10E:
    jmp stage_2

.s0 db "Booting...", 0x0A, 0x0D, 0 ; 0x0A = LF, 0x0D = CR
.e0 db "Error: sector read", 0


ALIGN 2, db 0
BOOT: ; ブートドライブに関する情報
    istruc drive
        at drive.no,    dw 0
        at drive.cyln,  dw 0
        at drive.head,  dw 0
        at drive.sect,  dw 2
    iend


; ****************************
; 最初の512バイト内の処理で必要なモジュール
; ****************************
%include "../modules/real/puts.s"
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"

; ****************************
; ブートフラグ
; ****************************
    times 510 - ($ - $$) db 0x00
    db 0x55, 0xaa

; ****************************
; リアルモード時に取得した情報
; ****************************
FONT:
.seg:
    dw 0
.off:
    dw 0
ACPI_DATA:
.adr:
    dd 0
.len:
    dd 0


; ****************************
; 512バイト以降の処理で必要なモジュール
; ****************************
%include "../modules/real/itoa.s"
%include "../modules/real/get_drive_param.s"
%include "../modules/real/get_font_adr.s"
%include "../modules/real/get_mem_info.s"

; ****************************
; ブート処理の第2ステージ
; ****************************
stage_2:

    ; 文字列を表示
    cdecl puts, .s0

    ; ドライブ情報を取得
    cdecl get_drive_param, BOOT + drive
    cmp ax, 0
.10Q:
    jne .10E
.10T:
    cdecl puts, .e0
    call reboot
.10E:
    ; ドライブ情報の表示
    mov ax, [BOOT + drive.no]
    cdecl itoa, ax, .p1, 2, 16, 0b0100
    mov ax, [BOOT + drive.cyln]
    cdecl itoa, ax, .p2, 2, 16, 0b0100
    mov ax, [BOOT + drive.head]
    cdecl itoa, ax, .p3, 2, 16, 0b0100
    mov ax, [BOOT + drive.sect]
    cdecl itoa, ax, .p4, 2, 16, 0b0100
    cdecl puts, .s1


    jmp stage_3rd

.s0:
    db "2nd stage...", 0x0A, 0x0D, 0
.s1:
    db " Drive:0x"
.p1:
    db "  , C:0x"
.p2:
    db "   , H:0x"
.p3:
    db "  , S:0x"
.p4:
    db "  ", 0x0A, 0x0D, 0

.e0:
    db "Can't get drive parameter.", 0

; ****************************
; ブート処理の第3ステージ
; ****************************
stage_3rd:
    cdecl puts, .s0

    cdecl get_font_adr, FONT

    ; フォントアドレスの表示
    cdecl itoa, word [FONT.seg], .p1, 4, 16, 0b0100
    cdecl itoa, word [FONT.off], .p2, 4, 16, 0b0100
    cdecl puts, .s1


    ; メモリ情報の取得と表示
    cdecl get_mem_info

    mov eax, [ACPI_DATA.adr]
    cmp eax, 0
    je .10E

    cdecl itoa, ax, .p4, 4, 16, 0b0100
    shr eax, 16
    cdecl itoa, ax, .p3, 4, 16, 0b0100
    cdecl puts, .s2

.10E:

    jmp $

.s0:
    db "3rd stage...", 0x0A, 0x0D, 0

.s1:
    db " Font Address="
.p1:
    db "ZZZZ:"
.p2:
    db "ZZZZ", 0x0A, 0x0D, 0

.s2:
    db " ACPI data="
.p3:
    db "ZZZZ"
.p4:
    db "ZZZZ", 0x0A, 0x0D, 0



; ****************************
; padding (このファイルは8kバイトとする)
; ****************************
    times BOOT_SIZE - ($ - $$) db 0