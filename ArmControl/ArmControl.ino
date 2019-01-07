#include <AFMotor.h>
boolean NewSerial=false;
String inString = "";
String inStringRaw = "";
int Duration=0;
int DataRecievedState=0;

int MotorSpeeds[4] = {0,0,0,0}; // Note Motor0 is the Hand

int PressureSensorReading = 0;
int OptoCplSensorReading = 0;

AF_DCMotor motor0(1);
AF_DCMotor motor1(2);
AF_DCMotor motor2(3);
AF_DCMotor motor3(4);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
    Serial.begin(9600);
    Serial.println("ArmControlStart\n");
    // turn on motor
    RunMotors(0,0,0,0,0); // needed??
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void loop() {
    PressureSensorReading = analogRead(A5);
    OptoCplSensorReading = analogRead(A4);
    if (NewSerial) {
        NewSerial = false;
        RunMotors(MotorSpeeds[0],MotorSpeeds[1],MotorSpeeds[2],MotorSpeeds[3],Duration);
        if(MotorSpeeds[0] != 0) {
            Serial.print(PressureSensorReading);
            Serial.print("_");
            Serial.println(OptoCplSensorReading);
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void RunMotors(int m0, int m1, int m2, int m3, int dur) {
    int dir_polarity_0,dir_polarity_1,dir_polarity_2,dir_polarity_3;

    dir_polarity_0 = (m0>0)? FORWARD : (m0<0)? BACKWARD : RELEASE;
    dir_polarity_1 = (m1>0)? FORWARD : (m1<0)? BACKWARD : RELEASE;
    dir_polarity_2 = (m2>0)? FORWARD : (m2<0)? BACKWARD : RELEASE;
    dir_polarity_3 = (m3>0)? FORWARD : (m3<0)? BACKWARD : RELEASE;
    
    motor0.setSpeed(abs(m0));
    motor1.setSpeed(abs(m1));
    motor2.setSpeed(abs(m2));
    motor3.setSpeed(abs(m3));
    
    motor0.run(dir_polarity_0);
    motor1.run(dir_polarity_1);
    motor2.run(dir_polarity_2);
    motor3.run(dir_polarity_3);

    delay(dur);

    motor0.run(RELEASE);
    motor1.run(RELEASE);
    motor2.run(RELEASE);
    motor3.run(RELEASE);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void serialEvent() {
    int inChar;
    // Read serial input:
    inChar = Serial.read();
    inStringRaw += (char)inChar;
    // FSM
    if ((inChar == 'B')&&(DataRecievedState ==  0)) { // Begin
        DataRecievedState =  1;
    } else if ((inChar == '_')&&(DataRecievedState == 1)) { // Init for first int
        inString = ""; // Clear for int-str init
        DataRecievedState =  2;
    } else if ((inChar == 'E')&&(DataRecievedState == 7)) { // End
        NewSerial = true;
        inStringRaw = "";
        DataRecievedState = 0;
    } else {
        if ((isDigit(inChar))||(inChar == '-')) { // Valid int-char
            inString += (char)inChar;
        } else if ((inChar == '_')&&(inString.length() > 0)){ // int str terminator
            if(DataRecievedState == 6) Duration = inString.toInt();
            else                       MotorSpeeds[DataRecievedState-2] = inString.toInt();
            inString = ""; // For next use
            DataRecievedState =  DataRecievedState + 1;
        } else {
            Serial.println("ArmControlERROR:Serial_Pattern::" + inStringRaw);
            inStringRaw = "";
            DataRecievedState = 0;
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
