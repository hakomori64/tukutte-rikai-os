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

    ; ハードディスクから、512~(ブートセクションより先の部分)を読み出す
    mov ah, 0x02 ;          AH = 読み込み命令
    mov al, 1 ;             AL = 読み込みセクタ数
    mov cx, 0x0002;         CX = (CL[7:6]CH[7:0] = シリンダ, CL[5:0] = セクタ)
    mov dh, 0x00;           DH = ヘッド番号
    mov dl, [BOOT.DRIVE] ;  DL = ドライブ番号
    mov bx, 0x7c00 + 512 ;  ES:BX = 読み込み位置
    int 0x13
.10Q:
    jnc .10E ; CF = 0 (エラーが発生した)の場合、再起動
.10T:
    cdecl puts, .e0
    call reboot
.10E:
    jmp stage_2

.s0 db "Booting...", 0x0A, 0x0D, 0 ; 0x0A = LF, 0x0D = CR
.e0 db "Error: sector read", 0


ALIGN 2, db 0
BOOT: ; ブートドライブに関する情報
    .DRIVE dw 0 ; ドライブ番号


; ****************************
; モジュール
; ****************************
%include "../modules/real/putc.s"
%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"
%include "../modules/real/reboot.s"

; ****************************
; ブートフラグ
; ****************************
    times 510 - ($ - $$) db 0x00
    db 0x55, 0xaa


; ****************************
; ブート処理の第2ステージ
; ****************************
stage_2:

    ; 文字列を表示
    cdecl puts, .s0

    ; 処理の終了
    jmp $

.s0:
    db "2nd stage...", 0x0A, 0x0D, 0


; ****************************
; padding (このファイルは8kバイトとする)
; ****************************
    times (1024 * 8) - ($ - $$) db 0