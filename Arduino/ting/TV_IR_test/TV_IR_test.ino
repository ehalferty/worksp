#include <IRremote.h>

int RECV_PIN = 11;

IRsend irsend;
IRrecv irrecv(RECV_PIN);

decode_results results;

void setup()
{
  Serial.begin(9600);
  irrecv.enableIRIn(); // Start the receiver
}

// Dumps out the decode_results structure.
// Call this after IRrecv::decode()
// void * to work around compiler issue
//void dump(void *v) {
//  decode_results *results = (decode_results *)v
void dump(decode_results *results) {
  int count = results->rawlen;
  if (results->decode_type == UNKNOWN) {
    Serial.print("Unknown encoding: ");
  } 
  else if (results->decode_type == NEC) {
    Serial.print("Decoded NEC: ");
  } 
  else if (results->decode_type == SONY) {
    Serial.print("Decoded SONY: ");
  } 
  else if (results->decode_type == RC5) {
    Serial.print("Decoded RC5: ");
  } 
  else if (results->decode_type == RC6) {
    Serial.print("Decoded RC6: ");
  }
  else if (results->decode_type == PANASONIC) {  
    Serial.print("Decoded PANASONIC - Address: ");
    Serial.print(results->panasonicAddress,HEX);
    Serial.print(" Value: ");
  }
  else if (results->decode_type == JVC) {
     Serial.print("Decoded JVC: ");
  }
  Serial.print(results->value, HEX);
  Serial.print(" (");
  Serial.print(results->bits, DEC);
  Serial.println(" bits)");
  Serial.print("Raw (");
  Serial.print(count, DEC);
  Serial.print("): ");

  for (int i = 0; i < count; i++) {
    if ((i % 2) == 1) {
      Serial.print(results->rawbuf[i]*USECPERTICK, DEC);
    } 
    else {
      Serial.print(-(int)results->rawbuf[i]*USECPERTICK, DEC);
    }
    Serial.print(" ");
  }
  Serial.println("");
}

void loop() {
//    irsend.sendNEC(0xFF18E7, 32); //机顶盒开关
//    irsend.sendNEC(0xFF629D, 32); //向上
//    irsend.sendNEC(0xFF6897, 32); //向下
//    irsend.sendNEC(0xFFE21D, 32); //向左
//    irsend.sendNEC(0xFFA857, 32); //向右
//    irsend.sendNEC(0xFF28D7, 32); //音量高
//    irsend.sendNEC(0xFF08F7, 32); //音量低
//    irsend.sendNEC(0xFFAA55, 32); //确定
//    irsend.sendNEC(0xFF02FD, 32); //退出
//  irsend.sendRC6(0x1000C, 20); //电视开关
//  delay(500);
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
  irsend.sendRC6(0x10059, 20);
  delay(200);
  irsend.sendRC6(0x59, 20);
  delay(200);
  irsend.sendRC6(0x59, 20);
  delay(200);
  irsend.sendRC6(0x59, 20);
  delay(200);
  irsend.sendRC6(0x59, 20);
  delay(200);
//  irsend.sendRC6(0x1000C, 20); //亮度低
  delay(50);
}
