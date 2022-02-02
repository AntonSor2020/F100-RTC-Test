_ADC_Get_Sample_Filtered:
;F100RTCTest.c,26 :: 		unsigned int ADC_Get_Sample_Filtered(char channel)
; channel start address is: 0 (R0)
SUBW	SP, SP, #540
STR	LR, [SP, #0]
; channel end address is: 0 (R0)
; channel start address is: 0 (R0)
;F100RTCTest.c,37 :: 		mean=0;
MOVS	R1, #0
STR	R1, [SP, #516]
;F100RTCTest.c,38 :: 		longsigma=0;
; longsigma start address is: 24 (R6)
MOVS	R6, #0
;F100RTCTest.c,39 :: 		resmean=0;
MOVS	R1, #0
STR	R1, [SP, #520]
;F100RTCTest.c,44 :: 		for (counter=0;counter<NoOfSample;counter++){//цикл по измерениям
; counter start address is: 36 (R9)
MOVW	R9, #0
SXTH	R9, R9
; channel end address is: 0 (R0)
; longsigma end address is: 24 (R6)
; counter end address is: 36 (R9)
UXTB	R8, R0
SXTH	R5, R9
L_ADC_Get_Sample_Filtered0:
; counter start address is: 20 (R5)
; channel start address is: 32 (R8)
; longsigma start address is: 24 (R6)
; channel start address is: 32 (R8)
; channel end address is: 32 (R8)
CMP	R5, #255
IT	GE
BGE	L_ADC_Get_Sample_Filtered1
; channel end address is: 32 (R8)
;F100RTCTest.c,45 :: 		ADCData[counter]=ADC1_Get_Sample(channel);
; channel start address is: 32 (R8)
ADD	R2, SP, #4
STR	R2, [SP, #536]
LSLS	R1, R5, #1
ADDS	R1, R2, R1
STR	R1, [SP, #532]
UXTB	R0, R8
BL	_ADC1_Get_Sample+0
LDR	R1, [SP, #532]
STRH	R0, [R1, #0]
;F100RTCTest.c,46 :: 		mean=mean+ADCData[counter];//накапливаем среднее
LSLS	R2, R5, #1
LDR	R1, [SP, #536]
ADDS	R1, R1, R2
LDRH	R2, [R1, #0]
LDR	R1, [SP, #516]
ADDS	R1, R1, R2
STR	R1, [SP, #516]
;F100RTCTest.c,44 :: 		for (counter=0;counter<NoOfSample;counter++){//цикл по измерениям
ADDS	R1, R5, #1
; counter end address is: 20 (R5)
; counter start address is: 36 (R9)
SXTH	R9, R1
;F100RTCTest.c,51 :: 		};
; channel end address is: 32 (R8)
; counter end address is: 36 (R9)
SXTH	R5, R9
IT	AL
BAL	L_ADC_Get_Sample_Filtered0
L_ADC_Get_Sample_Filtered1:
;F100RTCTest.c,52 :: 		mean=mean/NoOfSample;//делим на количество, чтобы получить среднеарифметическое
LDR	R2, [SP, #516]
MOVW	R1, #255
UDIV	R1, R2, R1
STR	R1, [SP, #516]
;F100RTCTest.c,53 :: 		for (counter=0;counter<NoOfSample;counter++){//цикл для получения среднеквадратичного отклонения
; counter start address is: 0 (R0)
MOVS	R0, #0
SXTH	R0, R0
; longsigma end address is: 24 (R6)
; counter end address is: 0 (R0)
MOV	R3, R6
L_ADC_Get_Sample_Filtered3:
; counter start address is: 0 (R0)
; longsigma start address is: 12 (R3)
CMP	R0, #255
IT	GE
BGE	L_ADC_Get_Sample_Filtered4
;F100RTCTest.c,54 :: 		longsigma=longsigma+(ADCData[counter]-mean)*(ADCData[counter]-mean);  //накапливаем квадраты
ADD	R2, SP, #4
LSLS	R1, R0, #1
ADDS	R1, R2, R1
LDRH	R2, [R1, #0]
LDR	R1, [SP, #516]
SUB	R1, R2, R1
MULS	R1, R1, R1
ADDS	R1, R3, R1
; longsigma end address is: 12 (R3)
; longsigma start address is: 20 (R5)
MOV	R5, R1
;F100RTCTest.c,53 :: 		for (counter=0;counter<NoOfSample;counter++){//цикл для получения среднеквадратичного отклонения
ADDS	R1, R0, #1
; counter end address is: 0 (R0)
; counter start address is: 4 (R1)
;F100RTCTest.c,55 :: 		}
MOV	R3, R5
; longsigma end address is: 20 (R5)
; counter end address is: 4 (R1)
SXTH	R0, R1
IT	AL
BAL	L_ADC_Get_Sample_Filtered3
L_ADC_Get_Sample_Filtered4:
;F100RTCTest.c,57 :: 		sigma=pow((double)longsigma/(double)NoOfSample,0.5);//делим и берем корень
; longsigma start address is: 12 (R3)
MOV	R0, R3
BL	__SignedIntegralToFloat+0
; longsigma end address is: 12 (R3)
MOVW	R2, #0
MOVT	R2, #17279
BL	__Div_FP+0
MOV	R1, #1056964608
BL	_pow+0
; sigma start address is: 40 (R10)
MOV	R10, R0
;F100RTCTest.c,59 :: 		minuspredel=(long)(mean-3*sigma);
MOVW	R2, #0
MOVT	R2, #16448
BL	__Mul_FP+0
STR	R0, [SP, #532]
LDR	R0, [SP, #516]
BL	__UnsignedIntegralToFloat+0
LDR	R2, [SP, #532]
STR	R0, [SP, #532]
BL	__Sub_FP+0
BL	__FloatToSignedIntegral+0
; minuspredel start address is: 36 (R9)
MOV	R9, R0
;F100RTCTest.c,60 :: 		pluspredel=(long)(mean+3*sigma);
MOVW	R0, #0
MOVT	R0, #16448
MOV	R2, R10
BL	__Mul_FP+0
; sigma end address is: 40 (R10)
LDR	R2, [SP, #532]
BL	__Add_FP+0
BL	__FloatToSignedIntegral+0
; pluspredel start address is: 4 (R1)
MOV	R1, R0
;F100RTCTest.c,62 :: 		rescounter=0;
; rescounter start address is: 24 (R6)
MOVS	R6, #0
;F100RTCTest.c,63 :: 		for (counter=0;counter<NoOfSample;counter++){//цикл для отсечения и накопления среднего
; counter start address is: 20 (R5)
MOVS	R5, #0
SXTH	R5, R5
; minuspredel end address is: 36 (R9)
; pluspredel end address is: 4 (R1)
; rescounter end address is: 24 (R6)
; counter end address is: 20 (R5)
MOV	R4, R9
MOV	R3, R1
SXTH	R0, R5
L_ADC_Get_Sample_Filtered6:
; minuspredel start address is: 16 (R4)
; pluspredel start address is: 12 (R3)
; counter start address is: 0 (R0)
; rescounter start address is: 24 (R6)
; pluspredel start address is: 12 (R3)
; pluspredel end address is: 12 (R3)
; minuspredel start address is: 16 (R4)
; minuspredel end address is: 16 (R4)
CMP	R0, #255
IT	GE
BGE	L_ADC_Get_Sample_Filtered7
; pluspredel end address is: 12 (R3)
; minuspredel end address is: 16 (R4)
;F100RTCTest.c,65 :: 		if((ADCData[counter]>=minuspredel)&(ADCData[counter]<=pluspredel)){resmean=resmean+ADCData[counter];rescounter++;};
; minuspredel start address is: 16 (R4)
; pluspredel start address is: 12 (R3)
ADD	R2, SP, #4
LSLS	R1, R0, #1
ADDS	R1, R2, R1
LDRH	R1, [R1, #0]
CMP	R1, R4
MOVW	R2, #0
BLT	L__ADC_Get_Sample_Filtered58
MOVS	R2, #1
L__ADC_Get_Sample_Filtered58:
CMP	R1, R3
MOVW	R1, #0
BGT	L__ADC_Get_Sample_Filtered59
MOVS	R1, #1
L__ADC_Get_Sample_Filtered59:
AND	R1, R2, R1, LSL #0
CMP	R1, #0
IT	EQ
BEQ	L__ADC_Get_Sample_Filtered56
ADD	R2, SP, #4
LSLS	R1, R0, #1
ADDS	R1, R2, R1
LDRH	R2, [R1, #0]
LDR	R1, [SP, #520]
ADDS	R1, R1, R2
STR	R1, [SP, #520]
ADDS	R2, R6, #1
UXTH	R2, R2
; rescounter end address is: 24 (R6)
; rescounter start address is: 8 (R2)
; rescounter end address is: 8 (R2)
IT	AL
BAL	L_ADC_Get_Sample_Filtered9
L__ADC_Get_Sample_Filtered56:
UXTH	R2, R6
L_ADC_Get_Sample_Filtered9:
;F100RTCTest.c,63 :: 		for (counter=0;counter<NoOfSample;counter++){//цикл для отсечения и накопления среднего
; rescounter start address is: 8 (R2)
ADDS	R1, R0, #1
; counter end address is: 0 (R0)
; counter start address is: 20 (R5)
SXTH	R5, R1
;F100RTCTest.c,66 :: 		}
; pluspredel end address is: 12 (R3)
; minuspredel end address is: 16 (R4)
; rescounter end address is: 8 (R2)
; counter end address is: 20 (R5)
UXTH	R6, R2
SXTH	R0, R5
IT	AL
BAL	L_ADC_Get_Sample_Filtered6
L_ADC_Get_Sample_Filtered7:
;F100RTCTest.c,68 :: 		if (rescounter==0){resmean=mean;} else {resmean=resmean/rescounter;}//делим на количество накопленных
; rescounter start address is: 24 (R6)
CMP	R6, #0
IT	NE
BNE	L_ADC_Get_Sample_Filtered10
; rescounter end address is: 24 (R6)
LDR	R1, [SP, #516]
STR	R1, [SP, #520]
IT	AL
BAL	L_ADC_Get_Sample_Filtered11
L_ADC_Get_Sample_Filtered10:
; rescounter start address is: 24 (R6)
LDR	R1, [SP, #520]
UDIV	R1, R1, R6
; rescounter end address is: 24 (R6)
STR	R1, [SP, #520]
L_ADC_Get_Sample_Filtered11:
;F100RTCTest.c,96 :: 		return resmean;//выводим фильтрованное значение
LDR	R0, [SP, #520]
;F100RTCTest.c,97 :: 		}
L_end_ADC_Get_Sample_Filtered:
LDR	LR, [SP, #0]
ADDW	SP, SP, #540
BX	LR
; end of _ADC_Get_Sample_Filtered
_RTCWakeUp:
;F100RTCTest.c,99 :: 		void RTCWakeUp() iv IVT_INT_RTC_WKUP ics ICS_AUTO {//прерывание от часов - не знаю почему такое название
SUB	SP, SP, #28
STR	LR, [SP, #0]
;F100RTCTest.c,106 :: 		if (RTC_CRLbits.SECF){      //если причина прерывания - секундное
MOVW	R1, #lo_addr(RTC_CRLbits+0)
MOVT	R1, #hi_addr(RTC_CRLbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	EQ
BEQ	L_RTCWakeUp12
;F100RTCTest.c,107 :: 		RTC_CRLbits.SECF=0;  //снимаем бит прерывания
MOVS	R1, #0
SXTB	R1, R1
MOVW	R0, #lo_addr(RTC_CRLbits+0)
MOVT	R0, #hi_addr(RTC_CRLbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,110 :: 		TimeCount++;//увеличиваем счетчик секунд
MOVW	R1, #lo_addr(_TimeCount+0)
MOVT	R1, #hi_addr(_TimeCount+0)
LDRH	R0, [R1, #0]
ADDS	R0, R0, #1
UXTH	R0, R0
STRH	R0, [R1, #0]
;F100RTCTest.c,111 :: 		if(TimeCount>=TimeBetweenMeasure){     //меряем
CMP	R0, #5
IT	CC
BCC	L_RTCWakeUp13
;F100RTCTest.c,112 :: 		TimeCount=0;
MOVS	R1, #0
MOVW	R0, #lo_addr(_TimeCount+0)
MOVT	R0, #hi_addr(_TimeCount+0)
STRH	R1, [R0, #0]
;F100RTCTest.c,114 :: 		GPIO_Digital_Output(&GPIOC_BASE,_GPIO_PINMASK_8);//светодиод на выход
MOVW	R1, #256
MOVW	R0, #lo_addr(GPIOC_BASE+0)
MOVT	R0, #hi_addr(GPIOC_BASE+0)
BL	_GPIO_Digital_Output+0
;F100RTCTest.c,115 :: 		GPIOC_ODR.B8=1;
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(GPIOC_ODR+0)
MOVT	R0, #hi_addr(GPIOC_ODR+0)
STR	R1, [R0, #0]
;F100RTCTest.c,117 :: 		ADC_Set_Input_Channel(_ADC_CHANNEL_0 | _ADC_CHANNEL_1);      //иниц ацп
MOVS	R0, #3
BL	_ADC_Set_Input_Channel+0
;F100RTCTest.c,118 :: 		adc1_init();    //пробуждаем
BL	_ADC1_Init+0
;F100RTCTest.c,119 :: 		ADC1_SMPR1=0xffff;//максимальное время преобразования
MOVW	R1, #65535
MOVW	R0, #lo_addr(ADC1_SMPR1+0)
MOVT	R0, #hi_addr(ADC1_SMPR1+0)
STR	R1, [R0, #0]
;F100RTCTest.c,120 :: 		ADC1_SMPR2=0xffff;
MOVW	R1, #65535
MOVW	R0, #lo_addr(ADC1_SMPR2+0)
MOVT	R0, #hi_addr(ADC1_SMPR2+0)
STR	R1, [R0, #0]
;F100RTCTest.c,121 :: 		TSVREFE_bit=1;//включение измерения температуры и опорного напряжения
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(TSVREFE_bit+0)
MOVT	R0, #hi_addr(TSVREFE_bit+0)
STR	R1, [R0, #0]
;F100RTCTest.c,123 :: 		ADC1_Get_Sample(16);//два преобразования для калибровки
MOVS	R0, #16
BL	_ADC1_Get_Sample+0
;F100RTCTest.c,124 :: 		ADC1_Get_Sample(17);
MOVS	R0, #17
BL	_ADC1_Get_Sample+0
;F100RTCTest.c,126 :: 		while(ADC1_SRbits.EOC){delay_us(1);};//ждем флага окончания преобразования
L_RTCWakeUp14:
MOVW	R1, #lo_addr(ADC1_SRbits+0)
MOVT	R1, #hi_addr(ADC1_SRbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	EQ
BEQ	L_RTCWakeUp15
MOVW	R7, #1
MOVT	R7, #0
NOP
NOP
L_RTCWakeUp16:
SUBS	R7, R7, #1
BNE	L_RTCWakeUp16
NOP
NOP
IT	AL
BAL	L_RTCWakeUp14
L_RTCWakeUp15:
;F100RTCTest.c,127 :: 		ADC1_CR2bits.CAL=1;//калибровка
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(ADC1_CR2bits+0)
MOVT	R0, #hi_addr(ADC1_CR2bits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,128 :: 		while(ADC1_SRbits.EOC){delay_us(1);};//ждем флага окончания преобразования - готово!
L_RTCWakeUp18:
MOVW	R1, #lo_addr(ADC1_SRbits+0)
MOVT	R1, #hi_addr(ADC1_SRbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	EQ
BEQ	L_RTCWakeUp19
MOVW	R7, #1
MOVT	R7, #0
NOP
NOP
L_RTCWakeUp20:
SUBS	R7, R7, #1
BNE	L_RTCWakeUp20
NOP
NOP
IT	AL
BAL	L_RTCWakeUp18
L_RTCWakeUp19:
;F100RTCTest.c,130 :: 		WordToStr(RTC_CNTL,txt);
ADD	R1, SP, #8
MOVW	R0, #lo_addr(RTC_CNTL+0)
MOVT	R0, #hi_addr(RTC_CNTL+0)
LDR	R0, [R0, #0]
BL	_WordToStr+0
;F100RTCTest.c,132 :: 		uart1_write_text("RTC_CNTL ");
MOVW	R0, #lo_addr(?lstr1_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr1_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,134 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,136 :: 		WordToStr(RTC_CNTH,txt);
ADD	R1, SP, #8
MOVW	R0, #lo_addr(RTC_CNTH+0)
MOVT	R0, #hi_addr(RTC_CNTH+0)
LDR	R0, [R0, #0]
BL	_WordToStr+0
;F100RTCTest.c,137 :: 		uart1_write_text(" RTC_CNTH ");
MOVW	R0, #lo_addr(?lstr2_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr2_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,138 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,141 :: 		WordToStr(ADC_Get_Sample_Filtered(0),txt);
ADD	R0, SP, #8
STR	R0, [SP, #24]
MOVS	R0, #0
BL	_ADC_Get_Sample_Filtered+0
LDR	R1, [SP, #24]
BL	_WordToStr+0
;F100RTCTest.c,142 :: 		uart1_write_text(" ADC0(PA0) ");
MOVW	R0, #lo_addr(?lstr3_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr3_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,143 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,146 :: 		WordToStr(ADC_Get_Sample_Filtered(1),txt);
ADD	R0, SP, #8
STR	R0, [SP, #24]
MOVS	R0, #1
BL	_ADC_Get_Sample_Filtered+0
LDR	R1, [SP, #24]
BL	_WordToStr+0
;F100RTCTest.c,147 :: 		uart1_write_text(" ADC1(PA1) ");
MOVW	R0, #lo_addr(?lstr4_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr4_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,148 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,151 :: 		vref=ADC_Get_Sample_Filtered(17);
MOVS	R0, #17
BL	_ADC_Get_Sample_Filtered+0
STRH	R0, [SP, #16]
;F100RTCTest.c,152 :: 		WordToStr(vref,txt);
ADD	R1, SP, #8
BL	_WordToStr+0
;F100RTCTest.c,153 :: 		uart1_write_text(" ADC17(VRef) ");
MOVW	R0, #lo_addr(?lstr5_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr5_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,154 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,155 :: 		WordToStr(VRefIntCal*4096/vref,txt);
ADD	R2, SP, #8
LDRH	R1, [SP, #16]
MOV	R0, #4915200
SDIV	R0, R0, R1
MOV	R1, R2
UXTH	R0, R0
BL	_WordToStr+0
;F100RTCTest.c,156 :: 		uart1_write_text(" Vdd, mV ");
MOVW	R0, #lo_addr(?lstr6_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr6_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,157 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,160 :: 		iii=ADC_Get_Sample_Filtered(16);
MOVS	R0, #16
BL	_ADC_Get_Sample_Filtered+0
; iii start address is: 28 (R7)
UXTH	R7, R0
;F100RTCTest.c,161 :: 		WordToStr(iii,txt);
ADD	R1, SP, #8
BL	_WordToStr+0
;F100RTCTest.c,162 :: 		uart1_write_text(" ADC16(Temp) ");
MOVW	R0, #lo_addr(?lstr7_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr7_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,163 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,166 :: 		temper=(int)((((long)iii*VRefIntCal))/vref);//чтобы не было переполнения
UXTH	R1, R7
; iii end address is: 28 (R7)
MOVW	R0, #1200
MULS	R1, R0, R1
LDRH	R0, [SP, #16]
SDIV	R1, R1, R0
; temper start address is: 32 (R8)
SXTH	R8, R1
;F100RTCTest.c,168 :: 		IntToStr(temper,txt);
ADD	R0, SP, #8
STR	R1, [SP, #4]
MOV	R1, R0
LDRSH	R0, [SP, #4]
BL	_IntToStr+0
;F100RTCTest.c,169 :: 		uart1_write_text(" Temp Sensor, mV ");
MOVW	R0, #lo_addr(?lstr8_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr8_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,170 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,173 :: 		temper=25+(int)(((float)(TempV25-temper))/TempAvgSlope);
MOVW	R0, #1370
SXTH	R0, R0
SUB	R0, R0, R8, LSL #0
SXTH	R0, R0
; temper end address is: 32 (R8)
BL	__SignedIntegralToFloat+0
MOV	R2, #1082130432
BL	__Div_FP+0
BL	__FloatToSignedIntegral+0
SXTH	R0, R0
ADDW	R1, R0, #25
;F100RTCTest.c,174 :: 		IntToStr(temper,txt);
ADD	R0, SP, #8
STRH	R1, [SP, #4]
MOV	R1, R0
LDRSH	R0, [SP, #4]
BL	_IntToStr+0
;F100RTCTest.c,175 :: 		uart1_write_text(" Temp, C ");
MOVW	R0, #lo_addr(?lstr9_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr9_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,176 :: 		uart1_write_text(txt);
ADD	R0, SP, #8
BL	_UART1_Write_Text+0
;F100RTCTest.c,181 :: 		uart1_write(10);
MOVS	R0, #10
BL	_UART1_Write+0
;F100RTCTest.c,182 :: 		uart1_write(13);
MOVS	R0, #13
BL	_UART1_Write+0
;F100RTCTest.c,184 :: 		ADC1_CR2bits.ADON=0;//засыпаем АЦП
MOVS	R1, #0
SXTB	R1, R1
MOVW	R0, #lo_addr(ADC1_CR2bits+0)
MOVT	R0, #hi_addr(ADC1_CR2bits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,185 :: 		GPIOC_ODR.B8=0;
MOVW	R0, #lo_addr(GPIOC_ODR+0)
MOVT	R0, #hi_addr(GPIOC_ODR+0)
STR	R1, [R0, #0]
;F100RTCTest.c,186 :: 		GPIO_Digital_Input(&GPIOC_BASE,_GPIO_PINMASK_8);//светодиод на вход
MOVW	R1, #256
MOVW	R0, #lo_addr(GPIOC_BASE+0)
MOVT	R0, #hi_addr(GPIOC_BASE+0)
BL	_GPIO_Digital_Input+0
;F100RTCTest.c,191 :: 		};
L_RTCWakeUp13:
;F100RTCTest.c,192 :: 		};
L_RTCWakeUp12:
;F100RTCTest.c,193 :: 		}
L_end_RTCWakeUp:
LDR	LR, [SP, #0]
ADD	SP, SP, #28
BX	LR
; end of _RTCWakeUp
_RTC_INIT:
;F100RTCTest.c,195 :: 		void  RTC_INIT  (void)                                                                            //Инициализация RTC
;F100RTCTest.c,198 :: 		RCC_APB1ENRbits.BKPEN=1;
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(RCC_APB1ENRbits+0)
MOVT	R0, #hi_addr(RCC_APB1ENRbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,199 :: 		RCC_APB1ENRbits.PWREN=1;
MOVW	R0, #lo_addr(RCC_APB1ENRbits+0)
MOVT	R0, #hi_addr(RCC_APB1ENRbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,201 :: 		PWR_CRbits.DBP=1;
MOVW	R0, #lo_addr(PWR_CRbits+0)
MOVT	R0, #hi_addr(PWR_CRbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,203 :: 		LSEON_bit=1;
MOVW	R0, #lo_addr(LSEON_bit+0)
MOVT	R0, #hi_addr(LSEON_bit+0)
STR	R1, [R0, #0]
;F100RTCTest.c,205 :: 		while(!RCC_BDCRbits.LSERDY){delay_ms(10);};//пустой цикл
L_RTC_INIT22:
MOVW	R1, #lo_addr(RCC_BDCRbits+0)
MOVT	R1, #hi_addr(RCC_BDCRbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	NE
BNE	L_RTC_INIT23
MOVW	R7, #26665
MOVT	R7, #0
NOP
NOP
L_RTC_INIT24:
SUBS	R7, R7, #1
BNE	L_RTC_INIT24
NOP
NOP
IT	AL
BAL	L_RTC_INIT22
L_RTC_INIT23:
;F100RTCTest.c,207 :: 		RCC_BDCRbits.RTCSEL=0b01;
MOVS	R2, #1
MOVW	R1, #lo_addr(RCC_BDCRbits+0)
MOVT	R1, #hi_addr(RCC_BDCRbits+0)
LDRH	R0, [R1, #0]
BFI	R0, R2, #8, #2
STRH	R0, [R1, #0]
;F100RTCTest.c,209 :: 		RCC_BDCRbits.RTCEN=1;
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(RCC_BDCRbits+0)
MOVT	R0, #hi_addr(RCC_BDCRbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,211 :: 		while(!RTC_CRLbits.RSF){delay_ms(10);};//пустой цикл
L_RTC_INIT26:
MOVW	R1, #lo_addr(RTC_CRLbits+0)
MOVT	R1, #hi_addr(RTC_CRLbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	NE
BNE	L_RTC_INIT27
MOVW	R7, #26665
MOVT	R7, #0
NOP
NOP
L_RTC_INIT28:
SUBS	R7, R7, #1
BNE	L_RTC_INIT28
NOP
NOP
IT	AL
BAL	L_RTC_INIT26
L_RTC_INIT27:
;F100RTCTest.c,213 :: 		while(!RTC_CRLbits.RTOFF){delay_ms(10);};//пустой цикл
L_RTC_INIT30:
MOVW	R1, #lo_addr(RTC_CRLbits+0)
MOVT	R1, #hi_addr(RTC_CRLbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	NE
BNE	L_RTC_INIT31
MOVW	R7, #26665
MOVT	R7, #0
NOP
NOP
L_RTC_INIT32:
SUBS	R7, R7, #1
BNE	L_RTC_INIT32
NOP
NOP
IT	AL
BAL	L_RTC_INIT30
L_RTC_INIT31:
;F100RTCTest.c,215 :: 		RTC_CRHbits.SECIE=1;
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(RTC_CRHbits+0)
MOVT	R0, #hi_addr(RTC_CRHbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,217 :: 		RTC_CRHbits.ALRIE=0;
MOVS	R1, #0
SXTB	R1, R1
MOVW	R0, #lo_addr(RTC_CRHbits+0)
MOVT	R0, #hi_addr(RTC_CRHbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,218 :: 		RTC_CRHbits.OWIE=0;
MOVW	R0, #lo_addr(RTC_CRHbits+0)
MOVT	R0, #hi_addr(RTC_CRHbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,221 :: 		while(!RTC_CRLbits.RTOFF){delay_ms(10);};//пустой цикл
L_RTC_INIT34:
MOVW	R1, #lo_addr(RTC_CRLbits+0)
MOVT	R1, #hi_addr(RTC_CRLbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	NE
BNE	L_RTC_INIT35
MOVW	R7, #26665
MOVT	R7, #0
NOP
NOP
L_RTC_INIT36:
SUBS	R7, R7, #1
BNE	L_RTC_INIT36
NOP
NOP
IT	AL
BAL	L_RTC_INIT34
L_RTC_INIT35:
;F100RTCTest.c,224 :: 		RTC_PRLL=32767;
MOVW	R1, #32767
MOVW	R0, #lo_addr(RTC_PRLL+0)
MOVT	R0, #hi_addr(RTC_PRLL+0)
STR	R1, [R0, #0]
;F100RTCTest.c,228 :: 		RTC_CRLbits.CNF=0;
MOVS	R1, #0
SXTB	R1, R1
MOVW	R0, #lo_addr(RTC_CRLbits+0)
MOVT	R0, #hi_addr(RTC_CRLbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,230 :: 		while(!RTC_CRLbits.RTOFF){delay_ms(10);};//пустой цикл
L_RTC_INIT38:
MOVW	R1, #lo_addr(RTC_CRLbits+0)
MOVT	R1, #hi_addr(RTC_CRLbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	NE
BNE	L_RTC_INIT39
MOVW	R7, #26665
MOVT	R7, #0
NOP
NOP
L_RTC_INIT40:
SUBS	R7, R7, #1
BNE	L_RTC_INIT40
NOP
NOP
IT	AL
BAL	L_RTC_INIT38
L_RTC_INIT39:
;F100RTCTest.c,232 :: 		RTC_CRLbits.CNF=1;
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(RTC_CRLbits+0)
MOVT	R0, #hi_addr(RTC_CRLbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,234 :: 		while(!RTC_CRLbits.RTOFF){delay_ms(10);};//пустой цикл
L_RTC_INIT42:
MOVW	R1, #lo_addr(RTC_CRLbits+0)
MOVT	R1, #hi_addr(RTC_CRLbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	NE
BNE	L_RTC_INIT43
MOVW	R7, #26665
MOVT	R7, #0
NOP
NOP
L_RTC_INIT44:
SUBS	R7, R7, #1
BNE	L_RTC_INIT44
NOP
NOP
IT	AL
BAL	L_RTC_INIT42
L_RTC_INIT43:
;F100RTCTest.c,236 :: 		PWR_CRbits.DBP=1;
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(PWR_CRbits+0)
MOVT	R0, #hi_addr(PWR_CRbits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,238 :: 		}
L_end_RTC_INIT:
BX	LR
; end of _RTC_INIT
_main:
;F100RTCTest.c,240 :: 		void main() {
SUB	SP, SP, #8
;F100RTCTest.c,242 :: 		uart1_init(115200);
MOV	R0, #115200
BL	_UART1_Init+0
;F100RTCTest.c,243 :: 		uart1_write_text("Rdy");
MOVW	R0, #lo_addr(?lstr10_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr10_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,244 :: 		uart1_write(10);
MOVS	R0, #10
BL	_UART1_Write+0
;F100RTCTest.c,245 :: 		uart1_write(13);
MOVS	R0, #13
BL	_UART1_Write+0
;F100RTCTest.c,246 :: 		uart1_write_text("SerialNo ");
MOVW	R0, #lo_addr(?lstr11_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr11_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,247 :: 		LongWordToStr(Unique_ID[0],txt);
ADD	R1, SP, #0
MOVW	R0, #lo_addr(F100RTCTest_Unique_ID+0)
MOVT	R0, #hi_addr(F100RTCTest_Unique_ID+0)
LDR	R0, [R0, #0]
LDR	R0, [R0, #0]
BL	_LongWordToStr+0
;F100RTCTest.c,248 :: 		uart1_write_text(" ");
MOVW	R0, #lo_addr(?lstr12_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr12_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,249 :: 		uart1_write_text(txt);
ADD	R0, SP, #0
BL	_UART1_Write_Text+0
;F100RTCTest.c,250 :: 		LongWordToStr(Unique_ID[1],txt);
ADD	R1, SP, #0
MOVW	R0, #lo_addr(F100RTCTest_Unique_ID+0)
MOVT	R0, #hi_addr(F100RTCTest_Unique_ID+0)
LDR	R0, [R0, #0]
ADDS	R0, R0, #4
LDR	R0, [R0, #0]
BL	_LongWordToStr+0
;F100RTCTest.c,251 :: 		uart1_write_text(" ");
MOVW	R0, #lo_addr(?lstr13_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr13_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,252 :: 		uart1_write_text(txt);
ADD	R0, SP, #0
BL	_UART1_Write_Text+0
;F100RTCTest.c,253 :: 		LongWordToStr(Unique_ID[2],txt);
ADD	R1, SP, #0
MOVW	R0, #lo_addr(F100RTCTest_Unique_ID+0)
MOVT	R0, #hi_addr(F100RTCTest_Unique_ID+0)
LDR	R0, [R0, #0]
ADDS	R0, #8
LDR	R0, [R0, #0]
BL	_LongWordToStr+0
;F100RTCTest.c,254 :: 		uart1_write_text(" ");
MOVW	R0, #lo_addr(?lstr14_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr14_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,255 :: 		uart1_write_text(txt);
ADD	R0, SP, #0
BL	_UART1_Write_Text+0
;F100RTCTest.c,257 :: 		uart1_write(10);
MOVS	R0, #10
BL	_UART1_Write+0
;F100RTCTest.c,258 :: 		uart1_write(13);
MOVS	R0, #13
BL	_UART1_Write+0
;F100RTCTest.c,259 :: 		ADC_Set_Input_Channel(_ADC_CHANNEL_0 | _ADC_CHANNEL_1);      //иниц ацп
MOVS	R0, #3
BL	_ADC_Set_Input_Channel+0
;F100RTCTest.c,260 :: 		adc1_init();
BL	_ADC1_Init+0
;F100RTCTest.c,261 :: 		ADC1_SMPR1=0xffff;//максимальное время преобразования
MOVW	R1, #65535
MOVW	R0, #lo_addr(ADC1_SMPR1+0)
MOVT	R0, #hi_addr(ADC1_SMPR1+0)
STR	R1, [R0, #0]
;F100RTCTest.c,262 :: 		ADC1_SMPR2=0xffff;
MOVW	R1, #65535
MOVW	R0, #lo_addr(ADC1_SMPR2+0)
MOVT	R0, #hi_addr(ADC1_SMPR2+0)
STR	R1, [R0, #0]
;F100RTCTest.c,263 :: 		ADC1_Get_Sample(16);//два преобразования для калибровки
MOVS	R0, #16
BL	_ADC1_Get_Sample+0
;F100RTCTest.c,264 :: 		ADC1_Get_Sample(17);
MOVS	R0, #17
BL	_ADC1_Get_Sample+0
;F100RTCTest.c,265 :: 		while(ADC1_SRbits.EOC){delay_us(1);};//ждем флага окончания преобразования
L_main46:
MOVW	R1, #lo_addr(ADC1_SRbits+0)
MOVT	R1, #hi_addr(ADC1_SRbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	EQ
BEQ	L_main47
MOVW	R7, #1
MOVT	R7, #0
NOP
NOP
L_main48:
SUBS	R7, R7, #1
BNE	L_main48
NOP
NOP
IT	AL
BAL	L_main46
L_main47:
;F100RTCTest.c,266 :: 		ADC1_CR2bits.CAL=1;//калибровка
MOVS	R1, #1
SXTB	R1, R1
MOVW	R0, #lo_addr(ADC1_CR2bits+0)
MOVT	R0, #hi_addr(ADC1_CR2bits+0)
STR	R1, [R0, #0]
;F100RTCTest.c,267 :: 		while(ADC1_SRbits.EOC){delay_us(1);};//ждем флага окончания преобразования - готово!
L_main50:
MOVW	R1, #lo_addr(ADC1_SRbits+0)
MOVT	R1, #hi_addr(ADC1_SRbits+0)
LDR	R0, [R1, #0]
CMP	R0, #0
IT	EQ
BEQ	L_main51
MOVW	R7, #1
MOVT	R7, #0
NOP
NOP
L_main52:
SUBS	R7, R7, #1
BNE	L_main52
NOP
NOP
IT	AL
BAL	L_main50
L_main51:
;F100RTCTest.c,271 :: 		TSVREFE_bit=1;//включение измерения температуры и опорного напряжения
MOVS	R2, #1
SXTB	R2, R2
MOVW	R0, #lo_addr(TSVREFE_bit+0)
MOVT	R0, #hi_addr(TSVREFE_bit+0)
STR	R2, [R0, #0]
;F100RTCTest.c,276 :: 		STK_CTRLbits.CLKSOURCE=1;
MOVW	R1, #lo_addr(STK_CTRLbits+0)
MOVT	R1, #hi_addr(STK_CTRLbits+0)
LDR	R0, [R1, #0]
BFI	R0, R2, #2, #1
STR	R0, [R1, #0]
;F100RTCTest.c,278 :: 		STK_CTRLbits.ENABLE_=1;
MOVW	R1, #lo_addr(STK_CTRLbits+0)
MOVT	R1, #hi_addr(STK_CTRLbits+0)
LDR	R0, [R1, #0]
BFI	R0, R2, #0, #1
STR	R0, [R1, #0]
;F100RTCTest.c,282 :: 		RTC_INIT();
BL	_RTC_INIT+0
;F100RTCTest.c,284 :: 		NVIC_IntEnable(IVT_INT_RTC_WKUP);//прерывание для часов
MOVW	R0, #19
BL	_NVIC_IntEnable+0
;F100RTCTest.c,286 :: 		SLEEPDEEP_bit=0;//устанавливаем бит засыпания в sleep
MOVS	R3, #0
SXTB	R3, R3
MOVW	R1, #lo_addr(SLEEPDEEP_bit+0)
MOVT	R1, #hi_addr(SLEEPDEEP_bit+0)
LDR	R0, [R1, #0]
BFI	R0, R3, BitPos(SLEEPDEEP_bit+0), #1
STR	R0, [R1, #0]
;F100RTCTest.c,288 :: 		SLEEPONEXIT_bit=1;//засыпаем после выхода из прерывания
MOVS	R2, #1
SXTB	R2, R2
MOVW	R1, #lo_addr(SLEEPONEXIT_bit+0)
MOVT	R1, #hi_addr(SLEEPONEXIT_bit+0)
LDR	R0, [R1, #0]
BFI	R0, R2, BitPos(SLEEPONEXIT_bit+0), #1
STR	R0, [R1, #0]
;F100RTCTest.c,289 :: 		PWR_CRbits.PDDS=0;//сбрасываем
MOVW	R0, #lo_addr(PWR_CRbits+0)
MOVT	R0, #hi_addr(PWR_CRbits+0)
STR	R3, [R0, #0]
;F100RTCTest.c,290 :: 		PWR_CRbits.LPDS=0;//стабилизатор
MOVW	R0, #lo_addr(PWR_CRbits+0)
MOVT	R0, #hi_addr(PWR_CRbits+0)
STR	R3, [R0, #0]
;F100RTCTest.c,292 :: 		ADC1_CR2bits.ADON=0;//засыпаем АЦП
MOVW	R0, #lo_addr(ADC1_CR2bits+0)
MOVT	R0, #hi_addr(ADC1_CR2bits+0)
STR	R3, [R0, #0]
;F100RTCTest.c,295 :: 		WFI
WFI
;F100RTCTest.c,298 :: 		while(1)
L_main54:
;F100RTCTest.c,299 :: 		{uart1_write_text("No sleep!");   //сигнал о том, что контроллер не спит
MOVW	R0, #lo_addr(?lstr15_F100RTCTest+0)
MOVT	R0, #hi_addr(?lstr15_F100RTCTest+0)
BL	_UART1_Write_Text+0
;F100RTCTest.c,300 :: 		uart1_write(10);
MOVS	R0, #10
BL	_UART1_Write+0
;F100RTCTest.c,301 :: 		uart1_write(13); };
MOVS	R0, #13
BL	_UART1_Write+0
IT	AL
BAL	L_main54
;F100RTCTest.c,303 :: 		}
L_end_main:
L__main_end_loop:
B	L__main_end_loop
; end of _main
