TITLE Sorting and Counting Random Integers     (program5_onid.asm)

; Author: Phoenix Harris
; Last Modified: 5.17.2020
; OSU email address: harrisph@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 5                Due Date: 5.24.2020
; Description: This program generates 200 random numbers in the range [10 ... 29], displays 
;              the unsorted list, counts and displays the number of instances of each number, 
;              uses the list of counts to sort the list of random numbers, displays the 
;              median of the list, then finally displays the sorted list.
;
; Note: This program does not require any user input.
;
; Implementation note: This program uses procedures. Only the main procedure references global
;                      variables. All other procedures receive variables via the stack.

INCLUDE Irvine32.inc

ARRAYSIZE = 200
LO = 10
HI = 29

.data

title_author	BYTE	"Sorting and Counting Random Integers            "
				BYTE	"                   Programmed by Phoenix Harris", 0
description		BYTE	"This program generates 200 random numbers in the range [10 ... 29], displays "
				BYTE	"the original list, ", 10, 13
				BYTE	"counts and displays the number of instances of each number, uses the list of "
				BYTE	"counts to sort the ", 10, 13
				BYTE	"list of random numbers, displays the median of the list, then finally displays "
				BYTE	"the sorted list.", 0
EC_msg			BYTE	"**EC: Count list is derived before sorting the array, then count list is used "
				BYTE	"to sort the array.", 0
unsorted_msg	BYTE	"Your unsorted random numbers:", 0
sorted_msg		BYTE	"Your sorted random numbers:", 0
count_msg		BYTE	"Your list of instances of each generated number, starting with the number of 10s:", 0
median_msg		BYTE	"List Median: ", 0
farewell_msg	BYTE	"I hope that you have enjoyed this demonstration. Fare thee well, kind stranger.", 0
num_array		DWORD	ARRAYSIZE DUP(?)
count_list		DWORD	HI-LO+1 DUP(?)

.code
main PROC

	;display the program introduction
	push	OFFSET title_author
	push	OFFSET description
	push	OFFSET EC_msg
	call	introduction
	
	;fill num_array with ARRAYSIZE random numbers in the range [LO, HI]
	push	OFFSET num_array
	push	ARRAYSIZE
	push	LO
	push	HI
	call	fillArray

	;display the unsorted num_array
	push	OFFSET unsorted_msg
	push	OFFSET num_array
	push	ARRAYSIZE
	call	displayList
	
	;count the number of occurrances of each number in num_array and save the result in count_list
	push	OFFSET count_list
	push	OFFSET num_array
	push	ARRAYSIZE
	push	LO
	push	HI
	call	countList

	;display count_list
	push	OFFSET count_msg
	push	OFFSET count_list
	push	HI-LO+1
	call	displayList

	;sort num_array
	push	OFFSET num_array
	push	OFFSET count_list
	push	LO
	push	HI
	call	sortList

	;display the median of num_array
	push	OFFSET median_msg
	push	OFFSET num_array
	push	ARRAYSIZE
	call	displayMedian

	;display the sorted num_array
	push	OFFSET sorted_msg
	push	OFFSET num_array
	push	ARRAYSIZE
	call	displayList

	;display a farewell message
	push	OFFSET farewell_msg
	call	farewell

	exit	; exit to operating system
main ENDP


;-------------------------
introduction PROC USES edx
;
; Description: Displays program title and author, a description of the programs functionality, and
;              an extra credit message.
;
; Receives:
;	[ebp+20]	=	@title_author	=	address of string with program title and author
;	[ebp+16]	=	@description	=	address of string with program description
;	[ebp+12]	=	@EC_msg			=	address of string with extra credit message
;
; Returns: none
;
; Preconditions: none
;
; Postconditions: none
;
; Registers Changes: none
;------------------------

	;set up stack frame
	push	ebp
	mov		ebp, esp

	;display program title and author
	mov		edx, [esp+20]	;@title_author to edx
	call	WriteString
	call	CrLf
	call	CrLf

	;display description of program functionality
	mov		edx, [esp+16]	;@description to edx
	call	WriteString
	call	CrLf

	;display extra credit message
	mov		edx, [esp+12]	;EC_msg to edx
	call	WriteString
	call	CrLf
	call	CrLf

	pop		ebp
	ret		12
introduction ENDP



;------------------------------
fillArray PROC USES edi eax ecx
;
; Description: Fills an array of length ARRAYSIZE with pseudorandom numbers in the range [LO,HI].
;
; Receives:
;	[ebp+20]	=	HI			=	high end of the range of random numbers
;	[ebp+24]	=	LO			=	low end of the range of random numbers
;	[ebp+28]	=	ARRAYSIZE	=	length of the array being filled
;	[ebp+32]	=	@num_array	=	address of the array being filled
;
; Returns: num_array (filled with random numbers)
;
; Preconditions: HI > LO
;                ARRAYSIZE > 0
;
; Postconditions: none
;
; Registers Changes: none
;------------------------

	;set stack frame, fetch arguments
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+28]		;length of array
	mov		edi, [ebp+32]		;address of array

	call	randomize			;set random seed

Next:
	;set range for RandomRange procedure
	mov		eax, [ebp+20]		;HI-LO+1 to eax
	sub		eax, [ebp+24]
	inc		eax

	;get the next number into the array
	call	RandomRange
	add		eax, [ebp+24]		;add LO to RandomRange's return value
	mov		[edi], eax			;store the random number in the proper index in the array
	
	;increment the array index and repeat
	add		edi, 4
	loop	Next

	pop		ebp
	ret		16
fillArray ENDP



;------------------------------------
displayList PROC USES esi eax ecx edx
;
; Description: Displays the contents of an array.
;
; Receives:
;	[ebp+24]	=	length of the array
;	[ebp+28]	=	address of the array
;	[ebp+32]	=	address of string with array name
;
; Returns: none
;
; Preconditions: the length of the array must be a multiple of 20
;
; Postconditions: none
;
; Registers changed: none
;------------------------
	
	;set stack frame, fetch argument
	push	ebp				
	mov		ebp, esp
	mov		esi, [ebp+28]	;address of array

	;display name of array being displayed
	mov		edx, [ebp+32]	;address of string with array name
	call	WriteString
	call	CrLf

	;set outer loop counter
	mov		eax, [ebp+24]	;length of array being displayed
	cdq
	mov		ecx, 20
	div		ecx
	mov		ecx, eax		;length of the array divided by 20 in the outer loop counter

	;outer loop - determines how many lines of numbers to display
LineControl:
	push	ecx
	mov		ecx, 20			;set inner loop counter to 20

	;inner loop - displays 20 numbers on one line
Next:
	mov		eax, [esi]		;display current number
	call	WriteDec
	mov		al, 32			;insert 2 spaces between numbers
	call	WriteChar
	call	WriteChar
	add		esi, 4			;next number
	loop	Next

	;make a new line, restore outer loop counter, repeat the outer loop
	call	CrLf
	pop		ecx
	loop	LineControl

	call	CrLf

	pop		ebp
	ret		12
displayList ENDP




;--------------------------------------
countList PROC USES esi edi eax ebx ecx
;
; Description: Populates a list with the number of occurrences of each number from LO to HI 
;              in a separate list.
;
; Receives: 
;	[ebp+28]	=	HI			= high end of range of numbers in num_array
;	[ebp+32]	=	LO			= low end of range of numbers in num_array
;	[ebp+36]	=	ARRAYSIZE	= length of num_array
;	[ebp+40]	=	@num_array	= source list which is being scanned for occurrences from LO to HI
;	[ebp+44]	=	@count_list	= destination list which stores number of occurrences of numbers
;                                 in the source list
; 
; Returns: count_list
;
; Implementation note: the use of esi and edi are reversed from normal convention because the
;                      SCASD instruction requires edi be loaded with the array we want to scan
;
; Preconditions: num_array must be filled with numbers ranging from LO to HI 
;                HI > LO
;
; Postconditions: none
;
; Registers changed: none
;------------------------

	;set up stack frame, fetch arguments
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+44]	;@count_list to esi
	mov		eax, [ebp+32]	;LO to eax: start the scan with LO (inc up to HI with outer loop)
	
	;set outer loop counter to HI-LO+1
	mov		ecx, [ebp+28]	;HI
	sub		ecx, [ebp+32]	;LO
	inc		ecx
	
	cld						;clear direction flag so scan moves forward
	;outer loop - inserts a number into count_list at the correct index
NextNum:
	push	ecx
	mov		ecx, [ebp+36]	;ARRAYSIZE+1 to the inner loop counter
	inc		ecx
	mov		ebx, 0			;set accumulator to 0
	mov		edi, [ebp+40]	;@num_array to edi - must be reset after each use of SCASD instruction

	;inner loop - determines what number to insert into the next position of count_list
Counting:
	repne	scasd			;scan edi until value in eax is found or the end of the array is reached
	jecxz	Done
	inc		ebx				;increment the accumulator
	jmp		Counting

Done:
	mov		[esi], ebx		;save accumulator to correct position in count_list
	add		esi, 4
	inc		eax				;prepare to scan edi for occurrences of next number
	
	;restore outer loop counter and repeat
	pop		ecx
	loop	NextNum

	pop		ebp
	ret		20
countList ENDP



;---------------------------------
sortList PROC USES edi eax ebx ecx
;
; Description: Sorts a list by using the values in a separate list which holds the number of 
;              occurrences of each number in the list that is being sorted.
;
; Receives:
;	[ebp+24]	=	HI			=	high end of range of numbers in num_array
;	[ebp+28]	=	LO			=	low end of range of numbers in num_array
;	[ebp+32]	=	@count_list	=	list with number of occurrence of each number in num_array
;	[ebp+36]	=	@num_array	=	the list that is being sorted
;
; Returns: num_array (sorted)
;
; Preconditions: num_array must be filled with numbers ranging from LO to HI
;                count_list must be filled with the number of occurrences of each number in num_array
;                HI > LO
;
; Postconditions: none
;
; Registers Changes: none
;------------------------

	;set up stack frame, fetch arguments
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+36]	;num_array to edi
	mov		ebx, [ebp+32]	;count_list to ebx

	;set outer loop counter to HI-LO+1
	mov		ecx, [ebp+24]
	sub		ecx, [ebp+28]
	inc		ecx

	;LO to eax: start filling num_array with LO (inc up to high with outer loop)
	mov		eax, [ebp+28]

	cld
	;outer loop - increment eax from LO to HI
NextCount:
	push	ecx
	mov		ecx, [ebx]		;a number from count_list is moved to the inner loop counter	
	
	;inner loop
	;fill num_array with the number in eax
	;ecx holds the value indicating when to stop filling
	rep		stosd
	
	;prepare to fill with the next number
	inc		eax				;plus 1 to eax so num_array can be filled with the next number
	add		ebx, 4			;move to the next index in count_list
	
	;restore outer loop counter and repeat
	pop		ecx
	loop	NextCount

	pop		ebp
	ret		16
sortList ENDP



;------------------------------------------
displayMedian PROC USES edi eax ebx ecx edx
;
; Description: Calculates and displays the median of a list.
;
; Receives:
;	[ebp+28]	=	ARRAYSIZE	=	length of num_array
;	[ebp+32]	=	@num_array	=	the address of the array whose median is being calculated 
;                                   and displayed
;	[ebp+36]	=	@median_msg	=	the address of a string of the following form: "List Median: "
;
; Returns: none
;
; Preconditions: ARRAYSIZE must be even (the median is calculated based on two middle numbers)
;                num_array must be sorted
;
; Postconditions: none
;
; Registers Changes: none
;------------------------

	;set up stack frame, fetch array to sort
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+32]		;@num_array to esi
	
	;display median_msg
	mov		edx, [ebp+36]		;"List Median: "
	call	WriteString

	;get the index of the top-middle number
	mov		eax, [ebp+28]		;ARRAYSIZE to eax
	mov		ebx, 2
	mul		ebx					;multiply ARRAYSIZE by 2 and store in ecx
	mov		ecx, eax

	;get the sum of the two middle numbers into eax
	mov		eax, [esi+ecx]		;top-middle index to eax
	sub		ecx, 4
	add		eax, [esi+ecx]		;bottom-middle index to eax

	cdq
	div		ebx					;get the average of the middle numbers

	;determine if rounding is needed
	cmp		edx, 0
	je		Done
	inc		eax

Done:
	call	WriteDec			;display the median
	call	CrLf
	call	CrLf

	pop		ebp
	ret		12
displayMedian ENDP


;---------------------
Farewell PROC USES edx
;
; Description: Display a farewell message.
;
; Receives:
;	[ebp+12]	=	@farewell_msg	=	address of a string with a farewell message
;
; Returns: none
;
; Preconditions: none
;
; Postconditions: none
;
; Registers Changes: none
;------------------------

	;set up stack frame
	push	ebp
	mov		ebp, esp

	;display farewell message
	mov		edx, [ebp+12]		;@farewell_msg
	call	WriteString
	call	CrLf

	pop		ebp
	ret		4
Farewell ENDP

END main
