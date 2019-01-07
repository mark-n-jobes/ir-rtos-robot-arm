import processing.core.*; 
import processing.xml.*; 

import processing.serial.*; 
import lll.wrj4P5.*; 
import lll.Loc.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class ArmControlGUI extends PApplet {

float ScreenHeight = 768;//*0.8;
float ScreenWidth = 1024;//*0.8;
// Serial
int SerialEnabled = 1;
String inString = "";

Serial myPort;
// WiiRemote


int WiiRemoteEnabled = 1;
WiiPointList WiiRemote;
// Constraints
ConstraintsArrayList ConstraintsLinesArray = new ConstraintsArrayList();
Point ConstraintPoint;
int OneConstraintPointDrawn = 0;
// Arm
int MouseCanUpdatePoints = 0;
int PointMouseWillUpdate = 0;
ArmSegmentChain RobotArm = new ArmSegmentChain();
//-------------------------------------------------------------------------------//
public void setup() {
    size(floor(ScreenWidth),floor(ScreenHeight));
    // create a font with the third font available to the system:
    PFont myFont = createFont(PFont.list()[2], 20);
    textFont(myFont);
    // Serial
    if(SerialEnabled == 1) {
        println("Available ports are:");
        println(Serial.list());
        myPort = new Serial(this, Serial.list()[0], 9600);
    }
    // WiiRemote
    if(WiiRemoteEnabled == 1) WiiRemote = new WiiPointList(this,4);
    // Robot Arm
    RobotArm.InitPoints();
}
//-------------------------------------------------------------------------------//
public void draw() {
    //-----------Draw Prepare------------//
    background(0);
    if(RobotArm.ConstantPressureUpdate == 1) {
        RobotArm.ChangingHandState = 1; // To see echo
        myPort.write("B_1_0_0_0_1_E"); // To trigger the echo
    }
    // Update FeedBack Points
    if(WiiRemoteEnabled == 1) WiiRemote.UpdatePoints(ScreenWidth/3.f,ScreenHeight*2.f/3.f);
    //-----------Begin Draw------------//
    // WiiRemote
    WiiRemote.DrawAll(255,128,0);
    // RobotArm
    RobotArm.DrawAll(25,124,181);
    if(MouseCanUpdatePoints == 1) RobotArm.Points[PointMouseWillUpdate].DrawOX(0,255,0,40);
    // Constraints
    ConstraintsLinesArray.DrawAll(255,0,0);
    if(OneConstraintPointDrawn == 1) {
        stroke(0,0,255);
        fill(0,0,255);
        line(ConstraintPoint.X,ConstraintPoint.Y,mouseX,mouseY);
    }
    //---------- Movement ----------//
    if(RobotArm.EnableArmUpdate == 1) RobotArm.MoveTowardsAngles(WiiRemote.Angles, WiiRemote.ViolatingSegments, 3);
}
//-------------------------------------------------------------------------------//
public void mousePressed(){
    if(MouseCanUpdatePoints == 1) {
        RobotArm.Points[PointMouseWillUpdate] = new Point(mouseX,mouseY,20);
        RobotArm.BuildArmSegments();
    } else {

        WiiRemote.ExtraPoint = new Point(mouseX,mouseY,20);
        WiiRemote.PointMemorized = 4;
        // Append line to constraints or determin ConstraintPoint
        // if(OneConstraintPointDrawn == 0) {
            // OneConstraintPointDrawn = 1;
            // ConstraintPoint = new Point(mouseX,mouseY);
        // } else {
            // OneConstraintPointDrawn = 0;
            // Point ConstraintPoint_2 = new Point(mouseX,mouseY);
            // Line ConstraintLine = new Line(ConstraintPoint,ConstraintPoint_2);
            // ConstraintsLinesArray.add(ConstraintLine);
        // }
    }
}
//-------------------------------------------------------------------------------//
public void keyPressed() {
    // RobotArm related
    if     ((key == '1')&&(RobotArm.Motors[0] < 255))  RobotArm.Motors[0] += 5;
    else if((key == 'q')&&(RobotArm.Motors[0] > -255)) RobotArm.Motors[0] -= 5;
    else if((key == 'a'))                              RobotArm.Motors[0] = 0;
    else if((key == 'z'))                              RobotArm.Motors[0] *= -1;
    else if((key == '2')&&(RobotArm.Motors[1] < 255))  RobotArm.Motors[1] += 5;
    else if((key == 'w')&&(RobotArm.Motors[1] > -255)) RobotArm.Motors[1] -= 5;
    else if((key == 's'))                              RobotArm.Motors[1] = 0;
    else if((key == 'x'))                              RobotArm.Motors[1] *= -1;
    else if((key == '3')&&(RobotArm.Motors[2] < 255))  RobotArm.Motors[2] += 5;
    else if((key == 'e')&&(RobotArm.Motors[2] > -255)) RobotArm.Motors[2] -= 5;
    else if((key == 'd'))                              RobotArm.Motors[2] = 0;
    else if((key == 'c'))                              RobotArm.Motors[2] *= -1;
    else if((key == '4')&&(RobotArm.Motors[3] < 255))  RobotArm.Motors[3] += 5;
    else if((key == 'r')&&(RobotArm.Motors[3] > -255)) RobotArm.Motors[3] -= 5;
    else if((key == 'f'))                              RobotArm.Motors[3] = 0;
    else if((key == 'v'))                              RobotArm.Motors[3] *= -1;
    else if((key == CODED)&&(keyCode == RIGHT)&&(RobotArm.Duration < 1000)) RobotArm.Duration += 10;
    else if((key == CODED)&&(keyCode == LEFT)&&(RobotArm.Duration > 10))    RobotArm.Duration -= 10;
    else if((key == ']')&&(RobotArm.MagicDuration < 500))  RobotArm.MagicDuration += 10;
    else if((key == '[')&&(RobotArm.MagicDuration > 10))   RobotArm.MagicDuration -= 10;
    else if((key == '}')&&(RobotArm.MagicThreshold < 255)) RobotArm.MagicThreshold += 5;
    else if((key == '{')&&(RobotArm.MagicThreshold > 5))   RobotArm.MagicThreshold -= 5;
    else if((key == '+')&&(RobotArm.OnPressure < 255))     RobotArm.OnPressure += 5;
    else if((key == '-')&&(RobotArm.OnPressure > 5))       RobotArm.OnPressure -= 5;
    else if(key == ')') RobotArm.Damper += 0.25f;
    else if(key == '(') RobotArm.Damper -= 0.25f;
    else if(key == 'u') RobotArm.EnableArmUpdate = 1-RobotArm.EnableArmUpdate;
    else if(key == 'l') {
        for(int i=1;i<4;i++) RobotArm.Points[i] = new Point(WiiRemote.Points[i].X - WiiRemote.Points[0].X + RobotArm.Points[0].X,
                                                            WiiRemote.Points[i].Y - WiiRemote.Points[0].Y + RobotArm.Points[0].Y,
                                                            WiiRemote.Points[i].Z);
        RobotArm.BuildArmSegments();
    }
    else if(key == '>') RobotArm.CloseHand();
    else if(key == '<') RobotArm.OpenHand();
    else if(key == 'o') RobotArm.OpenHandSmallBit();
    else if(key == '?') RobotArm.ConstantPressureUpdate = 1-RobotArm.ConstantPressureUpdate;
    else if(key == '.') RobotArm.MoveTowardsAngles(WiiRemote.Angles, WiiRemote.ViolatingSegments, 3);
    else if((key == ' ')&&(SerialEnabled == 1)) RobotArm.RunMotors();
    else if(key == 'k') RobotArm.MoveTowardsPPP++;
    else if(key == 'K') RobotArm.MoveTowardsPPP=0;
    else if(key == 'g') RobotArm.AlignHandToPoint(WiiRemote.ExtraPoint,WiiRemote.Origin);
    else if(key == 'i') RobotArm.InitPoints();
    // WiiRemote related
    else if((key == CODED)&&(keyCode == UP))   WiiRemote.Scale *= 1.1f;
    else if((key == CODED)&&(keyCode == DOWN)) WiiRemote.Scale /= 1.1f;
    // Other related
    else if(key == 'z') OneConstraintPointDrawn = 0;
    else if(key == 'M') MouseCanUpdatePoints = 1-MouseCanUpdatePoints;
    else if(key == 'm') {
        if(PointMouseWillUpdate < 3) PointMouseWillUpdate++;
        else                         PointMouseWillUpdate=0;
    }
    else if(key == 'N') WiiRemote.PointMemorized = PointMouseWillUpdate;
    else if(key == 'n') WiiRemote.PointMemorized = -1;



    else if(key == 'h') WiiRemote.ExtraPoint = new Point(WiiRemote.ExtraPoint.X-2*(WiiRemote.ExtraPoint.X-RobotArm.Points[0].X),WiiRemote.ExtraPoint.Y,WiiRemote.ExtraPoint.Z);
}
//-------------------------------------------------------------------------------//
public void serialEvent(Serial myPort) {
    if(SerialEnabled == 1) {
        char inChar = (char)myPort.read();
        if(inChar != '\n') {
            inString += inChar;  // Keep reading until you hit a \n
        } else {
            if(RobotArm.ChangingHandState == 1) {
                // Convert string to int for Pressure
                int temp=0;
                for(int i=0;i<inString.length()-1;i++) {
                    temp *= 10;
                    char tempc = (char)inString.charAt(i);
                    if((tempc>='0')&&(tempc<='9')) temp += (int)(tempc - '0');
                    else if(tempc == '_') {
                        RobotArm.Pressure = temp/10;
                        temp = 0;
                    }
                }
                RobotArm.Openness += temp;
                RobotArm.Openness /= 2;
                if(RobotArm.DisplayStatus > 2) print("Changing Pressure and Openness to: " + RobotArm.Pressure + ", " + RobotArm.Openness);
            }
            // Regular echo
            println("SerialRead: " + inString);
            // Clear for next use
            inString = "";
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class WiiPointList {
    Point [] Points;
    int PointMemorized = -1;
    Point ExtraPoint = new Point(-10,-10);
    Point CurrRef = new Point(0,0);
    Point Origin = new Point(0,0);
    float [] Angles;
    boolean [] ViolatingSegments;
    int PointsDefined = 0;
    int numPoints = 0;
    Wrj4P5 Remote;
    int DisplayStatus = 1;
    float Scale = 1.f;
    ArmSegmentChain Arm;
    //------------------------------------------------------------------//
    WiiPointList(PApplet parent, int count) {
        this.Remote = new Wrj4P5(parent).connect(Wrj4P5.IR);
        this.numPoints = count;
        this.Points = new Point[count];
        for(int i=0;i<count;i++) this.Points[i] = new Point(0,0,0);
        this.Angles = new float[count-1];
        for(int i=0;i<count-1;i++) this.Angles[i] = 0;
        this.ViolatingSegments = new boolean[count-1];
        for(int i=0;i<count-1;i++) this.ViolatingSegments[i] = false;
        this.Arm = new ArmSegmentChain();
        this.Arm.Points = this.Points;
        this.Arm.Angles = this.Angles;
        this.Arm.DisplayStatus = 1;
    }
    //------------------------------------------------------------------//
    public void UpdatePoints(float X_origin, float Y_origin) {
        this.Origin = new Point(X_origin,Y_origin);
        this.PointsDefined = 1;
        for (int i=0;i<this.numPoints;i++) {
            Loc p=this.Remote.rimokon.irLights[i];
            if (p.x > -1) { // Valid point
                float x = p.x*640*this.Scale;
                float y = (1.f-p.y)*480*this.Scale;
                float z = p.z*120*this.Scale;
                if(i == this.PointMemorized) {  // Update memorized point
                    this.ExtraPoint = new Point(x,y,z);
                    this.ExtraPoint.SubtractOffset(this.CurrRef);
                    this.ExtraPoint.AddOffset(this.Origin);
                } else {
                    if(i == 0) {    // Update current ref
                        this.CurrRef = new Point(x,y,z);
                        this.Points[0] = new Point(X_origin,Y_origin,z);
                    } else {        // Update Point
                        this.Points[i] = new Point(x,y,z);
                        this.Points[i].SubtractOffset(this.CurrRef);
                        this.Points[i].AddOffset(this.Origin);
                    }
                }
            } else if(i != this.PointMemorized){    // ERROR
                this.Points[i].Z = 1;
                this.Points[i].DrawOX(255,0,0,60);
                this.Points[i].DrawO(255,0,0,40);
            } else {                // Lost memorized point
                this.Points[i].DrawOX(0,0,255,60);
            }
        }
        this.Arm.UpdateAngles();
        this.Arm.BuildArmSegments();
        // Now determin if any segments violate constraints
        for (int i=0;i<3;i++) {
            this.ViolatingSegments[i] = false;
            for (int j=0;j<4;j++) this.ViolatingSegments[i] |= (ConstraintsLinesArray.TestForIntersection(this.Arm.ArmLines[i*4+j]) > 0);
        }
    }
    //------------------------------------------------------------------//
    public void DrawAll(int r, int g, int b) {
        int i;
        stroke(r,g,b);
        fill  (r,g,b);
        if(this.PointsDefined == 1) {
            for (i=0;i<this.numPoints;i++) {
                if(i == this.PointMemorized) this.Points[i].DrawSq(255-r,255-g,255-b);
                else                         this.Points[i].DrawSq(r,g,b);
            }
            this.Arm.DrawAll(r,g,b);
        }
        if(this.PointMemorized != -1) {
            this.ExtraPoint.DrawOX(171,10,224,50);
            this.ExtraPoint.Print("Extra");
        }
    }
    //------------------------------------------------------------------//
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ArmSegmentChain {
    // Static Geometry
    float seg0_p0_distToEdge = 10;
    float seg0_p1_distToEdge = 10;
    float seg0_width = 20;
    float seg1_p0_distToEdge = 30;
    float seg1_p1_distToEdge = 10;
    float seg1_width = 60;
    float seg2_p0_distToEdge = 10;
    float seg2_p1_distToEdge = 80;
    float seg2_width = 30;
    // Arms
    int numPoints = 4;
    int numArmLines = 12;   // 3 Segments -> 3 Rects -> 12 Lines
    int ArmLinesDefined = 0;
    Line  [] ArmLines;
    Point [] Points;
    float [] Angles;
    float [] ArmLengths;
    // Motor Control
    int MoveTowardsPPP = 0;
    int EnableArmUpdate = 0;
    float [] MaxAngles = {180.f,315.f,200.f};
    float [] MinAngles = {45.f,45.f,155.f};
    int [] Motors = {0,0,0,0};
    int Duration = 0;
    float Damper = 3.5f;
    int MagicDuration = 40;
    int MagicThreshold = 90;
    // Hand Motor Control
    int ChangingHandState = 1;
    int ConstantPressureUpdate = 0;
    int OnPressure = 5;
    int Pressure = 0;
    int Openness = 0;
    // Debug
    int DisplayStatus = 2;
    //------------------------------------------------------------------//
    ArmSegmentChain() {
        this.ArmLines   = new Line[this.numArmLines];
        this.Points     = new Point[this.numPoints];
        this.Angles     = new float[this.numPoints-1];
        this.ArmLengths = new float[this.numPoints-1];
    }
    //------------------------------------------------------------------//
    public void InitPoints() {
        this.Points[0] = new Point(ScreenWidth*2.f/3.f,ScreenHeight*2.f/3.f,20);
        this.Points[1] = new Point(this.Points[0].X,this.Points[0].Y-118,20);
        this.Points[2] = new Point(this.Points[0].X,this.Points[1].Y-128,20);
        this.Points[3] = new Point(this.Points[0].X,this.Points[2].Y-47,20);
        this.BuildArmSegments();
    }
    //------------------------------------------------------------------//
    public void BuildArmSegments(){
        this.ArmLinesDefined = 1;
        this.UpdateAngles();
        this.BuildArmSegment(0,this.Points[0],this.Points[1],this.seg0_p0_distToEdge,this.seg0_p1_distToEdge,this.seg0_width);
        this.BuildArmSegment(1,this.Points[1],this.Points[2],this.seg1_p0_distToEdge,this.seg1_p1_distToEdge,this.seg1_width);
        this.BuildArmSegment(2,this.Points[2],this.Points[3],this.seg2_p0_distToEdge,this.seg2_p1_distToEdge,this.seg2_width);
    }
    //------------------------------------------------------------------//
    public void BuildArmSegment(int id, Point A, Point B, float A_distToEdge, float B_distToEdge, float Seg_width){
        // Make new 'origin'
        Point T = new Point(B.X-A.X,-(B.Y-A.Y)); // Note the -() is because: (height-B.Y-(height-A.Y))
        float length_AB = T.SqrtSumSq();
        float angle_AB = T.GetCurrentAngle();
        // Update CLASS internal vars:
        this.ArmLengths[id] = length_AB;
        // Build points as if angle where zero
        Point P0 = new Point(length_AB+B_distToEdge,Seg_width/2.0f);
        Point P1 = new Point(-A_distToEdge,Seg_width/2.0f);
        Point P2 = new Point(-A_distToEdge,-Seg_width/2.0f);
        Point P3 = new Point(length_AB+B_distToEdge,-Seg_width/2.0f);
        // Rotate points about 'origin' by angle
        P0.rotateCCWAboutOrigin(angle_AB);
        P1.rotateCCWAboutOrigin(angle_AB);
        P2.rotateCCWAboutOrigin(angle_AB);
        P3.rotateCCWAboutOrigin(angle_AB);
        // Return offset
        P0.AddOffset(A.X,A.Y);
        P1.AddOffset(A.X,A.Y);
        P2.AddOffset(A.X,A.Y);
        P3.AddOffset(A.X,A.Y);
        // Use points to make lines
        this.ArmLines[id*4+0] = new Line(P0,P1);
        this.ArmLines[id*4+1] = new Line(P1,P2);
        this.ArmLines[id*4+2] = new Line(P2,P3);
        this.ArmLines[id*4+3] = new Line(P3,P0);
    }
    //------------------------------------------------------------------//
    public void UpdateAngles() {
        Point Orig = new Point(this.Points[0].X + 100, this.Points[0].Y);
        this.Angles[0] = this.RelativeAngle(Orig,this.Points[0],this.Points[1]);
        this.Angles[1] = this.RelativeAngle(this.Points[0],this.Points[1],this.Points[2]);
        this.Angles[2] = this.RelativeAngle(this.Points[1],this.Points[2],this.Points[3]);
    }
    //------------------------------------------------------------------//
    public float RelativeAngle(Point A, Point B, Point C) {
        // Put B at the origin and translate A and C
        Point A_offset = new Point(A.X-B.X,A.Y-B.Y);
        Point C_offset = new Point(C.X-B.X,C.Y-B.Y);
        // Compute angle diff and return
        float AngleA = A_offset.GetCurrentAngle();
        float AngleC = C_offset.GetCurrentAngle();
        float temp = AngleA-AngleC;
        if(temp < 0) temp += 2.f*PI;
        return temp*180.f/PI;
    }
    //------------------------------------------------------------------//
    public void RunMotors() {
        String ToSend = "B_" + this.Motors[0] + "_" + this.Motors[1] + "_" + this.Motors[2] + "_" + this.Motors[3] + "_" + this.Duration + "_E";
        myPort.write(ToSend);
        if(this.DisplayStatus > 2) println("Serial Send: " + ToSend);
        delay(this.Duration);
    }
    //------------------------------------------------------------------//
    public void CloseHand() {
        int NumBursts=0;
        String ToSend = "B_128_0_0_0_20_E";
        this.ChangingHandState = 1;
        while((this.Pressure < this.OnPressure)&&(NumBursts < 80)) {
            myPort.write(ToSend);
            delay(40);
            NumBursts++;
        }
        println("Done CloseHand");
        this.ChangingHandState = 0;
    }
    //------------------------------------------------------------------//
    public void OpenHandSmallBit() {
        String ToSend = "B_-255_0_0_0_88_E";
        this.ChangingHandState = 1;
        myPort.write(ToSend);
        delay(100);
        this.ChangingHandState = 0;
    }
    //------------------------------------------------------------------//
    public void OpenHand() {
        int NumBursts=0;
        String ToSend = "B_-255_0_0_0_50_E";
        this.ChangingHandState = 1;
        do {
            myPort.write(ToSend);
            delay(100);
            NumBursts++;
        } while((this.Pressure > 0)&&(NumBursts < 5));

        NumBursts = 0;
        ToSend = "B_-128_0_0_0_30_E";
        while((this.Openness > 8)&&(NumBursts < 40)) {
            myPort.write(ToSend);
            delay(100);
            NumBursts++;
        }
        println("Done OpenHand");
        this.ChangingHandState = 0;
    }
    //------------------------------------------------------------------//
    public void MoveTowardsAngles(float [] FeedbackAngles, boolean [] Violators, int numAngles) {
        if(this.MoveTowardsPPP == 1) {
            float [] PreProgramedPosition = {90,180,180};
            RobotArm.MoveTowardsAngles(PreProgramedPosition,WiiRemote.Angles, WiiRemote.ViolatingSegments, 3);
        } else if(this.MoveTowardsPPP == 2) {
            float [] PreProgramedPosition = {51,312,164};
            RobotArm.MoveTowardsAngles(PreProgramedPosition,WiiRemote.Angles, WiiRemote.ViolatingSegments, 3);
        } else if(this.MoveTowardsPPP == 3) {
            float [] PreProgramedPosition = {126,53,185};
            RobotArm.MoveTowardsAngles(PreProgramedPosition,WiiRemote.Angles, WiiRemote.ViolatingSegments, 3);
        } else if(this.MoveTowardsPPP == 4) {
            float [] PreProgramedPosition = {156,207,161};
            RobotArm.MoveTowardsAngles(PreProgramedPosition,WiiRemote.Angles, WiiRemote.ViolatingSegments, 3);
        } else {
            this.MoveTowardsAngles(this.Angles,FeedbackAngles,Violators,numAngles);
        }
    }
    public void MoveTowardsAngles(float [] DestAngles, float [] FeedbackAngles, boolean [] Violators, int numAngles) {
        int RunMotorsIsWorthIt = 0;
        float [] DeltaAngles = {0,0,0};
        int MaxDeltaIndex = 0;
        for(int i=0;i<numAngles;i++) {
            // Get delta angle in and clip to static limits
            float DestAngleClipped = DestAngles[i];
            if(DestAngleClipped > this.MaxAngles[i]) DestAngleClipped = this.MaxAngles[i];
            if(DestAngleClipped < this.MinAngles[i]) DestAngleClipped = this.MinAngles[i];
            DeltaAngles[i] = DestAngleClipped - FeedbackAngles[i];
            if(DeltaAngles[i] > DeltaAngles[MaxDeltaIndex]) MaxDeltaIndex = i;
        }
        for(int i=0;i<numAngles;i++) {
            // Angle->Motor function
            this.Motors[i+1] = (int)(DeltaAngles[i]*255.f/this.Damper);
            // an attempt to finish all angles at the same time (still doesn't work, but better)
            // if(i == MaxDeltaIndex) this.Motors[i+1] /= 2;
            // else                   this.Motors[i+1] *= 2;
            // Clip Motor speeds
            if(this.Motors[i+1] >  255) this.Motors[i+1] =  255;
            if(this.Motors[i+1] < -255) this.Motors[i+1] = -255;
        }
        // Now to apply violation correction
        boolean Violation = false;
        for(int i=numAngles-1;i>=0;i--) {
            Violation |= Violators[i];
            if(Violation) this.Motors[i+1] *= -0.5f;
        }
        // Determin if it's all even worth it
        for(int i=0;i<numAngles;i++) {
            if(abs(this.Motors[i+1]) > this.MagicThreshold) RunMotorsIsWorthIt = 1;
        }
        RobotArm.Motors[0] = 0; // Only used in Hand Open/Close
        RobotArm.Duration = this.MagicDuration;
        if(RunMotorsIsWorthIt == 1) RobotArm.RunMotors();
    }
    //------------------------------------------------------------------//
    public void AlignHandToPoint(Point In, Point Origin) {
        // Copy the point and re-offset to be relative to this arm's Origin (i.e. Points[0])
        Point AdjustedIn = new Point(In.X,In.Y,In.Z);
        // AdjustedIn.SubtractOffset(Origin);
        // float Side = (AdjustedIn.X>0)? -1. : 1.;
        float Side = (AdjustedIn.X>this.Points[0].X)? -1.f : 1.f;
        // AdjustedIn.AddOffset(this.Points[0]);
        // Make furthest point along the arm have the same Y as the AdjustedIn
        // Point NewP3 = new Point(AdjustedIn.X+Side*this.seg2_p1_distToEdge, AdjustedIn.Y, this.Points[3].Z);
        // Make the next point down @ 180deg (extending away from AdjustedIn)
        // Point NewP2 = new Point(NewP3.X+Side*this.ArmLengths[2], 0.0, this.Points[2].Z);
        Point NewP3 = new Point(AdjustedIn.X+Side*this.seg2_p1_distToEdge, AdjustedIn.Y, this.Points[3].Z);
        Point NewP2 = new Point(NewP3.X+Side*this.ArmLengths[2], NewP3.Y, this.Points[2].Z);
        // AdjustedIn.SubtractOffset(this.Points[0]);
        // NewP3.SubtractOffset(this.Points[0]);
        // NewP2.SubtractOffset(this.Points[0]);
        // Point NewP1 = new Point(this.Points[1].X,this.Points[1].Y);
        // NewP1.SubtractOffset(this.Points[0]);
        // Solve for the last point (because the base can't move, Points[0] will be unchanged)
        float Dist_P2P0 = NewP2.RelativeDist(this.Points[0]);
        // float Dist_P2P0 = NewP2.SqrtSumSq();
        if(Dist_P2P0 < (this.ArmLengths[1]+this.ArmLengths[0])) { // Then easy solution exists
            // Get Point2's angle relative to Point0 and the axis there
            Point temp = new Point(this.Points[0].X + 1000, this.Points[0].Y);
            float AngleToPoint2 = this.RelativeAngle(temp,this.Points[0],NewP2)*PI/180;
            // Get the angle of the triangle (P0.P1.P2) at P2
            float AngleForPoint2 = acos((this.ArmLengths[1]*this.ArmLengths[1]+Dist_P2P0*Dist_P2P0-this.ArmLengths[0]*this.ArmLengths[0]) / (2*this.ArmLengths[1]*Dist_P2P0));
            // Place P1 on x-axis and rotate CW to build X,Y values (relative to P2)
            Point NewP1 = new Point(this.ArmLengths[1], 0.0f, this.Points[1].Z);
            // NewP1.rotateCWAboutOrigin(Side*(PI-AngleToPoint2-AngleForPoint2)); // Note the 'origin' is NewP2
            float rotateAngle = (PI-AngleToPoint2-AngleForPoint2);
            // if(rotateAngle < 0) rotateAngle += 2*PI;
            if(Side == -1) rotateAngle += PI/4;
            NewP1.rotateCWAboutOrigin(rotateAngle); // Note the 'origin' is NewP2
            // Offset back to where it should be
            NewP1.AddOffset(NewP2);
            // NewP3.AddOffset(this.Points[0]);
            // NewP2.AddOffset(this.Points[0]);
            // NewP1.AddOffset(this.Points[0]);
            // Now to update the points
            this.Points[3] = new Point(NewP3.X,NewP3.Y);
            this.Points[2] = new Point(NewP2.X,NewP2.Y);
            this.Points[1] = new Point(NewP1.X,NewP1.Y);
            // Debug
            println("Got: Side:" + Side + " AngleToPoint2:" + AngleToPoint2*180/PI + " AngleForPoint2:" + AngleForPoint2*180/PI + " rotateAngle:" + rotateAngle*180/PI);
        } else {
            println("Impossibly grabbable Extra point! " + Dist_P2P0 + " >= " + (this.ArmLengths[1]+this.ArmLengths[0]));
        }
        
        // AdjustedIn.DrawOX(25,124,181,50);
        // AdjustedIn.Print("Extra_rel");
        // delay(1000);
        // AdjustedIn.Print("Extra_rel");
        this.BuildArmSegments();
    }
    //------------------------------------------------------------------//
    public void DrawAll(int r, int g, int b) {
        if(this.ArmLinesDefined == 1) {
            for (int i=0;i<this.numArmLines;i++) {
                this.ArmLines[i].DrawLine(r,g,b);
            }
        }
        if(this.DisplayStatus >= 1) this.DebugInfo(r,g,b);
    }
    //------------------------------------------------------------------//
    // DEBUG
    public void DebugInfo(int r, int g, int b) {
        stroke(r,g,b);
        fill  (r,g,b);
        // Points, Angles
        for (int i=0;i<this.numPoints-1;i++) {
            this.Points[i].PrintID(i);
            this.Points[i].DrawSq(r,g,b);
            // text("   Angle" + i + ":" + this.Angles[i], this.Points[i].X,this.Points[i].Y);
        }
        this.Points[this.numPoints-1].PrintID(this.numPoints-1);
        this.Points[this.numPoints-1].DrawSq(r,g,b);
        if(this.DisplayStatus > 1) {
            // Motors:
            text("M0(" + this.Motors[0] + "), M1(" + this.Motors[1] + "), M2(" + this.Motors[2] + "), M3(" + this.Motors[3] + "), Duration(" + this.Duration + ")", 0, height-20);
            // Settings:
            text("Damper:" + this.Damper + "  MagicThreshold:" + this.MagicThreshold + "  MagicDuration:" + this.MagicDuration, 0, height-40);
            text("EnableArmUpdate:" + this.EnableArmUpdate, 0, height-60);
            text("Pressure:" + this.Pressure + "  Openness:" + this.Openness + "  OnPressure:" + this.OnPressure, 0, height-80);
            text("ConstantPressureUpdate:" + this.ConstantPressureUpdate, 0, height-100);
            text("MoveTowardsPreprogramedPosition:" + this.MoveTowardsPPP, 0, height-120);
        }
        if(this.DisplayStatus > 0) {
            for (int i=0;i<this.numPoints-1;i++) {
                text("   Line" + i + ":" + this.ArmLengths[i],
                    (this.Points[i].X+this.Points[i+1].X)/2.0f,
                    (this.Points[i].Y+this.Points[i+1].Y)/2.0f);
            }
        }
    }
    //------------------------------------------------------------------//
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ConstraintsArrayList extends ArrayList {
    int ErrorOn = 0;
    //------------------------------------------------------------------//
    public Line Pop(int index) {
        if(this.size()>index) {
            Line ToReturn;
            ToReturn = (Line)this.get(index);
            this.remove(index);
            return ToReturn;
        } else {
            return (Line)null;
        }
    }
    //------------------------------------------------------------------//
    public int TestForIntersection(Line In) {
        ErrorOn = 0; // Assume pass
        for(int i=0;i<this.size();i++) {
            if(In.Intersects((Line)this.get(i))) {
                ErrorOn++;
                break;
            }
        }
        return ErrorOn;
    }
    public int TestForIntersection(Line[] In, int size) {
        ErrorOn = 0; // Assume pass
        for(int i=0;i<this.size();i++) {
            for(int j=0;j<size;j++) {
                if(In[j].Intersects((Line)this.get(i))) {
                    ErrorOn++;
                    break;
                }
            }
        }
        return ErrorOn;
    }
    //------------------------------------------------------------------//
    public void DrawAll(int r, int g, int b) {
        for(int i=0;i<this.size();i++) ((Line)this.get(i)).DrawLine(r,g,b);
        if(ErrorOn > 0) {
            Point ERROR = new Point(width/2,height/2);
            ERROR.DrawX( r,g,b,100);
            ERROR.DrawSq(r,g,b,50);
        }
    }
    //------------------------------------------------------------------//
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Line {
    Point A,B;
    //------------------------------------------------------------------//
    Line(Point a, Point b) {
        this.A = new Point(a.X,a.Y);
        this.B = new Point(b.X,b.Y);
    }
    //------------------------------------------------------------------//
    public float LineLength() {
        return sqrt((this.A.X-this.B.X)*(this.A.X-this.B.X)+(this.A.Y-this.B.Y)*(this.A.Y-this.B.Y));
    }
    //------------------------------------------------------------------//
    public boolean Intersects(Line In) {
        return ((this.DeltaSlopeTest(In.A)^this.DeltaSlopeTest(In.B))&&(In.DeltaSlopeTest(this.A)^In.DeltaSlopeTest(this.B)));
    }
    //------------------------------------------------------------------//
    public boolean DeltaSlopeTest(Point In) {
        return (((In.Y-A.Y)*(B.X-A.X))>((B.Y-A.Y)*(In.X-A.X)));
    }
    //------------------------------------------------------------------//
    public void DrawLine(int r, int g, int b) {
        stroke(r,g,b);
        fill  (r,g,b);
        line(this.A.X,this.A.Y,this.B.X,this.B.Y);
    }
    //------------------------------------------------------------------//
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Point {
    float X,Y,Z; // Z is used for points' intensity
    //------------------------------------------------------------------//
    Point(float x, float y) {
        this.X = x;
        this.Y = y;
        this.Z = 0;
    }
    Point(float x, float y, float z) {
        this.X = x;
        this.Y = y;
        this.Z = z;
    }
    //------------------------------------------------------------------//
    public void rotateCWAboutOrigin(float Angle) {
        this.rotateCCWAboutOrigin((2*PI)-Angle);
    }
    //------------------------------------------------------------------//
    public void rotateCCWAboutOrigin(float Angle) {
        float tempLength = this.SqrtSumSq();
        float currentAngle = this.GetCurrentAngle();
        float NewX = tempLength*cos(currentAngle-Angle);
        float NewY = tempLength*sin(currentAngle-Angle);
        this.X = NewX;
        this.Y = NewY;
    }
    //------------------------------------------------------------------//
    public void AddOffset(Point Offset) {
        this.X += Offset.X;
        this.Y += Offset.Y;
    }
    public void AddOffset(float X_offset, float Y_offset) {
        this.X += X_offset;
        this.Y += Y_offset;
    }
    //------------------------------------------------------------------//
    public void SubtractOffset(Point Offset) {
        this.X -= Offset.X;
        this.Y -= Offset.Y;
    }
    public void SubtractOffset(float X_offset, float Y_offset) {
        this.X -= X_offset;
        this.Y -= Y_offset;
    }
    //------------------------------------------------------------------//
    public float SqrtSumSq() {
        return sqrt((this.X*this.X)+(this.Y*this.Y));
    }
    //------------------------------------------------------------------//
    public float RelativeDist(Point Ref) {
        return sqrt(((this.X-Ref.X)*(this.X-Ref.X))+((this.Y-Ref.Y)*(this.Y-Ref.Y)));
    }
    //------------------------------------------------------------------//
    public float GetCurrentAngle() {
        float result = abs(atan(this.Y/this.X));
        if ((this.X < 0)&&(this.Y < 0)) {
            result += PI;
        } else if (this.X < 0) {
            result = PI - result;
        } else if (this.Y < 0) {
            result = -result;
        }
        return result;
    }
    //------------------------------------------------------------------//
    public void DrawX(int r, int g, int b) {
        stroke(r,g,b);
        line(this.X-this.Z/2,this.Y-this.Z/2,this.X+this.Z/2,this.Y+this.Z/2);
        line(this.X-this.Z/2,this.Y+this.Z/2,this.X+this.Z/2,this.Y-this.Z/2);
    }
    public void DrawX(int r, int g, int b, float Height) {
        stroke(r,g,b);
        Height/=2; // Scale once in begining is more efficient, but I guess no scale is better :)
        line(this.X-Height,this.Y-Height,this.X+Height,this.Y+Height);
        line(this.X-Height,this.Y+Height,this.X+Height,this.Y-Height);
    }
    //------------------------------------------------------------------//
    public void DrawO(int r, int g, int b) {
        stroke(r,g,b);
        fill  (r,g,b);
        ellipse(this.X,this.Y,this.Z,this.Z);
    }
    public void DrawO(int r, int g, int b, float Radius) {
        stroke(r,g,b);
        fill  (r,g,b);
        ellipse(this.X,this.Y,Radius,Radius);
    }
    //------------------------------------------------------------------//
    public void DrawOX(int r, int g, int b) {
        stroke(r,g,b);
        noFill();
        ellipse(this.X,this.Y,this.Z,this.Z);
        this.DrawX(r,g,b);
    }
    public void DrawOX(int r, int g, int b, float Radius) {
        stroke(r,g,b);
        noFill();
        ellipse(this.X,this.Y,Radius,Radius);
        this.DrawX(r,g,b,Radius);
    }
    //------------------------------------------------------------------//
    public void DrawSq(int r, int g, int b) {
        stroke(r,g,b);
        fill  (r,g,b);
        rect(this.X-this.Z/4,this.Y-this.Z/4,this.Z/2,this.Z/2);
    }
    public void DrawSq(int r, int g, int b, float Height) {
        stroke(r,g,b);
        fill  (r,g,b);
        Height/=2; // Scale once in begining is more efficient, but I guess no scale is better :)
        rect(this.X-Height/2,this.Y-Height/2,Height,Height);
    }
    //------------------------------------------------------------------//
    public void PrintID(int ID) {
        text("ID:" + ID, this.X-20,this.Y-20);
    }
    //------------------------------------------------------------------//
    public void Print(String InStr) {
        text(InStr, this.X-InStr.length()*6,this.Y-20);
    }
    //------------------------------------------------------------------//
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "ArmControlGUI" });
  }
}
