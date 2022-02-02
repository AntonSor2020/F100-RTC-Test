//уже здесь - моргаем светодиодом раз в секунду по приходу прерывания от часов
#define VREFINT_CAL_ADDR 0x1ffff7ba
#define TS_CAL1_ADDR 0x1ffff7b8
#define TS_CAL2_ADDR 0x1ffff7c2

const TempAvgSlope=4.3;//из даташита калибровка температурного датчика 4,3 мВ/градус  = в градусах на милливольт
const TempV25=1370;//из даташита калибровка температурного датчика 1430 мВ при 25 градусах
const VRefIntCal=1200;//из даташита напряжение внутреннего ИОН 1200 мВ

const TimeBetweenMeasure=5;//время между измерениями в секундах

static unsigned long *Unique_ID = (unsigned long*)0x1FFFF7E8;          //уникальный ИД - исп в качестве серийного номера
/*unsigned long Unique_ID_0, Unique_ID_1, Unique_ID_2;
Unique_ID_0=Unique_ID[0];
Unique_ID_1=Unique_ID[1];
Unique_ID_2=Unique_ID[2];      */

unsigned int TimeCount=65534;//счетчик секунд - чтобы сработал при первом включении

/*
unsigned int VREFINT_CAL;//калибровка опорного напряжения
unsigned int TS_CAL1;//калибровка температурного датчика на 30 градусов
unsigned int TS_CAL2;//калибровка температурного датчика на 110 градусов
*/

unsigned int ADC_Get_Sample_Filtered(char channel)
{
//преобразование 32 раза с отсечением значений, выходящих за три сигмы
const NoOfSample=255;
int counter;
unsigned int ADCData[NoOfSample];//массив данных,
unsigned int rescounter; //  счетчик накопленных значений
unsigned long mean,resmean ;//среднее , конечный результат,
long longsigma, minuspredel, pluspredel;//пределы целые - для ускорения сравнения
double sigma;
char txt[7];
mean=0;
longsigma=0;
resmean=0;

/*uart1_write(10);
uart1_write(13); */

for (counter=0;counter<NoOfSample;counter++){//цикл по измерениям
    ADCData[counter]=ADC1_Get_Sample(channel);
    mean=mean+ADCData[counter];//накапливаем среднее
   /*
    WordToStr(ADCData[counter],txt);
    uart1_write_text(txt);
    */
    };
mean=mean/NoOfSample;//делим на количество, чтобы получить среднеарифметическое
for (counter=0;counter<NoOfSample;counter++){//цикл для получения среднеквадратичного отклонения
    longsigma=longsigma+(ADCData[counter]-mean)*(ADCData[counter]-mean);  //накапливаем квадраты
    }

sigma=pow((double)longsigma/(double)NoOfSample,0.5);//делим и берем корень
//теперь отделяем все выходящее за три сигмы
minuspredel=(long)(mean-3*sigma);
pluspredel=(long)(mean+3*sigma);
//счетчик попавших в результат
rescounter=0;
for (counter=0;counter<NoOfSample;counter++){//цикл для отсечения и накопления среднего
    //если в пределах - накапливаем к среднему
    if((ADCData[counter]>=minuspredel)&(ADCData[counter]<=pluspredel)){resmean=resmean+ADCData[counter];rescounter++;};
    }
//если ничего не попало - заносим среднее
if (rescounter==0){resmean=mean;} else {resmean=resmean/rescounter;}//делим на количество накопленных

/*
uart1_write(10);
uart1_write(13);
WordToStr(mean,txt);
uart1_write_text("mean ");
uart1_write_text(txt);

longToStr(minuspredel,txt);
uart1_write_text(" minuspredel ");
uart1_write_text(txt);

longToStr(pluspredel,txt);
uart1_write_text(" pluspredel ");
uart1_write_text(txt);

WordToStr(rescounter,txt);
uart1_write_text(" rescounter ");
uart1_write_text(txt);

WordToStr(resmean,txt);
uart1_write_text(" resmean ");
uart1_write_text(txt);
uart1_write(10);
uart1_write(13);
*/

return resmean;//выводим фильтрованное значение
}

void RTCWakeUp() iv IVT_INT_RTC_WKUP ics ICS_AUTO {//прерывание от часов - не знаю почему такое название
char txt[7];
unsigned int vref,iii;
int temper;



if (RTC_CRLbits.SECF){      //если причина прерывания - секундное
RTC_CRLbits.SECF=0;  //снимаем бит прерывания


TimeCount++;//увеличиваем счетчик секунд
if(TimeCount>=TimeBetweenMeasure){     //меряем
TimeCount=0;

GPIO_Digital_Output(&GPIOC_BASE,_GPIO_PINMASK_8);//светодиод на выход
GPIOC_ODR.B8=1;
//скидываем значение счетчика в терминал
ADC_Set_Input_Channel(_ADC_CHANNEL_0 | _ADC_CHANNEL_1);      //иниц ацп
adc1_init();    //пробуждаем
ADC1_SMPR1=0xffff;//максимальное время преобразования
ADC1_SMPR2=0xffff;
TSVREFE_bit=1;//включение измерения температуры и опорного напряжения

ADC1_Get_Sample(16);//два преобразования для калибровки
ADC1_Get_Sample(17);

while(ADC1_SRbits.EOC){delay_us(1);};//ждем флага окончания преобразования
ADC1_CR2bits.CAL=1;//калибровка
while(ADC1_SRbits.EOC){delay_us(1);};//ждем флага окончания преобразования - готово!

WordToStr(RTC_CNTL,txt);

uart1_write_text("RTC_CNTL ");

uart1_write_text(txt);

WordToStr(RTC_CNTH,txt);
uart1_write_text(" RTC_CNTH ");
uart1_write_text(txt);

//и результат с ацп тоже пишем
WordToStr(ADC_Get_Sample_Filtered(0),txt);
uart1_write_text(" ADC0(PA0) ");
uart1_write_text(txt);

//и результат с ацп тоже пишем
WordToStr(ADC_Get_Sample_Filtered(1),txt);
uart1_write_text(" ADC1(PA1) ");
uart1_write_text(txt);

//и результат измерения опорного напряжения тоже пишем
vref=ADC_Get_Sample_Filtered(17);
WordToStr(vref,txt);
uart1_write_text(" ADC17(VRef) ");
uart1_write_text(txt);
WordToStr(VRefIntCal*4096/vref,txt);
uart1_write_text(" Vdd, mV ");
uart1_write_text(txt);

//и результат с датчика температуры тоже пишем
iii=ADC_Get_Sample_Filtered(16);
WordToStr(iii,txt);
uart1_write_text(" ADC16(Temp) ");
uart1_write_text(txt);

//получаем значение напряжения датчика в милливольтах
temper=(int)((((long)iii*VRefIntCal))/vref);//чтобы не было переполнения

IntToStr(temper,txt);
uart1_write_text(" Temp Sensor, mV ");
uart1_write_text(txt);

//вычитаем напряжение при 25 градусах, делим на коэффициент и добавляем 25 градусов
temper=25+(int)(((float)(TempV25-temper))/TempAvgSlope);
IntToStr(temper,txt);
uart1_write_text(" Temp, C ");
uart1_write_text(txt);




uart1_write(10);
uart1_write(13);

ADC1_CR2bits.ADON=0;//засыпаем АЦП
GPIOC_ODR.B8=0;
GPIO_Digital_Input(&GPIOC_BASE,_GPIO_PINMASK_8);//светодиод на вход




};
};
}

void  RTC_INIT  (void)                                                                            //Инициализация RTC
{
//разрешаем область APB1
RCC_APB1ENRbits.BKPEN=1;
RCC_APB1ENRbits.PWREN=1;
//разрешаем доступ в область
PWR_CRbits.DBP=1;
//разрешаем низкоскоростной кристалл 32768
LSEON_bit=1;
//ждем поднятия флага
while(!RCC_BDCRbits.LSERDY){delay_ms(10);};//пустой цикл
//выбыраем источник тактирования часов - кристалл 32768
RCC_BDCRbits.RTCSEL=0b01;
//разрешаем работу часов
RCC_BDCRbits.RTCEN=1;
//ждем синхронизации
while(!RTC_CRLbits.RSF){delay_ms(10);};//пустой цикл
//ждем окончания последней операции
while(!RTC_CRLbits.RTOFF){delay_ms(10);};//пустой цикл
//разрешаем секундное прерывание
RTC_CRHbits.SECIE=1;
//остальные запрещаем
RTC_CRHbits.ALRIE=0;
RTC_CRHbits.OWIE=0;

//ждем окончания последней операции
while(!RTC_CRLbits.RTOFF){delay_ms(10);};//пустой цикл

//устанавливаем предделитель на 32767
RTC_PRLL=32767;


//запрещаем запись в регистры часов
RTC_CRLbits.CNF=0;
//ждем окончания последней операции
while(!RTC_CRLbits.RTOFF){delay_ms(10);};//пустой цикл
//разрешаем запись, при этом они синхронизируются
RTC_CRLbits.CNF=1;
//ждем окончания последней операции
while(!RTC_CRLbits.RTOFF){delay_ms(10);};//пустой цикл
//запрещаем доступ в область
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
ADC_Set_Input_Channel(_ADC_CHANNEL_0 | _ADC_CHANNEL_1);      //иниц ацп
adc1_init();
ADC1_SMPR1=0xffff;//максимальное время преобразования
ADC1_SMPR2=0xffff;
ADC1_Get_Sample(16);//два преобразования для калибровки
ADC1_Get_Sample(17);
while(ADC1_SRbits.EOC){delay_us(1);};//ждем флага окончания преобразования
ADC1_CR2bits.CAL=1;//калибровка
while(ADC1_SRbits.EOC){delay_us(1);};//ждем флага окончания преобразования - готово!



TSVREFE_bit=1;//включение измерения температуры и опорного напряжения



//системные тики - такт от внутреннего генератора
STK_CTRLbits.CLKSOURCE=1;
//разрешение работы
STK_CTRLbits.ENABLE_=1;



RTC_INIT();
//SECIE_bit=1;//включаем прерывание по односекундному интервалу
NVIC_IntEnable(IVT_INT_RTC_WKUP);//прерывание для часов

SLEEPDEEP_bit=0;//устанавливаем бит засыпания в sleep
//SLEEPDEEP_bit=1;//устанавливаем бит засыпания в stop
SLEEPONEXIT_bit=1;//засыпаем после выхода из прерывания
PWR_CRbits.PDDS=0;//сбрасываем
PWR_CRbits.LPDS=0;//стабилизатор

ADC1_CR2bits.ADON=0;//засыпаем АЦП
//засыпаем с пробуждением по прерыванию
asm {
   WFI
};

while(1)
{uart1_write_text("No sleep!");   //сигнал о том, что контроллер не спит
uart1_write(10);
uart1_write(13); };

}