#include <IRremote.h>
#include <SoftwareSerial.h>
#include <Servo.h> 

int Led = 2;
int potpin = 0;
int IR_send = 3;
//********************    IR    *******************//
IRsend irsend;
Servo myservo; 
SoftwareSerial mySerial(10, 11);

unsigned char temp = 0;
String inString = "";
int Ting_num;
int pos = 0;    // 用于存储舵机位置的变量

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
  mySerial.begin(9600);
  Serial.begin(9600);
  pinMode(Led,OUTPUT);
  pinMode(IR_send, OUTPUT); 
  myservo.attach(9);  // 舵机控制信号引脚 
}
void loop() {
  if ( Serial.available()){
    Ting_num = Serial_getRX();
  }
  else if (mySerial.available()){
    Ting_num = mySerial_getRX();
  }
  else 
    Ting_num = 0;
  if(Ting_num != 0){
   Serial.println(Ting_num);
   switch (Ting_num)
    {
      case 3:      //打开空调
        pos = 120;
        myservo.write(pos);
        delay(500);
        gree_open();
        delay(500);
        Serial.println("gree open");
        pos = 0;
        myservo.write(pos);
        break;
      case 4:      //关闭空调
        pos = 120;
        myservo.write(pos);
        delay(500);
        gree_close();
        delay(500);
        Serial.println("gree close");
        pos = 0;
        myservo.write(pos);
        break;
      case 5:      //电视开
        irsend.sendRC6(0x1000C, 20); //电视开关
        delay(100);
        break;
      case 6:      //电视关
        irsend.sendRC6(0x1000C, 20); //电视开关
        delay(100);
        break;
      case 7:      //向上
        irsend.sendNEC(0xFF629D, 32); //向上
        delay(100);
        break;
      case 8:      //向下
        irsend.sendNEC(0xFF6897, 32); //向下
        delay(100);
        break;
      case 9:      //向左
        irsend.sendNEC(0xFFE21D, 32); //向左
        delay(100);
        break;
      case 10:      //向右
        irsend.sendNEC(0xFFA857, 32); //向右
        delay(100);
        break;
      case 11:      //音量高
        irsend.sendNEC(0xFF28D7, 32); //音量高
        delay(100);
        break;
      case 12:      //音量低
        irsend.sendNEC(0xFF08F7, 32); //音量低
        delay(100);
        break;
      case 13:      //确定
        irsend.sendNEC(0xFFAA55, 32); //确定
        delay(100);
        break;
      case 14:      //退出
        irsend.sendNEC(0xFF02FD, 32); //退出
        delay(100);
        break;
      case 15:      //亮度高
        irsend.sendRC6(0x10076, 20); //亮度高
        delay(500);
        irsend.sendRC6(0x1005B, 20); 
        delay(500);
        irsend.sendRC6(0x10059, 20);
        delay(500);
        irsend.sendRC6(0x10059, 20);
        delay(500);
        irsend.sendRC6(0x1005C, 20);
        delay(500);
        irsend.sendRC6(0x10058, 20);
        delay(500);
        irsend.sendRC6(0x58, 20);
        delay(100);
        break;
      case 16:      //亮度低
        irsend.sendRC6(0x10076, 20); //亮度低
        delay(500);
        irsend.sendRC6(0x1005B, 20); 
        delay(500);
        irsend.sendRC6(0x10059, 20);
        delay(500);
        irsend.sendRC6(0x10059, 20);
        delay(500);
        irsend.sendRC6(0x1005C, 20);
        delay(500);
        irsend.sendRC6(0x10059, 20);
        delay(500);
        irsend.sendRC6(0x10059, 20);
        delay(500);
        break;
      case 17:      //打开机顶盒
        irsend.sendNEC(0xFF18E7, 32); //机顶盒开关
        delay(100);
        Serial.println("STB open");
        break;
      case 18:      //关闭机顶盒
        irsend.sendNEC(0xFF18E7, 32); //机顶盒开关
        delay(100);
        break;
      case 19:
        int val;
        int dat;
        val = analogRead(potpin);
        dat = (125*val)>>8;
        Serial.println(dat);
        delay(100);
        break;
      default: break;
     }
     delay(10);
  }
  delay(100);
}

int Serial_getRX(){
 inString = "";
 int num = 0;
 while (Serial.available() > 0) {
  int inChar = Serial.read();
  if (isDigit(inChar)) {
   inString += (char)inChar;
  }
  if (inChar == '\n') {
    num = inString.toInt();
  }
 }
 return num;
}

int mySerial_getRX(){
 inString = "";
 int num = 0;
 while (mySerial.available() > 0) {
  int inChar = mySerial.read();
  if (isDigit(inChar)) {
   inString += (char)inChar;
  }
  if (inChar == '\n') {
    num = inString.toInt();
  }
 }
 return num;
}
