#include <IRremote.h>
#include <SCoop.h>

int Led = 2;
int potpin = 0;
volatile int tmp = 0;
int IR_send = 3;
//********************    IR    *******************//
IRsend irsend;
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
  sendGree(0xFC, 8);
  sendGree(0x9E, 8);
  sendGree(0x20, 8);
  sendGree(0x50, 8);
  sendGree(0x02, 3);
  irsend.mark(560);
  irsend.space(10000);
  irsend.space(10000);
  sendGree(0x01, 8);
  sendGree(0x21, 8);
  sendGree(0x00, 8);
  sendGree(0x60, 8);
  irsend.mark(560);
  irsend.space(0);
}
void gree_close()
{
  irsend.enableIROut(38);
  sendpresumable();
  sendGree(0x00, 8);
  sendGree(0x00, 8);
  sendGree(0x00, 8);
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

defineTaskLoop(Task1) 
{
  if ( Serial.available())
  { switch (Serial.read())
    {
      case 'o':      //打开空调
        gree_open();
        sleep(500);
        Serial.println("gree open");
        break;
      case 'c':      //关闭空调
        gree_close();
        sleep(500);
        Serial.println("gree close");
        break;
      case 't':
        Serial.println(tmp);
        sleep(10);
        break;
     }
   }
   sleep(100);
}

defineTaskLoop(Task2) 
{
  int val;
  val = analogRead(potpin);
  tmp = (125*val)>>8;
  sleep(1000);
}
//********************  main loop  *****************//
void setup() {
  Serial.begin(9600);
  pinMode(Led,OUTPUT);
  pinMode(IR_send, OUTPUT); 
  mySCoop.start();
}
void loop() {
  yield();
}
