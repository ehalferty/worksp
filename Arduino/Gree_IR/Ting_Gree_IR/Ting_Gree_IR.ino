#include <IRremote.h>
#include <SoftwareSerial.h>

int Led = 2;
int potpin = 0;
int IR_send = 3;
//********************    IR    *******************//
IRsend irsend;
SoftwareSerial mySerial(10, 11);

unsigned char temp = 0;

void sendpresumable()
{
  irsend.mark(9000);
  irsend.space(4500);
}   
void send0()
{
  irsend.mark(560);
  irsend.space(565);
}
void send1()
{
  irsend.mark(560);
  irsend.space(1690);
}
void sendGree(byte ircode, byte len)
{
  byte mask = 0x01;
  for(int i = 0;i < len;i++)
  {
    if (ircode & mask)
    {
      send1();
    }
    else
    {
      send0();
    }
    mask <<= 1;
  }
}
void gree_open()
{
  irsend.enableIROut(38);
  sendpresumable();
  sendGree(0x3c, 8);
  sendGree(0x0a, 8);
  sendGree(0x20, 8);
  sendGree(0x50, 8);
  sendGree(0x02, 3);
  irsend.mark(560);
  irsend.space(10000);
  irsend.space(10000);
  sendGree(0x01, 8);
  sendGree(0x21, 8);
  sendGree(0x00, 8);
  sendGree(0x20, 8);
  irsend.mark(560);
  irsend.space(0);
}
void gree_close()
{
  irsend.enableIROut(38);
  sendpresumable();
  sendGree(0x00, 8);
  sendGree(0x00, 8);
  sendGree(0x20, 8);
  sendGree(0x50, 8);
  sendGree(0x02, 3);
  irsend.mark(560);
  irsend.space(10000);
  irsend.space(10000);
  sendGree(0x00, 8);
  sendGree(0x00, 8);
  sendGree(0x00, 8);
  sendGree(0xA0, 8);
  irsend.mark(560);
  irsend.space(0);
}

//********************  main loop  *****************//
void setup() {
  mySerial.begin(115200);
  Serial.begin(9600);
  pinMode(Led,OUTPUT);
  pinMode(IR_send, OUTPUT); 
}
void loop() {
  if ( Serial.available()){
   switch (Serial_getRX())
    {
      case 3:      //打开空调
        gree_open();
        delay(10);
        Serial.println("gree open");
        break;
      case 4:      //关闭空调
        gree_close();
        delay(10);
        Serial.println("gree close");
        break;
      case 19:
        int val;
        int dat;
        val = analogRead(potpin);
        dat = (125*val)>>8;
        Serial.println(dat);
        delay(100);
        break;
     }
     delay(10);
  }
  else if(mySerial.available()>0){
   switch (mySerial_getRX())
    {
      case 3:      //打开空调
        gree_open();
        delay(10);
        Serial.println("gree open");
        break;
      case 4:      //关闭空调
        gree_close();
        delay(10);
        Serial.println("gree close");
        break;
      case 19:
        int val;
        int dat;
        val = analogRead(potpin);
        dat = (125*val)>>8;
        Serial.println(dat);
        delay(100);
        break;
     }
   delay(10);
 }
  delay(100);
}

int Serial_getRX(){
 int num = 0;
 while(true){
   Serial.readBytes(&temp,1);
 
   //使用串口发送数值时，使用println（）方式，会将ASC码的13和10作为换行符号发出去，
   //这里也作为数据传输完成的标志，当发现13时，将后一个字符10读出来，则意味着传输结束。
   
   if(temp == 13){
     Serial.readBytes(&temp,1);
     break;
   }
 
   num = 10*num + (temp-'0');//print（）时串口会传送数字的ASC码字符号，需要用这个办法恢复数字
 }
 return num;
}

int mySerial_getRX(){
 int num = 0;
 while(true){
   mySerial.readBytes(&temp,1);
 
   //使用串口发送数值时，使用println（）方式，会将ASC码的13和10作为换行符号发出去，
   //这里也作为数据传输完成的标志，当发现13时，将后一个字符10读出来，则意味着传输结束。
   
   if(temp == 13){
     mySerial.readBytes(&temp,1);
     break;
   }
 
   num = 10*num + (temp-'0');//print（）时串口会传送数字的ASC码字符号，需要用这个办法恢复数字
 }
 return num;
}
