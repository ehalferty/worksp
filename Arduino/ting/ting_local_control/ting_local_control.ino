/*
 *语音识别wifi模块，本地控制示例代码 
 *功能：1、语音控制模块LED3、蜂鸣器和GPIO13
 *      2、唤醒模式，模块收到唤醒指令后5s内，其他指令有效，未唤醒，指令无效
 *作者：贝壳物联 www.bigiot.net
 *时间：2017.10.10
 */
#include <Ting.h>

TING ting;

bool commandBegin = false;//是否被唤醒进入命令模式
unsigned long commandBeginTime = 0;//唤醒进入命令模式时间
const int commandInterval = 5000;//命令有效时间
/*
   语音命令处理函数
   num对应语音命令编辑软件中的编号，在相应case中编写执行动作即可
*/
void voice_command(unsigned int num)
{
  switch (num) {
    case 1:
      commandBegin = true;
      commandBeginTime = millis();
      ting.voice(1,3);//蜂鸣器应答，1：声音种类；3：音频大小
      break;
    case 2:
      if (commandBegin) {
        ting.ledOn();//板载led3亮
      }
      break;
    case 3:
      if (commandBegin) {
        ting.ledOff();//板载led3亮
      }
      break;
    case 4:
      if (commandBegin) {
        ting.voice(0,6);//蜂鸣器应答，0：声音种类；6：声音频率高低
      }
      break;
    case 5:
      if (commandBegin) {
        digitalWrite(13, HIGH);//GPIO13置为高电平
      }
      break;
    case 6:
      if (commandBegin) {
        digitalWrite(13, LOW);//GPIO13置为低电平
      }                
      break;
    default:
      break;
  }
  return;
}

void setup() {
  Serial.begin(115200);
  pinMode(13, OUTPUT);//设置gpio13为输出模式
  ting.init();//初始化语音模块
  delay(500);
  ting.set_continue();//语音模块持续识别
}

void loop() {
  while (Serial.available()) {
    int result = ting.get_command();//获取语音识别命令，并返回对应语音命令编辑软件列表编号
    voice_command(result);//语音命令处理函数
  }
  if (commandBegin && millis() - commandBeginTime > commandInterval)commandBegin = false;//5s后退出语音命令状态
  delay(1);
}
