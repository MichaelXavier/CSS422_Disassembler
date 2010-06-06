*-----------------------------------------------------------
* Program    : ea_pmliam.X68
* Written by : Paul Michael A. Liam, Jr.
* Date       : 6/6/2010
* Description: Effective Addressing Code of Disassembler
*-----------------------------------------------------------

		; ... Blah...,
		; ... Blah...,
		; ... Blah......
		; ... (The group's previous code was in this area)
		
***************************************************************************
***************************************************************************
**			START OF EA CODE				 **
***************************************************************************
***************************************************************************

*********************************************************************************				
** The following code is for EA test purposes. Please delete when integrating. **
stack		EQU	$A000		; Stack location
sampleEA	EQU	%011101		; Sample 6-bits for EA mode field and register field
		
		ORG	$400		; (***Delete after testing***)
** 	The stuff before this was for EA test purposes. Please delete. 	       **
*********************************************************************************

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
*
* Postconditions:
*	- If both the EA mode and register fields were correct,
*	  then the register is printed into the good buffer.
*
*	- If either the EA mode and register fields were bad,
*	  then the bad flag (D6 == 1) is raised.
*
*********************************************************************

;decode_ea	MOVEM.L	A1-A2/D0-D2,-(SP)	; Before start, save these registers to the stack
start		LEA	stack,SP		; Load the stack pointer (***DELETE AFTER TESTING***)
		LEA	ea_mode_jmp,A1		; Index into the EA Mode jump table
		CLR.L	D0			; Make sure it's clean (***DELETE AFTER TESTING***)
		MOVE.W	#sampleEA,D0		; Load the sample EA (***DELETE AFTER TESTING***)
		MOVE.W	D0,D2			; Copy the original 6-bits for EA to D2
					  	  ; 1. Don't modify the original (now in D2)
					  	  ; 2. Play with the EA mode in D0 only
		MOVE.B	#3,D1			; Prepare to shift 3 bits to the right
		LSR.W	D1,D0			; Actually move the bits
					 	  ; D0 now has Bits 3..5 - The EA Mode Field
		MULU	#6,D0			; Form offset (Berger did it, not sure why)
		JSR	00(A1,D0)		; Jump into EA Mode jump table with index
		STOP	#$2700			; (***DELETE AFTER TESTING***)
		;MOVEM.L (SP)+,A1-A2/D0-D2	; Done, so restore all internally used registers
		;RTS
		
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
		;BSR	send_dreg	; Print out the data register to the good buffer
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
		;BSR	send_areg	; Print out the address register to the good buffer
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
		;BSR	print_instr	; Print the '(' to the good buffer
		
		CLR.L	D0		; Make sure to clean D0, prepare to print 'An'
		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get the Register Field (Bits 0..2)
					  ; Since the rest of the 6-bits for EA
					  ; are now '0', there is no need to roll it
		;BSR	send_areg	; Print the address register to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_cParen,A1	; Get the ASCII character for ')'
		MOVE.W	os_cParenL,D1	; Load its length
		;BSR	print_instr	; Print the ')' to the good buffer
		
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
		;BSR	print_instr	; Print the '(' to the good buffer
		
		CLR.L	D0		; Make sure to clean D0, prepare to print 'An'
		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get the Register Field (Bits 0..2)
					  ; Since the rest of the 6-bits for EA
					  ; are now '0', there is no need to roll it
		;BSR	send_areg	; Print the address register to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_cParen,A1	; Get the ASCII character for ')'
		MOVE.W	os_cParenL,D1	; Load its length
		;BSR	print_instr	; Print the ')' to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print '+'
		LEA	os_inc,A1	; Get the ASCII character for '+'
		MOVE.W	os_incL,D1	; Load its length
		;BSR	print_instr	; Print the '+' to the good buffer
		
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
		;BSR	print_instr	; Print the '-' to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print '('
		LEA	os_oParen,A1	; Get the ASCII character for '('
		MOVE.W	os_oParenL,D1	; Load its length
		;BSR	print_instr	; Print the '(' to the good buffer
		
		CLR.L	D0		; Make sure to clean D0, prepare to print 'An'
		MOVE	D2,D0		; Get the original 6-bits for EA back from D2
		ANDI	#7,D0		; Get only the Register Field (Bits 0..2)
					  ; Since the rest of the 6-bits for EA
					  ; are now '0', there is no need to roll it
		;BSR	send_areg	; Print the address register to the good buffer
		
		CLR.L	D1		; Make sure to clean D1, prepare to print ')'
		LEA	os_cParen,A1	; Get the ASCII character for ')'
		MOVE.W	os_cParenL,D1	; Load its length
		;BSR	print_instr	; Print the ')' to the good buffer
		
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
*	- The bad flag (D6) is raised if anything invalid was found
*	  in the extension word.
*
******************************************************************
mode110		; NEED TO FINISH THIS!!!

		RTS			; Done.

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
		JMP	m7sc010		; Mode 7, Subclass 2: PC with Displacement
		JMP	m7sc011		; Mode 7, Subclass 3: (Unsupported)
		JMP	m7sc100		; Mode 7, Subclass 4: Immediate Data
		JMP	m7sc101		; Mode 7, Subclass 5: (Unsupported)
		JMP	m7sc110 	; Mode 7, Subclass 6: (Unsupported)
		JMP	m7sc111		; Mode 7, Subclass 7: (Unsupported)

******************************************************************
* m7sc000: Mode 7, Subclass 0 - Absolute Addressing (Word)
*
* Description:	
*
*
* Preconditions:
*
*
* Postconditions:
*
*
******************************************************************
m7sc000		; NEED TO FINISH THIS!!!
		RTS			; Done.

******************************************************************
* m7sc001: Mode 7, Subclass 1 - Absolute Addressing (Long)
*
* Description:	
*
*
* Preconditions:
*
*
* Postconditions:
*
*
******************************************************************
m7sc001		; NEED TO FINISH THIS!!!
		RTS			; Done.

******************************************************************
* m7sc010: Mode 7, Subclass 2 - Program Counter with Displacement
*
* Description:	
*
*
* Preconditions:
*
*
* Postconditions:
*
*
******************************************************************
m7sc010		; NEED TO FINISH THIS!!!
		RTS			; Done.
		
******************************************************************
* m7sc011: Mode 7, Subclass 3 - (UNSUPPORTED)
*
* Description:	
*
*
* Preconditions:
*
*
* Postconditions:
*
*
******************************************************************
m7sc011		MOVE.B #1,D6		; Error. Mode 7, Subclass 3 is 
					  ; unsupported, so raise bad flag.
					  
		RTS			; Done.

******************************************************************
* m7sc100: Mode 7, Subclass 4 - Immediate Addressing (Data)
*
* Description:	
*
*
* Preconditions:
*
*
* Postconditions:
*
*
******************************************************************
m7sc100		; NEED TO FINISH THIS!!!
		RTS			; Done.

******************************************************************
* m7sc101: Mode 7, Subclass 5 - (UNSUPPORTED)
*
* Description:	
*
*
* Preconditions:
*
*
* Postconditions:
*
*
******************************************************************
m7sc101		MOVE.B #1,D6		; Error. Mode 7, Subclass 5 is 
					  ; unsupported, so raise bad flag.
					  
		RTS			; Done.

******************************************************************
* m7sc101: Mode 7, Subclass 6 - (UNSUPPORTED)
*
* Description:	
*
*
* Preconditions:
*
*
* Postconditions:
*
*
******************************************************************
m7sc110		MOVE.B #1,D6		; Error. Mode 7, Subclass 6 is 
					  ; unsupported, so raise bad flag.
					  
		RTS			; Done.

******************************************************************
* m7sc101: Mode 7, Subclass 7 - (UNSUPPORTED)
*
* Description:	
*
*
* Preconditions:
*
*
* Postconditions:
*
*
******************************************************************
m7sc111		MOVE.B #1,D6		; Error. Mode 7, Subclass 7 is 
					  ; unsupported, so raise bad flag.
					  
		RTS			; Done.
		
***************************************************************************
***************************************************************************
**			END OF EA CODE					 **
***************************************************************************
***************************************************************************

*************************************************************************
* 	Variables and Strings - PLEASE ADD TO GROUP'S CODE!!!		*
*************************************************************************

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
os_pc		DC.B	'PC'			; String for 'Program Counter'
os_pcL		DC.W	os_pcL-os_pc		; Length of 'PC'

		END 	$400	; (***Delete after testing***)




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
