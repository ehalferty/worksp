/*
 *语音识别wifi模块，本地控制示例代码 
 *功能：1、语音控制模块LED3、蜂鸣器和GPIO13
 *      2、唤醒模式，模块收到唤醒指令后5s内，其他指令有效，未唤醒，指令无效
 *作者：贝壳物联 www.bigiot.net
 *时间：2017.10.10
 */
#include <Ting.h>
#include <SoftwareSerial.h>

SoftwareSerial swSer(4, 5, false, 256);                               //receivePin, transmitPin, inverse_logic, buffSize
TING ting;

bool commandBegin = false;                                              //是否被唤醒进入命令模式
unsigned long commandBeginTime = 0;                                     //唤醒进入命令模式时间
const int commandInterval = 30000;                                      //命令有效时间
int open_rdy = 0;

/*
   语音命令处理函数
   num对应语音命令编辑软件中的编号，在相应case中编写执行动作即可
*/
void voice_command(unsigned int num)
{
  if(num == 1){
    open_rdy = 1;
  }
  else if(num == 2 && open_rdy == 1){
    commandBegin = true;
    commandBeginTime = millis();
    ting.voice(0,3);                                                  //蜂鸣器应答，1：声音种类；3：音频大小
    open_rdy = 0;
  }
  else{
    if (commandBegin){
      swSer.println(num);
      delay(10);
      }
    open_rdy = 0;
  }
}

void setup() {
  Serial.begin(115200);
  swSer.begin(115200);
  ting.init();                                                        //初始化语音模块
  delay(500);
  ting.set_continue();                                                //语音模块持续识别
}

void loop() {
  while (Serial.available()) {
    int result = ting.get_command();                                  //获取语音识别命令，并返回对应语音命令编辑软件列表编号
    voice_command(result);                                            //语音命令处理函数
  }
  if (commandBegin && millis() - commandBeginTime > commandInterval){
    commandBegin = false;                                             //commandInterval/1000 s后退出语音命令状态
    ting.voice(1,3);                                                  //蜂鸣器应答，1：声音种类；3：音频大小
    }
  delay(100);
}
