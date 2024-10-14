// Basic control of stepper motors. 1 Full rotation moves the corresponding base by 1 cm

// Set up which Arduino pins will be used
const int analogInputPin = A0;  // Define the analog input pin

const int dirPin1 = 2;
const int stepPin1 = 3;
const int dirPin2A = 4;
const int stepPin2A = 5;
const int dirPin2B = 7;
const int stepPin2B = 6;

const int read1 = 12;
const int read2 = 11;
const int read3 = 10;
const int read4 = 9;
const int read5 = 8;

int blueState = 0;
int rows = 0;
int cntX = 0;
int cntY = 0;

// Set up number of microsteps and how many revolutions are desired
const int stepsPerRev = 6400;  // 6400 steps per full revolution = 1 cm movement
const int stepsPerRevMini = 640;  // 640 steps per full revolution = 1 mm movement
const int tStop = 1985 + 600 - 20; //26
const int tStopLow = 1700 + 600 - 20;
const int delayTime = 58;       // delay time for microstepping - sets the motor speed - 72 gives 1cm/s
const int numCyclesMotor1 = 3;  // stage moves by 3cm in X direction
const int numCyclesMotor2 = 3;  // stage moves by 3cm in Y direction
const int numCyclesTot = 13;  // number of zig zag cycles

const float Vcutoff = 2.3;
const int delayTimeVcutoff = 1500;

// Set up Arduino pins to output signal
void setup() {
  // Serial.begin(9600);  // Comment In for diagnostics
  pinMode(dirPin1, OUTPUT);
  pinMode(stepPin1, OUTPUT);
  pinMode(dirPin2A, OUTPUT);
  pinMode(stepPin2A, OUTPUT);
  pinMode(dirPin2B, OUTPUT);
  pinMode(stepPin2B, OUTPUT);
  pinMode(read1, INPUT);
  pinMode(read2, INPUT);
  pinMode(read3, INPUT);
  pinMode(read4, INPUT);
  pinMode(read5, INPUT);
}

// Set up the direction of the motors.  ATTENTION: MOTORS 1A AND 1B SHOULD ALWAYS HAVE THE SAME DIRECTION
void loop() {


  // BLACK BUTTON - moves motor 1 individually
  if (digitalRead(read1) == HIGH) {
    if (digitalRead(read3) == LOW) {
      digitalWrite(dirPin1, HIGH);
    }
    if (digitalRead(read3) == HIGH) {
      digitalWrite(dirPin1, LOW);
    }
    for (int i = 0; i < stepsPerRevMini; i++) {
      digitalWrite(stepPin1, HIGH);
      delayMicroseconds(delayTime);
      digitalWrite(stepPin1, LOW);
      delayMicroseconds(delayTime);
    }
  }


  // WHITE BUTTON - moves motor 2 individually
  if (digitalRead(read2) == HIGH) {
    if (digitalRead(read3) == LOW) {
      digitalWrite(dirPin2A, HIGH);
      digitalWrite(dirPin2B, HIGH);
    }
    if (digitalRead(read3) == HIGH) {
      digitalWrite(dirPin2A, LOW);
      digitalWrite(dirPin2B, LOW);
    }
    for (int i = 0; i < stepsPerRevMini; i++) {
      digitalWrite(stepPin2A, HIGH);
      digitalWrite(stepPin2B, HIGH);
      delayMicroseconds(delayTime);
      digitalWrite(stepPin2A, LOW);
      digitalWrite(stepPin2B, LOW);
      delayMicroseconds(delayTime);
    }
  }


  // BLUE BUTTON - Basic zigzag operation for DROPPER

  if (digitalRead(read5) == HIGH) {

    if (digitalRead(read3) == HIGH) {

      digitalWrite(dirPin1, HIGH);  // AWAY FROM MOTOR
      for (int j = 0; j < 41; j++) {
        for (int i = 0; i < stepsPerRev; i++) {
          digitalWrite(stepPin1, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin1, LOW);
          delayMicroseconds(delayTime);
        }
      }
      for (int j = 0; j < 6; j++) {
        for (int i = 0; i < stepsPerRevMini; i++) {
          digitalWrite(stepPin1, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin1, LOW);
          delayMicroseconds(delayTime);
        }
      }

      digitalWrite(dirPin2A, HIGH);
      digitalWrite(dirPin2B, HIGH);
      for (int j = 0; j < 37; j++) {
        for (int i = 0; i < stepsPerRev; i++) {
          digitalWrite(stepPin2A, HIGH);
          digitalWrite(stepPin2B, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin2A, LOW);
          digitalWrite(stepPin2B, LOW);
          delayMicroseconds(delayTime);
        }
      }
      for (int j = 0; j < 4; j++) {
        for (int i = 0; i < stepsPerRevMini; i++) {
          digitalWrite(stepPin2A, HIGH);
          digitalWrite(stepPin2B, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin2A, LOW);
          digitalWrite(stepPin2B, LOW);
          delayMicroseconds(delayTime);
        }
      }


    } else {

      blueState = 1;
      digitalWrite(dirPin1, LOW);  // TOWARDS MOTOR
      for (int j = 0; j < 4; j++) {
        for (int i = 0; i < stepsPerRev; i++) {
          digitalWrite(stepPin1, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin1, LOW);
          delayMicroseconds(delayTime);
        }
      }
      delay(1000);
    }
  }

  if (blueState == 1 && rows < 30) {

    int sensorValue = analogRead(analogInputPin);  // Read the analog voltage
    float voltage = sensorValue * (5.0 / 1023.0);  // Convert the analog value to voltage

    if (voltage < 1.56 && cntY == 0) {
      // MOVE BASE 1 TOWARDS MOTOR
      if (cntX < 25) {
        digitalWrite(dirPin1, LOW);  // TOWARDS MOTOR
      } else {
        digitalWrite(dirPin1, HIGH);  // AWAY FROM MOTOR
      }
      for (int j = 0; j < numCyclesMotor1; j++) {
        for (int i = 0; i < stepsPerRev; i++) {
          digitalWrite(stepPin1, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin1, LOW);
          delayMicroseconds(delayTime);
        }
      }
      cntX++;
      if (cntX == 25) {
        cntY = 1;
      }
      if (cntX == 50) {
        cntY = 1;
        cntX = 0;
      }
      delay(delayTimeVcutoff);
    }

    sensorValue = analogRead(analogInputPin);  // Read the analog voltage
    voltage = sensorValue * (5.0 / 1023.0);    // Convert the analog value to voltage

    if (voltage < 1.56 && cntY == 1) {
      // MOVE BASE 2 TOWARDS MOTOR
      digitalWrite(dirPin2A, LOW);
      digitalWrite(dirPin2B, LOW);
      for (int j = 0; j < numCyclesMotor2; j++) {
        for (int i = 0; i < stepsPerRev; i++) {
          digitalWrite(stepPin2A, HIGH);
          digitalWrite(stepPin2B, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin2A, LOW);
          digitalWrite(stepPin2B, LOW);
          delayMicroseconds(delayTime);
        }
      }
      cntY = 0;
      rows++;
      delay(delayTimeVcutoff);
    }
  }



  // YELLOW BUTTON - Basic zigzag operation for CAMERA
  if (digitalRead(read4) == HIGH) {

    if (digitalRead(read3) == HIGH) {

      digitalWrite(dirPin1, HIGH);  // AWAY FROM MOTOR
      for (int j = 0; j < 41; j++) {
        for (int i = 0; i < stepsPerRev; i++) {
          digitalWrite(stepPin1, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin1, LOW);
          delayMicroseconds(delayTime);
        }
      }
      for (int j = 0; j < 9; j++) {
        for (int i = 0; i < stepsPerRevMini; i++) {
          digitalWrite(stepPin1, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin1, LOW);
          delayMicroseconds(delayTime);
        }
      }

      digitalWrite(dirPin2A, HIGH);
      digitalWrite(dirPin2B, HIGH);
      for (int j = 0; j < 52; j++) {
        for (int i = 0; i < stepsPerRev; i++) {
          digitalWrite(stepPin2A, HIGH);
          digitalWrite(stepPin2B, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin2A, LOW);
          digitalWrite(stepPin2B, LOW);
          delayMicroseconds(delayTime);
        }
      }
      for (int j = 0; j < 10; j++) {
        for (int i = 0; i < stepsPerRevMini; i++) {
          digitalWrite(stepPin2A, HIGH);
          digitalWrite(stepPin2B, HIGH);
          delayMicroseconds(delayTime);
          digitalWrite(stepPin2A, LOW);
          digitalWrite(stepPin2B, LOW);
          delayMicroseconds(delayTime);
        }
      }


    } else {


      digitalWrite(dirPin2A, LOW);
      digitalWrite(dirPin2B, LOW);

      for (int l = 0; l < numCyclesTot; l++) {

        // MOVE BASE 1 TOWARDS MOTOR
        digitalWrite(dirPin1, LOW);
        for (int k = 0; k < 25; k++) {
          for (int j = 0; j < numCyclesMotor1; j++) {
            for (int i = 0; i < stepsPerRev; i++) {
              digitalWrite(stepPin1, HIGH);
              delayMicroseconds(delayTime);
              digitalWrite(stepPin1, LOW);
              delayMicroseconds(delayTime);
            }
          }
          if (digitalRead(read4) == HIGH) {
            delay(tStopLow);
          } else {
            delay(tStop);
          }
          if (digitalRead(read3) == HIGH) {
            delay(200);
          }
        }

        // MOVE BASE 2 TOWARDS MOTOR
        for (int j = 0; j < numCyclesMotor2; j++) {
          for (int i = 0; i < stepsPerRev; i++) {
            digitalWrite(stepPin2A, HIGH);
            digitalWrite(stepPin2B, HIGH);
            delayMicroseconds(delayTime);
            digitalWrite(stepPin2A, LOW);
            digitalWrite(stepPin2B, LOW);
            delayMicroseconds(delayTime);
          }
        }
        delay(tStop);

        // MOVE BASE 1 AWAY FROM MOTOR
        for (int k = 0; k < 25; k++) {
          digitalWrite(dirPin1, HIGH);
          for (int j = 0; j < numCyclesMotor1; j++) {
            for (int i = 0; i < stepsPerRev; i++) {
              digitalWrite(stepPin1, HIGH);
              delayMicroseconds(delayTime);
              digitalWrite(stepPin1, LOW);
              delayMicroseconds(delayTime);
            }
          }
          if (digitalRead(read4) == HIGH) {
            delay(tStopLow);
          } else {
            delay(tStop);
          }

          if (digitalRead(read3) == HIGH) {
            delay(200);
          }
        }

        // MOVE BASE 2 TOWARDS MOTOR
        for (int j = 0; j < numCyclesMotor2; j++) {
          for (int i = 0; i < stepsPerRev; i++) {
            digitalWrite(stepPin2A, HIGH);
            digitalWrite(stepPin2B, HIGH);
            delayMicroseconds(delayTime);
            digitalWrite(stepPin2A, LOW);
            digitalWrite(stepPin2B, LOW);
            delayMicroseconds(delayTime);
          }
        }
        delay(tStop);
      }
    }
  }
}
