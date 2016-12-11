#include <SPI.h>
#include <WiFi.h>
char ssid[] = "CIC";     // the name of your network
int status = WL_IDLE_STATUS;     // the Wifi radio's status

unsigned long lastConnectionTime = 0;            // last time you connected to the server, in milliseconds
const unsigned long postingInterval = 10L * 1000L; // delay between updates, in milliseconds

//char server[] = "localhost";
//WiFiClient client;

#define humSensor A0
#define lightSensor A1
#define tempSensor A2 //LM355Z
#define soundSensor A3

const float miniVoltsToKelvin = 0.004882812 * 100; //found this online, I don't remember the source :(
const float kelvinOffset = 273.15;

void setup() {
  // initialize digital pin 13 as an output.
  //pinMode(13, OUTPUT);
  Serial.begin(9600);
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    // don't continue:
    while (true);
  }

  String fv = WiFi.firmwareVersion();
  if (fv != "1.1.0") {
    Serial.println("Please upgrade the firmware");
  }

  // attempt to connect to Wifi network:
  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to open SSID: ");
    Serial.println(ssid);
    status = WiFi.begin(ssid);

    // wait 10 seconds for connection:
    delay(10000);
  }

  // you're connected now, so print out the data:
  Serial.print("You're connected to the network");
}


void loop() {
  //humidity
  int humValue = analogRead(humSensor);
  float hum = map(humValue, 0, 1023, 5, 89); //from 11% to 89% humidity
  
  //light
  int lightValue = analogRead(lightSensor);
  float light = map(lightValue, -20, 1023, 0, 100); //from 0% to 100% brightness
  
  //temperature
  float kelvin;
  float fahr;
  kelvin = analogRead(tempSensor) * miniVoltsToKelvin; //converts the reading from the arduino into kelvin
  float temp = kelvin - kelvinOffset - 4; //4 = resistor offset
  
  //sound
  int soundValue = analogRead(soundSensor);
  float sound = map(soundValue, 400, 700, 0, 100); //from 11% to 89% humidity

  // if ten seconds have passed since your last connection,
  // then connect again and send data:
  if (millis() - lastConnectionTime > postingInterval) {
    postData("Humidity_1",hum);
    delay(2000);
    postData("Light_1",light);
    delay(2000);
    postData("Temperature_1",temp);
    delay(2000);
    postData("Sound_1",sound);
    delay(2000);
  }
  
  Serial.println(
    "Humidity: " + String(hum) + "% - " + 
    "Light:" + String(light) + "% - " + 
    "Temperature: " + String(temp) + "C - " +
    "Sound: " + String(sound) + " ");

  delay(2000);  
  
}

WiFiClient client;
void postData(String sensorId, float value){
  client.stop();
  if (client.connect("badneighbours.info", 80)) {
    //Serial.println("connected to server");
    // Make a HTTP request:
    client.println("POST /api/sensor/" + sensorId + "/" + String(value) + " HTTP/1.1");
    client.println("Host: badneighbours.info");
    client.println("Connection: close");
    client.println();
    //client.flush();
    //client.stop();
    Serial.println("Posted: " + sensorId);
    // note the time that the connection was made:
    lastConnectionTime = millis();
  } else {
    client.stop();
    client.flush();
    Serial.println("NOT connected to server");
  }
}








