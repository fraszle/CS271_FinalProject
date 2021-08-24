TITLE Demonstrating Low Level I/O Procedures     (Project06.asm)

; Author: Victoria Dmyterko
; Last Modified: 12/8/2019
; OSU email address: dmyterkv@oregonstate.edu
; Course number/section: CS271_400
; Project Number: Project 6                 Due Date:12/08/2019
; Description:Implement ReadVal and WriteVal procedures for unsigned integers. The ReadVal procedure will accept a 
;			  numeric string from the keyboard and compute the integer value. WriteVal will do the opposite and covert
;			  an unsigned into into the text string to display on the screen. These procedures will use macros
;			  getString and displayString to help get input and write the string to the screen. To demonstrate their
;			  usage, the program will get 10 valid integers (integers that aren't too big to fit into a 32-bit register)
;			  and store the values in an array. It will then display the list of integers, their sum, and their 
;			  average.

INCLUDE Irvine32.inc

;getString macro, used in ReadVal to get the inputted numeric string from the user
;Modified from Lecture 26
getString MACRO prompt, input
	push edx
	push ecx

	mov edx, prompt
	call WriteString

	mov edx, OFFSET input
	mov ecx, (SIZEOF input) - 1
	call ReadString

	pop ecx
	pop edx
ENDM

;displayString macro, used in WriteVal to display the numeric text on the screen
;Modified from Lecture 26
displayString MACRO numString
	push edx

	mov edx, numString
	call WriteString

	pop edx
ENDM	

.data

intro1		BYTE	"Demonstrating low-level I/O Procedures", 0
intro2		BYTE	"Written by: Victoria Dmyterko", 0
userInput	BYTE	256 DUP(0)
numInts		DWORD	10
inputSize	DWORD	?
multiplier	DWORD	1
accumulate	DWORD	?
strArray	BYTE	101 DUP(?)
numArray	DWORD	10 DUP(?)
rule1		BYTE	"Please provide 10 decimal integers.", 0
rule2		BYTE	"Each number needs to be small enough to fit inside a 32-bit integer.", 0
intro3		BYTE	"After you have finished inputting the numbers, I will display a list of inputted integers, their sum, and their average.", 0
numPrompt	BYTE	"Please enter an integer number: ", 0
errMsg		BYTE	"Error: You did not enter an integer or your number was too big. Please try again.", 0
display		BYTE	"You entered the following numbers:", 0
numSum		BYTE	"The sum of these numbers is: ", 0
numAvg		BYTE	"The average is: ", 0
sumVal		DWORD	?
AvgVal		DWORD	?		
byeStr		BYTE	"Thanks for using my program! Goodbye!", 0

.code
main PROC

	;Introduce the user to the program
	mov edx, OFFSET intro1
	call WriteString
	call Crlf

	mov edx, OFFSET intro2
	call WriteString
	call Crlf
	call Crlf

	mov edx, OFFSET rule1
	call WriteString
	call Crlf

	mov edx, OFFSET rule2
	call WriteString
	call Crlf

	mov edx, OFFSET intro3
	call WriteString
	Call Crlf

	;Read the user input, convert to numeric, and validate
	push OFFSET numPrompt
	push OFFSET errMsg
	push OFFSET numArray
	push OFFSET inputSize
	push OFFSET userInput
	push numInts
	push OFFSET multiplier
	push OFFSET accumulate
	call ReadVal

	;Convert the numeric values to a string, then displays those string values
	push OFFSET display
	push OFFSET strArray
	push OFFSET numArray
	call WriteVal

	;Calculate the sum and average of the inputted numbers, then displays them
	push OFFSET numArray
	push OFFSET numSum
	push OFFSET numAvg
	push OFFSET sumVal
	push OFFSET avgVal
	call SumAvg

	;Say goodbye to the user
	call Crlf
	mov edx, OFFSET byeStr
	call WriteString

	exit	; exit to operating system
main ENDP

;------------------------------------------------------------------------------------------------------------
; The ReadVal procedure reads in the user's inputted numeric string using the getString macro, it then 
;	converts the digit string to numeric, while validating the user's input.
; Receives: accumulate, multiplier, userInput, inputSize, numArray, errMsg, and numPrompt by reference. 
;			numInts by value. 
; Returns: Array filled with integers	
; Preconditions: None
; Postconditions: numArray will now be filled with unsigned integers which each fit into a 32-bit register
; Registers changed: ebp, esi, edi, ecx, eax, ebx, edx, saved by PUSH, and restored by POP
;------------------------------------------------------------------------------------------------------------
ReadVal PROC
	push ebp										;Save original values of registers used on the stack
	push esi								
	push edi
	push ecx
	push eax
	push ebx
	push edx

	mov ebp, esp

	mov edi, [ebp + 52]								;Offset of the array to hold the numbers

	mov ecx, [ebp + 40]								;Set outer loop counter to 10 

Outer: 
	push ecx										;Save outer loop counter

Request:
	mov esi, [ebp + 44]								;Points to the string that will hold the user's input 
	getString OFFSET numPrompt, userInput			;invoke getString macro to get the user input
	mov ebx, [ebp + 48]								;Save the length of the input
	mov [ebx], eax
	mov ecx, eax									;Also save size of input string as ecx inner counter
	add esi, eax									;Get the last byte of input string
	dec esi								
	mov ebx, [ebp + 36]								;Reset multiplier
	mov eax, 1
	mov [ebx], eax
	mov ebx, [ebp + 32]								;Reset accumulator
	mov eax, 0
	mov [ebx], eax			
	mov eax, 0										;Clear eax and edx	
	mov edx, 0
	std												;Move backwards through string 

checkString:
	mov eax, 0
	lodsb
	cmp al, 48										;Value of '0' in ASCII
	jl Invalid
	cmp al, 57										;Value of '9' in ASCII
	jg Invalid
	jmp Convert

Invalid:
	mov edx, [ebp + 56]								;Display our error message
	call WriteString
	call Crlf
	jmp Request

Convert:
	sub al, 48										;Convert the byte to its equivalent number
	mov ebx, [ebp + 48]								;Save ecx counter
	mov [ebx], ecx
	mov ebx, [ebp + 36]
	mov ecx, [ebx]									;Get multiplier
	mul ecx
	cmp edx, 0										;Check if value can still fit in a 32-but register after multiplying
	jnz Invalid
	mov ebx, [ebp + 32]								;Add calculated value into accumulator variable
	add [ebx], eax
	jc Invalid										;Check that number isn't too big when added onto
	mov eax, ecx									;Multiply multiplier by 10
	mov ecx, 10
	mul ecx											
	mov ebx, [ebp + 36]								;Save new multiplier
	mov [ebx], eax
	mov ebx, [ebp + 48]								;Restore ecx counter
	mov ecx, [ebx]
	loop checkString								;Move to next number in numeric string

	mov ebx, [ebp + 32]								;Move converted valid integer to number array						
	mov eax, [ebx]
	mov [edi], eax	
	add edi, 4										;Move to next array element
	pop ecx
	dec ecx											;Get next user inputted numeric string
	jnz Outer

	pop edx											;Restore the registers
	pop ebx
	pop eax
	pop ecx
	pop edi
	pop esi
	pop ebp

	ret 32

ReadVal ENDP

;------------------------------------------------------------------------------------------------------------
; The WriteVal procedure takes each integer, converts it to its numeric string, then displays it on the 
;	screen using the displayString macro.
; Receives: numArray, strArray, and display by reference
; Returns: strArray filled with ASCII representations of our numArray
; Preconditions: numArray must contain only 10 unsigned numbers, each of which must fit a 32-bit register
; Postconditions: Print strArray contents to the screen
; Registers changed: ebp, esi, edi, edx, ecx, ebx, eax, saved by PUSH and restored by POP
;------------------------------------------------------------------------------------------------------------
WriteVal PROC
	push ebp										;Save the original values of our registers onto the stack
	push esi
	push edi
	push edx
	push ecx
	push ebx
	push eax

	mov ebp, esp

	call Crlf
	mov edx, [ebp + 40]								;Line to display our numbers
	call WriteString
	call Crlf


	mov esi, [ebp + 32]								;Offset of the array that holds the numbers
	mov edi, [ebp + 36]								;Offset of the string array

	mov ecx, 10										;Outer loop counter
	mov edx, 0

NewNum:
	push ecx										;Save outer loop counter
	mov ebx, 1000000000								;Our first divisor is 1 billion, since the largest the 32-bit can hold is 4 billion or so
 
	mov eax, [esi]									;Get the first number from the array
	cmp eax, 0										;if the number is zero then we can just store it
	je Zero

FirstCheck:
	mov eax, [esi]									;Move array number to eax
	cmp eax, ebx									;Compare number to our divisor
	jge Divide										;If number is greater than or equal, then we can start dividing
	mov eax, ebx
	mov ebx, 10
	div ebx											;If not, we divide ebx by 10 and try again
	mov ebx, eax
	jmp FirstCheck
	
Divide:
	mov edx, 0
	div ebx											;Divide our number by ebx (some power of 10)
	add eax, 48										;Convert the quotient to its ASCII number
	cld 
	stosb											;Put it into our array

	cmp ebx, 1										;If ebx = 1, then we've reached the end of the current number
	je Next											;Get the next number from our number array
	push edx										;Otherwise, we continue to convert the remainder using smaller powers of 10
	mov edx, 0
	mov eax, ebx
	mov ebx, 10
	div ebx
	mov ebx, eax
	pop edx
	mov eax, edx
	jmp Divide

Next:
	mov eax, 0
	mov al, ' '										;Add a space between each number in the array
	cld												 
	stosb
	add esi, 4										;Move to the next number in the number array
	pop ecx											;Pop outer loop counter
	loop NewNum
	jmp Finish										;Once we've gone through the whole array we can print the converted numerical string
		
Zero:
	add eax, 48										;Convert to ASCII character number
	cld
	stosb											;Add to string array
	mov eax, 0
	mov al, ' '										;Add a space between each number in the array
	cld												 
	stosb
	add esi, 4										;Move to next element in number array
	pop ecx											;Pop outer loop counter
	loop NewNum										

Finish:
	displayString OFFSET strArray					;Use the displayString macro to display our number string
	call Crlf

	pop eax											;Restore the registers
	pop ebx
	pop ecx
	pop edx
	pop edi
	pop esi
	pop ebp

	ret 12
WriteVal ENDP

;------------------------------------------------------------------------------------------------------------
; The SumAvg procedure calculates the sum and average of the integers in the array and displays the results.
; Receives: numArray, numSum, numAvg, sumVal, and avgVal by reference
; Returns: Sum and average of array stored in sumVal and avgVal
; Preconditions: numArray must contain only 10 unsigned numbers, each of which must fit a 32-bit register
; Postconditions: Sum and average are displayed on the screen
; Registers changed: ebp, esi, edx, ecx, ebx, eax, save by PUSH and restored by POP
;------------------------------------------------------------------------------------------------------------
SumAvg PROC
	push ebp										;Save the original values of our registers onto the stack
	push esi
	push edx
	push ecx
	push ebx
	push eax

	mov ebp, esp

	mov esi, [ebp + 44]								;Offset of the beginning of our number array

	mov ecx, 9										;Loop counter, number of elements to go through in our array
	mov ebx, [esi]									;Move the first element of our array into ebx

Sum:
	add esi, 4										;Point to the next element
	add ebx, [esi]									;Add that element to what's already in ebx
	loop Sum

	mov edx, [ebp + 32]
	mov [edx], ebx									;Store calculated sum into our variable
	mov eax, [edx]
	mov edx, [ebp + 40]
	call WriteString								;Display our line and our sum
	call WriteDec
	call Crlf

	mov edx, 0										;Clear edx
	mov ebx, 10
	div ebx											;Divide our sum by 10
	mov ebx, [ebp + 28]								;Store calculated avg into our variable
	mov [ebx], eax
	mov edx, [ebp + 36]								;Display our line and our avg
	call WriteString
	mov eax, [ebx]
	call WriteDec
	call Crlf

	pop eax											;Restore the registers
	pop ebx
	pop ecx
	pop edx
	pop esi
	pop ebp

	ret 20
SumAvg ENDP

END main