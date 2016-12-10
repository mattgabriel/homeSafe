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
  
  
  Serial.println(
    "Humidity: " + String(hum) + "% - " + 
    "Light:" + String(light) + "% - " + 
    "Temperature: " + String(temp) + "C - " +
    "Sound: " + String(sound) + " ");
  delay(200);  
  
}

