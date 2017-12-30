/*
 *语音识别wifi模块，本地控制示例代码 
 *功能：1、语音控制模块LED3、蜂鸣器和GPIO13
 *      2、唤醒模式，模块收到唤醒指令后5s内，其他指令有效，未唤醒，指令无效
 *作者：贝壳物联 www.bigiot.net
 *时间：2017.10.10
 */
#include <Bigiot.h>
#include <Ting.h>
#include <SoftwareSerial.h>

SoftwareSerial swSer(4, 5, false, 256);                               //receivePin, transmitPin, inverse_logic, buffSize
TING ting;
BIGIOT bigiot;

//============== 此处需修该 ================
const String DEVICEID = "3893"; // 贝壳物联设备编号
const String  APIKEY = "b6f8315fe"; //设备密码
const char* ssid = "8510";//wifi名称
const char* password = "yzhg8510";//wifi密码
//==========================================

const char* serverIP = "www.bigiot.net";//贝壳物联连接地址
const int serverPort = 8181;//贝壳物联服务端口，可为8181、8282
const unsigned long postingInterval = 50000; // 每隔50秒向服务器报到一次
unsigned long lastCheckStatusTime = 0; //记录上次状态查询时间
unsigned long connectBigiotBeginTime = 0;//记录连接贝壳物联服务器开始时间
bool isConnect = false;//是否连接贝壳物联
bool commandBegin = false;                                              //是否被唤醒进入命令模式
unsigned long commandBeginTime = 0;                                     //唤醒进入命令模式时间
const int commandInterval = 10000;                                      //命令有效时间
int open_rdy = 0;

/*
   语音命令处理函数
   num对应语音命令编辑软件中的编号，在相应case中编写执行动作即可
*/
void voice_command(unsigned int num)
{ 
  if(num == 1){
    open_rdy = 1;
    commandBegin = false;
    delay(10);
  }
  else if(num == 2 && open_rdy == 1){
    commandBegin = true;
    commandBeginTime = millis();
    ting.voice(0,3);                                                  //蜂鸣器应答，1：声音种类；3：音频大小
    open_rdy = 0;
    delay(10);
  }
  else if(num == 20){
    commandBegin = false;
    ting.voice(1,3);
  }
  else{
    if (commandBegin){
      commandBeginTime = millis();
      swSer.println(num);
      delay(10);
      }
    open_rdy = 0;
  }
}

void processWifiMessage(aJsonObject *msg)
{
  aJsonObject* method = aJson.getObjectItem(msg, "M");
  if (!method) {
    return;
  }
  String M = method->valuestring;
  //设备登录
  if (M == "WELCOME TO BIGIOT" || M == "connected")
  {
    bigiot.checkout(DEVICEID, APIKEY);
    delay(10);
    bigiot.checkin(DEVICEID, APIKEY);
    return;
  }
  //判读say指令内容
  if (M == "say")
  {
    aJsonObject* content = aJson.getObjectItem(msg, "C");
    aJsonObject* client_id = aJson.getObjectItem(msg, "ID");
    if (!content || !client_id )return;
    String C = content->valuestring;
    String F_C_ID = client_id->valuestring;//可利用此ID判断命令来源
    Serial.println(F_C_ID);
    if(F_C_ID != "U3267") return;
    if (C == "offOn"){
        swSer.println(3);
        delay(100);
        return;
        }
    if (C == "play"){
        swSer.println(5);
        delay(100);
        swSer.println(17);
        return;
        }  
    if (C == "stop"){
        swSer.println(4);
        return;
        }  
    if (C == "minus"){
        swSer.println(12);
        return;
        }  
    if (C == "up"){
        swSer.println(7);
        return;
        }  
    if (C == "plus"){
        swSer.println(11);
        return;
        }  
    if (C == "left"){
        swSer.println(9);
        return;
        }  
    if (C == "pause"){
        swSer.println(6);
        delay(100);
        swSer.println(18);
        return;
        }  
    if (C == "right"){
        swSer.println(10);
        return;
        }  
    if (C == "backward"){
        swSer.println(14);
        return;
        }  
    if (C == "down"){
        swSer.println(8);
        return;
        }    
    if (C == "forward"){
        swSer.println(13);
        return;
        }
  }
}

void setup() {
  Serial.begin(115200);
  Serial1.begin(115200);                                             //调试串口输出波特率（gpio2 TX）
  swSer.begin(9600);
  ting.init();                                                        //初始化语音模块
  delay(500);
  ting.set_continue();                                                //语音模块持续识别
  WiFi.begin(ssid, password);                                        //连接wifi
}

void loop() {
 if (WiFi.status() == WL_CONNECTED) {                                 //判断是否连接wifi，并尝试连接贝壳物联服务器
   if (!bigiot.client.connected()) {
     if (connectBigiotBeginTime == 0 || millis() - connectBigiotBeginTime > 5000) {
       if (!bigiot.client.connect(serverIP, serverPort)) {
          Serial1.println("can not connect to bigiot.net");
          isConnect = false;
        } 
        else {
          Serial1.println("connected to bigiot.net");
          isConnect = true;
        }
        connectBigiotBeginTime = millis();
      }
    }
  }
 if ((millis() - lastCheckStatusTime > postingInterval || lastCheckStatusTime == 0) && isConnect) {
    bigiot.status();                                                  //定时查询设备是否在线
    lastCheckStatusTime = millis();
  }
  if (isConnect) {                                                    //接收网络指令，并处理
    while (bigiot.client.available()) {
      int num = bigiot.client.available();
      if (num < 8) break;
      String wifiInputString = bigiot.client.readStringUntil('\n');
      aJsonObject *msg = bigiot.getJsonObj(wifiInputString);
      if (msg != NULL)processWifiMessage(msg);
      aJson.deleteItem(msg);
    }
  }
  
  while (Serial.available()) {
    int result = ting.get_command();                                  //获取语音识别命令，并返回对应语音命令编辑软件列表编号
    voice_command(result);                                            //语音命令处理函数
    delay(10);
  }
  if (commandBegin && millis() - commandBeginTime > commandInterval){
    commandBegin = false;                                             //commandInterval/1000 s后退出语音命令状态
    ting.voice(1,3);                                                  //蜂鸣器应答，1：声音种类；3：音频大小
  }
  delay(10);
}
