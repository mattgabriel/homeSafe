#include "Sodaq_esp8266_tel0092.h"
#include <Wire.h>
#include <SPI.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>
#define BME_SCK 13
#define BME_MISO 12
#define BME_MOSI 11
#define BME_CS 10
#define SEALEVELPRESSURE_HPA (1013.25)
Adafruit_BME280 bme; // I2C
// WIFI Config
#define ssid  "CIC"   // you need to change the ssid and password to your wifi's name and password
#define password ""
// Philips BackEnd Data Config
const String server = "hdc-ds-doh001.cloud.pcftest.com";
#define      serverPort  (80)
const String loginId = "eversf+doh001@gmail.com";
const String userPassword = "FDtCrwFz@1";
const String apiVersion = "10";
const String appAgent = "HOMESAFE001";
const String applicationName = "DataCore";
//Other Configurations
bool debug = false;
bool debugReadingValues = true;
unsigned long tokenRefreshIntervalSeconds = 3600; // Amount of time the
authentication token is valid in seconds. Default: 3600 (1 hour).
unsigned long dataMomentPostIntervalSeconds = 15; // Data Moment Post
Interval in seconds.
Sodaq_esp8266_tel0092 wifi;
void init_bee() {
   pinMode(BEE_VCC, OUTPUT);
   digitalWrite(BEE_VCC, HIGH);
      delay(2);
   pinMode(BEEDTR, OUTPUT);
   digitalWrite(BEEDTR, HIGH);
   pinMode(BEECTS, INPUT);
  }
void ledblink(int rate, int numberOfBlinks){
    while(numberOfBlinks > 0) {
      digitalWrite(13, HIGH);
level)
// turn the LED on (HIGH is the voltage
// wait for 500ms
// turn the LED off by making the voltage
delay(rate);
digitalWrite(13, LOW);
delay(rate);
LOW
}
void setup() {
 SerialUSB.begin(115200);
 Serial1.begin(115200);
  Wire.begin();
  delay(3000);
  numberOfBlinks--;
}
  SerialUSB.println("--------- Setup:Init --------");
  pinMode(13, OUTPUT); //Configures the output led.
  digitalWrite(13, HIGH);
init_bee();
  if (!bme.begin()) {
    SerialUSB.println("Could not find a valid BME280 sensor, check
wiring!");
    while (1);
}
  delay(2000); // it will be better to delay 2s to wait esp8266 module OK
  if(debug){
      wifi.begin(&Serial1, &SerialUSB);
      SerialUSB.println("Debug Mode: ON");
  }else{
      wifi.begin(&Serial1);
      SerialUSB.println("Debug Mode: OFF");
}
  if(debugReadingValues)
    SerialUSB.println("Debug Reading Values: ON");
     else
    SerialUSB.println("Debug Reading Values: OFF");
 SerialUSB.print("Connecting to AP (");   // if you used a serial to debug,
then you can use wifi.debugPrintln() to print your debug info
  SerialUSB.print(ssid);
  SerialUSB.print(")...");
 if (wifi.connectAP(ssid, password)) {
    SerialUSB.println("OK");
 }else {
    SerialUSB.println("NOK!");
    while(true);
}
  String ip_addr;
  ip_addr = wifi.getIP();
  SerialUSB.println("Your Arduino IP Is:" + ip_addr);
  if(loginId.length() > 0 && userPassword.length() > 0)
  {
     SerialUSB.print("Credentials for (");
     SerialUSB.print(loginId);
     SerialUSB.println("), configured.");
  }else{
    SerialUSB.println("#ERROR: No user credentials configured!");
     while(true);
    }
  SerialUSB.print("Setting up single HTTP connection mode...");
  if (wifi.setSingleConnect()) {
    SerialUSB.println("OK");
  }else {
    SerialUSB.println("NOK!");
    while(true);
  }
  if(SERIAL_BUFFER_SIZE < 1025){
     SerialUSB.println("#ERROR: The 'SERIAL_BUFFER_SIZE' is is less than 1025. Please change configuration here: /Users/310233845/Library/Arduino15/packages/SODAQ/hardware/samd/1.6.9/cores/arduino/RingBuffer.h' to 1025.");
     SerialUSB.print("The current serial buffer size is: ");
     SerialUSB.println(SERIAL_BUFFER_SIZE);
     while(true);
}
  SerialUSB.print("Connecting to DataCore Server (");
  SerialUSB.print(server);
  SerialUSB.print(") on port (");
  SerialUSB.print(serverPort);
  SerialUSB.print(")...");
     if(wifi.createTCP(server, serverPort)){
    SerialUSB.println("OK");
    wifi.releaseTCP();
  }else {
    SerialUSB.println("NOK!");
    while(true);
}
  SerialUSB.print("Token Refresh Rate: ");
  SerialUSB.print(tokenRefreshIntervalSeconds);
  SerialUSB.println(" seconds.");
  SerialUSB.print("Data Moment Post Rate: ");
  SerialUSB.print(dataMomentPostIntervalSeconds);
  SerialUSB.println(" seconds.");
  ledblink(50,3);
  SerialUSB.println("--------- Setup:Done --------");
}
void printHTTPResponse(String response){
  SerialUSB.print("#DEBUG: Received:[");
  SerialUSB.print(response);
  SerialUSB.println("]");
}
String authenticationJsonBody =
"{\"loginId\":\""+loginId+"\",\"password\":\""+userPassword+"\"}";
String authenticationHttpPostRequest = "POST
/authentication/login?applicationName="+applicationName+" HTTP/1.1\r\nHost:
"+server+"\r\nContent-Type: application/json\r\nAccept:
application/json\r\nContent-Length:
"+authenticationJsonBody.length()+"\r\n\r\n"+authenticationJsonBody+"\r\n\
r\n";
String getVersionHttpGetRequest = "GET /api/version HTTP/1.1\r\nHost:
"+server+"\r\n\r\n";
String accessToken = "";
String performerId = "";
String dataMomentJsonBody = "";
String dataMomentHttpPostRequest = "";
unsigned long tokenRefreshPreviousMillis = (tokenRefreshIntervalSeconds *
1000)+1; // last time update
unsigned long dataMomentPostPreviousMillis = (dataMomentPostIntervalSeconds
* 1000)+1; // last time update
void loop() {
 unsigned long currentMillis = millis();
uint8_t buffer[1024] = {0};
   String response = "";
    if(currentMillis - tokenRefreshPreviousMillis >
(tokenRefreshIntervalSeconds * 1000)) {
           tokenRefreshPreviousMillis = currentMillis;
           SerialUSB.println("");
           wifi.createTCP(server, serverPort);
           SerialUSB.print("Autenticating the User (");
           SerialUSB.print(loginId);
           SerialUSB.print(")...");
           if(wifi.send((const uint8_t*)
string2char(authenticationHttpPostRequest),
authenticationHttpPostRequest.length())){
                ledblink(500,1);
                wifi.recv(buffer, sizeof(buffer), 10000);
                response = (char*)buffer;
                if(debug) printHTTPResponse(response);
                int indexAccessToken = response.indexOf("accessToken");
                int indexUUID = response.indexOf("userUUID");
                if(indexAccessToken > 0 && indexUUID > 0)
                {
                    SerialUSB.println("OK");
                    accessToken =
response.substring(indexAccessToken+14,indexAccessToken+30);
                    performerId =
response.substring(indexUUID+11,indexUUID+47);
                }else{
                    SerialUSB.println("NOK!");
                    printHTTPResponse(response);
}
                SerialUSB.print("AccessToken: ");
                SerialUSB.println(accessToken);
                SerialUSB.print("PerformerId: ");
                SerialUSB.println(performerId);
          }else {
            SerialUSB.println("ERROR!");
            }
         wifi.releaseTCP();
    }
    if(accessToken.length() > 0 && performerId.length() > 0)
       {
        if(currentMillis - dataMomentPostPreviousMillis >
(dataMomentPostIntervalSeconds * 1000)) {
                dataMomentPostPreviousMillis = currentMillis;
                SerialUSB.println("");
                wifi.createTCP(server, serverPort);
                buffer[1024] = {0};
                response = "";
                if(debugReadingValues) {
                      SerialUSB.print("Temperature = ");
                      SerialUSB.print(bme.readTemperature());
                      SerialUSB.println(" *C");
                      SerialUSB.print("Pressure = ");
                      SerialUSB.print(bme.readPressure() / 100.0F);
                      SerialUSB.println(" hPa");
                      SerialUSB.print("Approx. Altitude = ");
SerialUSB.print(bme.readAltitude(SEALEVELPRESSURE_HPA));
                      SerialUSB.println(" m");
                      SerialUSB.print("Humidity = ");
                      SerialUSB.print(bme.readHumidity());
                      SerialUSB.println(" %");
                }
                SerialUSB.print("-> Posting a sensor data moment...");
                // Moment JSON Body to be Posted to Datacore.
                dataMomentJsonBody =
"{\"details\":[{\"type\":\"SomeType\",\"value\":\"\"}],\"measurements\":[{
\"timestamp\":\"1900-01-01T00:00:00.000Z\",\"type\":\"Temperature\",\"unit
\":\"Celsius\",\"value\":"+String(bme.readTemperature())+"},{\"timestamp\"
:\"1900-01-01T00:00:00.000Z\",\"type\":\"Pressure\",\"unit\":\"hPa\",\"val
ue\":"+String(bme.readPressure() /
100.0F)+"},{\"timestamp\":\"1900-01-01T00:00:00.000Z\",\"type\":\"Humidity
\",\"unit\":\"Percentage\",\"value\":"+String(bme.readHumidity())+"}],\"ti
mestamp\":\"1900-01-01T00:00:00.000Z\",\"type\":\"THPReading\"}";
                dataMomentHttpPostRequest = "POST
/api/users/"+performerId+"/moments HTTP/1.1\r\nHost
:"+server+"\r\nContent-Type: application/json\r\nAuthorization: bearer
"+accessToken+"\r\nperformerId :"+performerId+"\r\napi-version
:"+apiVersion+"\r\nappAgent :"+appAgent+"\r\nContent-Length:
"+dataMomentJsonBody.length()+"\r\n\r\n"+dataMomentJsonBody+"\r\n\r\n";
                   if(wifi.send((const uint8_t*)
string2char(dataMomentHttpPostRequest),
dataMomentHttpPostRequest.length())){
                        ledblink(500,1);
                        wifi.recv(buffer, sizeof(buffer), 10000);
                        response = (char*)buffer;
                        if(debug) printHTTPResponse(response);
                        int indexMomentId = response.indexOf("momentId");
                        if(indexMomentId > 0){
                             SerialUSB.println("OK");
                             String momentId =
response.substring(indexMomentId+8,indexMomentId+47);
                             SerialUSB.print("Moment ID: ");
}
                    SerialUSB.println(momentId);
                }else{
                   SerialUSB.println("NOK!");
                   printHTTPResponse(response);
               }
               wifi.releaseTCP();
       }else {
         SerialUSB.println("POSTING NOK!");
} }
  SerialUSB.print(".");
  delay(1000);
}
char* string2char(String command){
    if(command.length()!=0){
        char *p = const_cast<char*>(command.c_str());
   
return p; }
}
