			org $4

vect1 		dc.l Main

			org $500

Main		bra IsCharErrorTest

IsMaxErrorTest 	movea.l #STRING_IS_MAX_ERROR,a0
				jsr IsMaxError
				illegal

IsMaxError	move.l a0,-(a7)
			jsr StrLen
			cmp.b 5,d0
			blt \false
			bhi \true
			cmp.b #3,(a0)+
			blt \false
			bhi \true
			cmp.b #2,(a0)+
			blt \false
			bhi \true
			cmp.b #7,(a0)+
			blt \false
			bhi \true
			cmp.b #6,(a0)+
			blt \false
			bhi \true
			cmp.b #7,(a0)+
			blt \false
			bhi \true
			
			bra \false
			

\false		andi.b #%11111011,ccr ; Set the Z flag to 0 (false).
			bra \quit
\true		ori.b #%00000100,ccr ; Set the Z flag to 1 (true).
			bra \quit
\quit		move.l (a7)+,a0
			rts

StrLen 	move.l a0,-(a7)
		clr.l d0

\loop 	tst.b (a0)+
		beq \quit
		addq.l #1,d0
		bra \loop

\quit 	movea.l (a7)+,a0 
		rts

IsCharErrorTest		movea.l #STRING_IS_CHAR_ERROR,a0
			jsr IsCharError
			illegal

IsCharError		move.l a0,-(a7)
			
\loop			tst.b (a0)
			beq \false
			
			cmp.b #'0',(a0)
			blO \true
			cmp.b #'9',(a0)+
			bhi \true
			bra \loop

\quit			move.l (a7)+,a0
			rts

\false			andi.b #%11111011,ccr ; Set the Z flag to 0 (false).
			bra \quit
\true			ori.b #%00000100,ccr ; Set the Z flag to 1 (true).
			bra \quit


RemoveSpaceTest 	movea.l #STRING_REMOVE_SPACE,a0
			jsr RemoveSpace
			illegal

RemoveSpace 		movem.l a0/a1,-(a7)
			move.l a0,a1
	
\loop			tst.b (a0)
			beq \quit
			
			cmp.b #' ',(a0)
			beq \is_space
			move.b (a0),(a1)+

\is_space		addq.l #1,a0
			bra \loop

\quit			move.b #0,(a1)
			movem.l (a7)+,a0/a1
			rts

STRING_REMOVE_SPACE 		dc.b "5 +  12 ",0
STRING_IS_CHAR_ERROR		dc.b "1233",0
STRING_IS_MAX_ERROR			dc.b "32768",0
