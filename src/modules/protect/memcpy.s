; void memcpy(dst (4 bytes), src (4 bytes), size (4 bytes))
memcpy:
    ; スタックフレームの構築
    
    push ebp
    mov ebp, esp

    ; EBP + 16 | バイト数
    ; EBP + 12 | コピー元
    ; EBP +  8 | コピー先
    ; EBP +  4 | EIP
    ; EBP +  0 | EBP

    ; レジスタの保存
    push ecx
    push esi
    push edi

    ; バイト単位でのコピー
    cld ; +方向にアドレスを移動させる
    mov edi, [ebp + 8] ; コピー先
    mov esi, [ebp + 12] ; コピー元
    mov ecx, [ebp + 16] ; バイト数

    rep movsb

    ; レジスタの復帰
    pop edi
    pop esi
    pop ecx

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret