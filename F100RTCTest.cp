#line 1 "C:/ARM32 Proj/F100 RTC Test/F100RTCTest.c"





const TempAvgSlope=4.3;
const TempV25=1370;
const VRefIntCal=1200;

const TimeBetweenMeasure=5;

static unsigned long *Unique_ID = (unsigned long*)0x1FFFF7E8;
#line 18 "C:/ARM32 Proj/F100 RTC Test/F100RTCTest.c"
unsigned int TimeCount=65534;
#line 26 "C:/ARM32 Proj/F100 RTC Test/F100RTCTest.c"
unsigned int ADC_Get_Sample_Filtered(char channel)
{

const NoOfSample=255;
int counter;
unsigned int ADCData[NoOfSample];
unsigned int rescounter;
unsigned long mean,resmean ;
long longsigma, minuspredel, pluspredel;
double sigma;
char txt[7];
mean=0;
longsigma=0;
resmean=0;
#line 44 "C:/ARM32 Proj/F100 RTC Test/F100RTCTest.c"
for (counter=0;counter<NoOfSample;counter++){
 ADCData[counter]=ADC1_Get_Sample(channel);
 mean=mean+ADCData[counter];
#line 51 "C:/ARM32 Proj/F100 RTC Test/F100RTCTest.c"
 };
mean=mean/NoOfSample;
for (counter=0;counter<NoOfSample;counter++){
 longsigma=longsigma+(ADCData[counter]-mean)*(ADCData[counter]-mean);
 }

sigma=pow((double)longsigma/(double)NoOfSample,0.5);

minuspredel=(long)(mean-3*sigma);
pluspredel=(long)(mean+3*sigma);

rescounter=0;
for (counter=0;counter<NoOfSample;counter++){

 if((ADCData[counter]>=minuspredel)&(ADCData[counter]<=pluspredel)){resmean=resmean+ADCData[counter];rescounter++;};
 }

if (rescounter==0){resmean=mean;} else {resmean=resmean/rescounter;}
#line 96 "C:/ARM32 Proj/F100 RTC Test/F100RTCTest.c"
return resmean;
}

void RTCWakeUp() iv IVT_INT_RTC_WKUP ics ICS_AUTO {
char txt[7];
unsigned int vref,iii;
int temper;



if (RTC_CRLbits.SECF){
RTC_CRLbits.SECF=0;


TimeCount++;
if(TimeCount>=TimeBetweenMeasure){
TimeCount=0;

GPIO_Digital_Output(&GPIOC_BASE,_GPIO_PINMASK_8);
GPIOC_ODR.B8=1;

ADC_Set_Input_Channel(_ADC_CHANNEL_0 | _ADC_CHANNEL_1);
adc1_init();
ADC1_SMPR1=0xffff;
ADC1_SMPR2=0xffff;
TSVREFE_bit=1;

ADC1_Get_Sample(16);
ADC1_Get_Sample(17);

while(ADC1_SRbits.EOC){delay_us(1);};
ADC1_CR2bits.CAL=1;
while(ADC1_SRbits.EOC){delay_us(1);};

WordToStr(RTC_CNTL,txt);

uart1_write_text("RTC_CNTL ");

uart1_write_text(txt);

WordToStr(RTC_CNTH,txt);
uart1_write_text(" RTC_CNTH ");
uart1_write_text(txt);


WordToStr(ADC_Get_Sample_Filtered(0),txt);
uart1_write_text(" ADC0(PA0) ");
uart1_write_text(txt);


WordToStr(ADC_Get_Sample_Filtered(1),txt);
uart1_write_text(" ADC1(PA1) ");
uart1_write_text(txt);


vref=ADC_Get_Sample_Filtered(17);
WordToStr(vref,txt);
uart1_write_text(" ADC17(VRef) ");
uart1_write_text(txt);
WordToStr(VRefIntCal*4096/vref,txt);
uart1_write_text(" Vdd, mV ");
uart1_write_text(txt);


iii=ADC_Get_Sample_Filtered(16);
WordToStr(iii,txt);
uart1_write_text(" ADC16(Temp) ");
uart1_write_text(txt);


temper=(int)((((long)iii*VRefIntCal))/vref);

IntToStr(temper,txt);
uart1_write_text(" Temp Sensor, mV ");
uart1_write_text(txt);


temper=25+(int)(((float)(TempV25-temper))/TempAvgSlope);
IntToStr(temper,txt);
uart1_write_text(" Temp, C ");
uart1_write_text(txt);




uart1_write(10);
uart1_write(13);

ADC1_CR2bits.ADON=0;
GPIOC_ODR.B8=0;
GPIO_Digital_Input(&GPIOC_BASE,_GPIO_PINMASK_8);




};
};
}

void RTC_INIT (void)
{

RCC_APB1ENRbits.BKPEN=1;
RCC_APB1ENRbits.PWREN=1;

PWR_CRbits.DBP=1;

LSEON_bit=1;

while(!RCC_BDCRbits.LSERDY){delay_ms(10);};

RCC_BDCRbits.RTCSEL=0b01;

RCC_BDCRbits.RTCEN=1;

while(!RTC_CRLbits.RSF){delay_ms(10);};

while(!RTC_CRLbits.RTOFF){delay_ms(10);};

RTC_CRHbits.SECIE=1;

RTC_CRHbits.ALRIE=0;
RTC_CRHbits.OWIE=0;


while(!RTC_CRLbits.RTOFF){delay_ms(10);};


RTC_PRLL=32767;



RTC_CRLbits.CNF=0;

while(!RTC_CRLbits.RTOFF){delay_ms(10);};

RTC_CRLbits.CNF=1;

while(!RTC_CRLbits.RTOFF){delay_ms(10);};

PWR_CRbits.DBP=1;

}

void main() {
char txt[7];
uart1_init(115200);
uart1_write_text("Rdy");
uart1_write(10);
uart1_write(13);
uart1_write_text("SerialNo ");
LongWordToStr(Unique_ID[0],txt);
uart1_write_text(" ");
uart1_write_text(txt);
LongWordToStr(Unique_ID[1],txt);
uart1_write_text(" ");
uart1_write_text(txt);
LongWordToStr(Unique_ID[2],txt);
uart1_write_text(" ");
uart1_write_text(txt);

uart1_write(10);
uart1_write(13);
ADC_Set_Input_Channel(_ADC_CHANNEL_0 | _ADC_CHANNEL_1);
adc1_init();
ADC1_SMPR1=0xffff;
ADC1_SMPR2=0xffff;
ADC1_Get_Sample(16);
ADC1_Get_Sample(17);
while(ADC1_SRbits.EOC){delay_us(1);};
ADC1_CR2bits.CAL=1;
while(ADC1_SRbits.EOC){delay_us(1);};



TSVREFE_bit=1;




STK_CTRLbits.CLKSOURCE=1;

STK_CTRLbits.ENABLE_=1;



RTC_INIT();

NVIC_IntEnable(IVT_INT_RTC_WKUP);

SLEEPDEEP_bit=0;

SLEEPONEXIT_bit=1;
PWR_CRbits.PDDS=0;
PWR_CRbits.LPDS=0;

ADC1_CR2bits.ADON=0;

asm {
 WFI
};

while(1)
{uart1_write_text("No sleep!");
uart1_write(10);
uart1_write(13); };

}
