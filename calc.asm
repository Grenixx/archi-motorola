                org     $0

vector_000      dc.l    $ffb500
vector_001      dc.l    Main

                org     $500

Main            bra     UitoaTest

UitoaTest       move.l #10825,d0
                lea buffer,a0
                jsr Uitoa
                illegal

Uitoa           move.l a0,-(sp)
                move.l #0,-(sp)

\loop           divu #10,d0
                and.l #$FFFF0000,d0
                swap.l d0
                tst d0
                beq \dequeue
                add.l #'0',d0
                move.w d0,-(sp)

\dequeue        move.w (sp)+,d0
                tst d0
                beq \quit
                move.b d0,(a0)
                addq.l #1,a0
                bra \dequeue

\quit           move.l (sp)+,a0
                rts


GetExprTest     lea sGetExprTest,a0
                jsr GetExpr
                illegal

GetExpr         movem.l a0/d1/d2/d3,-(sp)
                move.l d0,d3 ; on le save au cas ou ca foire

                jsr GetNum
                bne \false

                move.b d0,d1 ; init

\loop           move.b (a0),d2
                beq \true
                addq.l #1,a0
                jsr GetNum
                bne \false

                cmp #'+',d2
                beq \add

                cmp #'-',d2
                beq \sub

                cmp #'*',d2
                beq \mult

                cmp #'/',d2
                beq \div

\add        add.l d0,d1
            bra \loop

\sub        sub.l d0,d1
            bra \loop

\mult       muls d0,d1
            bra \loop

\div        tst d0
            beq \false
            divs.w d0,d1
            ext.l d1
            bra \loop

\true       move.l d1,d0
            movem.l (sp)+,a0/d1/d2/d3
            ori.b #%00000100,ccr
            rts

\false      move.l d3,d0
            movem.l (sp)+,a0/d1/d2/d3
            andi.b #%11111011,ccr
            rts

GetNumTest      lea sGetNumTest,a0
                jsr GetNum
                illegal

GetNum          movem.l a1/a2/d1/d2,-(sp)
                move.l d0,d2

                movea.l a0,a1
                jsr NextOp

                movea.l a0,a2
                movea.l a1,a0

                move.b (a2),d1
                move.b #$00,(a2)

                jsr Convert
                bne \error

                move.b d1,(a2)
                movea.l a2,a0
                movem.l (sp)+,a1/a2/d1/d2
                bra \true

\error          move.b d1,(a2)
                movea.l a1,a0
                move.l d2,d0
                movem.l (sp)+,a1/a2/d1/d2
                bra \false

\true           ori.b #%00000100,ccr
                rts
\false          andi.b #%11111011,ccr
                rts

NextOpTest      lea sNextOpTest,a0
                jsr NextOp
                move.b (a0),d3
                illegal

NextOp          tst.b (a0)
                beq \quit
                cmp.b #'+',(a0)
                beq \quit
                cmp.b #'-',(a0)
                beq \quit
                cmp.b #'*',(a0)
                beq \quit
                cmp.b #'/',(a0)
                beq \quit
                adda.l #1,a0
                bra NextOp

\quit           rts

PrintTest       lea sTest,a0
                move.b #24,d1
                move.b #20,d2
                jsr Print
                illegal

Print           move.l a0,-(sp)
\loop           move.b (a0)+,d0
                beq \quit
                jsr PrintChar
                add.l #1,d1
                bra \loop

\quit           move.l (sp)+,a0
                rts

PrintChar incbin "PrintChar.bin"

ConvertTest     movea.l #STRING_TO_CONVERT,a0
                jsr     Convert
                illegal

Convert         movem.l a0/d1,-(a7)
                tst.b   (a0)
                beq     \false

                jsr     IsCharError
                beq     \false

                jsr     IsMaxError
                beq     \false

                jsr     Atoui
                bra     \true

\false          andi.b  #%11111011,ccr
                bra     \quit
\true           ori.b   #%00000100,ccr
                bra     \quit
\quit           movem.l (sp)+,a0/d1
                rts

Atoui           clr.l   d0
\loop           move.b  (a0)+,d1
                beq     \quit
                sub.b   #'0',d1
                mulu.w  #10,d0
                add.w   d1,d0
                bra     \loop
\quit           rts

IsMaxErrorTest  movea.l #STRING_IS_MAX_ERROR,a0
                jsr     IsMaxError
                illegal

IsMaxError      movem.l a0/d0,-(a7)
                jsr     StrLen
                cmp.b   #5,d0
                blt     \false
                bhi     \true
                cmp.b   #'3',(a0)+
                blt     \false
                bhi     \true
                cmp.b   #'2',(a0)+
                blt     \false
                bhi     \true
                cmp.b   #'7',(a0)+
                blt     \false
                bhi     \true
                cmp.b   #'6',(a0)+
                blt     \false
                bhi     \true
                cmp.b   #'7',(a0)+
                blt     \false
                bhi     \true
                bra     \false

\false          andi.b  #%11111011,ccr
                bra     \quit
\true           ori.b   #%00000100,ccr
\quit           movem.l (a7)+,a0/d0
                rts

StrLen          move.l  a0,-(a7)
                clr.l   d0
\loop           tst.b   (a0)+
                beq     \quit
                addq.l  #1,d0
                bra     \loop
\quit           movea.l (a7)+,a0
                rts

IsCharErrorTest movea.l #STRING_IS_CHAR_ERROR,a0
                jsr     IsCharError
                illegal

IsCharError     move.l  a0,-(a7)
\loop           tst.b   (a0)
                beq     \false
                cmp.b   #'0',(a0)
                blo     \true
                cmp.b   #'9',(a0)+
                bhi     \true
                bra     \loop

\false          andi.b  #%11111011,ccr
                bra     \quit
\true           ori.b   #%00000100,ccr
\quit           move.l  (a7)+,a0
                rts

RemoveSpaceTest movea.l #STRING_REMOVE_SPACE,a0
                jsr     RemoveSpace
                illegal

RemoveSpace     movem.l a0/a1,-(a7)
                move.l  a0,a1
\loop           tst.b   (a0)
                beq     \quit
                cmp.b   #' ',(a0)
                beq     \is_space
                move.b  (a0),(a1)+
\is_space       addq.l  #1,a0
                bra     \loop
\quit           move.b  #0,(a1)
                movem.l (a7)+,a0/a1
                rts

STRING_REMOVE_SPACE     dc.b    "5 +  12 ",0
STRING_IS_CHAR_ERROR    dc.b    "1233",0
STRING_IS_MAX_ERROR     dc.b    "32768",0
STRING_TO_CONVERT       dc.b    "12",0
sTest                   dc.b    "Hello World",0
sNextOpTest             dc.b    "12+5",0
sGetNumTest             dc.b    "104+9*2-3",0
sGetExprTest            dc.b    "104+9*2-3",0
buffer                  ds.b    10
