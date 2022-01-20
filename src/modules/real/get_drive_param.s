; get_drive_param
; ドライブの情報を取得して、drive構造体のアドレスに置く
; @params
;   drive: drive構造体のアドレス. noを事前にセットしておく
; @return
;    ax : セクタ数
; @example
;   cdecl get_drive_param BOOT + drive

get_drive_param:
    ; スタックフレーム構築
    push bp
    mov bp, sp

    ; + 4 | drive構造体のアドレス
    ; + 2 | IP
    ; + 0 | BP

    ; レジスタの保存
    push bx
    push cx
    push es
    push si
    push di

    ; INT 0x13(AH = 8)を呼び出す
    ; @params DL = ドライブ番号
    ; @returns 実際にアクセス可能な最終地点が帰ってくる
    ;   CF : 失敗
    ;   AH : リターンコード
    ;   BL : FDDタイプ(1 = 360K, 2 = 1.2M, 3 = 720K, 4 = 1.44M)
    ;   CL[7:6] : シリンダ(上位2bit)
    ;   CH : シリンダ(下位8bit)
    ;   CL[5:0] : セクタ
    ;   DH : ヘッド
    ;   DL : ドライブ
    ;   ES:DI : ディスクベーステーブルのアドレス(詳細な情報が格納される)

    ; 処理の開始
    mov si, [bp + 4]
    mov ax, 0
    mov es, ax
    mov di, ax

    mov ah, 8
    mov dl, [si + drive.no]
    int 0x13

.10Q:
    jc .10F
.10T:
    mov al, cl
    and ax, 0x3F ; 実際にアクセス可能な最終セクタが帰ってくる。セクタは1から番号がはじまるので
                 ; 最終地点の番号がそのままセクタ数

    shr cl, 6 ; シリンダ数の上位2ビット
    ror cx, 8 ; axレジスタのビットを右に8ビット回転させる <=> CH[1:0]CL = シリンダ数
    inc cx ; 実際にアクセス可能な最終シリンダが帰ってくるので、＋１でシリンダ数になる

    movzx bx, dh ; ヘッド数
    inc bx ; 実際にアクセス可能な最終ヘッダ番号が帰ってくるので＋１でヘッダ数になる

    mov [si + drive.cyln], cx
    mov [si + drive.head], bx
    mov [si + drive.sect], ax

    jmp .10E

.10F:
    mov ax, 0

.10E:
    ; レジスタの復帰
    pop di
    pop si
    pop es
    pop cx
    pop bx

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret