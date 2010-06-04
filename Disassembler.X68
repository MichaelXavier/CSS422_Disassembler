*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$1000
START:				; first instruction of program

*******************************************************************************
*	Subroutine:	h_to_a
*	Description:	takes Hex value, separates into individual Hex digits
*			then saves them in memory as ASCII values
*	Precondition:	D3 holds Hex value
*			D4 holds number of Hex digits in value,counter
*			A0 points to value in memory where ASCII values should
*			be saved
*	Postcondition:	A0's memory location will be filled with ASCII digits
*			A0 will be put back at the start. it is more useful to 
*			have it point to the start of the string it created than the end
*			D2 will be used as utility register
*			D6 and D7 will not be changed, no return value
*******************************************************************************
h_to_a		MOVEM.L	A0/D2,-(SP)	;save D2 and A0
		MOVEM.W	D4,-(SP)	; save D4
		CMPI.W	#00,D4		*is count done		
		BEQ	ha_exit		*if done exit subroutine
		ROL.L	#4,D3		*update D3 to next hex
		MOVE.L	D3,D2		*so D3 isn't corrupted
		ANDI.L	#$0000000F,D2	*isolate the last 4 binary digits
		SUBI.B	#1,D4		*update counter
		ADDI.W	#$30,D2		*add 30 to get ASCII	
		MOVE.B	D2,(A0)+	*save in memory and ++
		BRA	h_to_a		*back to top of loop
ha_exit		MOVEM.W	(SP)+,D4	*restore registers
		MOVEM.L (SP)+,A0/D2	
		RTS



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
		BSR	00(A1,D0)	; spool up FTL drives, Mr. Gaeta

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

code0000	MOVE.W	D2,D0 		; don't need to mask the first 4 because they are already 0. NICE		
		ANDI.W	#$0F00,D0	; get the next 4 to see which instruction it is
		ASR.W	#8,D0		; roll it right 4 so we can treat it like a number
		CMPI.W	#6,D0		; 6 is an ADDI
		BEQ	0000_addi	; we've gotten an ADDI
		CMPI.W	#2,D0		; 2 is an ANDI
		BEQ	0000_andi	; we've gotten an ANDI
		CMPI.W	#12,D0		; 12 is an CMPI
		BEQ	0000_cmpi	; we've gotten an CMPI
		CMPI.W	#10,D0		; 10 is an EORI
		BEQ	0000_eori	; we've gotten an EORI
		CMPI.W	#0,D0		; 0 is an ORI
		BEQ	0000_ori	; we've gotten an ORI
		CMPI.W	#4,D0		; 4 is a SUBI
		BEQ	0000_subi	; we've gotten an SUBI
		MOVE.B	#1,D6		; error!
		RTS			; FIXME: do i need to do a subroutine to handle error or just rts with bad bit?
		
0000_addi	LEA	os_addi,A1	; we got an ADDI, load the string and length
		MOVE.W	osl_addi,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?

0000_andi	LEA	os_andi,A1	; we got an ANDI, load the string and length
		MOVE.W	osl_andi,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?

0000_cmpi	LEA	os_cmpi,A1	; we got an CMPI, load the string and length
		MOVE.W	osl_cmpi,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?

0000_eori	LEA	os_eori,A1	; we got an EORI, load the string and length
		MOVE.W	osl_eori,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?

0000_ori	LEA	os_ori,A1	; we got an ORI, load the string and length
		MOVE.W	osl_ori,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?

0000_subi	LEA	os_subi,A1	; we got an SUBI, load the string and length
		MOVE.W	osl_subi,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?

code0001	STOP	#$2700
code0010	STOP	#$2700
code0011	STOP	#$2700

code0100	BSR	mask_f4		; cache full instruction word into D0
		CMPI.W	#$E71,D0	; 111001110001 remainder is nop
		BEQ	0100_nop
		CMPI.W	#$E75,D0
		BEQ	0100_rts
		MOVE.W	D2,D0		; restore D0 as a copy of d2
		ANDI.W	#$0F00,D0	; mask the second most significant nibble
		CMPI.W	#$0400,D0	; if the next 4 bits are 0100, NEG
		BEQ	0100_neg	; we've found a NEG
		CMPI.W	#$0600,D0	; if the next 4 bits are 0110, NOT
		BEQ	0100_not	; we've found a NOT
		CMPI.W	#$0002,D0	; if the next 4 bits are 0010, CLR
		BEQ	0100_clr	; we've found a CLR
		MOVE.W	D2,D0		; restore the D2 register
		ANDI.W	#$0FC0,D0	; take 6 bits after the first nibble
		ASR.W	#6,D0		; roll it right 4 bits so it can be treated as a number
		CMPI.W	#$3B,D0		; 111011 is JMP
		BEQ	0100_jmp	; we've found a JMP
		CMPI.W	#$3A,D0		; 111010 is JSR
		BEQ	0100_jsr	; we've found a JSR
		MOVE.W	D2,D0		; restore the D2 register
		ANDI.W	#$0FF8,D0	; take 9 bits after the first nibble
		CMPI.W	#$2100,D0	; 100001000 is SWAP
		BEQ	0100_swap	; we've found a SWAP
		MOVE.W	D2,D0		; reload the instruction
		ANDI.W	#$1C0,D0	; mask off bits 8-6
		CMPI.W, #$1C0,D0	; 111 is LEA
		BEQ	0100_lea
		
		;TODO: MOVEM or throw an error
		
0100_nop	LEA	os_nop,A1	; we got a NOP, load the string and length
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
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?		

0100_not	LEA	os_not,A1	; we got a NOT, load the string and length
		MOVE.W	osl_not,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?		
		
0100_clr	LEA	os_clr,A1	; we got a CLR, load the string and length
		MOVE.W	osl_clr,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		; TODO: continue on with clr stuff
		RTS			; FIXME: does this break all the way out of decode_inst?		

0100_jmp	LEA	os_jmp,A1	; we got a JMP, load the string and length
		MOVE.W	osl_jmp,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?		

0100_jsr	LEA	os_jsr,A1	; we got a JSR, load the string and length
		MOVE.W	osl_jsr,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_ea		; send the ea into ea land
		RTS			; FIXME: does this break all the way out of decode_inst?		

0100_swap	LEA	os_swap,A1	; we got a SWAP, load the string and length
		MOVE.W	osl_swap,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		; TODO: continue on with swap stuff
		RTS

0100_lea	LEA	os_lea,A1	; we got a LEA, load the string and length
		MOVE.W	osl_lea,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_ea		; send the EA stuff off to ea land for printing
		BSR	send_comma	; comma after the first operand
		MOVE.W	D2,D0		; reload the buffer
		ANDI.W	#$E00,D0	; bits 11-9 are the register number
		ASR.W	#9,D0		; roll it right so it can be treated as a number
		BSR	send_areg	; print out an address register to the buffer
		RTS		
		

code0101	STOP	#$2700
code0110	BSR	mask_f4		; cache full instruction word into D0
		CMPI.W	#$100,D0	; if the next 4 are 0001, its a BSR
		BEQ	0110_bsr
		MOVE.B	#1,D6		; error!
		RTS			; FIXME: do i need to do a subroutine to handle error or just rts with bad bit?
	
0110_bsr	LEA	os_bsr,A1	; we got a BSR, load the string and length
		MOVE.W	osl_bsr,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		; TODO: continue on with BSR stuff
		RTS
		
code0111	STOP	#$2700
code1000	STOP	#$2700 		; FIXME: this is either an OR or its bad
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
* D0 (W) is modified and restored to hold the size bit mask.
*
* Since sz_76 is used specifically for immediate instructions, it will copy the immediate
* operand and then call print_op1
**********************************************
sz_76		MOVEM.W	D0,-(SP)	; save registers
		MOVE.W	D2,D0		; copy the original to the D0
		ANDI.W	#$00C0,D0	; check bits 7-6 for size
		ASR.W	#6,D0		; roll it right so it is just a number, 0-2
		CMPI.W	#2,D0		; if D0 > 2, invalid
		BGT	sz_76err	; set the error bit
		BSR	print_3sz	; print out the size
		BSR	printi		; print out the immediate operand (first operand)
		BSR	send_comma
		BRA	sz_76exit	; skip over the error part
sz_76err	MOVE.B	#1,D6		; set the error bit
sz_76exit	MOVEM.W	(SP)+,D0	; restore registers
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
* printi - print an immediate
* D0 - size of the operation (tells it how much to read). This is not modified
* D3 - internal register for to hold the immediate read. Restored
* D4 - temporarily stores the number of hex digits in the string. Restored
*
* FIXME: is it possible to have a non hex value stored in the immediate?
**********************************************
printi		MOVEM.L	D3/A1,-(SP)	; save the internally used registers
		MOVEM.W	D4/D1,-(SP)
		CLR.L	D3		; clear out the whole register so we can treat it as the same size once copied into
		LEA	pound,A1	; print a pound symbol for the immediate
		MOVE.W	poundl,D1	; load the length of the pound
		BSR	print_instr
		CMPI.W	#0,D0		; if its 0, byte operation
		BEQ	printiw	
		CMPI.W	#1,D0		; if its 1, word operation
		BEQ	printil	
		CMPI.W	#2,D0		; if its 2, long operation
printib		MOVE.B	(A1)+,D3	; advance the instruction pointer 1 byte, read immediate to D3
		MOVE.B	#2,D4		; 2 hex nibbles long
		BRA	printic		; continue
printiw		MOVE.W	(A1)+,D3	; advance the instruction pointer 1 word, read immediate to D3
		MOVE.B	#4,D4		; 4 hex nibbles long
		BRA	printic		; continue
printil		MOVE.L	(A1)+,D3	; advance the instruction pointer 1 long, read immediate to D3
		MOVE.B	#8,D4		; 8 hex nibbles long
printic		MOVEA	A0,A3		; h_to_a messes with A0, lets cache it
		LEA	imm_str,A0	; we will store it in the immediate string
		BSR	h_to_a		; h_to_a will take D3 and D4 and store it at imm_str (A0)
		MOVEA	A0,A1		; print_instr wants the address in A1
		MOVEA	A3,A0		; put the instruction pointer back in A0
		MOVE.B	D4,D1		; print_instr wants string length in D1
		BSR	print_instr
		MOVEM.W	(SP)+,D4/D1	; restore the internally used register
		MOVEM.L	(SP)+,D3/A1
		RTS			; done	
		
**********************************************
* send_ea - Prepare and send out the ea data to decode_ea
* TODO: this makes assumptions about decode_ea that might be incorrect
* D0 is a temporary register to hold a mask of the full op word
**********************************************
send_ea		MOVEM.W	D0,-(SP)	; save D0
		MOVE.W	D2,D0		; get a fresh copy of the instruction
		ANDI.W	#$3F,D0		; we only want the last 6 bits (bit pos 0-5 LSB)
		BSR	decode_ea	; send it off into ea land, if something went bad, it will set a bad bit
		MOVEM.W	(SP)+,D0	; restore D0
		RTS
		
**********************************************
* send_areg - send an address register string to the buffer
* saves A1 and D0-D2
**********************************************
send_areg	MOVEM.L D0-D2/A1,-(SP)	; save A1 and D1
		LEA	areg_strs,A1	; load up the A registers table into A1
		BSR 	g_send_reg	; let the generic method handle the heavy lifting
		MOVEM.L	(SP)+,D0-D2/A1	; cleanup
		RTS			; done

**********************************************
* send_dreg - send an data register string to the buffer
* saves A1 and D0-D2
**********************************************	
send_dreg	MOVEM.L D0-D2/A1,-(SP)	; save A1 and D1
		LEA	dreg_strs,A1	; load up the D registers table into A1
		BSR 	g_send_reg	; let the generic method handle the heavy lifting
		MOVEM.L	(SP)+,D0-D2/A1	; cleanup
		RTS			; done
	
*********************************************
* g_send_reg - Generic send reg, expects A1 to hold the starting address of the table
* NEVER called directly, always called through send_areg or send_dreg
* D0 is the address count TODO: error check it here? I guess its impossible to exceed the number of registers
* indexes into the array of registers and appends it to the buffer
* note that this does NOT clean up after itself because it is meant to be called within the context of one
* of the send_*reg methods
*********************************************
g_send_reg	ANDI.W	$00FF,D0	; mask away the 8 MSBs of the word. We have to use a word size but there could be extra data in there
		MULU.B	#2,D0		; multiply offset by the length of each reg string
		MOVE.W, #2,D1 		; d1 holds the length, which is always 2 for a register
		LEA	(A1,D0.W),A1	; index in by the offset
		BSR	print_instr	; defer to print_instr to load it into the buffer
		RTS			; done

**********************************************
* send a comma off to the buffer
**********************************************
send_comma	LEA	comma,A1	; print a comma after the first operand
		MOVE.W	commal,D1	; load the length of the comma
		BSR	print_instr
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
os_lea		DC.B	'LEA '
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

sz_b		DC.B	'.B '
szl_b		szl_b-sz_b
sz_w		DC.B	'.W '
szl_w		szl_w-sz_w
sz_l		DC.B	'.L '
szl_l		szl_b-sz_b

pound		DC.B	'#'
poundl		poundl-pound
comma		DC.B	','
commal		commal-comma

imm_str		DS.B  	8 		; immediate hex value string, supports up to 32 bits (8 hex nibbles)

*********************
* Register strings
*********************
areg_strs	DC.B  	'A0','A1','A2','A3','A4','A5','A6','A7'
dreg_strs	DC.B  	'D0','D1','D2','D3','D4','D5','D6','D7'

	END	START		; last line of source












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
