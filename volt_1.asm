list p=pic12f675			
	Include	<p12f675.inc>		
__config _INTRC_OSC_NOCLKOUT &_CP_ON &_BODEN_ON &_MCLRE_OFF &_PWRTE_ON &_WDT_OFF

DELAY_1		EQU		20h
DELAY_2		EQU		21h
DELAY_3		EQU		22h
ALL1		EQU		23h
ALL2		EQU		24h
ALH1		EQU		25h
ALH2		EQU		26h				 				
		
#define	SHIFT	STATUS,RP0
#define	NEG		STATUS,C		
#define	GREEN	GPIO,4
#define	RED		GPIO,5
#define	YELLOW	GPIO,2
#define	BF_1	GPIO,0

	org 0x000					
								
RESET	BSF		SHIFT		
		MOVLW	0X0F
		MOVWF	OPTION_REG
		MOVLW	0X0A
		MOVWF	TRISIO
		BCF		SHIFT
		CLRF	STATUS
		MOVLW	0X07
		MOVWF	CMCON
		CLRF	INTCON
		MOVLW	0XF7
		MOVWF	ALH2	
		MOVLW	0XEE
		MOVWF	ALH1	
		MOVLW	0XE6
		MOVWF	ALL1	
		MOVLW	0XDE
		MOVWF	ALL2	
		MOVLW	0X05
		MOVWF	ADCON0
		BSF		SHIFT
		MOVLW	0X12
		MOVWF	ANSEL
		BCF		SHIFT
		MOVLW	0X10	
		MOVWF	DELAY_1	
		DECFSZ	DELAY_1,1			
		GOTO	$-1
		;
CHECK	MOVLW	0X10	
		MOVWF	DELAY_1	
		DECFSZ	DELAY_1,1			
		GOTO	$-1
		
		BSF		ADCON0,1
		BTFSC	ADCON0,1
		GOTO	$-1
		;
		MOVF	ADRESH,0
		SUBWF	ALL2,0
		BTFSC	NEG
		GOTO	L_2
		;
		MOVF	ADRESH,0
		SUBWF	ALL1,0
		BTFSC	NEG
		GOTO	L_1
		;
		MOVF	ADRESH,0
		SUBWF	ALH1,0
		BTFSC	NEG
		GOTO	NORM
		;
		MOVF	ADRESH,0
		SUBWF	ALH2,0
		BTFSC	NEG
		GOTO	H_1
		;
		GOTO	H_2
		;
L_2		CLRF	GPIO	
		BSF		YELLOW
		BSF		BF_1
		CALL	HALF
		GOTO	CHECK
		;
L_1		CLRF	GPIO	
		BSF		YELLOW
		BSF		BF_1
		CALL	HALF
		BCF		BF_1
		BCF		YELLOW
		CALL	HALF
		GOTO	CHECK	
		;
NORM	CLRF	GPIO	
		BSF		GREEN	
		GOTO	CHECK
		;
H_1		CLRF	GPIO	
		BSF		RED
		BSF		BF_1
		CALL	HALF
		BCF		BF_1
		BCF		RED
		CALL	HALF
		GOTO	CHECK
		;
H_2		CLRF	GPIO	
		BSF		RED
		BSF		BF_1
		CALL	HALF
		GOTO	CHECK
		;
HALF	MOVLW	0X02		
		MOVWF	DELAY_1		
		MOVLW	0X02
		MOVWF	DELAY_2	
		MOVLW	0X03
		MOVWF	DELAY_3		
		DECFSZ	DELAY_3,1	
		GOTO	$+2
		Return
		DECFSZ	DELAY_1,1	
		GOTO	$+2
		GOTO	$-5
		DECFSZ	DELAY_2,1	
		GOTO	$-1
		GOTO	$-5	
		;
	END