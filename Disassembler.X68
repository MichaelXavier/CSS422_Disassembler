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
code0100	STOP	#$2700	; TODO: most of these will be easy
code0101	STOP	#$2700
code0110	STOP	#$2700
code0111	STOP	#$2700
code1000	STOP	#$2700
code1001	STOP	#$2700
code1010	STOP	#$2700
code1011	BRA	code1011 ;FIXME
code1101	STOP	#$2700
code1110	STOP	#$2700
code1111	STOP	#$2700

* Variables and Strings
**********************************************
* OP names
**********************************************


os_add		DC.B	'ADD'
osl_add		osl_add-os_add
os_adda		DC.B	'ADDA'
osl_adda	osl_adda-os_adda
os_addi	  	DC.B	'ADDI'
osl_addi	osl_addi-os_addi
os_and	  	DC.B	'AND'
osl_and		osl_and-os_and
os_andi		DC.B	'ANDI'
osl_andi	osl_andi-os_andi
os_asl		DC.B	'ASL'
osl_asl		osl_asl-os_asl
os_asr		DC.B	'ASR'
osl_asr		osl_asr-os_asr
os_bsr		DC.B	'BSR'
osl_bsr		osl_bsr-os_bsr
os_clr		DC.B	'CLR'
osl_clr		osl_clr-os_clr
os_cmp		DC.B	'CMP'
osl_cmp		osl_cmp-os_cmp
os_cmpa		DC.B	'CMPA'
osl_cmpa	osl_cmpa-os_cmpa
os_cmpi		DC.B	'CMPI'
osl_cmpi	osl_cmpi-os_cmpi
os_eor		DC.B	'EOR'
osl_eor		osl_eor-os_eor
os_eori		DC.B	'EORI'
osl_eori	osl_eori-os_eori
os_exg		DC.B	'EXG'
osl_exg		osl_exg-os_exg
os_jmp		DC.B	'JMP'
osl_jmp		osl_jmp-os_jmp
os_jsr		DC.B	'JSR'
osl_jsr		osl_jsr-os_jsr
os_lea		DC.B	'LEA'
osl_lea		osl_lea-os_lea
os_lsr		DC.B	'LSR'
osl_lsr		osl_lsr-os_lsr
os_lsl		DC.B	'LSL'
osl_lsl		osl_lsl-os_lsl
os_move		DC.B	'MOVE'
osl_move	osl_move-os_move
os_movea	DC.B	'MOVEA'
osl_movea	osl_movea-os_movea
os_movem	DC.B	'MOVEM'
osl_movem	osl_movem-os_movem
os_neg		DC.B	'NEG'
osl_neg		osl_neg-os_neg
os_nop		DC.B	'NOP'
osl_nop		osl_nop-os_nop
os_not		DC.B	'NOT'
osl_not		osl_not-os_not
os_or		DC.B	'OR'
osl_or		osl_or-os_or
os_ori		DC.B	'ORI'
osl_ori		osl_ori-os_ori
os_rol		DC.B	'ROL'
osl_rol		osl_rol-os_rol
os_ror		DC.B	'ROR'
osl_ror		osl_ror-os_ror
os_rts		DC.B	'RTS'
osl_rts		osl_rts-os_rts
os_sub		DC.B	'SUB'
osl_sub		osl_sub-os_sub
os_suba		DC.B	'SUBA'
osl_suba	osl_suba-os_suba
os_subi		DC.B	'SUBI'
osl_subi	osl_subi-os_subi
os_swap		DC.B	'SWAP'
osl_swap	osl_swap-os_swap

sz_b		DC.B	'.B'
szl_b		szl_b-sz_b
sz_w		DC.B	'.W'
szl_w		szl_w-sz_w
sz_l		DC.B	'.L'
szl_l		szl_b-sz_b


	END	START		; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
