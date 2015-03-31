 ;**************************************************************************;
 ;              УСТРОЙСТВО КОНТРОЛЯ УРОВНЯ НАПРЯЖЕНИЯ БОРТСЕТИ v 1.1        ;
 ;              Автор: Царегородцев Олег (г. Екатеринбург)                  ;
 ;**************************************************************************;

	List p=pic12f675
			
	Include	<p12f675.inc>	
	
__config _INTRC_OSC_NOCLKOUT &_CP_OFF &_BODEN_ON &_MCLRE_OFF &_PWRTE_ON &_WDT_OFF

ALL1	EQU		20h
ALL2	EQU		21h
ALH1	EQU		22h
ALH2	EQU		23h				 				
FLAGS	EQU		24h	
			 				
; -------------------- Биты регистра "FLAGS" ----------------------
;	 -7-     -6-     -5-     -4-     -3-     -2-     -1-     -0-
; |-------|-------|-------|-------|-------|-------|-------|-------|
; | ----- | ----- | SOUND |  H 2  |  H 1  |   N   |  L 1  |  L 2  |
; |-------|-------|-------|-------|-------|-------|-------|-------|
;    MSB                                                     LSB

L2		EQU		0  ; Если "1" - 
L1		EQU		1  ; Если "1" - 
N		EQU		2  ; Если "1" - 
H1		EQU		3  ; Если "1" - 
H2		EQU		4  ; Если "1" -  
SOUND   EQU		5  ; Если "1" - РАЗРЕШЕНА ЗВУКОВАЯ СИГНАЛИЗАЦИЯ

;MASK	macro
;		MOVLW	0X1F
;		IORWF	FLAGS,1		
;		SUBWF	FLAGS,1
;		ENDM

#define		SHIFT	STATUS,RP0		
#define		TMRON	T1CON,TMR1ON
#define		OVER	PIR1,TMR1IF
#define		GREEN	GPIO,4
#define		RED		GPIO,5
#define		YELLOW	GPIO,2
#define		BF_1	GPIO,0

	org 0x000													

RESET	BSF		SHIFT			; BANK 1
		MOVLW	0X0F
		MOVWF	OPTION_REG
		CLRF	STATUS
		MOVLW	0X0A
		MOVWF	TRISIO
		CLRF	INTCON
		MOVLW	0X12
		MOVWF	ANSEL
		CLRF	ADRESL

		BCF		SHIFT			; BANK 0
		CLRF	GPIO
		MOVLW	0X30
		MOVWF	T1CON
		MOVLW	0X07
		MOVWF	CMCON
		MOVLW	0X05
		MOVWF	ADCON0
		CLRF	ADRESH

		MOVLW	0XF7
		MOVWF	ALH2	
		MOVLW	0XEE
		MOVWF	ALH1	
		MOVLW	0XE6
		MOVWF	ALL1
		MOVLW	0XDE
		MOVWF	ALL2

		MOVLW	0X35			; TEST LED - 1/4 S
		MOVWF	GPIO
		CALL	QUATER
		CLRF	GPIO

CHECK	BCF		SHIFT			; BANK 0
		BSF		ADCON0,1
		BTFSC	ADCON0,1
		GOTO	$-1
		;
		MOVF	ADRESH,0		;
		SUBWF	ALL2,0
		BTFSC	STATUS,C
		GOTO	L_2				;
		;
		MOVF	ADRESH,0		;
		SUBWF	ALL1,0
		BTFSC	STATUS,C
		GOTO	L_1				;
		;
		MOVF	ADRESH,0		;
		SUBWF	ALH1,0
		BTFSC	STATUS,C
		GOTO	NORM			;
		;
		MOVF	ADRESH,0		;
		SUBWF	ALH2,0
		BTFSC	STATUS,C
		GOTO	H_1				;
		;
		GOTO	H_2				;
		;
L_2		BCF		SHIFT			; BANK 0
		BTFSC	FLAGS,L2		;
		GOTO	CHECK			;
		MOVLW	0X1F
		IORWF	FLAGS,1		
		SUBWF	FLAGS,1			;	MASK					;
		BSF		FLAGS,L2		;
		CLRF	GPIO			;
		BSF		YELLOW			;
		BTFSS	FLAGS,SOUND		;
		BCF		BF_1			;
		BSF		BF_1			;
		GOTO	CHECK			
		;
L_1		BCF		SHIFT			; BANK 0
		CLRF	GPIO	
		BSF		YELLOW
		BSF		BF_1
		CALL	QUATER
		BCF		BF_1
		BCF		YELLOW
		CALL	QUATER
		GOTO	CHECK	
		;
NORM	BCF		SHIFT			; BANK 0
		BTFSC	FLAGS,N			;
		GOTO	CHECK			;
		MOVLW	0X1F
		IORWF	FLAGS,1		
		SUBWF	FLAGS,1			;MASK					;
		BSF		FLAGS,N			;
		CLRF	GPIO			;
		BSF		GREEN			;
		CALL	QUATER			;
		GOTO	CHECK			
		;
H_1		BCF		SHIFT			; BANK 0
		CLRF	GPIO	
		BSF		RED
		BSF		BF_1
		CALL	QUATER
		BCF		BF_1
		BCF		RED
		CALL	QUATER
		GOTO	CHECK
		;
H_2		BCF		SHIFT			; BANK 0
		BTFSC	FLAGS,H2		;
		GOTO	CHECK			;
		MOVLW	0X1F
		IORWF	FLAGS,1		
		SUBWF	FLAGS,1			;MASK					
		BSF		FLAGS,H2		;
		CLRF	GPIO			;
		BSF		RED				;
		BTFSS	FLAGS,SOUND		;
		BCF		BF_1			;
		BSF		BF_1			;
		GOTO	CHECK			
		;
QUATER	BCF		SHIFT			; BANK 0
		BCF		TMRON			;
		CLRF	TMR1L			;
		CLRF	TMR1H			;
		MOVLW	0X80			;
		MOVWF	TMR1H			;
		BSF		TMRON			;
		BTFSS	OVER			;
		GOTO	$-1				;
		BCF		OVER			;
		BCF		TMRON			;
		Return
	END
