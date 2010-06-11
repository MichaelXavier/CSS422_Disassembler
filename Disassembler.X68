*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$1000
START:				; first instruction of program


		OPT		CRE		*so I can see Symbol Table
CR		EQU		$0D		*ASCII for carriage return
LF		EQU		$0A		*ASCII for line feed
task0		EQU		00		*to hold task 0
task1		EQU		01		*to hold task 1
task2		EQU		02		*to hold task 2
start		EQU		$1000		*to hold start address
addSz		EQU		08		*to hold size of an address
wdSz		EQU		04		*to hold size of a word
stack		EQU		$00100000	*stack location
evenAnd		EQU		$00000001	*to use for evenCk subroutine
strtAd		EQU		$00002000	*region program can start
endAd		EQU		$000FFFFF	*region program can end
region		EQU		80		*decimal number 80 to help fill 
space		EQU		$20		*to hold ASCII for space
D		EQU		$44		*to hold ASCII for D
A		EQU		$41		*to hold ASCII for A
T		EQU		$54		*to hold ASCII for T
comma		EQU		$2C		*for ASCII for comma
upY		EQU		$59		*for ASCII Y
lwY		EQU		$79		*for ASCII y
upQ		EQU		$51		*for ASCII Q
lwQ		EQU		$71		*for ASCII q


**************************************************************************
*			START OF IO CODE				 *
**************************************************************************

		ORG		start		*start of program
		LEA		stack,SP	*stack pointer in A7/SP
	
MNMIntro	MOVE.B		#task0,D0	*D0 hols task0, print w CR
		LEA		intro,A1	*A1 holds intro string
		MOVE.W		introL,D1	*D1 holds length of intro string
		TRAP		#15		*do it
		
		MOVE.B		#task2,D0	*D0 holds task2, take input
		LEA		dataSt,A1	*string to hold input
		TRAP		#15		*string ptr in A1,length in D1
		MOVE.B		(A1),D2		*so D2 holds first byte of input
		CMPI.B		#upY,D2		*is D2 a Y
		BEQ		stSec		*then start disassembling
		CMPI.B		#lwY,D2		*is D2 a y
		BEQ		stSec		*then start disassembling
		CMPI.B		#upQ,D2		*is D2 a Q
		BEQ		stp		*then done, stop
		CMPI.B		#lwQ,D2		*is D2 a q
		BEQ		stp		*then done, stop
		BRA		bIntro		*invalid input	
		
bIntro		MOVE.B		#task0,D0	*D0 holds task2, print w CR
		LEA		iErr,A1		*A1 holds error string
		MOVE.W		iErrL,D1	*D1 holds length of start error string
		TRAP		#15		*do it
		BRA		MNMIntro	*back to start sequence for reprompt
				
stSec		MOVE.B		#task1,D0	*D0 holds task1, print wo CR
		LEA		stAdd,A1	*A1 holds string asking for start
		MOVE.W		stAddL,D1	*D1 holds length of start string
		TRAP		#15		*do it
		
		MOVE.B		#task2,D0	*D0 holds task2, take input
		LEA		data1,A1	*to hold input string
		TRAP		#15		*string ptr in A1,length in D1
		CMPI.B		#00,D1		*compare D1 and 0
		BLE		badSt		*if less than or equal to 0 
		CMPI.B		#addSz,D1	*compare D1 and 8
		BGT		badSt		*if larger than 8 go to badSt
		CLR.L		D7		*clear D7
		BSR		a_to_h		*convert to hex
		CMPI.B		#01,D6		*check if D6 holds a 1/bad flag
		BEQ		badSt		*is bad go to badSt
		CLR.L		D2		*clear register
		MOVE.B		#addSz,D2	*put 8 in D2
		SUB.B		D1,D2		*subtract length of string from 8
		MULU.W		#4,D2		*multiply by 4
		ROL.L		D2,D7		*move hex over appropriate digits
		BSR		evenCk		*need to check if address is even 
		CMPI.L		#strtAd,D7	*compare start and D7
		BLT		badSt		*if smaller then is a bad address
		CMPI.L		#endAd,D7	*if end address is smaller, bad
		BGE		badSt		*if start is larger than end, bad
		MOVE.L		D7,istart	*istart holds valid start address in hex
		BRA		endSec		*go to end sequence

badSt		MOVE.B		#0,D6		*reset bad flag
		MOVE.B		#task0,D0	*D0 holds task2, print w CR
		LEA		stErr,A1	*A1 holds error string
		MOVE.W		stErrL,D1	*D1 holds length of start error string
		TRAP		#15		*do it
		BRA		stSec		*back to start sequence for reprompt

endSec		MOVE.B		#task1,D0	*D0 holds task1, print wo CR
		LEA		endAdd,A1	*A1 holds string asking for start
		MOVE.W		endAddL,D1	*D1 holds length of start string
		TRAP		#15		*do it
		
		MOVE.B		#task2,D0	*D0 holds task2, take input
		LEA		data2,A1	*to hold input string
		TRAP		#15		*string ptr in A1,length in D1
		CMPI.B		#00,D1		*compare D1 and 0
		BLE		badEnd		*if less than or equal to 0 
		CMPI.B		#addSz,D1	*compare D1 and 8
		BGT		badEnd		*if larger than 8 go to badSt
		CLR.L		D7		*clear D7
		BSR		a_to_h		*convert to hex
		CMPI.B		#01,D6		*check if D6 holds a 1/bad flag
		BEQ		badEnd		*is bad go to badSt
		CLR.L		D2		*clear register
		MOVE.B		#addSz,D2	*put 8 in D2
		SUB.B		D1,D2		*subtract length of string from 8
		MULU.W		#4,D2		*multiply by 4
		ROL.L		D2,D7		*move hex over appropriate digits
		CMPI.L		#endAd,D7	*compare end address and D7
		BGT		badEnd		*if larger, it's invalid
		MOVE.L		istart,D6	*move istart to D6
		CMP.L		D6,D7		*compare istart and end address
		BLE		badEnd		*if it's less than or equal, bad
		MOVE.L		D7,iend		*iend holds valid start address in hex
		BRA		buffy		*go create buffers

badEnd		MOVE.B		#0,D6		*reset bad flag
		MOVE.B		#task0,D0	*D0 holds task2, print w CR
		LEA		endErr,A1	*A1 holds error string
		MOVE.W		endErrL,D1	*D1 holds length of start error string
		TRAP		#15		*do it
		BRA		endSec		*back to end sequence for repromp
		
buffy		MOVE.W		#goodBuf,A0	*set pointer
		MOVE.W		#region,D0	*set counter
		JSR		fillBuf		*branch to fillBuf subroutine
		
		MOVE.W		#badBuf,A0	*set pointer
		MOVE.W		#region,D0	*set counter
		JSR		fillBuf		*branch to fillBuf subroutine
		
		MOVE.B		#task0,D0	*D0 holds task2, print w CR
		LEA		headr,A1	*A1 holds error string
		MOVE.W		headrL,D1	*D1 holds length of start error string
		TRAP		#15		*do it
		
		MOVE.L		#iend,A1	*move ptr to A1
		MOVEA.L		(A1),A4		*move end address to A4
		MOVE.L		#istart,A1	*D0 now holds a start address
		MOVEA.L		(A1),A0		*A0 holds address
		
dis		JSR		data		*fill up bad buffer
		CMPA.L		A0,A4		*compare addresses
		BLT		MNMIntro	*done with region
		MOVE.W		#goodBuf,A3	*A3 PRT TO GOOD BUFFER
		CLR.L		D3		*D3 HOLDS COUNT TO BUFFERS
		BSR		decode_inst	*A0 needst to pt to next, D6 needs 1/0,D1 needs count in byte
		*MOVE.B		#01,D6		*set bad flag
		MOVE.W		#$12,D1		*D1 needs to hold count
*		COUNT WORKS W WORDS??
		JSR		printAsm	*print the good or bad buffer
		MOVE.W		(A0)+,D6	*update A0
		CLR.L		D6		*clear D6
		MOVE.B		#0,D6		*reset bad flag	
		BRA		dis		*back to top

stp		STOP		#$2700		*back to simulator
*******************************************************************************
* Subroutine:		a_to_h
* Description:		converts a ascii string to a hex value
* Precondition:		assumes A1 is a pointer to the string, and D1 holds 
*			string's length, and D7 is cleared
* Postcondition:	will return the hex value in D7, if invalid characters
*			in the string D6 will be set to 1
*			A1 and D1 will be modified
*			Internally will use D2
*			pushes D2 and D1 on stack
*******************************************************************************
	
a_to_h		MOVEM.L		D1/D2,-(SP)	*put utility register on stack
a_to_hSt	CMPI.B		#00,D1		*if D1 is 0 done
		BEQ		hexExit		*if done exit
		SUBI.B		#01,D1		*update counter
		ROL.L		#4,D7		*prepare register to take next hex
		MOVE.B		(A1)+,D2	*D2 holds next byte to convert
		CMPI.B		#$30,D2		*compare 30 to D2 if 
		BLT		badEx		*is ASCII is less than 30 bad
		CMPI.B		#$39,D2		*if equal or less than 39
		BLE		ah_num		*convert a number
		CMPI.B		#$40,D2		*if D2 is $40 invalid
		BLE		badEx		*then bad and exit
		CMPI.B		#$46,D2		*compare D2 to $46
		BLE		ah_uc		*convert to hex letter
		CMPI.B		#$61,D2		*compare D2 to $61
		BLT		badEx		*if less than bad and exit
		CMPI.B		#$66,D2		*compare D2 to $66
		BLE		ah_lc		*if less than or equal convert to HEX
		BRA		badEx		*if haven't coverted here, it's invalid
ah_num		SUBI.B		#$30,D2		*convert a number
		OR.B		D2,D7		*add hex digit to D7
		BRA		a_to_hSt	*back to loop
ah_lc		SUBI.B		#$57,D2		*convert to Hex letter
		OR.B		D2,D7		*add hex digit to D7
		BRA		a_to_hSt	*back to loop
ah_uc		SUBI.B		#$37,D2		*convert to Hex letter
		OR.B		D2,D7		*add hex digit to D7
		BRA		a_to_hSt	*back to loop
badEx		MOVE.B		#01,D6		*set bad flag
		BRA		hexExit		*then exit
hexExit		MOVEM.L		(SP)+,D1/D2	*pop register off stack
		RTS				*return from subroutine	



*******************************************************************************
* Subroutine:		evenCk
* Description:		checks if Hex address is even or odd
* Precondition:		assumes D7 holds address
* Postcondition:	if even, nothing will change
*			if odd, will add one to D7 and return it
*			Internally will use D2, so pushes that on stack
*			will not affect good bad flag, will return D7
*******************************************************************************
evenCk		MOVEM.L		D2,-(SP)	*put utility register on stack
		MOVE.L		D7,D2		*move D7 to D2
		ANDI.L		#evenAnd,D2	*and $00000001 with D2
		CMPI.L		#00,D2		*if D2 is 0 then value was odd
		BEQ		even		*if D2 equals 0 it was even	
		ADDI.L		#01,D7		*if was odd add one to D7 
		BRA		even		*done
even		MOVEM.L	(SP)+,D2		*pop resister off stack		
		RTS				*return from subroutine
		
*******************************************************************************
* Subroutine:		fillBuf
* Description:		subroutine that fills region with ASCII character 20
*			which is spaces
* Precondition:		assumes D0 is set with number of bytes, counter
*			assumes A0 points at first byte in region to fill
* Postcondition:	region will be filled with spaces
*			D0 and A0 will be modified
*			no return value, no use of good/bad flag, no use of 
*			internal registers
*			nothing pushed on stack		
*******************************************************************************
fillBuf		CMPI.W	#00,D0			*see if D0 is empty
		BEQ	exit			*if empty exit
		MOVE.B	#space,(A0)+		*copy space and ++
		SUBI.W	#01,D0			*update counter
		BRA	fillBuf			*branch to top of routine
exit		RTS				*return to subroutine

*******************************************************************************
* Subroutine:		print_instr
* Description:		subroutine that takes a string and copies it to 
*			good buffer
* Preconditions:	A3 points to good buffer position
*			D1 holds length of string in words
*			D3 holds count for good buffer
*			A1 points to the string to be copied
* Postconditions:	string will be added to buffer 
*			internally will use register D0 and A2
*			D3 and A3 will be modified
*			D1,A1,D0, and A2 will be pushed to stack
*******************************************************************************
print_instr	MOVEM.L	A1/A2/D1/D0,-(SP)	*push to stack
		ADD.B	D1,D3			*update count of buffer
prtInL		CMPI.B	#00,D1			*compare 0 to counter
		BEQ	done			*if 0, done
		MOVE.W	(A1)+,D0		*move next word to data register
		MOVE.W	D0,(A3)+		*move next word from register to buffer
		SUBI.B	#01,D1			*update counter
		BRA	prtInL			*back to loop
done		MOVEM.L	(SP)+,A1/A2/D1/D0	*restore stack	
		RTS				*return from subroutine
		
*******************************************************************************
* Subroutine:		printAsm
* Description:		subroutine that checks good bad flag, if it shows
*			0 for good will print good buffer, if shows 1 for bad
*			will print bad buffer.  Assumes both buffers are 
*			populated with a string of ASCII characters
* Precondition:		good and bad buffer needs to be set
*			D1 needs to hold count in bytes of string
* Postcondition:	instruction will be printed to screen
*			internally will use A1,D0, and D1
*			A1,D0, and D1 will be pushed to stack
*******************************************************************************
printAsm	MOVEM.L	A0/D0/D1,-(SP)		*push to stack
		CMPI.B	#01,D6			*check if D6 holds a 1/bad flag
		BEQ	prtBd			*if bad print bad buffer
		BRA	prtGd			*if not bad must be good
prtBd		MOVE.L	#badBuf,A1		*A1 holds start of badBuffer		
		MOVE.B	#task0,D0		*D0,A1, and D1 sb set up
		TRAP	#15			*do it
		BRA	prtDn			*done
prtGd		MOVE.L	#goodBuf,A1		*move A1 to hold string
		MOVE.B	#task0,D0		*D0,A1, and D1 sub set up
		TRAP	#15			*do it
		BRA	prtDn			*done
prtDn		MOVEM.L	(SP)+,A0/D0/D1		*restore stack
		RTS				*return from subroutine	
*******************************************************************************
*	Subroutine:	h_to_a
*	Description:	takes Hex value, separates into individual Hex bytes
*			then saves them in memory as ASCII values
*	Precondition:	D3 holds Hex value
*			D4 holds number of Hex bytes in value,counter
*			A3 points to value in memory where ASCII values should
*			be saved
*			assumes count will be 4 for a word or 8 for a long
*	Postcondition:	A3's memory location will be filled with ASCII digits
*			A3 will point to end of string
*			D2 will be used as utility register
*			D6 and D7 will not be changed, no return value
*******************************************************************************
h_to_a		MOVEM.L	D3/D4/D2,-(SP)	;save D2 and A0
		CMPI.W	#04,D4		*see if D4 is a long or word
		BEQ	moveOvr		*if a word need to shift 
h_to_aSt	CMPI.W	#00,D4		*is count done		
		BEQ	ha_exit		*if done exit subroutine
		ROL.L	#4,D3		*update D3 to next hex
		MOVE.L	D3,D2		*so D3 isn't corrupted
		ANDI.L	#$0000000F,D2	*isolate the last 4 binary digits
		SUBI.B	#1,D4		*update counter
		CMPI.B	#$09,D2		*compare hex 9 and D2
		BLE	num		*if 9 or less it's a number
		BRA	uc		*then is a letter
num		ADDI.W	#$30,D2		*convert a number
		BRA	mem		*now put in  memory
uc		ADDI.W	#$37,D2		*convert to Hex letter
		BRA	mem		*now put in memory
mem		MOVE.B	D2,(A3)+	*save in memory and ++
		BRA	h_to_aSt	*back to top of loop
moveOvr		ROL.L	#08,D3		*move over 2 digits
		ROL.L	#08,D3		*move over 2 digits
		BRA	h_to_aSt	*start the loop
ha_exit		MOVEM.L	(SP)+,D3/D4/D2	;pop off stack
		RTS


	
*******************************************************************************
* Subroutine:		data
* Description:		subroutine that sets up the bad buffer to print a bad
*			location in memory
* Precondition:		assumes A0 points to location in memory, and assumes 
*			will always print 1 words worth of memory
* Postcondition:	A0 will not be changed
*			bad buffer will be set up with the address, space, 
*			DATA, space, word value at memory, CR, LR
*			no return value, no use of good/bad flag
*			internally will use A1,A3,D3,and D4
*			will push A1,A3,D3, and D4
*			NOTE will always be for 1 word, 
*******************************************************************************
data		MOVEM.L	A1/A3/D3/D4,-(SP)	;save to stack
		MOVEA.L	A0,A1			*use A1 internally	
		MOVE.L	A1,D3			*D3 holds address in hex
		MOVEA.L	#badBuf,A3		*A3 points to start of buf
		MOVE.B	#addSz,D4		*D4 holds counter
		JSR	h_to_a			*convert and save
		MOVE.B	#space,(A3)+		*move a space 
		MOVE.B	#D,(A3)+		*move D to memory and ++
		MOVE.B	#A,(A3)+		*move A to memory and ++
		MOVE.B	#T,(A3)+		*move T to memory and ++
		MOVE.B	#A,(A3)+		*move A to memory
		MOVE.B	#space,(A3)+		*move a space
		MOVE.W	(A1),D3			*D3 holds word of memory in hex
		MOVE.B	#wdSz,D4		*D4 holds count
		JSR	h_to_a			*convert and save
		MOVE.B	#comma,(A3)+		*put in comma
		MOVE.B	#CR,(A3)+		*put in CR
		MOVE.B	#comma,(A3)+		*put in comma
		MOVE.B	#LF,(A3)+		*put in LR	
		MOVEM.L	(SP)+,A1/A3/D3/D4	*pop off stack	
		RTS				*return from subroutine

**************************************************************************
*			END OF IO CODE				 *
**************************************************************************


**************************************************************************
*			START OF OPCODE CODE				 *
**************************************************************************

**********************************************
* decode - Expects A0 to point to the current instruction
* D2 is the unmodified opcode WORD
* D0 is used to index into the jump table and it contains bits and pieces of the instruction at different parts
* A5 - pointer to data after the opcode that is advanced/used by EA. not restored
* D5 - Byte-long indicator of instruction size needed for some immediate modes by EA. restored
**********************************************
decode_inst	MOVEM.L	A1-A2/D0-D2/D4/D5,-(SP)
		LEA	jmp_table,A1	; prepare to index into the jump table
		MOVE.L	A0,D4		; cache starting address for PC in ea land
		MOVEA.L	A0,A2		; cache the starting address for counting purposes
		MOVE.B	#12,D1 		; We will shift LSR right 12 bytes to get the 4 MSBs
		MOVE.W	(A0)+,D2	; advance A0 by a word, read the full opcode into D2
		MOVEA.L	A0,A5		; after-opcode pointer for EA is set up
		MOVE.W	D2,D0		; cache a working copy of the opcode to D0
		LSR.W	D1,D0		; D0 now has the 4 bits we need for the jump table
		
		ADDQ.W	#1,D0		;DEBUG: off by 1, this is almost certainly not the solution!!!!!!!!!!!!!!!!!!!!!!
		
		MULU.W	#6,D0		; Prepare D0 as an index into the jump table
		JSR	00(A1,D0)	; spool up FTL drives, Mr. Gaeta

decodei_ext	MOVEA.L	A5,A0			; advance the pointer up to where EA left its read pointer
		LEA	crs,A1			; send cr
		MOVE.W	crsl,D1			
		BSR	print_instr
		LEA	lfs,A1			; send lf
		MOVE.W	lfsl,D1			
		BSR	print_instr
		MOVEM.L	(SP)+,A1-A2/D0-D2/D4/D5	; restore all the registers we used

		
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
		BEQ	addi_0000	; we've gotten an ADDI
		CMPI.W	#2,D0		; 2 is an ANDI
		BEQ	andi_0000	; we've gotten an ANDI
		CMPI.W	#12,D0		; 12 is an CMPI
		BEQ	cmpi_0000	; we've gotten an CMPI
		CMPI.W	#10,D0		; 10 is an EORI
		BEQ	eori_0000	; we've gotten an EORI
		CMPI.W	#0,D0		; 0 is an ORI
		BEQ	ori_0000	; we've gotten an ORI
		CMPI.W	#4,D0		; 4 is a SUBI
		BEQ	subi_0000	; we've gotten an SUBI
		MOVE.B	#1,D6		; error!
		JMP	decodei_ext	; we are done with the decode
		
addi_0000	LEA	os_addi,A1	; we got an ADDI, load the string and length
		MOVE.W	osl_addi,D1	; FIXME: assuming that I/O's function wants them in these regs
		JMP	cnti_0000

andi_0000	LEA	os_andi,A1	; we got an ANDI, load the string and length
		MOVE.W	osl_andi,D1	; FIXME: assuming that I/O's function wants them in these regs
		JMP	cnti_0000

cmpi_0000	LEA	os_cmpi,A1	; we got an CMPI, load the string and length
		MOVE.W	osl_cmpi,D1	; FIXME: assuming that I/O's function wants them in these regs
		JMP	cnti_0000

eori_0000	LEA	os_eori,A1	; we got an EORI, load the string and length
		MOVE.W	osl_eori,D1	; FIXME: assuming that I/O's function wants them in these regs
		JMP	cnti_0000

ori_0000	LEA	os_ori,A1	; we got an ORI, load the string and length
		MOVE.W	osl_ori,D1	; FIXME: assuming that I/O's function wants them in these regs
		JMP	cnti_0000

subi_0000	LEA	os_subi,A1	; we got an SUBI, load the string and length
		MOVE.W	osl_subi,D1	; FIXME: assuming that I/O's function wants them in these regs
		JMP	cnti_0000
		
cnti_0000	BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; CONTINUE: print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		JMP	decodei_ext	; we are done with the decode

code0001	BSR	extr_opmode	; pull out 8-6 bits into D0
		CMPI.W	#$80,D0		; 001 is a MOVEA and isn't allowed with this size
		BNE	code0001c	; continue if not a match
		MOVE.W	#1,D6		; error!
		JMP	decodei_ext	; we are done with the decode
		
code0001c	LEA	os_move,A1	; we got an MOVE.B, load the string and length
		MOVE.W	osl_move,D1	
		BSR	print_instr	; print the instruction to the buffer
		LEA	sz_b,A1		; load size B string address
		MOVE.W	szl_b,D1	; load the string length
		MOVE.W	#0,D5		; Save the size for EA
		BSR 	print_instr	; print out the size
		JMP	decodei_ext	; we are done with the decode

code0010	BSR	extr_opmode	; pull out 8-6 bits into D0
		CMPI.W	#$80,D0		; 001 is a MOVEA
		BNE	movel_0010
		LEA	jb_movea,A4	; save the jumpback to A4
		LEA	os_movea,A1	; we got an MOVEA.L, load the string and length
		MOVE.W	#2,D5		; Save the size for EA
		MOVE.W	osl_movea,D1	
		BSR	print_instr	; print the instruction to the buffer
		BRA	cnt_0010	; continue
		
movel_0010	LEA	os_move,A1	; we got an MOVE.L, load the string and length
		MOVE.W	osl_move,D1	
		BSR	print_instr	; print the instruction to the buffer
		MOVE.W	#2,D5		; Save the size for EA
		LEA	jb_move,A4	; set the jumpback to A4		

cnt_0010	LEA	sz_l,A1		; load size L string address
		MOVE.W	szl_l,D1	; load the string length
		MOVE.W	#2,D5		; Save the size for EA
		BSR 	print_instr	; print out the size
		BSR	reg_119		; extract the register
		JMP	(A4)		; go to the jumpback so MOVE/MOVEA can handle the regs independently
		

code0011	BSR	extr_opmode	; pull out 8-6 bits into D0
		CMPI.W	#$80,D0		; 001 is a MOVEA
		BNE	movew_0011
		LEA	jb_movea,A4	; save the jumpback to A4
		LEA	os_movea,A1	; we got an MOVEA.W, load the string and length
		MOVE.W	#1,D5		; Save the size for EA
		MOVE.W	osl_movea,D1	
		BSR	print_instr	; print the instruction to the buffer
		BRA	cnt_0011	; continue


movew_0011	LEA	os_move,A1	; we got an MOVE.W, load the string and length
		MOVE.W	osl_move,D1	
		MOVE.W	#1,D5		; Save the size for EA
		BSR	print_instr	; print the instruction to the buffer
		LEA	jb_move,A4	; set the jumpback to A4		

cnt_0011	LEA	sz_l,A1		; load size L string address
		MOVE.W	szl_l,D1	; load the string length
		MOVE.W	#2,D5		; Save the size for EA
		BSR 	print_instr	; print out the size
		JMP	(A4)		; go to the jumpback so MOVE/MOVEA can handle their cases independently
		
jb_move		; FIXME: apparently the dest EA not only comes first but transposes the halves. this is handled below but I don't know if swapping the halves alone will solve it
		BSR	send_ea		; ea at the lsb end is the *source* according to the manual
		BSR	send_comma	; first operand handled
		MOVE.W	D2,D0		; reload the instruction
		ANDI.W	#$FC0,D0	; we want EA bits 11-6, we are going to flip the two halves of bits 11-6
		MOVE.W	D0,D1		; make a copy to D1 to swap ea halves
		ANDI.W	#$1C0,D0	; just the lsb 3
		ANDI.W	#$E00,D1	; just the msb 3
		LSL.W	#3,D0		; shift the right one left and the left one right
		LSR.W	#3,D1
		OR.W	D1,D0		; combine them
		LSR.W	#6,D0		; roll the whole chunk right to be treated as a number
		BSR	decode_ea	; send D0 off into ea land, if something went bad, it will set a bad bit
		JMP	decodei_ext	; we are done with the decode

jb_movea	BSR	send_ea		; EA at the end is the source, do it first
		BSR	send_comma	; first operand handled
		BSR	reg_119		; extract the register
		BSR	send_areg	; send the destination as an address register
		JMP	decodei_ext	; we are done with the decode

code0100	BSR	mask_f4		; cache full instruction word into D0
		CMPI.W	#$E71,D0	; 111001110001 remainder is nop
		BEQ	nop_0100
		CMPI.W	#$E75,D0
		BEQ	rts_0100
		MOVE.W	D2,D0		; restore D0 as a copy of d2
		ANDI.W	#$0F00,D0	; mask the second most significant nibble
		CMPI.W	#$0400,D0	; if the next 4 bits are 0100, NEG
		BEQ	neg_0100	; we've found a NEG
		CMPI.W	#$0600,D0	; if the next 4 bits are 0110, NOT
		BEQ	not_0100	; we've found a NOT
		CMPI.W	#$0002,D0	; if the next 4 bits are 0010, CLR
		BEQ	clr_0100	; we've found a CLR
		MOVE.W	D2,D0		; restore the D2 register
		ANDI.W	#$0FC0,D0	; take 6 bits after the first nibble
		ASR.W	#6,D0		; roll it right 4 bits so it can be treated as a number
		CMPI.W	#$3B,D0		; 111011 is JMP
		BEQ	jmp_0100	; we've found a JMP
		CMPI.W	#$3A,D0		; 111010 is JSR
		BEQ	jsr_0100	; we've found a JSR
		MOVE.W	D2,D0		; restore the D2 register
		ANDI.W	#$0FF8,D0	; take 9 bits after the first nibble
		CMPI.W	#$2100,D0	; 100001000 is SWAP
		BEQ	swap_0100	; we've found a SWAP
		BSR	extr_opmode	; we happen to need bits 8-6
		MOVE.W	D2,D0		; reload the instruction
		ANDI.W	#$1C0,D0	; mask off bits 8-6
		CMPI.W 	#$1C0,D0	; 111 is LEA
		BEQ	lea_0100
		MOVE.W	D2,D0		; reload the instruction
		BTST.L	#11,D0		; if bit 11 isn't set, it can't be a movem so we don't support it
		BNE	err_0100	; error!
		ANDI.W	#$380,D0	; check if bits 9-7 are 001
		CMPI.W	#$80,D0
		BNE	err_0100

movem_0100	LEA	os_movem,A1	; we got a MOVEM, load the string and length
		MOVE.W	osl_movem,D1
		BSR	print_instr	; print the instruction to the buffer
		MOVE.W	D2,D0		; reload the instruction
		BTST.L	#6,D0		; size field, 0 for word, 1 for long
		BEQ	moveml_0100	; long

movemw_0100	LEA	sz_w,A1		; load size W string address
		MOVE.W	szl_w,D1	; load the string length
		MOVE.W	#1,D5		; Save the size for EA
		BRA	movemc_0100	; continue		

moveml_0100	LEA	sz_l,A1		; load size L string address
		MOVE.W	szl_l,D1	; load the string length
		MOVE.W	#1,D5		; Save the size for EA

movemc_0100	BSR 	print_instr	; print out the size
		BTST.L	#10,D0		; direction. if 0, reg to mem, else mem to reg
		BEQ	movemr_0100
movemm_0100	BSR	send_ea		; reg to mem
		BSR	send_comma
		BSR	send_movem
		JMP	decodei_ext
movemr_0100	BSR	send_movem	; mem to reg
		BSR	send_comma
		BSR	send_ea
		JMP	decodei_ext	; we are done with the decode

err_0100	MOVE.W 	#1,D6		; error!
		JMP	decodei_ext	; we are done with the decode
		
nop_0100	LEA	os_nop,A1	; we got a NOP, load the string and length
		MOVE.W	osl_nop,D1
		BSR	print_instr	; print the instruction to the buffer
		JMP	decodei_ext	; we are done with the decode

rts_0100	LEA	os_rts,A1	; we got an RTS, load the string and length
		MOVE.W	osl_rts,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		JMP	decodei_ext	; we are done with the decode
		
neg_0100	LEA	os_neg,A1	; we got a NEG, load the string and length
		MOVE.W	osl_neg,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		JMP	decodei_ext	; we are done with the decode

not_0100	LEA	os_not,A1	; we got a NOT, load the string and length
		MOVE.W	osl_not,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea		; send the ea into ea land
		JMP	decodei_ext	; we are done with the decode
		
clr_0100	LEA	os_clr,A1	; we got a CLR, load the string and length
		MOVE.W	osl_clr,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	sz_76		; print out the size from bits 7-6
		BSR	send_ea
		JMP	decodei_ext	; we are done with the decode

jmp_0100	LEA	os_jmp,A1	; we got a JMP, load the string and length
		MOVE.W	osl_jmp,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_ea		; send the ea into ea land
		JMP	decodei_ext	; we are done with the decode

jsr_0100	LEA	os_jsr,A1	; we got a JSR, load the string and length
		MOVE.W	osl_jsr,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_ea		; send the ea into ea land
		JMP	decodei_ext	; we are done with the decode

swap_0100	LEA	os_swap,A1	; we got a SWAP, load the string and length
		MOVE.W	osl_swap,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		MOVE.W	D2,D0		; reload the instruction
		ANDI.W	#7,D0		; we only want the last 3 bits for the register
		BSR	send_dreg	; send out the dreg and we're done
		JMP	decodei_ext	; we are done with the decode

lea_0100	LEA	os_lea,A1	; we got a LEA, load the string and length
		MOVE.W	osl_lea,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_ea		; send the EA stuff off to ea land for printing
		BSR	send_comma	; comma after the first operand
		BSR	reg_119		; extract the register field and save it to D0
		BSR	send_areg	; print out an address register to the buffer
		JMP	decodei_ext	; we are done with the decode
		
code0101	STOP	#$2700

code0110	BSR	mask_f4		; cache full instruction word into D0
		CMPI.W	#$100,D0	; if the next 4 are 0001, its a BSR
		BEQ	bsr_0110
		MOVE.B	#1,D6		; error!
		JMP	decodei_ext	; we are done with the decode
	
bsr_0110	LEA	os_bsr,A1	; we got a BSR, load the string and length
		MOVE.W	osl_bsr,D1	; FIXME: assuming that I/O's function wants them in these regs
		BSR	print_instr	; print the instruction to the buffer
		LEA	os_dollar,A1	; send dollar for address
		MOVE.W	os_dollarl,D1	; length for printing
		BSR	print_instr
		MOVEM.W	D4,-(SP)	; save D4, which will hold the count of bytes
		ANDI 	#$FF,D0		; mask off the last 8 bits
		CMPI.W	#$00,D0		; if its 00, its word
		BNE	bsr_retry
		CLR.L	D3		; clear it out to prevent conflicts, this will be passed to h_to_a
bsr_word	MOVE.W	(A5)+,D3	; its a word. advance the after opcode pointer 
		MOVE.B	#$4,D4		; 4 hex bytes for a word
		JMP	bsr_cnt

bsr_retry	CMPI.W	#$FF,D0		; if its FF, its long
		BNE	bsr_byte	; otherwise its a byte

bsr_long	MOVE.L	(A5)+,D3	; advance the after opcode pointer a long
		MOVE.B	#$8,D4		; 8 hex bytes for a long
		JMP	bsr_cnt

bsr_byte	MOVE.B	(A5)+,D3	; advance the after opcode pointer a byte
		MOVE.B	#$2,D4		; 2 hex bytes for a byte, fall through to bsr cnt

bsr_cnt		BSR	h_to_a		; convert to ascii, memory pointer will be in A3
		MOVEA.L	A3,A1		; load A3 with the string address returned
		BSR	print_instr
		MOVEM.W	(SP)+,D4	; restore D4
		JMP	decodei_ext	; we are done with the decode
		
code0111	STOP	#$2700		;FIXME: handle better
code1000	BSR	extr_opmode	; valid OR opmodes are anything but 011 or 111
		ANDI	#3,D0		; check last 2 bits
		CMPI.B	#3,D0		; if they are set, bad instruction
		BNE	or_1000		; if not, we've got an OR
		MOVE.B	#1,D6		; error!
		JMP	decodei_ext	; we are done with the decode
		
or_1000		LEA	os_or,A1	; we got a OR, load the string and length
		MOVE.W	osl_or,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode

code1001	BSR 	extr_opmode	; opmode will differentiate between SUB and SUBA
		ANDI	#3,D0		; check last 2 bits
		CMPI.B	#3,D0		; if the last 2 bits are 11, SUBA
		BEQ	suba_1001	; otherwise, fall through sub
		
sub_1001	LEA	os_sub,A1	; we got a SUB, load the string and length
		MOVE.W	osl_sub,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode
		
suba_1001	LEA	os_suba,A1	; we got a SUBA, load the string and length
		MOVE.W	osl_suba,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode

code1010	STOP	#$2700
code1011	BSR	extr_opmode	; opmode differentiates between CMP,CMPA,EOR
		CMPI.B	#2,D0		; 000-010 is CMP
		BLS	cmp_1011
		CMPI.B	#3,D0		; 011 and 111 are cmpa
		BEQ	cmpa_1011
		CMPI.B	#7,D0
		BEQ	cmpa_1011	; otherwise fall through to eor

eor_1011	LEA	os_eor,A1	; we got a EOR, load the string and length
		MOVE.W	osl_eor,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode
		
cmpa_1011	LEA	os_cmpa,A1	; we got a CMPA, load the string and length
		MOVE.W	osl_cmpa,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode
		
cmp_1011	LEA	os_cmp,A1	; we got a CMP, load the string and length
		MOVE.W	osl_cmp,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode
		
code1100	MOVE.W	D2,D0		; reload the instruction
		ANDI.W	#$1F8,D0	; take off bits 8-3
		CMPI	#$140,D0	; the pattern 101000 there is EXG with data regs
		BEQ	exg_data
		CMPI	#$148,D0	; the pattern 101001 there is EXG with address registers
		BEQ	exg_addr
		CMPI	#$188,D0	; the pattern 110001 there is EXG with data and address regs
		BEQ	exg_both	; otherwise, fall through to AND

and_1100	LEA	os_and,A1	; we got an AND, load the string and length
		MOVE.W	osl_and,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode

exg_data	MOVEM.L	A2-A3,-(SP)	; A2 and A3 will store left/right functions; send_dreg, comma, send_dreg
		LEA	send_dreg,A3	; left and right will be processed with dreg
		LEA	send_dreg,A3
		JMP	exg_cnt
exg_addr	MOVEM.L	A2-A3,-(SP)	; left and right will be processsed with areg
		LEA	send_areg,A3
		LEA	send_areg,A3
		JMP	exg_cnt
exg_both	MOVEM.L	A2-A3,-(SP)
		LEA	send_dreg,A3	; left will be dreg, right will be areg
		LEA	send_areg,A3	; fall through to continue

exg_cnt		LEA	os_exg,A1	; we got a EXG, load the string and length
		MOVE.W	osl_exg,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	reg_119		; reg is now in D0, original is in D2
		JSR	(A2)		; call left function
		BSR	send_comma
		MOVE.W	D2,D0		; restore the instruction
		ANDI.W	#7,D0		; mask off the last 3 bits
		JSR	(A3)		; call right function
		MOVEM.L	(SP)+,A2-A3	; restore the 2 address registers										~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		JMP	decodei_ext	; we are done with the decode
		
code1101	BSR	extr_opmode	; opmode differentiates between ADD and ADDA
		CMPI.B	#3,D0		; 011 and 111 are ADDA
		BEQ	adda_1101
		CMPI.B	#7,D0
		BEQ	adda_1101	; otherwise fall through to ADDA

add_1101	LEA	os_add,A1	; we got a ADD, load the string and length
		MOVE.W	osl_add,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode
		
adda_1101	LEA	os_add,A1	; we got a ADDA, load the string and length
		MOVE.W	osl_add,D1
		BSR	print_instr	; print the instruction to the buffer
		BSR	send_86op	; handle the op generically from this point forward
		JMP	decodei_ext	; we are done with the decode

code1110	MOVE.W	D2,D0		; reload the instruction
		ANDI.W	#$18,D0		; extract bits 4 and 3 to determine the opcode
		LSR.W	#3,D0		; roll it right 3 so it can be treated as a number
		CMPI.W	#9,D0		; if its 00, ASL/ASR
		BEQ	as_1110
		CMPI.W	#1,D0		; if its 01, LSL/LSR
		BEQ	ls_1110
		CMPI.W	#3,D0		; if its 11, ROL/ROR
		BEQ	ls_1110
		MOVE.B	#1,D6		; error!
		JMP	decodei_ext	; we are done with the decode
		
as_1110		MOVE.W	D2,D0
		BTST.L	#8,D0		; If bit 8 is set, it is left, otherwise right
		BEQ	asl_1110
		
asr_1110	LEA	os_asr,A1	; we got an ASR, load the string and length
		MOVE.W	osl_asr,D1
		BRA	cnt_1110	; continue
		
asl_1110	LEA	os_asl,A1	; we got an ASL, load the string and length
		MOVE.W	osl_asl,D1
		BRA	cnt_1110	; continue
		
ls_1110		MOVE.W	D2,D0
		BTST.L	#8,D0		; If bit 8 is set, it is left, otherwise right
		BEQ	lsl_1110
		
lsr_1110	LEA	os_lsr,A1	; we got an LSR, load the string and length
		MOVE.W	osl_lsr,D1
		BRA	cnt_1110	; continue
		
lsl_1110	LEA	os_lsl,A1	; we got an LSL, load the string and length
		MOVE.W	osl_lsl,D1
		BRA	cnt_1110	; continue

ro_1110		MOVE.W	D2,D0
		BTST.L	#8,D0		; If bit 8 is set, it is left, otherwise right
		BEQ	rol_1110
		
ror_1110	LEA	os_ror,A1	; we got an ROR, load the string and length
		MOVE.W	osl_ror,D1
		BRA	cnt_1110	; continue
		
rol_1110	LEA	os_rol,A1	; we got an ROL, load the string and length
		MOVE.W	osl_rol,D1

cnt_1110	BSR	sz_76		; handle the size and add it to the buffer
		BTST.L	#5,D0		; at this point we have sent out the opcode and can decode the rest generically
		BEQ	imm_1110	; if i/r bit 5 is 0, shift count (immediate)
		BSR	reg_119		; extract the register from bits 11-9
		BSR	send_dreg	; send a D register to the buffer
		BRA	fin_1110	; do the final part of the operation
		
imm_1110	BSR	reg_119		; even though its not a register, extract the immediate bits to D0
		MOVE.W	poundl,D1	; load the length of the pound
		BSR	print_instr	
		LEA	imm_str,A1	; load the target string
		ADDI.W	#$30,D0		; lets just do the hex conversion here, since the immediate is a single char
		MOVE.W	D0,(A1)
		MOVE.W	#1,D1		; The length we want to send is 1
		BSR	print_instr	; tell print_instr to print that single immediate character
		BRA	fin_1110	; finish up
		
fin_1110	BSR	send_comma 	; comma inbetween operands
		ANDI.W	#7,D0		; mask off the 3 lsbs, they represent the other operand
		BSR	send_dreg	; send that operand to the output buffer and we're done
		JMP	decodei_ext	; we are done with the decode
		
code1111	STOP	#$2700

**********************************************
* sz_76
* It is very common for bits 7-6 to be the size bits, so the logic
* to print that has been extracted here. D2 is expected to be the original register.
* D0 (W) is modified and restored to hold the size bit mask, restored
* D5 holds the size mask and is left for the EA section to use
*
* Since sz_76 is used specifically for immediate instructions, it will copy the immediate
* operand and then call print_3sz
**********************************************
sz_76		MOVEM.W	D0,-(SP)	; save registers
		MOVE.W	D2,D0		; copy the original to the D0
		ANDI.W	#$00C0,D0	; check bits 7-6 for size
		ASR.W	#6,D0		; roll it right so it is just a number, 0-2
		CMPI.W	#2,D0		; if D0 > 2, invalid
		MOVE.W	D0,D5		; copy the size to D5 for EA's use
		BGT	sz_76err	; set the error bit
		BSR	print_3sz	; print out the size
		BSR	sendi		; print out the immediate operand (first operand)
		BSR	send_comma
		BRA	sz_76exit	; skip over the error part
sz_76err	MOVE.B	#1,D6		; set the error bit
sz_76exit	MOVEM.W	(SP)+,D0	; restore registers
		RTS			; done
		
**********************************************
* reg_119 - extract register bits from bits 11-9 and
* saves them to D0. Assumes the original is in D2
**********************************************
reg_119		MOVEM.W	D3,-(SP)	; save register
		MOVE.W	D2,D0		; reload the buffer
		ANDI.W	#$E00,D0	; bits 11-9 are the register number
		MOVE.W	#9,D3		; we want to roll it over right 9 places
		ASR.W	D3,D0		; roll it right so it can be treated as a number
		MOVEM.W	(SP)+,D3	; restore register
		RTS			; done
		
**********************************************
* send_86op - send the size and both operands in the format where 8-6 are
* the opmode bits that indicate either <EA>,Dv or Dv,<EA>
* modifies the D0 register to hold the full opcode and restores it when done
* expects D2 to hold the full opcode
* D3 used temporarily and is restored
**********************************************
send_86op	MOVEM.W	D0/D3,-(SP)	; save registers
		BSR	extr_opmode	; take bits 8-6 to look at the opmode and put them into D0
		MOVE.W	D0,D3		; cache opmode
		CMPI.B	#4,D0		; D0 <= 4, no offset needed
		BLS	s86_cont	; modes 0 or 4, 1 or 5, 2 or 6 are B, W and L  respectively
		SUBI.B	#4,D0		; offset D0 by 4 to get the proper register number
s86_cont	MOVE.W	D0,D5		; Save the size for EA
		BSR	print_3sz	; continue with operations, print the size
		; use d3 as the register size 
		MOVE.W	D3,D0		; load the opmode again
		CMPI.B	#4,D0		; D0 <= 4 EA comes first
		BLS	s86_o1ea	; otherwise, dreg first
		BSR	reg_119		; extract the register from bits 11-9
		BSR	send_dreg	; send a D register to the buffer
		BSR	send_comma	; comma after the first operand
		BSR	send_ea		; ea is the second operand
		BRA	s86_exit					
s86_o1ea	BSR	send_ea		; ea is the first operand
		BSR	send_comma	; comma after the first operand
		BSR	reg_119		; extract the register from bits 11-9
		BSR	send_dreg	; send a D register to the buffer then fall through to exit		
s86_exit	MOVEM.W	(SP)+,D0/D3	; restore registers
		RTS

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
* sendi - sendi an immediate to the good buffer
* Preconditions:
* D0 - size of the operation (tells it how much to read). This is not modified
* The number that is read in will be treated and printed as hex, hence why the string
* gets prepended with #$
*
* Postconditions:
* The immediate, prepended with a #$ 
* D3 - internal register for to hold the immediate read. Restored
* D4 - temporarily stores the number of hex digits in the string. Restored
* A5 - the pointer after the opcode for additional data gets advanced
*
* FIXME: is it possible to have a non hex value stored in the immediate?
**********************************************
sendi		MOVEM.L	D3/A1,-(SP)	; save the internally used registers
		MOVEM.W	D4/D1,-(SP)
		CLR.L	D3		; clear out the whole register so we can treat it as the same size once copied into
		LEA	pound,A1	; print a pound symbol for the immediate
		MOVE.W	poundl,D1	; load the length of the pound
		BSR	print_instr
		CMPI.W	#0,D0		; if its 0, byte operation
		BEQ	sendiw	
		CMPI.W	#1,D0		; if its 1, word operation
		BEQ	sendil	
		CMPI.W	#2,D0		; if its 2, long operation
sendib		MOVE.B	(A5)+,D3	; advance the instruction pointer 1 byte, read immediate to D3
		MOVE.B	#2,D4		; 2 hex nibbles long
		BRA	sendic		; continue
sendiw		MOVE.W	(A5)+,D3	; advance the instruction pointer 1 word, read immediate to D3
		MOVE.B	#4,D4		; 4 hex nibbles long
		BRA	sendic		; continue
sendil		MOVE.L	(A5)+,D3	; advance the instruction pointer 1 long, read immediate to D3
		MOVE.B	#8,D4		; 8 hex nibbles long
sendic		MOVEM.L	A0,-(SP)	; h_to_a messes with A0, lets save it
		LEA	imm_str,A0	; we will store it in the immediate string
		BSR	h_to_a		; h_to_a will take D3 and D4 and store it at imm_str (A0)
		MOVEA	A0,A1		; print_instr wants the address in A1
		MOVEM.L	(SP)+,A0	; pop A0 back off the stack
		MOVE.B	D4,D1		; print_instr wants string length in D1
		BSR	print_instr
		MOVEM.W	(SP)+,D4/D1	; restore the internally used register
		MOVEM.L	(SP)+,D3/A1
		RTS			; done	
		
**********************************************
* send_ea - Prepare and send out the ea data to decode_ea
* D0 is a temporary register to hold the EA mask of the full op word
**********************************************
send_ea		MOVEM.W	D0,-(SP)	; save D0
		MOVE.W	D2,D0		; get a fresh copy of the instruction
		ANDI.W	#$3F,D0		; we only want the last 6 bits (bit pos 0-5 LSB)
		BSR	decode_ea	; send it off into ea land, if something went bad, it will set a bad bit
		MOVEM.W	(SP)+,D0	; restore D0
		RTS
		
**********************************************
* send_movem - Prepare and send out ea data to EA land
* specifically for decoding a MOVEM regiser mask.
* D0 is a temporary register to hold the EA of the full op word
**********************************************
send_movem	MOVEM.W	D0,-(SP)	; save D0
		MOVE.W	D2,D0		; get a fresh copy of the instruction
		ANDI.W	#$3F,D0		; we only want the last 6 bits (bit pos 0-5 LSB)
		;!!!!!!!!!!!!!!!!!!!!!TURN BACK ON !!!!!!!!!!!!!!!!!!!BSR	movem_ea	; send it off into ea land, if something went bad, it will set a bad bit
		MOVEM.W	(SP)+,D0	; restore D0
		RTS
		
**********************************************
* send_areg - send an address register string to the buffer
* saves A1 and D0-D2
* D0 is the reg number
**********************************************
send_areg	MOVEM.L D0-D2/A1,-(SP)	; save A1 and D1
		LEA	areg_strs,A1	; load up the A registers table into A1
		BSR 	g_send_reg	; let the generic method handle the heavy lifting
		MOVEM.L	(SP)+,D0-D2/A1	; cleanup
		RTS			; done

**********************************************
* send_dreg - send an data register string to the buffer
* saves A1 and D0-D2
* D0 is the reg number
**********************************************	
send_dreg	MOVEM.L D0-D2/A1,-(SP)	; save A1 and D1
		LEA	dreg_strs,A1	; load up the D registers table into A1
		BSR 	g_send_reg	; let the generic method handle the heavy lifting
		MOVEM.L	(SP)+,D0-D2/A1	; cleanup
		RTS			; done
	
*********************************************
* g_send_reg - Generic send reg, expects A1 to hold the starting address of the table
* NEVER called directly, always called through send_areg or send_dreg
* D0 is the address number
* indexes into the array of registers and appends it to the buffer
* note that this does NOT clean up after itself because it is meant to be called within the context of one
* of the send_*reg methods
*********************************************
g_send_reg	ANDI.W	#$00FF,D0	; mask away the 8 MSBs of the word. We have to use a word size but there could be extra data in there
		MULU.W	#2,D0		; multiply offset by the length of each reg string
		MOVE.W 	#2,D1 		; d1 holds the length, which is always 2 for a register
		LEA	(A1,D0.W),A1	; index in by the offset
		BSR	print_instr	; defer to print_instr to load it into the buffer
		RTS			; done

**********************************************
* send a comma off to the buffer
**********************************************
send_comma	LEA	commas,A1	; print a comma after the first operand
		MOVE.W	commasl,D1	; load the length of the comma
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
	
**********************************************
* extr_opmode
* Given the original instruction is in D2, masks out
* bits 8-6, rolls them right and puts them in D0 to be dealt with
**********************************************
extr_opmode	MOVE.W	D2,D0		; return value will be in D0. Used internally so thats OK
		ANDI.W	#$1C0,D0	; we only want bits 8-6
		ASR.W	#6,D0		; roll it right 6 times to treat it as a number
		RTS

**************************************************************************
*			END OF OPCODE CODE				 *
**************************************************************************
		

**************************************************************************
*			START OF EA CODE				 *
**************************************************************************

********************************************************************
* decode_ea
*
* Description: 	Decodes the effective address bits and identifies
*		the correct addressing mode and subclass.
*
* Preconditions:
*	- D0: Contains the 6 bits for the effective addressing
*		- Bits 3..5 contains the EA Mode Field
*		- Bits 0..2 contains the EA Register Field:
*			- the register (everything except Mode 7)
*			- the subclass (Mode 7 stuff)
*	- D4: Contains the address of the current instruction
*	- D5: Contains the length of the current instruction
*	- A5: Contains a pointer to the extension word (if needed)
*		- The extension word exists immediately after
*		  the instruction word.
*
* Postconditions:
*	- If both the EA mode and register fields were correct,
*	  then the operand is printed into the good buffer.
*
*	- If either the EA mode and register fields were bad,
*	  then the bad flag (D6 == 1) is raised.
*
*********************************************************************

decode_ea	MOVEM.L	A1-A3/A5/D0-D2/D4/D5,-(SP)  ; Before start, save these registers to the stack	
		LEA	ea_mode_jmp,A1		; Index into the EA Mode jump table
		MOVE.W	D0,D2			; Copy the original 6-bits for EA to D2
					  	  ; 1. Don't modify the original (now in D2)
					  	  ; 2. Play with the EA mode in D0 only
		MOVE.B	#3,D1			; Prepare to shift 3 bits to the right
		LSR.W	D1,D0			; Actually move the bits
					 	  ; D0 now has Bits 3..5 - The EA Mode Field
		MULU	#6,D0			; Form offset (Berger did it, not sure why)
		JSR	00(A1,D0)		; Jump into EA Mode jump table with index
		MOVEM.L (SP)+,A1-A3/A5/D0-D2/D4/D5  ; Done, so restore all internally used registers
		RTS				; Done decoding the EA. Go back to op-code.
		
************************************************************************************
* ea_mode_jmp
*
* Description: 	Jump table for EA Modes.  Used to find the appropriate EA mode
*		and handle it within a specific EA mode subroutine.
*
* Preconditions:
*	- This subroutine is ONLY called from within the 'decode_ea' subroutine
*
* Postconditions:
*	- When the appropriate EA mode is decoded, it will jump to the appropriate
*	  EA mode subroutine to handle that EA mode.
*
*************************************************************************************
ea_mode_jmp	JMP	mode000		; Mode 0: Data Reg Direct
		JMP	mode001		; Mode 1: Addr Reg Direct
		JMP	mode010		; Mode 2: Addr Reg Indirect
		JMP	mode011		; Mode 3: Addr Reg Indirect - Postincrement
		JMP	mode100		; Mode 4: Addr Reg Indirect - Predecrement
		JMP	mode101		; Mode 5: (Unsupported)
		JMP	mode110		; Mode 6: Addr Reg Indirect - Index
		JMP	mode111		; Mode 7: Absolute, PC, or Immediate EA
					  ; Note: Mode 7 gets broken down into
					  ; subclasses 0, 1, 2, and 4.
	
******************************************************************
* mode000: Mode 0 - Data Register Direct
*
* Description:	Prints 'Dn' to the good buffer,
*		where Dn is a data register.
*
* Preconditions:
*	- 'mode000' was called by the ea_mode_jmp table.
*
* Postconditions:
*	- 'Dn' was printed to the good buffer.
*	- There should be no invalid 'Dn' since the
*	  last 3 bits should be between 0-7.
*
******************************************************************	  
mode000		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get the Register Field (Bits 0..2)
		BSR	send_dreg	; Print out the data register to the good buffer
		RTS

******************************************************************
* mode001: Mode 1 - Address Register Direct
*
* Description: 	Prints 'An' to the good buffer,
*		where An is an address register.
*
* Preconditions:
*	- 'mode001' was called by the ea_mode_jmp table.
*
* Postconditions:
*	- 'An' was printed to the good buffer.
*	- There should be no invalid 'An' since the
*	  last 3 bits should be between 0-7.
*
******************************************************************
mode001		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get the Register Field (Bits 0..2)
		BSR	send_areg	; Print out the address register to the good buffer
		RTS

******************************************************************
* mode010: Mode 2 - Address Register Indirect
*
* Description: 	Prints '(An)' to the good buffer,
*		where An is an address register
*
* Preconditions:
*	- 'mode010' was called by the ea_mode_jmp table.
*
* Postconditions:
*	- '(An)' was printed to the good buffer.
*	- There should be no invalid 'An' since the
*	  last 3 bits should be between 0-7.
*
******************************************************************
mode010		LEA	os_oParen,A1	; Get the ASCII character for '('
		MOVE.W	os_oParenL,D1	; Load its length
		BSR	print_instr	; Print the '(' to the good buffer

		CLR.L	D0		; Make sure to clean D0, prepare to print 'An'
		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get the Register Field (Bits 0..2)
					  ; Since the rest of the 6-bits for EA
					  ; are now '0', there is no need to roll it
		BSR	send_areg	; Print the address register to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_cParen,A1	; Get the ASCII character for ')'
		MOVE.W	os_cParenL,D1	; Load its length
		BSR	print_instr	; Print the ')' to the good buffer
		
		RTS			; Done.

******************************************************************
* mode011: Mode 3 - Address Register Indirect with Postincrement
*
* Description:	Prints '(An)+' to the good buffer,
*		where An is an address register
*
* Preconditions:
*	- 'mode011' was called by the ea_mode_jmp table.
*
* Postconditions:
*	- '(An)+' was printed to the good buffer.
*	- There should be no invalid 'An' since the
*	  last 3 bits should be between 0-7.
*
******************************************************************
mode011		LEA	os_oParen,A1	; Get the ASCII character for '('
		MOVE.W	os_oParenL,D1	; Load its length
		BSR	print_instr	; Print the '(' to the good buffer
		
		CLR.L	D0		; Make sure to clean D0, prepare to print 'An'
		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get the Register Field (Bits 0..2)
					  ; Since the rest of the 6-bits for EA
					  ; are now '0', there is no need to roll it
		BSR	send_areg	; Print the address register to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_cParen,A1	; Get the ASCII character for ')'
		MOVE.W	os_cParenL,D1	; Load its length
		BSR	print_instr	; Print the ')' to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print '+'
		LEA	os_inc,A1	; Get the ASCII character for '+'
		MOVE.W	os_incL,D1	; Load its length
		BSR	print_instr	; Print the '+' to the good buffer
		
		RTS			; Done.

******************************************************************
* mode100: Mode 4 - Address Register Indirect with Predecrement
*
* Description:	Prints '-(An)' to the good buffer,
*		where An is an address register
*
* Preconditions:
*	- 'mode100' was called by the ea_mode_jmp table.
*
* Postconditions:
*	- '-(An)' was printed to the good buffer.
*	- There should be no invalid 'An' since the
*	  last 3 bits should be between 0-7.
*
******************************************************************
mode100		LEA	os_dec,A1	; Get the ASCII character for '-'
		MOVE.W	os_decL,D1	; Load its length
		BSR	print_instr	; Print the '-' to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print '('
		LEA	os_oParen,A1	; Get the ASCII character for '('
		MOVE.W	os_oParenL,D1	; Load its length
		BSR	print_instr	; Print the '(' to the good buffer
		
		CLR.L	D0		; Make sure to clean D0, prepare to print 'An'
		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get only the Register Field (Bits 0..2)
					  ; Since the rest of the 6-bits for EA
					  ; are now '0', there is no need to roll it
		BSR	send_areg	; Print the address register to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_cParen,A1	; Get the ASCII character for ')'
		MOVE.W	os_cParenL,D1	; Load its length
		BSR	print_instr	; Print the ')' to the good buffer
		
		RTS			; Done.

******************************************************************
* mode101: Mode 5 - (UNSUPPORTED)
*
* Description:	This handles the EA mode '101',
*		which is unsupported by our disassembler.
*
* Preconditions:
*	- 'mode101' was called by the ea_mode_jmp table.
*
* Postconditions:
*	- Raises the bad flag (D6) to indicate that an
*	  error has been encountered.
*
******************************************************************
mode101		MOVE.B #1,D6		; Error. Mode 5 is unsupported, 
					  ; so raise bad flag.
					  
		RTS			; Done.

******************************************************************
* mode110: Mode 6 - Address Register Indirect with Index
*
* Description:	Prints '(d8,An,Xn.SIZE*SCALE)', where
*		  - d8 is the 8-bit displacement
*		  - An is an address register
*		  - Xn.SIZE*SCALE is the index register
*
* Preconditions:
*	- 'mode110' was called by the ea_mode_jmp table.
*
* Postconditions:
*	- '(d8,An,Xn.SIZE*SCALE)' is printed to the good buffer
*
******************************************************************
mode110		LEA	os_dollar,A1	; Get the ASCII character for '$'
		MOVE.W	os_dollarL,D1	; Load its length
		BSR	print_instr	; Print the '$' to the good buffer

	; Get the 8-bit displacement from the extension word
		MOVE.W	(A5),D0		; Get the entire extension word from memory
		MOVE.L	D0,D5		; Store original in D5, mess with it in D0
		ANDI	#$FF,D0		; Get the lower byte (the 8-bit displacement)
		
	; Convert the 8-bit displacement hex value using h_to_a
	  ; The converted value (in ASCII) should be returned in A3
		MOVE.L	D0,D3		; Put the actual Hex value here
					  ; Precondition for h_to_a
		CLR.L	D4		; Make sure this register is clean
		MOVE.B	#$4,D4		; The number of Hex bytes is always 4 (1 word)
					  ; Precondition for h_to_a
		BSR	h_to_a		; Convert the Hex value to ASCII, returns in A3
		
	; Print the hex value to the good buffer
		MOVEA.L	A3,A1		; Move the ASCII value to A1, prepare to print
		MOVE.W	#$4,D1		; Load its length (always 1 word)
		BSR	print_instr	; Print the hex digit to the good buffer
		
	; Print the '(' symbol
		CLR.L	D1		; Make sure to clean D1, prepare to print '('
		LEA	os_oParen,A1	; Get the ASCII character for '('
		MOVE.W	os_oParenL,D1	; Load its length
		BSR	print_instr	; Print the '(' to the good buffer
		
	; Print the address register	
		CLR.L	D0		; Make sure to clean D0, prepare to print 'An'
		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get only the Register Field (Bits 0..2)
					  ; Since the rest of the 6-bits for EA
					  ; are now '0', there is no need to roll it
		BSR	send_areg	; Print the address register to the good buffer
		
	; Print the ',' symbol
		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_comma,A1	; Get the ASCII character for ')'
		MOVE.W	os_commaL,D1	; Load its length
		BSR	print_instr	; Print the ')' to the good buffer
		
	; Print the index register
		MOVE.L	D5,D0		; Get a copy of the original
		ANDI	#$F000,D0	; Mask off the rest of it, the first byte is
					  ; the index register
		LSR.L	#8,D0		; Shift it as far as you can
					  ; (Trying to move the byte to position 0)
		LSR.L	#4,D0		; Need to shift it over one more time
		BSR	byt_reg_prt	; Print register based on byte value
		
	; Print the size of the index (either '.W' or '.L')
		MOVE.L	D5,D0		; Get a copy of the original
		ANDI	#$0F00,D0	; Mask off everything except the size hex byte
		LSR.L	#8,D0		; Shift the hex byte to position 0
		
		CMPI	#8,D0		; Check if it's a long
		BEQ	prt_lng		; If it's long, then print '.L'
		
		CMPI	#0,D0		; Check if it's a word
		BEQ	prt_wrd		; If it's word, then print '.W'
		
		MOVE.B	#1,D6		; It's neither a word or long, so it's an
					  ; invalid size for this EA mode.
					  ; Raise the bad flag (D6)
		BRA	m6done		; Jump to the end

prt_lng		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_long,A1	; Get the ASCII character for ')'
		MOVE.W	os_longL,D1	; Load its length
		BSR	print_instr	; Print '.L' to the good buffer
		BRA	m6finish	; Go print the closing parenthesis

prt_wrd		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_word,A1	; Get the ASCII character for ')'
		MOVE.W	os_wordL,D1	; Load its length
		BSR	print_instr	; Print '.W' to the good buffer
		BRA	m6finish	; Go print the closing parenthesis
		
	; Print the ')' symbol
m6finish	CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_cParen,A1	; Get the ASCII character for ')'
		MOVE.W	os_cParenL,D1	; Load its length
		BSR	print_instr	; Print the ')' to the good buffer
		
m6done		RTS			; Done.

******************************************************************
* mode111: Mode 7 - Absolute, PC, or Immediate Modes
*
* Description:	This subroutine inspects the EA register field
*		and determines the Mode 7 subclass.  After it is
*		determined, it uses the mode7_sc_jmp to handle
*		the Mode 7 subclass.
*
* Preconditions:
*	- 'mode111' was called by the ea_mode_jmp table.
*
* Postconditions:
*	- When the appropriate Mode 7 subclass is determined, it will use
*	  the mode7_sc_jmp table to jump to the appropriate Mode 7 subclass
*	  subroutine which will handle that subclass.
*
******************************************************************
mode111		LEA	mode7_sc_jmp,A1	; Need to find out which subclass it is
		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get the Register Field (Bits 0..2)
					  ; This will indicate the subclass
		MULU	#6,D0		; Form offset (Berger did it, not sure why)
		JSR	00(A1,D0)	; Jump to Mode 7 Subclass Jump Table with index		  
		RTS
		
******************************************************************
* mode7_sc_jmp: Mode 7 Subclass Jump Table
*
* Description:	Jump table for Mode 7 Subclasses.  Used to find the appropriate
*		Mode 7 subclass and handle it within a specific subclass subroutine.
*
* Preconditions:
*	- 'mode7_sc_jmp' was called by the 'mode111' subroutine
*	- D0 has the offset in order to jump to the proper subroutine
*
* Postconditions:
*	- Jumps to the appropriate Mode 7 subclass subroutine that handles
*	  that subclass.
*
******************************************************************

mode7_sc_jmp	JMP	m7sc000		; Mode 7, Subclass 0: Absolute Addressing (Word)
		JMP	m7sc001		; Mode 7, Subclass 1: Absolute Addressing (Long)
		JMP	m7sc010		; Mode 7, Subclass 2: PC Indirect with Displacement
		JMP	m7sc011		; Mode 7, Subclass 3: (Unsupported)
		JMP	m7sc100		; Mode 7, Subclass 4: Immediate Data
		JMP	m7sc101		; Mode 7, Subclass 5: (Unsupported)
		JMP	m7sc110 	; Mode 7, Subclass 6: (Unsupported)
		JMP	m7sc111		; Mode 7, Subclass 7: (Unsupported)

******************************************************************
* m7sc000: Mode 7, Subclass 0 - Absolute Addressing (Word)
*
* Description:	Prints the address of the operand, which is
*		contained in the extension word.
*		There is only one (1) extension word used
*		for this EA mode, which contains the word
*		address.
*
* Preconditions:
*	- 'm7sc000' was called by the mode7_sc_jmp table.
*	- A5 holds the pointer to the extension word (which is
*	  stored immediately the after instruction word).
*
* Postconditions:
*	- The word address (held in the extension word)
*	  is displayed in the good buffer.
*
******************************************************************
m7sc000		LEA	asc_wrd,A3	; A3: Where the converted address word is saved

	; Print the '$' symbol
		LEA	os_dollar,A1	; Get the ASCII character for '$'
		MOVE.W	os_dollarL,D1	; Load its length
		BSR	print_instr	; Print the '$' to the good buffer
		
	; Convert the address hex value using h_to_a
	  ; The converted value (in ASCII) should be returned in A3
	  	MOVE.W	(A5)+,D0	; Get the word data from the ext word
		MOVE.L	D0,D3		; Put the actual Hex value here
					  ; Precondition for h_to_a
		CLR.L	D4		; Make sure this register is clean
		MOVE.B	#$4,D4		; The number of Hex bytes is always 4 (1 word)
					  ; Precondition for h_to_a
		BSR	h_to_a		; Convert the Hex value to ASCII, returns in A3
		
	; Print the hex value to the good buffer
		MOVEA.L	A3,A1		; Move the ASCII value to A1, prepare to print
		MOVE.W	#$4,D1		; Load its length (always 1 word)
		BSR	print_instr	; Print the hex digit to the good buffer
		
		MOVEA.L	#00000000,A3	; Make sure to clear out A3
		
		RTS			; Done.

******************************************************************
* m7sc001: Mode 7, Subclass 1 - Absolute Addressing (Long)
*
* Description:	Prints the address of the operand, which is
*		contained in the two extension words after
*		the instruction word.
*		There is two (2) extension words used for
*		this EA mode, where:
*		  - The first extension word contains the
*		    high-order part of the address.
*		  - The second extension word contains the
*		    low-order part of the address.
*
* Preconditions:
*	- 'm7sc001' was called by the mode7_sc_jmp table.
*	- A5 holds the pointer to the extension word (which is
*	  stored immediately after the instruction word).
*
* Postconditions:
*	- The long address are displayed in the good buffer.
*
******************************************************************
m7sc001		LEA	asc_wrd,A3	; A3: Where the converted address word is saved

	; Print the '$' symbol
		LEA	os_dollar,A1	; Get the ASCII character for '$'
		MOVE.W	os_dollarL,D1	; Load its length
		BSR	print_instr	; Print the '$' to the good buffer
		
	; Convert the high-order address hex value using h_to_a
	  ; The converted value (in ASCII) should be returned in A3
	  	MOVE.L	(A5)+,D0	; Get the high-order data, advance the A5 pointer
		MOVE.L	D0,D3		; Put the actual Hex value here
					  ; Precondition for h_to_a
		CLR.L	D4		; Make sure this register is clean
		MOVE.B	#$8,D4		; The number of Hex bytes is always 8 (1 long)
					  ; Precondition for h_to_a
		BSR	h_to_a		; Convert the Hex value to ASCII, returns in A3
		
	; Print the high-order hex value to the good buffer
		MOVEA.L	A3,A1		; Move the ASCII value to A1, prepare to print
		MOVE.W	#$8,D1		; Load its length (always 1 long)
		BSR	print_instr	; Print the hex digit to the good buffer
		
		MOVEA.L	#00000000,A3	; Make sure to clear out A3
			
		RTS			; Done.

******************************************************************
* m7sc010: Mode 7, Subclass 2 - Program Counter Indirect with Displacement
*
* Description:	This subroutine handles Mode 7, Subclass 2 ('111010')
*		which is EA mode Program Counter Indirect with Displacement.
*		The actual displacement address is stored in the extension
*		word, so this subroutine extracts the necessary data in
*		order to obtain the actual 16-bit extention value specified
*		by the programmer.  The subroutine displays the operand
*		correctly in the good buffer.
*
* Preconditions:
*	- 'm7sc010' was called by the mode7_sc_jmp table.
*	- D4: Contains the address location of the instruction
*	- A5: Pointer to the extension word (the displaced address)
*
* Postconditions:
*	- 'd16(PC)' are printed out to the good buffer
*		- d16 is the actual 16-bit displacement value specified
*
******************************************************************
m7sc010		MOVE.L	D4,-(SP)	; Save these used registers
		LEA	asc_wrd,A3	; A3: Where the converted displacement is saved
		
	; Print the '$' symbol to the good buffer
		LEA	os_dollar,A1	; Get the ASCII character for '$'
		MOVE.W	os_dollarL,D1	; Load its length
		BSR	print_instr	; Print the '$' to the good buffer
		
	; Calculate the 16-bit displacement from the extension word
		ADDI.B	#2,D4		; Increment the address location as if the
					  ; assembler would read in the instruction,
					  ; but has not yet executed (where the PC
					  ; should be if it wasn't displaced).
		MOVE.W	(A5),D0		; Get the word data from the ext word
					  ; This is the actual displaced address of
					  ; the PC (as a result of the displacement)
		ADDI.L	#$FFFF0000,D0	; Pad it because of the sign extension
		ADD.L	D4,D0		; Add these two locations to get the 16-bit
					  ; displacement value used
					  
	; Convert the 16-bit displacement hex value using h_to_a
	  ; The converted value (in ASCII) should be returned in A3
		MOVE.L	D0,D3		; Put the actual Hex value here
					  ; Precondition for h_to_a
		CLR.L	D4		; Make sure this register is clean
		MOVE.B	#$4,D4		; The number of Hex bytes is always 4 (1 word)
					  ; Precondition for h_to_a
		BSR	h_to_a		; Convert the Hex value to ASCII, returns in A3
		
	; Print the hex value to the good buffer
		MOVEA.L	A3,A1		; Move the ASCII value to A1, prepare to print
		MOVE.W	#$4,D1		; Load its length (always 1 word)
		BSR	print_instr	; Print the hex digit to the good buffer
		
		MOVEA.L	#00000000,A3	; Make sure to clear out A3
		
	; Print the '(PC)' string to the good buffer
		LEA	os_pc,A1	; Get the ASCII character for '(PC)'
		MOVE.W	os_pcL,D1	; Load its length
		BSR	print_instr	; Print the '(PC)' to the good buffer
		
		MOVE.L	(SP)+,D4	; Restore that register back.
		RTS			; Done.
		
******************************************************************
* m7sc011: Mode 7, Subclass 3 - (UNSUPPORTED)
*
* Description:	This subroutine handles Mode 7, Subclass 3 ('111011')
*		which is unsupported in our disassembler.
*
* Preconditions:
*	- 'm7sc011' was called by the mode7_sc_jmp table.
*
* Postconditions:
*	- Raises the bad flag (D6) to indicate that an
*	  error has been encountered.
*
******************************************************************
m7sc011		MOVE.B #1,D6		; Error. Mode 7, Subclass 3 is 
					  ; unsupported, so raise bad flag.
					  
		RTS			; Done.


******************************************************************
* m7sc100: Mode 7, Subclass 4 - Immediate Addressing (Data)
*
* Description:	This subroutine handles Mode 7, Subclass 3 ('111100')
*		which prints the immediate data to the good buffer.
*		For immediate addressing, the operation length is needed
*		in order to obtain the immediate data in the extension
*		word.
*
* Preconditions:
*	- 'm7sc100' was called by the mode7_sc_jmp table.
*	- D5: Holds the operation length (2-bits, '0' to '3')
*		- 00: Byte Operation
*		- 01: Word Operation
*		- 10: Long Operation
*	- A5: Holds a pointer to the beginning of the extension word
*
* Postconditions:
*	- Prints the immediate data to the good buffer
*		- Immediate data always starts with '#'
*	- If an invalid operation length is encountered ('11'),
*	  then the bad flag is raised, indicating an invalid operation.
*
*
******************************************************************
m7sc100		LEA	asc_wrd,A3	; A3: Where the converted address word is saved
		CMPI	#2,D5		; Check if it's a Long length
		BEQ	immdLong	; Handle it with the long version
		
		CMPI	#3,D5		; Check if it's an invalid length
		BEQ	immdBad		; Handle the invalid length
		
********************************************************************************************
* If its operation length == 00 or 01, then get the immediate data from the extension word *
*	Note: Even if it's a byte, that data is held in the low-order byte of the word	   *
********************************************************************************************
		LEA	os_pound,A1	; Get the ASCII character for '#'
		MOVE.W	os_poundL,D1	; Load its length
		BSR	print_instr	; Print the '#' to the good buffer
		
		LEA	os_dollar,A1	; Get the ASCII character for '$'
		MOVE.W	os_dollarL,D1	; Load its length
		BSR	print_instr	; Print the '$' to the good buffer
		
	; Convert the immediate hex value using h_to_a
	  ; The converted value (in ASCII) should be returned in A3
	  	MOVE.W	(A5)+,D0	; Get the word data from the ext word,
					  ; advance the A5 pointer
		MOVE.L	D0,D3		; Put the actual Hex value here
					  ; Precondition for h_to_a
		CLR.L	D4		; Make sure this register is clean
		MOVE.B	#$4,D4		; The number of Hex bytes is always 4 (1 word)
					  ; Precondition for h_to_a
		BSR	h_to_a		; Convert the Hex value to ASCII, returns in A3
		
	; Print the hex value to the good buffer
		MOVEA.L	A3,A1		; Move the ASCII value to A1, prepare to print
		MOVE.W	#$4,D1		; Load its length (always 1 word)
		BSR	print_instr	; Print the hex digit to the good buffer
		
		MOVEA.L	#00000000,A3	; Make sure to clear out A3
		
		BRA	immdDone	; Finished, go to the end.

*********************************************************
* immdLong - Handles m7sc100's long size immediate data *
*********************************************************
immdLong	LEA	os_pound,A1	; Get the ASCII character for '#'
		MOVE.W	os_poundL,D1	; Load its length
		BSR	print_instr	; Print the '#' to the good buffer
		
		LEA	os_dollar,A1	; Get the ASCII character for '$'
		MOVE.W	os_dollarL,D1	; Load its length
		BSR	print_instr	; Print the '$' to the good buffer
		
	; Convert the upper-word immediate hex value using h_to_a
	  ; The converted value (in ASCII) should be returned in A3
	  	MOVE.L	(A5)+,D0	; Get the word data from the ext word,
					  ; advance the A5 pointer
		MOVE.L	D0,D3		; Put the actual Hex value here
					  ; Precondition for h_to_a
		CLR.L	D4		; Make sure this register is clean
		MOVE.B	#$8,D4		; The number of Hex bytes is always 8 (1 long)
					  ; Precondition for h_to_a
		BSR	h_to_a		; Convert the Hex value to ASCII, returns in A3
		
	; Print the hex value to the good buffer
		MOVEA.L	A3,A1		; Move the ASCII value to A1, prepare to print
		MOVE.W	#$8,D1		; Load its length (always 1 word)
		BSR	print_instr	; Print the hex digit to the good buffer
		
		MOVEA.L	#00000000,A3	; Make sure to clear out A3

		BRA	immdDone	; Finished, go to the end.

****************************************************
* immdBad - Handles m7sc100's bad operation length *
****************************************************		
immdBad		MOVE.B	#1,D6		; Error. Invalid operation length,
					  ; so raise the bad flag.
		
immdDone	RTS			; Done.

******************************************************************
* m7sc101: Mode 7, Subclass 5 - (UNSUPPORTED)
*
* Description:	This subroutine handles Mode 7, Subclass 5 ('111101')
*		which is unsupported in our disassembler.
*
* Preconditions:
*	- 'm7sc101' was called by the mode7_sc_jmp table.
*
* Postconditions:
*	- Raises the bad flag (D6) to indicate that an
*	  error has been encountered.
*
******************************************************************
m7sc101		MOVE.B #1,D6		; Error. Mode 7, Subclass 5 is 
					  ; unsupported, so raise bad flag.
					  
		RTS			; Done.

******************************************************************
* m7sc101: Mode 7, Subclass 6 - (UNSUPPORTED)
*
* Description:	This subroutine handles Mode 7, Subclass 6 ('111110')
*		which is unsupported in our disassembler.
*
* Preconditions:
*	- 'm7sc110' was called by the mode7_sc_jmp table.
*
* Postconditions:
*	- Raises the bad flag (D6) to indicate that an
*	  error has been encountered.
*
******************************************************************
m7sc110		MOVE.B #1,D6		; Error. Mode 7, Subclass 6 is 
					  ; unsupported, so raise bad flag.
					  
		RTS			; Done.

******************************************************************
* m7sc101: Mode 7, Subclass 7 - (UNSUPPORTED)
*
* Description:	This subroutine handles Mode 7, Subclass 7 ('111111')
*		which is unsupported in our disassembler.
*
* Preconditions:
*	- 'm7sc111' was called by the mode7_sc_jmp table.
*
* Postconditions:
*	- Raises the bad flag (D6) to indicate that an
*	  error has been encountered.
*
******************************************************************
m7sc111		MOVE.B #1,D6		; Error. Mode 7, Subclass 7 is 
					  ; unsupported, so raise bad flag.
					  
		RTS			; Done.
		
******************************************************************
* byt_reg_prt - Byte Register Print
*
* Description:	Prints out the correct register for a Hex byte
*		that contains a reference for both data and
*		address registers.  According to 68K's specs:
* 			D0..D7, Byte == 0..7
* 			A0..A7, Byte == 8..F
* 
* Preconditions:
*	- D0: Contains Hex byte that needs to be converted to a register
*
* Postconditions
*	- Prints out the correct register to the good buffer
*	  - Both data and address registers are handled
*******************************************************************		
byt_reg_prt	CMPI	#8,D0		; Check if it's past the limit for data registers
		BLT	brp_dreg	; If it's a data register, handle it
	
	; It's an address register, handle it	
		SUBI	#8,D0		; Take off the extra bits,
					  ; we know it's an address register
		BSR	send_areg	; Print the address register
		BRA	brp_done	; We're finished, skip the dreg stuff

	; It's a data register, handle it
brp_dreg	BSR	send_dreg	; Don't have to delete anything.  Just print
					  ; data the register.

brp_done	RTS			; Done.
		
**************************************************************************
*			END OF EA CODE				 *
**************************************************************************






* Variables and Strings
**********************************************
* OP names
**********************************************


os_add		DC.B	'ADD'
osl_add		DC.W	osl_add-os_add
os_adda		DC.B	'ADDA'
osl_adda	DC.W	osl_adda-os_adda
os_addi	  	DC.B	'ADDI'
osl_addi	DC.W	osl_addi-os_addi
os_and	  	DC.B	'AND'
osl_and		DC.W	osl_and-os_and
os_andi		DC.B	'ANDI'
osl_andi	DC.W	osl_andi-os_andi
os_asl		DC.B	'ASL'
osl_asl		DC.W	osl_asl-os_asl
os_asr		DC.B	'ASR'
osl_asr		DC.W	osl_asr-os_asr
os_bsr		DC.B	'BSR'
osl_bsr		DC.W	osl_bsr-os_bsr
os_clr		DC.B	'CLR'
osl_clr		DC.W	osl_clr-os_clr
os_cmp		DC.B	'CMP'
osl_cmp		DC.W	osl_cmp-os_cmp
os_cmpa		DC.B	'CMPA'
osl_cmpa	DC.W	osl_cmpa-os_cmpa
os_cmpi		DC.B	'CMPI'
osl_cmpi	DC.W	osl_cmpi-os_cmpi
os_eor		DC.B	'EOR'
osl_eor		DC.W	osl_eor-os_eor
os_eori		DC.B	'EORI'
osl_eori	DC.W	osl_eori-os_eori
os_exg		DC.B	'EXG'
osl_exg		DC.W	osl_exg-os_exg
os_jmp		DC.B	'JMP'
osl_jmp		DC.W	osl_jmp-os_jmp
os_jsr		DC.B	'JSR'
osl_jsr		DC.W	osl_jsr-os_jsr
os_lea		DC.B	'LEA '
osl_lea		DC.W	osl_lea-os_lea
os_lsr		DC.B	'LSR'
osl_lsr		DC.W	osl_lsr-os_lsr
os_lsl		DC.B	'LSL'
osl_lsl		DC.W	osl_lsl-os_lsl
os_move		DC.B	'MOVE'
osl_move	DC.W	osl_move-os_move
os_movea	DC.B	'MOVEA'
osl_movea	DC.W	osl_movea-os_movea
os_movem	DC.B	'MOVEM'
osl_movem	DC.W	osl_movem-os_movem
os_neg		DC.B	'NEG'
osl_neg		DC.W	osl_neg-os_neg
os_nop		DC.B	'NOP'
osl_nop		DC.W	osl_nop-os_nop
os_not		DC.B	'NOT'
osl_not		DC.W	osl_not-os_not
os_or		DC.B	'OR'
osl_or		DC.W	osl_or-os_or
os_ori		DC.B	'ORI'
osl_ori		DC.W	osl_ori-os_ori
os_rol		DC.B	'ROL'
osl_rol		DC.W	osl_rol-os_rol
os_ror		DC.B	'ROR'
osl_ror		DC.W	osl_ror-os_ror
os_rts		DC.B	'RTS'
osl_rts		DC.W	osl_rts-os_rts
os_sub		DC.B	'SUB'
osl_sub		DC.W	osl_sub-os_sub
os_suba		DC.B	'SUBA'
osl_suba	DC.W	osl_suba-os_suba
os_subi		DC.B	'SUBI'
osl_subi	DC.W	osl_subi-os_subi
os_swap		DC.B	'SWAP'
osl_swap	DC.W	osl_swap-os_swap

sz_b		DC.B	'.B '
szl_b		DC.B 	szl_b-sz_b
sz_w		DC.B	'.W '
szl_w		DC.B 	szl_w-sz_w
sz_l		DC.B	'.L '
szl_l		DC.B 	szl_b-sz_b

pound		DC.B	'#$'
poundl		DC.B 	poundl-pound
commas		DC.B	','
commasl		DC.B 	commasl-commas
crs		DC.B	CR
crsl		DC.B	crsl-crs
lfs		DC.B	LF
lfsl		DC.B	lfsl-lfs

imm_str		DS.B  	8 		; immediate hex value string, supports up to 32 bits (8 hex nibbles)

*********************
* Register strings
*********************
areg_strs	DC.B  	'A0','A1','A2','A3','A4','A5','A6','A7'
dreg_strs	DC.B  	'D0','D1','D2','D3','D4','D5','D6','D7'


*******************************************************************************
*	Data area
*******************************************************************************
intro		DC.B		'Team MNMs Disassembler',CR,LF
		DC.B		'would you like to disassembler a region of  memory?',CR,LF
		DC.B		'Please enter Y for yes, or Q to quit program',CR,LF
introL		DC.W		introL-intro	*length of intro message string
stAdd		DC.B		'Please enter valid start address',CR,LF
		DC.B		'start address must be above or equal to $00002000   '
stAddL		DC.W		stAddL-stAdd	*length of start address message string
endAdd		DC.B		CR,LF,'Please enter valid end address',CR,LF
		DC.B		'end address must be below $000FFFFF',CR,LF
		DC.B		'end address must be at least 1 word larger than start address   '
endAddL		DC.W		endAddL-endAdd	*lenght of end address message string

*******************************************************************************
*	Error Messages
*******************************************************************************
stErr		DC.B		'You entered and invalid start address',CR,LF
		DC.B		'start address must be above $00002000',CR,LF
		DC.B		'and below $000FFFFF',CR,LF
stErrL		DC.W		stErrL-stErr	*length of start error message string
endErr		DC.B		'You entered and invalid end address',CR,LF
		DC.B 		'end address must be at least one word larger than start address',CR,LF
		DC.B		'and smaller than $000FFFFF',CR,LF
endErrL		DC.W		endErrL-endErr	*length of end error message string
iErr		DC.B		'You entered an invalid value, it must be the letter',CR,LF
		DC.B		'Y for yes or Q to quit program',CR,LF
iErrL		DC.W		iErrL-iErr	*length of intro error message

*******************************************************************************
*	Input storage area
*******************************************************************************
data1		DS.B	20	*to hold input of start address
data2		DS.B	20	*to hold input of end address
dataSt		DS.B	20	*to hold introduction's input (Y or Q)
istart		DS.L	1	*holds start address in hex
iend		DS.L	1	*holds end address in hex

goodBuf		DS.B	80		*reserves 80 bytes to hold good buffer
badBuf		DS.B	80		*reserves 80 bytes to hold bad buffer
headr		DC.B	CR,LF,CR,LF,'MEMORY LOCATION   OP-CODE   OPERAND',CR,LF
headrL		DC.W	headrL-headr		*holds length of header string
temp		DS.B	30		*reserves 30 bytes 4 prting instrs

*****************************************
* 	EA Variables and Strings        *
*****************************************

asc_wrd		DS.W	1		; This is the location where I'll be
					  ; keeping the ASCII converted Hex word
					  ; that will be output to the good buffer.
					  ; This is used for EA modes for immediate
					  ; data and also absolute addressing.

*********************************************************
* 		Additional EA Strings			*
*********************************************************

os_oParen	DC.B	'('			; Open parenthesis symbol
os_oParenL	DC.W	os_oParenL-os_oParen	; Length of open parenthesis
os_cParen	DC.B	')'			; Closing parenthesis symbol
os_cParenL	DC.W	os_cParenL-os_cParen	; Length of closing parenthesis
os_inc		DC.B	'+'			; Addition/Increment symbol
os_incL		DC.W	os_incL-os_inc		; Length of addition/increment
os_dec		DC.B	'-'			; Subtraction/Decrement symbol
os_decL		DC.W	os_decL-os_dec		; Length of subtraction/decrement
os_pound	DC.B	'#'			; Pound symbol for immediate data
os_poundL	DC.W	os_poundL-os_pound	; Length of pound
os_dollar	DC.B	'$'			; Dollar symbol for hex
os_dollarL	DC.W	os_dollarL-os_dollar	; Length of dollar sign (hex)
os_comma	DC.B	','			; Symbol for the comma ','
os_commaL	DC.W	os_commaL-os_comma	; Length of the comma symbol
os_pc		DC.B	'(PC)'			; String for 'Program Counter'
os_pcL		DC.W	os_pcL-os_pc		; Length of 'PC'
os_word		DC.B	'.W'			; String for word length
os_wordL	DC.W	os_wordL-os_word	; Length for the word length
os_long		DC.B	'.L'			; String for long length
os_longL	DC.W	os_longL-os_long	; Length for the long length

		
		END		start





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
