*-----------------------------------------------------------
* Program    : Test
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	OPT	CRE
start	EQU	$4000
test1	EQU	$5000
test2	EQU	$500
test3	EQU	$2
test4	EQU	$1	

	ORG	start
	; BSR	fun
	;NOP
	;NOP
	;CLR.L	D0 THIS IS BROKEN
	OR.W	D0,D1
	SUB.W	D0,D1
	SUBA.W	D0,A1
	CMP.W	D0,D1
	CMPA.W	D0,A1
	EOR.W	D0,D1
	AND.W	D0,D1
	ADD.W	D0,D1
	ADDA.W	D0,A1

	;JMP	(A4)
	;BSR	A4 	BUSTED
	;LEA	test1,A0	*fill A0
	;LEA	test2,A1	*fill A

	
fun	CLR.W	D0		*clear data register
	RTS			*return from subroutine

iceIce	


	END	start		; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
