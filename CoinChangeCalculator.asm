TITLE Coin Change Calculator (CoinChangeCalculator.asm)

;// Name:	Tomas Ochoa 	   		
;//
;// Program 4: Change Calculator 
;//
;// 	This program calculates and tells what coins to give out for any amount 
;// of change from 1 cent to 99 cents. 
INCLUDE	Irvine32.inc

;//------------------------- DATA SEGMENT ------------------------- 
.data
;// For Colors
CustomColor	= red + (lightMagenta * 16)
DefaultColor	= lightGray + (black * 16) 
;// Prompts and Related
Prompt1		BYTE "Please enter an amount of change: ", 0
Prompt2		BYTE "Would you like to try a different amount? (y/n): ", 0
Prompt3		BYTE "Colors have been reset to default...", 0
Prompt4		BYTE "Goodbye!", 0
Prompt5		BYTE	"Error! Could not recover!", 0
Prompt6		BYTE	"Exiting now...", 0
Prompt7		BYTE "Invalid Input! Try Again! (y/n): ", 0
Prompt8		BYTE "Invalid amount! Please enter an amount of change between 99 and 1: ", 0
Display1		BYTE " cents can be returned as ", 0
NumCoins1		BYTE " quarter(s), ", 0
NumCoins2		BYTE " dime(s), and ", 0
NumCoins3		BYTE " penny(pennies).", 0
;// Variables that hold the amount of coins needed of each 
;// denomination for correct change
NumOfQuarters  DWORD ?
NumOfDimes	DWORD ?
NumOfPennies	DWORD ?
;// To calculate change
StartAmount	DWORD 0 
amount_left	DWORD ?
coin_value	DWORD ?
number		DWORD ?
;// Static/Unchanging Values
Quarter		EQU 25
Dime			EQU 10
Penny		EQU 1
Denominations	EQU 3
;// Decision to start over or not
Decision	BYTE ?
;//------------------------- CODE SEGMENT -------------------------
.code
main		PROC						;// Begin main process
Start:
	call		ChangeColors			;// Change FG & BG
	call		Input					;// Input Procedure
	call		compute_coin			;// Computre coins for denominations 
	call		Display					;// Display Results 	
	;// For Looping to start over or not
	mov		edx, OFFSET Prompt2			;// "Would you like to try a different amount? (y/n): "
	call		WriteString					
Loop_Yes:
	call		ReadChar				;// >> input 
	mov		Decision, al
	.IF(al == 'y') || (al == 'Y' )		;// Validate input
		jmp Start 
	.ELSEIF(al == 'n') || (al == 'N' )
		jmp		Loop_No 
	.ELSE								;// If anything else besides 'y','Y','n' or 'N'
		call		Crlf
		mov		edx, OFFSET Prompt7		;// "Invalid Input! Try Again! (y/n): "
		call		WriteString 
		jmp		Loop_Yes 
	.ENDIF	
Loop_No:
	call		DefaultColors			;// Change back to default colors
	call		Crlf 
	exit 
main		ENDP						;// End main process
;//------------------------- SUB ROUTINES -------------------------
;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;//NAME: ChangeColors
;//
;//DESCRIPTION:
;//			This sub routine changes the default colors of both
;//		Foreground and Background to Red and light pink
;//
;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ChangeColors	PROC
PUSHAD 
	mov	eax, CustomColor
	call	SetTextColor
	call Clrscr 
POPAD
ret 
ChangeColors	ENDP 

;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;//NAME: DefaultColors
;//
;//DESCRIPTION:
;//			This sub routine changes the current colors of 
;//		forground and background bac to default (LightGray + Black)
;//
;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
DefaultColors	PROC
PUSHAD 
	mov	eax, DefaultColor		;// Load default colors
	call	SetTextColor		;// Change the colors
	call Clrscr					;// clear the screen show new colors
	mov edx, OFFSET Prompt3		;// Cout << Prompt3 << endl
	call WriteString			
	call Crlf 
	mov	edx, OFFSET Prompt4		;// cout << Prompt4 << endl 
	call WriteString
	call Crlf 
POPAD
ret 
DefaultColors	ENDP 

;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;//NAME: Input
;//
;//DESCRIPTION:
;//			This sub routine when called prompts the user for input
;//		and stores the user's input to the apropriate variables
;//
;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Input	PROC 
PUSHAD 
	;// Prompt User
	mov		edx, OFFSET Prompt1 
	call		WriteString 
	;// Input check for input only btween 1-99
InputVal:
	;// Read input
	call		ReadDec 
	mov		StartAmount, eax
	;// If else to check 
	.IF(eax < 1) || (eax > 99)			;// If eax > 99 or < 1 reinput
		mov		edx, OFFSET Prompt8 
		call		WriteString 
		jmp		InputVal  
	.ELSE								
		jmp		InputBreak 		
	.ENDIF	
InputBreak: 
	call		Crlf 
POPAD	
ret 
Input	ENDP

;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;//NAME: Display
;//
;//DESCRIPTION:
;//			This sub routine displays the result change to give
;//		out onto screen
;//
;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Display	PROC 
PUSHAD 
	;// "[StartAmount] can be returned as [NumOfQuarters] quarter(s)...
	;//		, [NumOFDimes] dime(s), and [NumOfPennies]penny(pennies)"
	mov		eax, StartAmount
	call		WriteDec
	mov		edx, OFFSET Display1 
	call		WriteString 
	mov		eax, NumOfQuarters
	call		WriteDec 
	mov		edx, OFFSET NumCoins1 
	call		WriteString 
	mov		eax, NumOfDimes
	call		WriteDec
	mov		edx, OFFSET NumCoins2
	call		WriteString
	mov		eax, NumOfPennies
	call		WriteDec
	mov		edx, OFFSET NumCoins3 
	call		WriteString 
	call		Crlf 		
	call		Crlf 
POPAD	
ret  
Display	ENDP

;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;//NAME: compute_coin
;//
;//DESCRIPTION:
;//			This sub routine computes the number of coins needed
;//		for the amount of change given as user input
;//
;//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
compute_coin	PROC 
PUSHAD
cc_Start:
	mov		ecx, Denominations	;// Count = # of Denominations = 3
	mov		eax, StartAmount	;// eax => StartAmount
	mov		amount_left, eax	;// amount_left = eax => StartAmount
	jmp		Count_Check			;// jump to count_check
Count_Check:	
	;// Check what coin_value to set
	.IF(ecx == 3)
		;// Set coin_value to a quarter
		mov		ebx, Quarter 
		mov		coin_value, ebx
		mov		ebx, coin_value 
		LOOP Division_Stuff 
	.ENDIF
	.IF(ecx == 2)
		mov		ebx, Dime 
		mov		coin_value, ebx
		mov		ebx, coin_value
		LOOP Division_Stuff
	.ENDIF
	.IF(ecx == 1)
		mov		ebx, Penny 
		mov		coin_value, ebx
		mov		ebx, coin_value
		LOOP Division_Stuff
	.ENDIF
Division_Stuff:
	;// Divide by denomination
	mov		edx, 0			;// edx = 0
	mov		eax, amount_left;// eax => amount_left 
	div		ebx				;// Divide eax/ebx 
	mov		number, eax		;// 
	mov		amount_left, edx
	jmp		Coin_Number 
Coin_Number:
	;// Set amount of coins for each denomination
	;// Quarters
	.IF(ecx == 2)
		mov	NumOfQuarters, eax
		jmp	Count_Check 
	.ENDIF	
	;// Dimes 
	.IF(ecx == 1)
		mov	NumOfDimes, eax 	
		jmp	Count_Check
	.ENDIF
	;// Pennies 
	.IF(ecx == 0)
		mov	NumOfPennies, eax 
		jmp	cc_End 
	.ENDIF
cc_End:
POPAD	
ret  
compute_coin	ENDP
end		main											;// End main