#define TIMER_DISABLE_INTR  (TIMSK2 = 0)
#define SYSCLOCK  16000000 
#define TIMER_CONFIG_KHZ(val) ({ \
  const uint8_t pwmval = SYSCLOCK / 2000 / (val); \
  TCCR2A               = _BV(WGM20); \
  TCCR2B               = _BV(WGM22) | _BV(CS20); \
  OCR2A                = pwmval; \
  OCR2B                = pwmval / 3; \
})
#define TIMER_ENABLE_PWM    (TCCR2A |= _BV(COM2B1))
#define TIMER_DISABLE_PWM   (TCCR2A &= ~(_BV(COM2B1)))

void  mark (unsigned int time)
{
  TIMER_ENABLE_PWM; // Enable pin 3 PWM output
  if (time > 0) custom_delay_usec(time);
}

void  space (unsigned int time)
{
  TIMER_DISABLE_PWM; // Disable pin 3 PWM output
  if (time > 0) custom_delay_usec(time);
}

void custom_delay_usec(unsigned long uSecs) 
{
  if (uSecs > 4) {
    unsigned long start = micros();
    unsigned long endMicros = start + uSecs - 4;
    if (endMicros < start) { // Check if overflow
      while ( micros() > start ) {} 
    }
    while ( micros() < endMicros ) {} 
  } 
}

void sendpresumable()
{
  mark(9000);
  space(4500);
}   

void send0()
{
  mark(560);
space(565);
}

void send1()
{
  mark(560);
  space(1690);
}

void sendGree(byte ircode, byte len)
{
  byte mask = 0x01;
  for(int i = 0;i < len;i++)
  {
    if (ircode & mask)
    {   send1();   }
    else
    {   send0();   }
    mask <<= 1;
  }
}

void open1()
{
  TIMER_DISABLE_INTR; //Timer2 Overflow Interrupt
  pinMode(3, OUTPUT);//PWM端口
  digitalWrite(3, LOW); //PWM端口
  digitalWrite(4, LOW);  
  
  TIMER_CONFIG_KHZ(38);//PWM端口频率KHz
  
  sendpresumable();
  //sendGree(0x31, 8);//000自动 100制冷 010除湿 110送风 001制热； 1开；00自动 10小风 01中风 11大风；0扫风；0睡眠//关
  sendGree(0x39, 8);//000自动 100制冷 010除湿 110送风 001制热； 1开；00自动 10小风 01中风 11大风；0扫风；0睡眠//开
  sendGree(0x0A, 8);//温度0000-16度 1000-17度 1100-18度.... 0111-30度 低位在后
  sendGree(0x20, 8);
  sendGree(0x50, 8);
  sendGree(0x02, 3);
  mark(560);
  space(10000);
  space(10000);
  sendGree(0x00, 8);
  sendGree(0x21, 8);
  sendGree(0x00, 8);
  sendGree(0xF0, 8);
  mark(560);
  space(0);
  digitalWrite(4, HIGH); 
}
void close1()
{
  TIMER_DISABLE_INTR; //Timer2 Overflow Interrupt
pinMode(3, OUTPUT);//PWM端口
  digitalWrite(3, LOW); //PWM端口
   digitalWrite(4, LOW);  
  TIMER_CONFIG_KHZ(38);//PWM端口频率KHz
  
  sendpresumable();
  sendGree(0x31, 8);//000自动 100制冷 010除湿 110送风 001制热； 1开；00自动 10小风 01中风 11大风；0扫风；0睡眠//关
  //sendGree(0x39, 8);//000自动 100制冷 010除湿 110送风 001制热； 1开；00自动 10小风 01中风 11大风；0扫风；0睡眠//开
  sendGree(0x0A, 8);//温度0000-16度 1000-17度 1100-18度.... 0111-30度 低位在后
  sendGree(0x20, 8);
  sendGree(0x50, 8);
  sendGree(0x02, 3);
  mark(560);
  space(10000);
  space(10000);
  sendGree(0x00, 8);
  sendGree(0x21, 8);
  sendGree(0x00, 8);
  sendGree(0xF0, 8);
  mark(560);
  space(0);
  digitalWrite(5, HIGH);
}
    void open2()
{
  TIMER_DISABLE_INTR; //Timer2 Overflow Interrupt
  pinMode(3, OUTPUT);//PWM端口
  digitalWrite(3, LOW); //PWM端口
  digitalWrite(5, LOW);  
  TIMER_CONFIG_KHZ(38);//PWM端口频率KHz
  
  sendpresumable();
  //sendGree(0x31, 8);//000自动 100制冷 010除湿 110送风 001制热； 1开；00自动 10小风 01中风 11大风；0扫风；0睡眠//关
  sendGree(0x39, 8);//000自动 100制冷 010除湿 110送风 001制热； 1开；00自动 10小风 01中风 11大风；0扫风；0睡眠//开
  sendGree(0x0A, 8);//温度0000-16度 1000-17度 1100-18度.... 0111-30度 低位在后
  sendGree(0x20, 8);
  sendGree(0x50, 8);
  sendGree(0x02, 3);
  mark(560);
  space(10000);
  space(10000);
  sendGree(0x00, 8);
  sendGree(0x21, 8);
  sendGree(0x00, 8);
  sendGree(0xF0, 8);
  mark(560);
  space(0);
  digitalWrite(4, HIGH); 
}
void close2()
{
  TIMER_DISABLE_INTR; //Timer2 Overflow Interrupt
pinMode(3, OUTPUT);//PWM端口
digitalWrite(3, LOW); //PWM端口
digitalWrite(5, LOW);  
TIMER_CONFIG_KHZ(38);//PWM端口频率KHz
  
  sendpresumable();
  sendGree(0x31, 8);//000自动 100制冷 010除湿 110送风 001制热； 1开；00自动 10小风 01中风 11大风；0扫风；0睡眠//关
  //sendGree(0x39, 8);//000自动 100制冷 010除湿 110送风 001制热； 1开；00自动 10小风 01中风 11大风；0扫风；0睡眠//开
  sendGree(0x0A, 8);//温度0000-16度 1000-17度 1100-18度.... 0111-30度 低位在后
  sendGree(0x20, 8);
  sendGree(0x50, 8);
  sendGree(0x02, 3);
  mark(560);
  space(10000);
  space(10000);
  sendGree(0x00, 8);
  sendGree(0x21, 8);
  sendGree(0x00, 8);
  sendGree(0xF0, 8);
  mark(560);
  space(0);
    digitalWrite(5, HIGH);
}

void setup()
{
pinMode(4,OUTPUT);
pinMode(5,OUTPUT);
digitalWrite(4, HIGH);
digitalWrite(5, HIGH);
}

void loop()
{
    open1();
    delay(500);
    close1();
    delay(500);
    open2();
    delay(500);
    close2();
    delay(500);
}
