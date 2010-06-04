*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$1000
START:				; first instruction of program

	MOVE.W	#2,D2	; index/offset
	;SUBI.W	#1,D2
	MULU.W	#2,D2	; mult by the common length of 2 to get actual offset
	MOVE.W	#2,D1	; length INCORRECT DEBUG
	MOVE.W	#01,D0	; task 1
	LEA	reg_strs,A1
	LEA	(A1,D2.W),A1
	TRAP	#15	;print

	MOVE.B	#9,D0
	TRAP	#15		; halt simulator

* Variables and Strings
reg_strs	DC.B  	'A0','A1','A2','A3','A4','A5','A6','A7'

	END	START		; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
