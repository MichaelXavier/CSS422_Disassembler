*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$1000
START:				; first instruction of program



	MOVE.B	#9,D0
	TRAP	#15		; halt simulator

* Variables and Strings
jmp_table	JMP	code0000
	JMP	code0000
	JMP	code0001
	JMP	code0010
	JMP	code0011
	JMP	code0100
	JMP	code0101
	JMP	code0110
	JMP	code0111
	JMP	code1000
	JMP	code1001
	JMP	code1010
	JMP	code1011
	JMP	code1100
	JMP	code1101
	JMP	code1110
	JMP	code1111

code0000	STOP	#$2700
code0001	STOP	#$2700
code0010	STOP	#$2700
code0011	STOP	#$2700
code0100	STOP	#$2700
code0101	STOP	#$2700
code0110	STOP	#$2700
code0111	STOP	#$2700
code1000	STOP	#$2700
code1001	STOP	#$2700
code1010	STOP	#$2700


	END	START		; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
