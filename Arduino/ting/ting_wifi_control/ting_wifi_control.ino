/*
  语音识别wifi模块，远程控制示例代码
  功能：1、语音控制其他接入贝壳物联平台设备
        2、模块接收来自贝壳物联平台的控制
        3、唤醒模式，模块收到唤醒指令后5s内，其他指令有效，未唤醒，指令无效
  作者：贝壳物联 www.bigiot.net
  时间：2017.10.10
*/
#include <Bigiot.h>
#include <Ting.h>

TING ting;
BIGIOT bigiot;

//=============  此处需修该=================
const String DEVICEID = "3893"; // 贝壳物联设备编号==
const String  APIKEY = "b6f8315fe"; //设备密码====
const char* ssid = "8510";//wifi名称
const char* password = "yzhg8510";//wifi密码
//==========================================

const char* serverIP = "www.bigiot.net";//贝壳物联连接地址
const int serverPort = 8181;//贝壳物联服务端口，可为8181、8282
const unsigned long postingInterval = 50000; // 每隔50秒向服务器报到一次
unsigned long lastCheckStatusTime = 0; //记录上次状态查询时间
unsigned long connectBigiotBeginTime = 0;//记录连接贝壳物联服务器开始时间
bool isConnect = false;//是否连接贝壳物联
bool commandBegin = false;//是否进入命令模式
unsigned long commandBeginTime = 0;//是否进入命令模式
const int commandInterval = 5000;//命令有效时间
/*
   语音命令处理函数
   num对应语音命令编辑软件的列表编号，在相应case中编写执行动作即可
*/
void voice_command(unsigned int num)
{
  switch (num) {
    case 1:
      if (commandBegin) {
        bigiot.say("D3261", "play");//给目标设备（目标设备ID在贝壳物联用户中心获取）发送play指令
      }
      break;
    case 19:
      if (commandBegin) {
        bigiot.say("D3261", "stop");//给目标设备（目标设备ID在贝壳物联用户中心获取）发送stop指令
      }
      break;
    case 22:
      commandBegin = true;
      commandBeginTime = millis();
      ting.voice(1, 3);//蜂鸣应答
      break;
    default:
      break;
  }
  return;
}
/*
   wifi指令（来自贝壳物联平台）处理函数
   参考贝壳物联通讯协议：http://www.bigiot.net/help/1.html
   json字符串解析参考，bigiot库文件中example文件夹
*/
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
    if (C == "play")//为play时打开led3
    {
      ting.ledOn();
      return;
    }
    if (C == "stop")//为play时关闭led3
    {
      ting.ledOff();
      return;
    }
  }
}
void setup() {
  Serial.begin(115200);
  Serial1.begin(115200);//调试串口输出波特率（gpio2 TX）
  ting.init();//初始化语音模块
  delay(500);
  ting.set_continue();//语音模块持续识别
  WiFi.begin(ssid, password);//连接wifi
}
void loop() {
  //判断是否连接wifi，并尝试连接贝壳物联服务器
  if (WiFi.status() == WL_CONNECTED) {
    if (!bigiot.client.connected()) {
      if (connectBigiotBeginTime == 0 || millis() - connectBigiotBeginTime > 5000) {
        if (!bigiot.client.connect(serverIP, serverPort)) {
          Serial1.println("can not connect to bigiot.net");
          isConnect = false;
        } else {
          Serial1.println("connected to bigiot.net");
          isConnect = true;
        }
        connectBigiotBeginTime = millis();
      }
    }
  }
  //5s后退出语音命令状态
  if (commandBegin && millis() - commandBeginTime > commandInterval)commandBegin = false;
  //定时查询设备是否在线
  if ((millis() - lastCheckStatusTime > postingInterval || lastCheckStatusTime == 0) && isConnect) {
    bigiot.status();
    lastCheckStatusTime = millis();
  }
  //接收网络指令，并处理
  if (isConnect) {
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
    int result = ting.get_command();//获取语音识别命令，并返回对应语音命令编辑软件列表编号
    voice_command(result);//语音命令处理函数
  }
  delay(10);
}
