; エントリーポイント
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
    jmp $

    times 510 - ($ - $$) db 0x00
    db 0x55, 0xaa