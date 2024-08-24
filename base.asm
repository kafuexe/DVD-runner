.286
IDEAL
MODEL small
STACK 100h

MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200			

SMALL_BMP_HEIGHT = 27												;the hight of the bmp file of the dvd	;27
SMALL_BMP_WIDTH = 70												;the width of the bmp file of the dvd  ;70

DATASEG


	WINDOW_BOUNDS dw 3    	 										;check collisions with bounds early
	CORNER_THRESHOLD dw 20											;size of box of corner to make game ez
	
	TEXT_GAME_OVER_TITLE db 'GAME OVER','$' 						;game over menu text
	TEXT_PRESS_SPACE_TO_CONTINUE db 'press space to RESTART','$'	;game over menu text
	TEXT_GAME_START_TITLE db	'DVD RUNNER','$' 					;game start menu text TITLE
	TEXT_GAME_SPACE_TO_START db 'press space to START','$'			;game start menu text
	SCORE_COLUMN db 04h												;column pos of score
	SCORE_ROW db  	04h												;row pos of score
	
	PLAYER_X dw 10 													;player starting pos (x)
	PLAYER_y dw 15 													;player starting pos (y)
	
	PLAYER_VAL_X dw 07h 											;velocity of the player on (X)
	PLAYER_VAL_Y dw 07h 											;velocity of the player on (y)
	PLAYER_SIZE dw 05h 												;size of the player
	PLAYER_COLOR db 5  												;player color
	
	
	PLAYER_2_X dw 20 												;player starting pos (x)
	PLAYER_2_y dw 15 												;player starting pos (y)
	PLAYER_2_COLOR db 5  
	
	DVD_X dw 30														;DVD starting pos (x)
	DVD_Y dw 30														;DVD starting pos (Y)
	DVD_WIDTH dw 70													;DVD WIDTH 
	DVD_HIGHT dw 25													;DVD HIGHT 
	
	DVD_VAL_X dw 03h												;DVD velocity (x)  
	DVD_VAL_Y dw 03h 												;dvd velocity (y)
	DVD_COLOR db 2													;DVD color
	DVD_COLOR_DRAW db 1
	VEL_DVD_INCREMENTS dw 1    										;the change of speed of dvd every delay*TIME_AUX-framerate
	SET_DVD_DELAY dw 40 											;Delay between increace in velocity valocity

	MAX_DVD_VAL_X dw 09h											;max velocity of dvd(or the next multiplaction of VEL_DVD_INCREMENTS) on (X)
	MAX_DVD_VAL_Y dw 09h											;max velocity of dvd(or the next multiplaction of VEL_DVD_INCREMENTS) on (Y)
	
	 
	note dw 3043 ; 1193180 / 131 -> (hex) ;f= 3416 ;g= 3043
	
	
	;DONT CHANGE
	
	PLAYER_POINTS db 0 												;points of player
	CURRENT_DELAY dw 0												;rest delay(LEAVE AT 0!)
	TIME_AUX db 0 													;variable used when checking if the time has changed
	WINDOW_WIDTH DW 140h     										;the width of the window (320 pixels) 
	WINDOW_HEIGHT DW 0C8h    										;the hight of the window (200 pixels)
	CONST_DVD_WIDTH dw 70											;DVD WIDTH for drawing(DO NOT CHANGE)
	CONST_DVD_HIGHT dw 25											;DVD HIGHT for drawing(DO NOT CHANGE)
	TEXT_PLAYER_POINTS_ONES db '0', '$'								;starting player points(DONT NOT TOUCH)
	TEXT_PLAYER_POINTS_TENS db '0', '$'								;starting player points(DONT NOT TOUCH)
	TEXT_PLAYER_POINTS_HUNDREDS db '0', '$'							;starting player points(DONT NOT TOUCH)
	GAME_ACTIVE db 1 												;if game is active 1 else 0(MUST START ON 1)
	BACKGROUND_COLOR db 00h											;allways black!
	; check if score has been givin more then 1 time in a row(DO NOT CHANGE)
	
	;CORENER FLAGS
	FLAG_TOP_LEFT db  0
	FLAG_BOT_LEFT db 0
	FLAG_TOP_RIGHT db 0
	FLAG_BOT_RIGHT db 0
	POINTS_FLAG db 0

	;BMP FILE STUFF
    OneBmpLine  db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
    ScreenLineMax   db MAX_BMP_WIDTH dup (0)  	;One Color line read buffer
    ;BMP File data
    FileHandle  dw ?		
    Header      db 54 dup(0)
    Palette     db 400h dup (0)
    SmallPicName db 'DVDPIC.bmp',0			;file name
    BmpFileErrorMsg     db 'Error At Opening Bmp File .', 0dh, 0ah,'$'
    ErrorFile           db 0
    BB db "BB..",'$'
	
	
	
	;music notes and dealys
	DSHARP dw 	3834	
	ENORMAL dw  3619
	FNORMAL dw  3416
	FSHARP dw  	3224
	GNORMAL dw 	3043
	GSHARP dw 	2873
	ANORMAL dw 	2711
	BNORMAL dw 	2415
	CXDELAY DW 01h
	DXSMALLORBIG dw 00h
	BIGDELAY dw 02h
	soundflag dw 1
	
	;TEXT file vars 
	file_name        db 'TSCORE.txt',0						;name of text file
	Text_Buffer db 4 dup ('$')								;where the ascii code of text file is saved 
	TXT_filehandle       dw ?								;storing file name and opening method 
	TEXTHUNDREDS db ?										;indevidual saving of score ascii chars 
	TEXTTENS	 db ?										;indevidual saving of score ascii chars 
	TEXTONES	 db ?										;indevidual saving of score ascii chars 
	TEXTTOTAL    dw 0										;total of score (as a normal num)
	TEXT_HIGHSCORE_TEXT db 'All Time High Score:',0,'$'		;text for showing high score
	
	COLOR_BACKGROUND_1 db 2

	
CODESEG													

proc ReadFile 
	pusha
	mov ah, 3dh 				;open the file
	mov al, 2 					;open for reading and writeing
	lea dx, [file_name]		
	int 21h 
	mov [TXT_filehandle], ax	;file handel is now new file name

	mov ah, 3fh  
	lea dx, [Text_Buffer]
	mov cx, 3 					;Read 3 Byte (as ascii)
	mov bx, [TXT_filehandle] 
	int 21h
	
	mov al,[Text_Buffer]				
	mov [TEXTHUNDREDS], al		;devide the 3 bytes to hundreds
	mov al,[Text_Buffer+1]			
	mov [TEXTTENS], al			;devide the 3 bytes to tens
	mov al,[Text_Buffer+2]
	mov [TEXTONES],al			;devide the 3 bytes to ones
	
	sub [TEXTHUNDREDS], 30h		;make the ascii nums to normal nums
	sub [TEXTTENS],30h			;make the ascii nums to normal nums
	sub [TEXTONES],30h			;make the ascii nums to normal nums
	
	mov al,100
	mul	[TEXTHUNDREDS]			;multiply hundreds by 100 		
	add [TEXTTOTAL],ax			;add to total high score		
	
	mov al,10
	mul	[TEXTTENS]				;multiply tens by 10
	add [TEXTTOTAL],ax			;add to total high score
	
	mov al,1
	mul	[TEXTONES]				;multiply ones by 1 (needed inorder to make it a word not a byte)
	add [TEXTTOTAL],ax			;add to total high score
	
	mov ax,1
	mul [PLAYER_POINTS]
	cmp [TEXTTOTAL],ax 			;check if new high score is reached
	jnl NO_TEXT_WRITE 			;skip changing the top score	
	
		mov al, [TEXT_PLAYER_POINTS_HUNDREDS]	;make new score top score 
		mov [Text_Buffer],al
		mov al, [TEXT_PLAYER_POINTS_TENS]		;make new score top score 
		mov [Text_Buffer+1],al
		mov al, [TEXT_PLAYER_POINTS_ONES]		;make new score top score 
		mov [Text_Buffer+2],al	
		
		
												;top score is saved in [Text_Buffer]
		
		mov bx, [TXT_filehandle]
		mov ah, 3eh 					;close file
		int 21h
	
		mov ah, 3dh 					;reopen the file (needed for writing)
		mov al, 2 						;open for reading and writeing
		lea dx, [file_name]
		int 21h 
		mov [TXT_filehandle], ax 
	
		mov ah,40h
		mov bx, [TXT_filehandle]
		mov cx,0						;delete everything in the file (by writing 0 bytes)
		mov dx,0	
		int 21h 
	
		mov ah,40h
		mov bx, [TXT_filehandle]
		mov cx,3						;rewrite new top score	(4 new bytes)
		lea dx,[Text_Buffer]
		int 21h 
		
	NO_TEXT_WRITE:
	mov bx, [TXT_filehandle]
	mov ah, 3eh 						;close file
	int 21h
	
	popa
	ret

endp ReadFile 


proc SCREEN_CLEAR						;clear screen by reaseting vidoe mode
	mov AH,00h  						;set cofig for vidoe mode
	mov AL,13h  						;choose vidoe mode 
	int 10h								;execute vidoe mode
	
	mov ah,0bh							;set configuration
	mov bh,00h							;to the background color
	mov bl,[BACKGROUND_COLOR]			;choose background color
	int 10h					 			;execute
	
	ret
endp SCREEN_CLEAR
	
	
proc ENDGAME							;sets game as over.
	
	mov [DVD_VAL_X],0
	mov	[DVD_VAL_Y], 0
	mov [GAME_ACTIVE],00h  				;Stops the game
	ret
ENDP ENDGAME


proc DRAW_GAME_OVER_MENU ;draws game over menu
	call SCREEN_CLEAR  					;clear the screen
	call ReadFile
	
	
	;show title
	mov ah,02h							;set cursor pos 
	mov bh,00h							;set page num
	mov DH,04h							;set row
	mov DL,0Fh							;set column
	int 10h	
	
	mov ah,09h							;write string to output
	lea dx, [TEXT_GAME_OVER_TITLE]		;give dx a pointer to string
	int 21h								;print the string
	
	;add SCORE COUNTER 
	
	
	
	;add 'press space to continue
	mov ah,02h							;set cursor pos 
	mov bh,00h							;set page num
	mov DH,10h							;set row
	mov DL,09h							;set column
	int 10h	
	
	mov ah,09h							;write string to output
	lea dx, [TEXT_PRESS_SPACE_TO_CONTINUE]	;give dx a pointer to string
	int 21h								;print the string
	
	
	;draw the points for player
	;----------------ONES
	mov ah,02h		;set cursor pos
	mov bh,00h		;set page num
	mov dh,	08h	;set row
	mov dl, 13h	;set column
	add dl,2 ;move right
	int 10h
	mov ah, 09h 						;write string to standard output
	
	lea dx,[TEXT_PLAYER_POINTS_ONES] 	;give dx a point to string 
	int 21h								;print the string
	
	;----------------tens
	mov ah,02h		;set cursor pos
	mov bh,00h		;set page num
	mov dh,	08h	;set row
	mov dl, 13h	;set column
	add dl,1 ;move right
	int 10h
	mov ah, 09h 						;write string to standard output
	
	lea dx,[TEXT_PLAYER_POINTS_TENS] 	;give dx a point to string 
	int 21h								;print the string
	
	;----------------------hundreds
	mov ah,02h		;set cursor pos
	mov bh,00h		;set page num
	mov dh,	08h	;set row
	mov dl, 13h	;set column
	int 10h
	mov ah, 09h 						;write string to standard output
	lea dx,[TEXT_PLAYER_POINTS_HUNDREDS]
	int 21h
	
	
	;draw the highscore
	
	;--------------text for high score
	mov ah,02h		;set cursor pos
	mov bh,00h		;set page num
	mov dh,	0ch	;set row
	mov dl, 06h	;set column
	int 10h
	mov ah, 09h 						;write string to standard output
	
	lea dx,[TEXT_HIGHSCORE_TEXT] 	;give dx a point to string 
	int 21h		
	
	;----------------points
	mov ah,02h		;set cursor pos
	mov bh,00h		;set page num
	mov dh,	0ch	;set row
	mov dl, 19h	;set column
	add dl,2 ;move right
	int 10h
	mov ah, 09h 						;write string to standard output
	
	lea dx,[Text_Buffer] 	;give dx a point to string 
	int 21h								;print the string
	
	
	
	;draws one time and waits for keypress
	mov ah,00h
	int 16h
	cmp al, 20h							;compers the keypress to ASCII of 'SPACE'(20h)
	jne NOT_SPACE
	call GAME_RESTART
	call start
	NOT_SPACE:
	ret
endp DRAW_GAME_OVER_MENU
	
proc GAME_RESTART
	call SCREEN_CLEAR
	mov [PLAYER_X] , 10 				;player starting pos (x)
	mov [PLAYER_y] , 10 				;player starting pos (y)
	mov	[PLAYER_VAL_X] , 07h 			;velocity of the player on (X)
	mov [PLAYER_VAL_Y] , 07h 			;velocity of the player on (y)
	mov [DVD_X] , 30					;DVD starting pos (x)
	mov [DVD_Y] , 30					;DVD starting pos (Y)

	mov [DVD_VAL_X] , 03h				;DVD velocity (x)  
	mov [DVD_VAL_Y] , 03h 				;dvd velocity (y)
	
	mov [PLAYER_POINTS] , 0 			;points of player
	mov [CURRENT_DELAY] , 0				;rest delay(LEAVE AT 0!)
	
	mov [TIME_AUX],0 					;variable used when checking if the time has changed
	mov [TEXT_PLAYER_POINTS_ONES],0
	mov [TEXT_PLAYER_POINTS_tens],0		;starting player points(DONT NOT TOUCH)
	mov [TEXT_PLAYER_POINTS_HUNDREDS],0
	mov [FLAG_TOP_LEFT] ,0				;rest flag for corners 
	mov [FLAG_BOT_LEFT] ,0				;rest flag for corners 
	mov [FLAG_TOP_RIGHT] ,0				;rest flag for corners  
	mov	[FLAG_BOT_RIGHT] ,0				;rest flag for corners 	
	mov [soundflag], 1	
	
	mov [TEXTHUNDREDS], 0
	mov [TEXTTENS], 0
	mov [TEXTONES], 0
	mov [TEXTTOTAL ] , 0
	
	
	ret
	
endp GAME_RESTART
proc DRAW_DVD
	mov CX,[DVD_X] 					;set starting pos CX the (X) value for DVD
	mov DX,[DVD_Y] 					;set starting pos DX the (Y) value	for DVD
	DRAW_DVD_HORIZONTAL:
		mov AH,0Ch 					;set config to write a pixel
		mov AL, [DVD_COLOR] 		;choose pixel color
		mov bh, 00h 				;set page num
		int 10h 					;execute
		
		inc cx  					;cx=cx+1
		mov ax, cx					;cx - DVD_X > DVD_SIZE(y -> we go to next line,n -> we go to next column)
		sub ax,[DVD_X]
		cmp ax, [DVD_WIDTH]
		jng DRAW_DVD_HORIZONTAL
		
		mov cx,[DVD_X] 				;cx gose back to inatial column
		inc dx 						;advance one line
		mov ax,dx
		sub ax,[DVD_Y]
		cmp ax,[DVD_HIGHT]
		jng DRAW_DVD_HORIZONTAL 
	
	ret
endp DRAW_DVD


proc CLEAR_DVD		; clears only the dvd area to optimze
	mov CX,[DVD_X] 					;set starting pos CX the (X) value for DVD
	mov DX,[DVD_Y] 					;set starting pos DX the (Y) value	for DVD
	CLEAR_DVD_HORIZONTAL:
		mov AH,0Ch 					;set config to write a pixel
		mov AL, [BACKGROUND_COLOR] 		;choose pixel color
		mov bh, 00h 				;set page num
		int 10h 					;execute
		
		inc cx  					;cx=cx+1
		mov ax, cx					;cx - DVD_X > DVD_SIZE(y -> we go to next line,n -> we go to next column)
		sub ax,[DVD_X]
		cmp ax, [DVD_WIDTH]
		jng CLEAR_DVD_HORIZONTAL
		
		mov cx,[DVD_X] 				;cx gose back to inatial column
		inc dx 						;advance one line
		mov ax,dx
		sub ax,[DVD_Y]
		cmp ax,[DVD_HIGHT]
		jng CLEAR_DVD_HORIZONTAL 
	
	ret
endp CLEAR_DVD

proc DRAW_DVD_DRAWING				;useing bmp and procs form book
	mov dx,offset SmallPicName
    call OpenShowBmp 
    cmp [ErrorFile],1
    jne cont1
    jmp exitError
	 cont1:  

    jmp exittow

	exitError:   

		mov dx, offset BmpFileErrorMsg
		mov ah,9
		int 21h
		
	exittow:
		
	;input :
	;1.DVD_X offset from left (where to start draw the picture) 
	;2. DVD_Y offset from top
	;3. DVD_WIDTH picture width , 
	;4. DVD_HIGHT bmp height 
	;5. dx offset to file name with zero at the end 
	
	ret
endp DRAW_DVD_DRAWING

proc DEATH_SOUND

	;Sound boop 
	; open speaker
	
	; D# E F - F F# G - G G# A - B
	; small time delay 
	; - big time delay
	
	
	;D#------------
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [DSHARP] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	
	
	;E-------------------------
	
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [ENORMAL] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	
	
	;F-------------------------
	
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [FNORMAL] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	;BIG dealy-----
	
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	
	;F-------------------------
	
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [FNORMAL] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	;F#-------------------------
	
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [FSHARP] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	
	;G-------------------------
	
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [GNORMAL] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	
	;G#-------------------------
	
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [GSHARP] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
		
	
	;A-------------------------
	
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [ANORMAL] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [CXDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	;BIG dealy-----
	
	MOV     CX, [BIGDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	
	;B-------------------------
	
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [BNORMAL] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, [BIGDELAY]
	MOV     DX, 00H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	
	
	mov [soundflag] , 0
	ret
endp DEATH_SOUND

proc OpenShowBmp near
    push cx
    push bx


    call OpenBmpFile
    cmp [ErrorFile],1
    je @@ExitProc


    call ReadBmpHeader

    ; from  here assume bx is global param with file handle. 
    call ReadBmpPalette

    call CopyBmpPalette

    call ShowBMP


    call CloseBmpFile

@@ExitProc:
    pop bx
    pop cx
	
    ret
endp OpenShowBmp

proc OpenBmpFile    near                         
    mov ah, 3Dh
    xor al, al
    int 21h
    jc @@ErrorAtOpen
    mov [FileHandle], ax
    jmp @@ExitProc

@@ErrorAtOpen:
    mov [ErrorFile],1
@@ExitProc: 
    ret
endp OpenBmpFile


proc CloseBmpFile near
    mov ah,3Eh
    mov bx, [FileHandle]
    int 21h
    ret
endp CloseBmpFile

proc ReadBmpHeader  near                    
    push cx
    push dx

    mov ah,3fh
    mov bx, [FileHandle]
    mov cx,54
    mov dx,offset Header
    int 21h

    pop dx
    pop cx
    ret
endp ReadBmpHeader

proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
                         ; 4 bytes for each color BGR + null)           
    push cx
    push dx

    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h

    pop dx
    pop cx

    ret
endp ReadBmpPalette

proc CopyBmpPalette     near                    

    push cx
    push dx

    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0  ; black first                         
    out dx,al ;3C8h
    inc dx    ;3C9h
CopyNextColor:
    mov al,[si+2]       ; Red               
    shr al,2            ; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).             
    out dx,al                       
    mov al,[si+1]       ; Green.                
    shr al,2            
    out dx,al                           
    mov al,[si]         ; Blue.             
    shr al,2            
    out dx,al                           
    add si,4            ; Point to next color.  (4 bytes for each color BGR + null)             

    loop CopyNextColor

    pop dx
    pop cx

    ret
endp CopyBmpPalette

proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (DVD_HIGHT lines in VGA format),
; displaying the lines from bottom to top.
    push cx

    mov ax, 0A000h
    mov es, ax

    mov cx,[DVD_HIGHT]

    mov ax,[DVD_WIDTH] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
    xor dx,dx
    mov si,4
    div si
    mov bp,dx

    mov dx,[DVD_X]

@@NextLine:
    push cx
    push dx

    mov di,cx  ; Current Row at the small bmp (each time -1)
    add di,[DVD_Y] ; add the Y on entire screen


    ; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
    mov cx,di
    shl cx,6
    shl di,8
    add di,cx
    add di,dx

    ; small Read one line
    mov ah,3fh
    mov cx,[DVD_WIDTH]  
    add cx,bp  			; extra  bytes to each row must be divided by 4
    mov dx,offset ScreenLineMax
    int 21h
    ; Copy one line into video memory
    cld ; Clear direction flag, for movsb
    mov cx,[DVD_WIDTH]  
    mov si,offset ScreenLineMax
    rep movsb ; Copy line to the screen

    pop dx
    pop cx

    loop @@NextLine

    pop cx
    ret
endp ShowBMP 



proc MOVE_DVD
	mov ax,[SET_DVD_DELAY]
	CMP ax,[CURRENT_DELAY]          ;checking if delay has passed	
	jG NO_CHANGE
	
	mov ax,[MAX_DVD_VAL_X] 			;checking if it has gotten to max valocity in (x)
	cmp[DVD_VAL_X],ax
	jge NO_CHANGE_X_VAL
	neg ax							;velocity can be negtives so must be checked in NEG
	cmp [DVD_VAL_X],ax
	jle NO_CHANGE_X_VAL
														
	mov ax,[VEL_DVD_INCREMENTS]				
	cmp [DVD_VAL_X],0				;if the velocity is negtive you subtract to increace(X)
	jl VAL_IS_NEG_X					;else you add	(X)
	add [DVD_VAL_X],ax
	VAL_IS_NEG_X:
		sub [DVD_VAL_X],ax
		
	NO_CHANGE_X_VAL:
		
	mov ax,[MAX_DVD_VAL_Y]			;checking if it has gotten to max valocity in (y)
	cmp[DVD_VAL_Y],ax
	jge NO_CHANGE
	NEG ax
	cmp[DVD_VAL_Y],ax				;velocity can be negtives so must be checked in NEG
	jle NO_CHANGE
	
	mov ax,[VEL_DVD_INCREMENTS]		;reset ax back to normal
	cmp [DVD_VAL_Y],0				;if the velocity is negtive you subtract to increace(Y)
	jl VAL_IS_NEG_y					;else you add(Y)
	add [DVD_VAL_Y],ax
	VAL_IS_NEG_y:
		sub[DVD_VAL_Y],ax
	mov [CURRENT_DELAY], 0			;reset delay counter
	
	NO_CHANGE:
	inc [CURRENT_DELAY]
	

	mov ax,[DVD_VAL_X]  			;set velocity 
	add [DVD_X],ax					;moving the DVD by velocity
	
	mov ax,[WINDOW_BOUNDS]
	cmp [DVD_X], ax					;if PLAYER_X < 0 + WINDOW_BOUNDS (colided with left bondery)
	jl NEG_VELOCITY_x				;gose to reversing of (X) velocity
	
	mov ax,[WINDOW_WIDTH]
	sub ax,[DVD_WIDTH]
	sub ax, [WINDOW_BOUNDS]
	cmp [DVD_X],ax					;if DVD_X > WINDOW_WIDTH - DVD_WIDTH -bounds(colided with right bondery)
	jg NEG_VELOCITY_x				;gose to reversing of (X) velocity
	
	
	
	mov ax,[DVD_VAL_Y]	
	add [DVD_Y],ax					;moving the DVD by valocity on Y
	
	mov ax,[WINDOW_BOUNDS]
	cmp [DVD_Y], ax					;if DVD_Y < 0 (colided with TOP bondery)
	jl NEG_VELOCITY_Y				;gose to reversing of (Y) velocity

	mov ax,[WINDOW_HEIGHT]
	sub ax,[DVD_HIGHT]
	sub ax, [WINDOW_BOUNDS]
	cmp [DVD_Y],ax					;if DVD_Y > WINDOW_WIDTH -DVD_HIGHT - bounds(colided with Bottom bondery)
	jg NEG_VELOCITY_Y  				;gose to reversing of (Y) velocity
	
	jmp SKIP_NEG_VEL
	NEG_VELOCITY_x:
		NEG [DVD_VAL_X]  			;revers DVD velocity (X)
		ret
	NEG_VELOCITY_Y:
		NEG [DVD_VAL_Y]				;revers DVD velocity (Y)
		ret
	
	SKIP_NEG_VEL:
	
	
	
	
	; check if dvd colides with player.
	;maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2
	;DVD_X+DVD_WIDTH > PLAYER_X && DVD_X< PLAYER_X +PLAYER_SIZE && 
	;DVD_Y +DVD HIGHT > PLAYER_Y && DVD_Y<PLAYER_Y +PLAYER_SIZE 
	;this is a simplfied AABB Tree Collision Detection
	
	mov ax,[DVD_X]
	add ax,[DVD_WIDTH]
	cmp AX,[PLAYER_X]
	jng NEXT_COLIDE ;no colison jump to next check
	
	mov ax,[PLAYER_X]
	add ax,[PLAYER_SIZE]
	cmp [DVD_X],ax
	jnl NEXT_COLIDE	;no colison jump to next check
	
	mov ax,[DVD_Y]
	add ax ,[DVD_HIGHT]
	cmp ax, [PLAYER_Y]
	jng NEXT_COLIDE	;no colison jump to next check
	
	mov AX,[PLAYER_Y]
	add ax,[PLAYER_SIZE]
	cmp [DVD_Y],ax
	jnl NEXT_COLIDE	;no colison jump to next check
	
	; if didnt jump theres a collision
	call ENDGAME
	ret
	
	NEXT_COLIDE:
	
	
	
	
	
	
	
	
	
	;---------------------------
	;check if dvd colides with corners(need to make vars for corners..)
	
	
	
	
	;maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2
	;DOSENT WORK
	
	;if DVD_X <CORNER_THRESHOLD+WINDOW_BOUNDS && DVD_Y < CORNER_THRESHOLD+WINDOW_BOUNDS add point (LEFT TOP CORNER)
	mov ax, [CORNER_THRESHOLD]
	add ax,[WINDOW_BOUNDS]
	cmp [DVD_X],ax
	jnl NO_COLIDE_TOP_LEFT
	mov ax, [CORNER_THRESHOLD]
	add ax,[WINDOW_BOUNDS]
	cmp [DVD_Y], ax
	jnl	NO_COLIDE_TOP_LEFT
	;----
	cmp [FLAG_TOP_LEFT],1	;flag top left = 1 if allready added point 
	je TOP_LEFT_COL	

	call ADD_POINT
	mov [FLAG_TOP_LEFT],1	
	jmp TOP_LEFT_COL
	;----
	NO_COLIDE_TOP_LEFT:
	mov [FLAG_TOP_LEFT],0
	
	TOP_LEFT_COL:
	
	
	
	;if DVD_X <CORNER_THRESHOLD+WINDOW_BOUNDS && DVD_Y+DVD_HIGHT > CORNER_THRESHOLD-WINDOW_BOUNDS+WINDOW_HEIGHT add point (LEFT BOT CORNER)
	mov ax, [CORNER_THRESHOLD]
	add ax,[WINDOW_BOUNDS]
	cmp [DVD_X],ax
	jnl NO_COLIDE_BOT_LEFT
	
	mov ax,[WINDOW_HEIGHT]
	SUB ax,[WINDOW_BOUNDS]
	sub ax,[CORNER_THRESHOLD]
	mov bx,[DVD_Y]
	add bx,[DVD_HIGHT]
	cmp bx, ax
	jng	NO_COLIDE_BOT_LEFT
	cmp [FLAG_BOT_LEFT],1
	je BOT_LEFT_COL
	call ADD_POINT
	mov [FLAG_BOT_LEFT],1
	jmp BOT_LEFT_COL
	NO_COLIDE_BOT_LEFT:
	mov [FLAG_BOT_LEFT],0
	
	BOT_LEFT_COL:
	
	
	
	;if DVD_X >CORNER_THRESHOLD-WINDOW_BOUNDS + WINDOW_WIDTH && DVD_Y < CORNER_THRESHOLD+WINDOW_BOUNDS add point (RIGHT TOP CORNER)
	mov ax, [WINDOW_WIDTH]
	sub ax,[WINDOW_BOUNDS]
	sub ax,[CORNER_THRESHOLD]
	mov bx,[DVD_X]
	add bx,[DVD_WIDTH]
	cmp bx,ax
	jng NO_COLIDE_TOP_RIGHT
	
	mov ax, [CORNER_THRESHOLD]
	add ax,[WINDOW_BOUNDS]
	cmp [DVD_Y], ax
	jnl	NO_COLIDE_TOP_RIGHT
	cmp [FLAG_TOP_RIGHT],1
	je TOP_RIGHT_COL
	call ADD_POINT
	
	mov [FLAG_TOP_RIGHT],1
	jmp TOP_RIGHT_COL
	NO_COLIDE_TOP_RIGHT:
	mov [FLAG_TOP_RIGHT],0
	
	TOP_RIGHT_COL:
	
	
	;if DVD_X <CORNER_THRESHOLD-WINDOW_BOUNDS + WINDOW_WIDTH+ &&	DVD_Y < CORNER_THRESHOLD-WINDOW_BOUNDS+WINDOW_HEIGHT add point (RIGHT BOT CORNER)
	mov ax, [WINDOW_WIDTH]
	sub ax,[WINDOW_BOUNDS]
	sub ax,[CORNER_THRESHOLD]
	mov bx,[DVD_X]
	add bx,[DVD_WIDTH]
	cmp bx,ax
	jng NO_COLIDE_BOT_RIGHT
	
	mov ax,[WINDOW_HEIGHT]
	SUB ax,[WINDOW_BOUNDS]
	sub ax,[CORNER_THRESHOLD]
	mov bx,[DVD_Y]
	add bx,[DVD_HIGHT]
	cmp bx, ax
	jng	NO_COLIDE_BOT_RIGHT
	cmp [FLAG_BOT_RIGHT],1
	je ENDING_COL
	
	call ADD_POINT
	mov [FLAG_BOT_RIGHT],1
	
	jmp ENDING_COL
	NO_COLIDE_BOT_RIGHT:
	mov [FLAG_BOT_RIGHT],0 
	
	ENDING_COL:

	ret
	;---------------------------
	

	
endp MOVE_DVD






proc DRAW_PLAYER
	
	mov CX,[PLAYER_X] 				;set starting pos CX the (X) value for player
	mov DX,[PLAYER_y] 				;set starting pos DX the (Y) value for player
	
	DRAW_PLAYER_HORIZONTAL:
		mov AH,0Ch 					;set config to write a pixel
		mov AL, [PLAYER_COLOR] 		;choose pixel color
		mov bh, 00h 				;set page num
		int 10h 					;execute
		
		inc cx  					;cx=cx+1
		mov ax, cx					;cx - PLAYER_X > PLAYER_SIZE(y -> we go to next line,n -> we go to next column)
		sub ax,[PLAYER_X]
		cmp ax, [PLAYER_SIZE]
		jng DRAW_PLAYER_HORIZONTAL
		
		mov cx,[PLAYER_X] 			;cx gose back to inatial column
		inc dx 						;advance one line
		mov ax,dx
		sub ax,[PLAYER_y]
		cmp ax,[PLAYER_SIZE]
		jng DRAW_PLAYER_HORIZONTAL 
				
		
	
	ret
endp DRAW_PLAYER
proc CLEAR_PLAYER
	
	mov CX,[PLAYER_X] 				;set starting pos CX the (X) value for player
	mov DX,[PLAYER_y] 				;set starting pos DX the (Y) value for player
	
	CLEAR_PLAYER_HORIZONTAL:
		mov AH,0Ch 					;set config to write a pixel
		mov AL, [BACKGROUND_COLOR] 		;choose pixel color
		mov bh, 00h 				;set page num
		int 10h 					;execute
		
		inc cx  					;cx=cx+1
		mov ax, cx					;cx - PLAYER_X > PLAYER_SIZE(y -> we go to next line,n -> we go to next column)
		sub ax,[PLAYER_X]
		cmp ax, [PLAYER_SIZE]
		jng CLEAR_PLAYER_HORIZONTAL
		
		mov cx,[PLAYER_X] 			;cx gose back to inatial column
		inc dx 						;advance one line
		mov ax,dx
		sub ax,[PLAYER_y]
		cmp ax,[PLAYER_SIZE]
		jng CLEAR_PLAYER_HORIZONTAL 
				
		
	
	ret
endp CLEAR_PLAYER
	
proc MOVE_PLAYER
									;check if a key is being pressed(if not exit proc)
	mov ah, 01h  					;change mod to check for a keypress mode
	int 16h   						;check if key is pressed 
	jz NEXT_MOVMENT_stop			;jump if zero (zero is activate)
	
									;check wich key is being pressed(AL = ASCII CHAR)
	mov ah,00h 						;change mod to wait and read keyppres
	int 16h							;interupt and get key in AL
	

									;if 'w' or 'W'  move up
	cmp AL,57h 						;'W'
	je MOVE_PLAYER_UP				;
	cmp al,77h 						;'w'
	je MOVE_PLAYER_UP				;
	
									;if 's' or 'S' move down
	cmp AL,53h 						;'S'
	je MOVE_PLAYER_DOWN				;
	cmp al,73h 						;'s'
	je MOVE_PLAYER_DOWN				;
	
	
									;if 'd' or 'D' move right
	cmp AL,44h 						;'D'
	je MOVE_PLAYER_RIGHT			;
	cmp al,64h 						;'d'
	je MOVE_PLAYER_RIGHT			;
	
									;if 'A' or 'a' move LEft
	cmp AL,41h 						;'A'
	je MOVE_PLAYER_LEFT				;
	cmp al,61h 						;'a'
	je MOVE_PLAYER_LEFT				;
	cmp AL,1Bh 						;'ESC' TO RESTART THE GAME
	je END_GAME_ESC_WAYPOINT 
	

	jmp NEXT_MOVMENT				;if non of the bottons above are click, go to end of proc
	NEXT_MOVMENT_stop:				;a fix for jump length beeing to high
		jmp NEXT_MOVMENT
;--------------------------------up	
	MOVE_PLAYER_UP:
		call CLEAR_PLAYER
		mov ax,[PLAYER_VAL_Y]
		sub [PLAYER_Y],ax
		
		mov ax,[WINDOW_BOUNDS]
		cmp [PLAYER_Y],ax
		jl FIX_PLAYER_TOP_POS
		jmp NEXT_MOVMENT
	FIX_PLAYER_TOP_POS:
		mov ax,[WINDOW_BOUNDS]
		mov [PLAYER_Y],ax
		jmp NEXT_MOVMENT
;-------------------------------DOWN		
	MOVE_PLAYER_DOWN:
		call CLEAR_PLAYER
		;call ADD_POINT	;FOR DEBUG DELETE ;debug 
		mov ax,[PLAYER_VAL_Y]
		add [PLAYER_Y],ax
		
		mov ax,[WINDOW_HEIGHT]
		SUB ax,[WINDOW_BOUNDS]
		sub ax,[PLAYER_SIZE]
		cmp [PLAYER_Y],ax
		jG FIX_PLAYER_BOTTOM_POS
		jmp NEXT_MOVMENT
	FIX_PLAYER_BOTTOM_POS:
		mov [PLAYER_Y],ax
		jmp NEXT_MOVMENT
;-----------------------------right		
	MOVE_PLAYER_RIGHT:
		call CLEAR_PLAYER
		mov ax,[PLAYER_VAL_X]
		add [PLAYER_X],ax
		
		mov ax,[WINDOW_WIDTH]
		SUB ax,[WINDOW_BOUNDS]
		sub ax,[PLAYER_SIZE]
		cmp [PLAYER_X],ax
		jG FIX_PLAYER_RIGHT_POS
		jmp NEXT_MOVMENT
	FIX_PLAYER_RIGHT_POS:
		mov [PLAYER_X],ax
		jmp NEXT_MOVMENT
;-------------------------------
jmp NEXT_MOVMENT
END_GAME_ESC_WAYPOINT:			; a way point for the jmp commad (otherwise too long)
	jmp END_GAME_ESC	

;---------------------------left
	MOVE_PLAYER_LEFT:
		call CLEAR_PLAYER
		mov ax,[PLAYER_VAL_X]
		sub [PLAYER_X],ax
		
		mov ax,[WINDOW_BOUNDS]
		cmp [PLAYER_X],ax
		jl FIX_PLAYER_LEFT_POS
		jmp NEXT_MOVMENT
	FIX_PLAYER_LEFT_POS:
		mov ax,[WINDOW_BOUNDS]
		mov [PLAYER_X],ax
		jmp NEXT_MOVMENT
;---------------------------; ;DELETE
	
;-------------------
	jmp NEXT_MOVMENT
	END_GAME_ESC:
	call ENDGAME
	NEXT_MOVMENT:
	
	ret
	
endp MOVE_PLAYER
	
proc ADD_POINT ;adds and updates player points 
	
	inc [PLAYER_POINTS]							;increaces players points
	
	cmp [POINTS_FLAG],1					
	je ASCII_DONE								;may only turn points to asccii ones a game
	add [TEXT_PLAYER_POINTS_ONES],30h			;adding 30h to a char makes it an ascii char
	add [TEXT_PLAYER_POINTS_tens],30h 
	add [TEXT_PLAYER_POINTS_HUNDREDS],30h
	mov [POINTS_FLAG],1							;turn on flag 
	ASCII_DONE:
	
	inc [TEXT_PLAYER_POINTS_ONES]				;increace ones by 1
	mov ah,9
	add ah,30h
	cmp [TEXT_PLAYER_POINTS_ONES],ah			;can only go up to 9
	jg OVER_NINE								;if ones are over nine go to tens
	jmp POINTS_ADDED							;else continue
	
	OVER_NINE:
	mov [TEXT_PLAYER_POINTS_ONES],30h			;rest ones to 0 ascii
	inc [TEXT_PLAYER_POINTS_tens]				;inc tens by 1
	mov ah,9
	add ah,30h
	cmp [TEXT_PLAYER_POINTS_tens],ah			;can only go up to 9
	jg OVER_NINETY								;if tens are over ninety go to hundreds
	jmp POINTS_ADDED							;else continue
	
	OVER_NINETY:
	mov [TEXT_PLAYER_POINTS_tens],30h			;rest tens to 0 ascii
	inc [TEXT_PLAYER_POINTS_HUNDREDS]			;increace hundreds
	
	
	POINTS_ADDED:

	;Sound boop 
	; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
							;send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 
	mov ax, [note] 
	out 42h, al 			;Sending lower byte
	mov al, ah
	out 42h, al 			;Sending upper byte
							;ADD DLEAY FOR POINT
	MOV     CX, 01H
	MOV     DX, 01H
	MOV     AH, 86H
	INT     15H
	;-----
							;close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
    RET



	;add soundfx
	
endp ADD_POINT	
	
proc DRAW_UI
	;draw the points for player
	;----------------ONES
	mov ah,02h							;set cursor pos
	mov bh,00h							;set page num
	mov dh,[SCORE_ROW]					;set row
	mov dl,[SCORE_COLUMN]				;set column
	add dl,2 ;move right
	int 10h
	mov ah, 09h 						;write string to standard output
	
	lea dx,[TEXT_PLAYER_POINTS_ONES] 	;give dx a point to string 
	int 21h								;print the string
	
	;----------------tens
	mov ah,02h							;set cursor pos
	mov bh,00h							;set page num
	mov dh,[SCORE_ROW]					;set row			
	mov dl,[SCORE_COLUMN]				;set column
	add dl,1 ;move right
	int 10h
	mov ah, 09h 						;write string to standard output
	
	lea dx,[TEXT_PLAYER_POINTS_TENS] 	;give dx a point to string 
	int 21h								;print the string
	
	;----------------------hundreds
	mov ah,02h							;set cursor pos
	mov bh,00h							;set page num
	mov dh,[SCORE_ROW]					;set row			
	mov dl,[SCORE_COLUMN]				;set column
	int 10h
	mov ah, 09h 						;write string to standard output
	lea dx,[TEXT_PLAYER_POINTS_HUNDREDS]
	int 21h
	
	ret
endp DRAW_UI	
	
proc START_UI ;draws game over menu
	call SCREEN_CLEAR  					;clear the screen
	cmp [GAME_ACTIVE],1
	jne THIS_IS_A_RES
	;show title
	
	
	mov ah,02h							;set cursor pos 
	mov bh,00h							;set page num
	mov DH,04h							;set row
	mov DL,0Fh							;set column
	int 10h	
	
	mov ah,09h							;write string to output
	lea dx, [TEXT_GAME_START_TITLE]		;give dx a pointer to string
	int 21h								;print the string
	
	;add SCORE COUNTER 
	
	
	
	;add 'press space to continue
	mov ah,02h							;set cursor pos 
	mov bh,00h							;set page num
	mov DH,10h							;set row
	mov DL,0Ah							;set column
	int 10h	
	
	mov ah,09h							;write string to output
	lea dx, [TEXT_GAME_SPACE_TO_START]	;give dx a pointer to string
	int 21h								;print the string
	
	NOT_SPACE_START:
	;draws one time and waits for keypress
	mov ah,00h
	int 16h
	cmp al, 20h							;compers the keypress to ASCII of 'SPACE'(20h)
	jne NOT_SPACE_START					;one space is detected, will go thru restart proc under "THIS_IS_A_RES: "
	

	
	THIS_IS_A_RES:
	mov [TEXT_PLAYER_POINTS_ONES],0
	mov [TEXT_PLAYER_POINTS_tens],0
	mov [TEXT_PLAYER_POINTS_HUNDREDS] , 0
	mov [POINTS_FLAG],0
	mov ah,2ch 			 				;get system time
	int 21h 			 				;CH = hour CL = minute DH = second DL = 1/100 seconds
	mov dh,0
	cmp dx, 90
	jng SKIP_ADD_X						;compering to a small number due to number sometimes glitcching out of bounds
	mov dx,90							;if grater, set to 90
	SKIP_ADD_X:
	add [DVD_X],dx
	mov ah,2ch 			 		;get system time
	int 21h 			 		;CH = hour CL = minute DH = second DL = 1/100 seconds
	mov dh,0
	cmp dx, 70 
	jng SKIP_ADD_Y				;compering to a small number due to number sometimes glitcching out of bounds
	mov dx,70					;if grater, set to 70(Y must be smaller due to the window hight being small)
	SKIP_ADD_Y:
	add [DVD_Y],dx
	
	mov [GAME_ACTIVE],1			;stasrt GAME!
	call SCREEN_CLEAR
	
	mov ah,2ch 	
	int 21h 			 		;CH = hour CL = minute DH = second DL = 1/100 seconds
	mov dh,0
	cmp dx, 70
	jge NEG_VELOCITY_Y_ON_RESTART
	cmp dx,50
	jge	NEG_VELOCITY_x_ON_RESTART
	jmp ending
	
	NEG_VELOCITY_x_ON_RESTART:
		NEG [DVD_VAL_X]  		;revers DVD velocity (X)
		ret 
	NEG_VELOCITY_Y_ON_RESTART:
		NEG [DVD_VAL_Y]			;revers DVD velocity (Y)
		ret

	ending:
	ret	
	
	
endp START_UI	





start:
	mov ax, @data
	mov ds, ax
	
	
	call SCREEN_CLEAR 					;set inatial screen config
	call START_UI
	
	CHECK_TIME:
	
		cmp [GAME_ACTIVE], 00h 			;checks if game is over
		je SHOW_GAME_OVER	 			;if it is, gose to game over menu.
		mov ah,2ch 			 			;get system time
		int 21h 			 			;CH = hour CL = minute DH = second DL = 1/100 seconds
		 
		cmp Dl,[TIME_AUX]	 			;check if current time is equal to previsose one (TIME_AUX)
		JE CHECK_TIME   	 			;if equal check again
										;if diffrent draw ,move,ect...
		
		mov [TIME_AUX],DL 	 			;update current time to TIME_AUX
		
		
		
		
		call MOVE_PLAYER				;moves the player with wasd 
		
		call CLEAR_DVD					;clears the area of the dvd 
		call MOVE_DVD					;moves dvd and checks collisions 
		
		;---------
		;---------	
		call DRAW_PLAYER				;draws player 
		;call DRAW_DVD					;draws a represntation of a bounding box of dvd simble (IN GREEN)
		call DRAW_DVD_DRAWING			;draws dvd BMP
		call DRAW_UI					;draw all game user intraface(score etc)
		
		
		
		jmp CHECK_TIME 					;go back to time check for a loop.
		
		SHOW_GAME_OVER:  
			cmp [soundflag] ,1
			jne no_sound
			call death_sound
			no_sound:
			call DRAW_GAME_OVER_MENU 	; draws menu 
			
			jmp CHECK_TIME   		 	;restarts game
	

	
	
	



exit:
	mov ax, 4c00h
	int 21h
END start