; エントリーポイント

BOOT_LOAD equ 0x7c00

org BOOT_LOAD

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
    ; セグメントの初期化とスタックの指定
    ; BIOSがセットアップしたときのままになっているので指定しなおす

    cli ; maskableな割り込みをストップする

    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_LOAD ; スタックはブートローダーが読み込まれた場所から上に伸びていく

    sti ; maskableな割り込みを受け付ける

    mov [BOOT.DRIVE], dl ; ドライブ番号を保存する  

    jmp $


ALIGN 2, db 0
BOOT: ; ブートドライブに関する情報
    .DRIVE dw 0 ; ドライブ番号


    times 510 - ($ - $$) db 0x00
    db 0x55, 0xaa