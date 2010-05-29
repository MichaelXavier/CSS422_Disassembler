*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$1000
START:				; first instruction of program


**********************************************
* decode - Expects A0 to point to the current instruction
* D2 is the unmodified opcode WORD
* D0 is used to index into the jump table and it contains bits and pieces of the instruction at different parts
* TODO: more documentation
**********************************************
decode_inst	MOVEM.L	A1-A2/D0-D2,-(SP)
		LEA	jmp_table,A1	; prepare to index into the jump table
		LEA	A0,A2		; cache the starting address for counting purposes
		MOVE.B	#12,D1 		; We will shift LSR right 12 bytes to get the 4 MSBs
		MOVE.W	(A0)+,D2	; advance A0 by a word, read the full opcode into D2
		MOVE.W	D2,D0		; cache a working copy of the opcode to D0
		LSR.W	D1,D0		; D0 now has the 4 bits we need for the jump table
		MULU	#6,D0		; Prepare D0 as an index into the jump table
		JSR	00(A1,D0)	; spool up FTL drives, Mr. Gaeta

				; TODO continue subroutine here. jump table should save the opcode and advance?

		MOVEM.L	(SP)+,A1-A2/D0-D2	; restore all the registers we used


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

code0100	BSR	mask_f4		; cache full instruction word into d0
		CMPI.W	#$E71,D0	; 111001110001 remainder is nop
		BEQ	0100_nop
		CMPI.W	#$E75,D0
		BEQ	0100_rts
		MOVE.W	D2,D0		; restore D0 as a copy of d2
		ANDI.W	#$0F00,D0	; mask the second most significant nibble
		CMPI.W	#$0400,D0	; if the next 4 bits are 0100, NEG
		BEQ	0100_neg	; we've found a NEG
		CMPI.W	#$0600,D0	; if the next 4 bits are 0110, NOT
		BEQ	0110_not	; we've found a NOT
		
		
0100_nop	LEA	os_nop,A1	; we got a nop, load the string and length
		MOVE.W	osl_nop,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		RTS			; FIXME: does this break all the way out of decode_inst?

0100_rts	LEA	os_rts,A1	; we got an RTS, load the string and length
		MOVE.W	osl_rts,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		RTS			; FIXME: does this break all the way out of decode_inst?		
		
0100_neg	LEA	os_neg,A1	; we got a NEG, load the string and length
		MOVE.W	osl_neg,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		; TODO: continue on with neg stuff
		RTS			; FIXME: does this break all the way out of decode_inst?		

0100_not	LEA	os_not,A1	; we got a NOT, load the string and length
		MOVE.W	osl_not,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		; TODO: continue on with not stuff
		RTS			; FIXME: does this break all the way out of decode_inst?		


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

**********************************************
* sz_76
* It is very common for bits 7-6 to be the size bits, so the logic
* to print that has been extracted here. D2 is expected to be the original register.
* D0 (W) is modified and restored to hold the size bit mask
**********************************************
sz_76		MOVEM.W	D0,-(SP)	; save registers
		MOVE.W	D2,D0		; copy the original to the D0
		ANDI.W	#$00C0,D0	; check bits 7-6 for size
		ASR.W	#6,D0		; roll it right so it is just a number, 0-2
		BSR	print_3sz	; print out the size
		MOVEM.W	(SP)+,D0	; restore registers
		RTS			; done

**********************************************
* print_3sz
* Since most of the size operations have 0,1,2 as B,W,L respectively
* This should DRY (dont repeat yourself) out the code a bit
* D0 argument is the 2 bit field for the size
* A1 (L) and D1 (W) are used to call out to print_instr and are restored at the end
**********************************************
print_3sz	MOVEM.L	A1,-(SP)
		MOVEM.W	D1,-(SP)
		CMPI.W	#0,D0		; if its 0, byte operation
		BEQ	print_szb	
		CMPI.W	#1,D0		; if its 1, word operation
		BEQ	print_szw	
		CMPI.W	#2,D0		; if its 2, long operation
		BEQ	print_szl
print_szb	LEA	sz_b,A1		; load size B string address
		MOVE.W	szl_b,D1	; load the string length
		BSR 	print_instr	; print out the size
		BRA	print_3szc	; continue		
print_szw	LEA	sz_w,A1		; load size W string address
		MOVE.W	szl_w,D1	; load the string length
		BSR 	print_instr	; print out the size
		BRA	print_3szc	; continue
print_szl	LEA	sz_l,A1		; load size L string address
		MOVE.W	szl_l,D1	; load the string length
		BSR 	print_instr	; print out the size
		BRA	print_3szc	; continue
print_3szc	MOVEM.W	(SP)+,D1	; continue with subroutine
		MOVEM.L	(SP)+,A1
		RTS

**********************************************
* mask_f4
* Given the original instruction word in D2, masks off
* the first 4 bits, leaving the last 12 in D0
**********************************************
mask_f4		MOVE.W	D2,D0		; return value will be in D0. used internally so thats OK
		ANDI.W	#$0FFF,D0	; done
		RTS

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
