const int analogInputPin = A0;  // Define the analog input pin
unsigned long initialTime = 0;  // Variable to store the initial time
int cnt = 0;

void setup() {
  Serial.begin(9600);          // Initialize serial communication at 9600 baud rate
}

void loop() {

  int sensorValue = analogRead(analogInputPin);  // Read the analog voltage
  float voltage = sensorValue * (5.0 / 1023.0);  // Convert the analog value to voltage

  Serial.println(voltage);
  delay(100);

}