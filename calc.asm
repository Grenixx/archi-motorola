			org $4

vect1 		dc.l Main

			org $500

Main 		movea.l #STRING,a0
			jsr RemoveSpace
			illegal

RemoveSpace movem.l a0/a1,-(a7)
			move.l a0,a1
	
\loop		tst.b (a0)
			beq \quit
			
			cmp.b #' ',(a0)
			beq \is_space
			move.b (a0),(a1)+
\is_space	addq.l #1,a0
			bra \loop

\quit		move.b #0,(a1)
			movem.l (a7)+,a0/a1
			rts



STRING 		dc.b "5 +  12 ",0
