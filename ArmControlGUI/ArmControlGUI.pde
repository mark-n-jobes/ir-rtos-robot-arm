//-------------------------------------------------------------------------------//
// Global
float ScreenHeight = 768*.9;
float ScreenWidth  = 1024*1.75;
boolean SomethingWentWrong = false;
// Serial
boolean SerialEnabled = true;
String inString = "";
import processing.serial.*;
Serial myPort;
// WiiRemote
import lll.wrj4P5.*;
import lll.Loc.*;
boolean WiiRemoteEnabled = true;
WiiPointList WiiRemote;
// Constraints
ConstraintsArrayList ConstraintsLinesArray = new ConstraintsArrayList();
Point ConstraintPoint;
boolean OneConstraintPointDrawn = false;
// Arm
boolean ArmStarted = false;
boolean AutoAlignArmPointsToExtra = false;
boolean MouseCanUpdatePoints = false;
int PointMouseWillUpdate = 0;
ArmSegmentChain RobotArm = new ArmSegmentChain();
// Debug
Point TestPoint = new Point(-100,-100);
//-------------------------------------------------------------------------------//
void setup() {
    size(floor(ScreenWidth),floor(ScreenHeight));
    // create a font with the third font available to the system:
    PFont myFont = createFont(PFont.list()[2], 20);
    textFont(myFont);
    // Serial
    if(SerialEnabled) {
        println("Available ports are:");
        println(Serial.list());
        myPort = new Serial(this, Serial.list()[0], 9600);
    }
    // WiiRemote
    if(WiiRemoteEnabled) WiiRemote = new WiiPointList(this,4);
    else                 WiiRemote = new WiiPointList(ScreenWidth*2./3.,ScreenHeight*2./3.); // 2 float Args is for a skelleton (they make origin)
    // Robot Arm
    RobotArm.InitPoints();
}
//-------------------------------------------------------------------------------//
void draw() {
    //-----------Draw Prepare------------//
    background(0);
    if(RobotArm.ConstantPressureUpdate) {
        RobotArm.ChangingHandState = true; // To see echo
        myPort.write("B_1_0_0_0_1_E"); // To trigger the echo
    }
    if(keyPressed && (key == 'E')) {
        WiiRemote.ExtraPoint = new Point(mouseX,mouseY,20);
        WiiRemote.PointMemorized = 4;
    }
    // Update FeedBack Points
    if(WiiRemoteEnabled) WiiRemote.UpdatePoints(ScreenWidth/3.,ScreenHeight);//*2./3.);
    // Update RobotArm Points if needed
    if(AutoAlignArmPointsToExtra) RobotArm.AlignHandToPoint(WiiRemote.ExtraPoint,WiiRemote.Origin);
    //-----------Begin Draw------------//
    strokeWeight(16);
    // WiiRemote
    WiiRemote.DrawAll(255,128,0);
    // RobotArm
    RobotArm.DrawAll(25,124,181);
    if(MouseCanUpdatePoints) RobotArm.Points[PointMouseWillUpdate].DrawOX(0,255,0,40);
    // Constraints
    ConstraintsLinesArray.DrawAll(255,0,0);
    if(OneConstraintPointDrawn) {
        stroke(0,0,255);
        fill(0,0,255);
        line(ConstraintPoint.X,ConstraintPoint.Y,mouseX,mouseY);
    }
    TestPoint.DrawOX(0,255,0,40);

    //---------- Global Settings Echo ----------//
    stroke(69,88,148);
    fill(  69,88,148);
    text("AutoAlignArmPointsToExtra:" + AutoAlignArmPointsToExtra,20,20);
    if(SomethingWentWrong) {
        stroke(255,0,0);
        fill(  255,0,0);
        text("SomethingWentWrong!",20,50);
    }
    //---------- Movement ----------//
    if(RobotArm.EnableArmUpdate&&(!SomethingWentWrong)) RobotArm.MoveTowardsAngles(WiiRemote.Angles, WiiRemote.ViolatingSegments, 3);
}
//-------------------------------------------------------------------------------//
void mousePressed(){
    if(MouseCanUpdatePoints) {
        RobotArm.Points[PointMouseWillUpdate] = new Point(mouseX,mouseY,20);
        RobotArm.BuildArmSegments();
    } else {
        if(keyPressed && key=='C') { // Draw constriant point
            // Append line to constraints or determin ConstraintPoint
            if(!OneConstraintPointDrawn) {
                OneConstraintPointDrawn = true;
                ConstraintPoint = new Point(mouseX,mouseY);
            } else {
                OneConstraintPointDrawn = false;
                Point ConstraintPoint_2 = new Point(mouseX,mouseY);
                Line ConstraintLine = new Line(ConstraintPoint,ConstraintPoint_2);
                ConstraintsLinesArray.add(ConstraintLine);
            }
        } else {
            TestPoint = new Point(mouseX,mouseY,20);
        }
    }
}
//-------------------------------------------------------------------------------//
void keyPressed() {
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
    else if((key == ' ')&&SerialEnabled)                   RobotArm.RunMotors();
    else if((key == ']')&&(RobotArm.MagicDuration < 500))  RobotArm.MagicDuration += 10;
    else if((key == '[')&&(RobotArm.MagicDuration > 10))   RobotArm.MagicDuration -= 10;
    else if((key == '}')&&(RobotArm.MagicThreshold < 255)) RobotArm.MagicThreshold += 5;
    else if((key == '{')&&(RobotArm.MagicThreshold > 5))   RobotArm.MagicThreshold -= 5;
    else if((key == '+')&&(RobotArm.OnPressure < 255))     RobotArm.OnPressure += 5;
    else if((key == '-')&&(RobotArm.OnPressure > 5))       RobotArm.OnPressure -= 5;
    else if((key == CODED)&&(keyCode == RIGHT)&&(RobotArm.Duration < 1000)) RobotArm.Duration += 10;
    else if((key == CODED)&&(keyCode == LEFT)&&(RobotArm.Duration > 10))    RobotArm.Duration -= 10;
    else if(key == ')')  RobotArm.Damper += 0.25;
    else if(key == '(')  RobotArm.Damper -= 0.25;
    else if(key == 'i')  RobotArm.InitPoints();
    else if(key == 'l')  RobotArm.SetPoints(WiiRemote.Points,WiiRemote.Arm.seg2_p1_distToEdge);
    else if(key == '>')  RobotArm.CloseHand();
    else if(key == '<')  RobotArm.OpenHand();
    else if(key == 'o')  RobotArm.OpenHandSmallBit();
    else if(key == '.')  RobotArm.MoveTowardsAngles(WiiRemote.Angles, WiiRemote.ViolatingSegments, 3);
    else if(key == 'k')  RobotArm.MoveTowardsPPP = (RobotArm.MoveTowardsPPP+1)%5;
    else if(key == 'K')  RobotArm.MoveTowardsPPP = (RobotArm.MoveTowardsPPP+4)%5;  // Cuz 4==-1  %5
    else if(key == '?')  RobotArm.ConstantPressureUpdate = !RobotArm.ConstantPressureUpdate;
    else if(key == 'u')  RobotArm.EnableArmUpdate = !RobotArm.EnableArmUpdate;
    else if(key == '\'') RobotArm.MassageAngles = !RobotArm.MassageAngles;
    // WiiRemote related
    else if((key == CODED)&&(keyCode == UP))   WiiRemote.Scale *= 1.1;
    else if((key == CODED)&&(keyCode == DOWN)) WiiRemote.Scale /= 1.1;
    else if(key == 'N')                        WiiRemote.PointMemorized = PointMouseWillUpdate;
    else if(key == 'n')                        WiiRemote.PointMemorized = -1;
    else if(key == 'O')                        WiiRemote.PointMemorized = 0;
    else if(key == 'h')                        WiiRemote.ExtraPoint = new Point(WiiRemote.ExtraPoint.X-2*(WiiRemote.ExtraPoint.X-RobotArm.Points[0].X),WiiRemote.ExtraPoint.Y,WiiRemote.ExtraPoint.Z);
    // Other related
    else if(key == '=') AutoAlignArmPointsToExtra = !AutoAlignArmPointsToExtra;
    else if(key == 'W') SomethingWentWrong = false;
    else if(key == 'Z') OneConstraintPointDrawn = false;
    else if(key == 'M') MouseCanUpdatePoints = !MouseCanUpdatePoints;
    else if(key == 'm') {
        if(PointMouseWillUpdate < 3) PointMouseWillUpdate++;
        else                         PointMouseWillUpdate=0;
    }
}
//-------------------------------------------------------------------------------//
void serialEvent(Serial myPort) {
    if(SerialEnabled) {
        char inChar = (char)myPort.read();
        if(inChar != '\n') {
            inString += inChar;  // Keep reading until you hit a \n
        } else {
            if(inString.equals("ArmControlStart")) {
                if(ArmStarted) SomethingWentWrong = true; // Only could see twice+ if reset button hit
                else           ArmStarted = true;
            }
            if(RobotArm.ChangingHandState) {
                // Convert string to int for Pressure
                int [] ParsedInts = ParseIntegerString(inString,'_',2);
                if(ParsedInts[0] == 2) { // There should only be two ints in the string
                    RobotArm.Pressure = ParsedInts[1];
                    RobotArm.Openness = ParsedInts[2];
                    if(RobotArm.DisplayStatus > 2) print("Changing Pressure and Openness to: " + RobotArm.Pressure + ", " + RobotArm.Openness);
                }
            }
            // Regular echo
            println("SerialRead: " + inString);
            // Clear for next use
            inString = "";
        }
    }
}
//-------------------------------------------------------------------------------//
int [] ParseIntegerString(String Input, char Spacer, int numInts) { // Note that returned[0] is the count of integers found
    int [] Buffer = new int[numInts+1]; // numInts + [0] holding the count
    int [] ToReturn;
    int index=1;    // Start at first int
    Buffer[0] = 0; // Start with nothine, invalid==-1
    int temp=0;
    for(int i=0;i < Input.length();i++) {
        char tempc = 0;
        if(i != Input.length()-1) tempc = (char)Input.charAt(i);
        if((tempc>='0')&&(tempc<='9')) {
            temp *= 10; // Base10 shift of accumulator
            temp += (int)(tempc - '0');  // Collect
        } else if((tempc == Spacer)||(tempc == 0)||(index == numInts)) {
            if(index > numInts) {
                index--; // So the right value get's passed on
                break;   // Don't care about any other ints
            } else {
                Buffer[index] = temp;
                temp = 0;
                index++;
            }
        } else {
            println("ParseIntegerString::ERROR:: bad char:" + tempc);
            Buffer[0] = -1;
            break;
        }
    }
    if(Buffer[0] == -1) {
        ToReturn = new int[1];
        ToReturn[0] = -1;
        println("ParseIntegerString::ERROR Occured:");
    } else {
        Buffer[0] = index-1;
        ToReturn = new int[numInts+1]; // index ints + count
        for(int i=0;i < numInts+1;i++) ToReturn[i] = Buffer[i];
        // println("ParseIntegerString::Got this many ints::" + index);
    }
    return ToReturn;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class WiiPointList {
    Point [] Points;
    int PointMemorized = -1;
    Point ExtraPoint = new Point(-10,-10);
    Point CurrRef = new Point(0,0);
    Point Origin = new Point(0,0);
    boolean PointsDefined = false;
    int numPoints = 0;
    float [] Angles;
    float AngleFlex = 30;   // Remember to try to reduce this and see how picky it gets
    boolean [] ViolatingSegments;
    boolean RemoteConnected = false;
    boolean RelativeExtraDistSet = false;
    Wrj4P5 Remote;
    int DisplayStatus = 1;//1;
    float Scale = 1.5;
    ArmSegmentChain Arm;
    //------------------------------------------------------------------//
    WiiPointList(PApplet parent, int count) {
        this.Remote = new Wrj4P5(parent).connect(Wrj4P5.IR);
        this.numPoints = count;
        this.Points = new Point[count];
        for(int i=0;i < count;i++) this.Points[i] = new Point(0,0,0);
        this.Angles = new float[count-1];
        for(int i=0;i < count-1;i++) this.Angles[i] = 0;
        this.ViolatingSegments = new boolean[count-1];
        for(int i=0;i < count-1;i++) this.ViolatingSegments[i] = false;
        this.Arm = new ArmSegmentChain();
        this.Arm.Points = this.Points;
        this.Arm.Angles = this.Angles;
        this.Arm.DisplayStatus = this.DisplayStatus;
    }
    WiiPointList(float x, float y) {
        this.Origin = new Point(x,y);
        this.numPoints = 0;
    }
    //------------------------------------------------------------------//
    void UpdatePoints(float X_origin, float Y_origin) {
        if(!this.RemoteConnected) {
            if(!this.Remote.isConnecting()) {
                this.RemoteConnected = true;
                println("WiiRemote connected!");
            }
        } else {
            this.PointsDefined = true;
            this.Origin = new Point(X_origin,Y_origin);
            for (int i=0;i < this.numPoints;i++) {
                Loc p=this.Remote.rimokon.irLights[i];
                if (p.x > -1) { // Valid point
                    float x = p.x*640*this.Scale;
                    float y = (1.-p.y)*480*this.Scale;
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
                    SomethingWentWrong = true;
                } else {                // Lost memorized point
                    this.Points[i].DrawOX(0,0,255,60);
                }
            }
            if(!this.RelativeExtraDistSet) {
                this.Arm.seg2_p1_distToEdge = 2*this.Points[3].RelativeDist(this.Points[2]);
                this.RelativeExtraDistSet = true;
            }
            this.Arm.UpdateAngles();
            for (int i=0;i<3;i++) if((this.Arm.Angles[i]>(this.Arm.MaxAngles[i]+this.AngleFlex))||(this.Arm.Angles[i]<(this.Arm.MinAngles[i]-this.AngleFlex))) SomethingWentWrong = true;
            this.Arm.BuildArmSegments();
            // Now determin if any segments violate constraints
            for (int i=0;i<3;i++) {
                this.ViolatingSegments[i] = false;
                for (int j=0;j<4;j++) this.ViolatingSegments[i] |= (ConstraintsLinesArray.TestForIntersection(this.Arm.ArmLines[i*4+j]) > 0);
            }
        }
    }
    //------------------------------------------------------------------//
    void DrawAll(int r, int g, int b) {
        int i;
        stroke(r,g,b);
        fill  (r,g,b);
        if(this.PointsDefined) {
            this.Arm.DrawAll(r,g,b);
            for (i=0;i < this.numPoints;i++) {
                if(i == this.PointMemorized) this.Points[i].DrawSq(255-r,255-g,255-b);
                else                         this.Points[i].DrawSq(r,g,b);
            }
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
    float seg2_p1_distToEdge = 120;
    float seg2_width = 30;
    // Arms
    int numPoints = 4;
    int numArmLines = 12;   // 3 Segments -> 3 Rects -> 12 Lines
    boolean ArmLinesDefined = false;
    Line  [] ArmLines;
    Point [] Points;
    float [] Angles;
    float [] ArmLengths;
    boolean MassageAngles = true;
    // Motor Control
    int MoveTowardsPPP = 0;
    boolean EnableArmUpdate = false;
    float [] MaxAngles = {180.,315.,200.};
    float [] MinAngles = {45.,45.,155.};
    int [] Motors = {0,0,0,0};
    int Duration = 0;
    float Damper = 3.5;
    int MagicDuration = 40;
    int MagicThreshold = 90;
    // Hand Motor Control
    boolean ChangingHandState = false;
    boolean ConstantPressureUpdate = false;
    int OnPressure = 5;
    int Pressure = 0;
    int Openness = 0;
    // Debug
    int DisplayStatus = 2;//3;
    //------------------------------------------------------------------//
    ArmSegmentChain() {
        this.ArmLines   = new Line[this.numArmLines];
        this.Points     = new Point[this.numPoints];
        this.Angles     = new float[this.numPoints-1];
        this.ArmLengths = new float[this.numPoints-1];
    }
    //------------------------------------------------------------------//
    void SetPoints(Point [] In, float HandLength) {
        for(int i=1;i<4;i++) {
            this.Points[i] = new Point(In[i].X - In[0].X + this.Points[0].X,
                                       In[i].Y - In[0].Y + this.Points[0].Y,
                                       In[i].Z);
        }
        this.seg2_p1_distToEdge = HandLength;
        this.BuildArmSegments();
    }
    //------------------------------------------------------------------//
    void InitPoints() {
        this.Points[0] = new Point(ScreenWidth*2./3.,ScreenHeight/**2./3.*/,20);
        this.Points[1] = new Point(this.Points[0].X,this.Points[0].Y-160,20);
        this.Points[2] = new Point(this.Points[0].X,this.Points[1].Y-167,20);
        this.Points[3] = new Point(this.Points[0].X,this.Points[2].Y-62,20);
        this.BuildArmSegments();
    }
    //------------------------------------------------------------------//
    void BuildArmSegments(){
        this.ArmLinesDefined = true;
        this.UpdateAngles();
        this.BuildArmSegment(0,this.Points[0],this.Points[1],this.seg0_p0_distToEdge,this.seg0_p1_distToEdge,this.seg0_width);
        this.BuildArmSegment(1,this.Points[1],this.Points[2],this.seg1_p0_distToEdge,this.seg1_p1_distToEdge,this.seg1_width);
        this.BuildArmSegment(2,this.Points[2],this.Points[3],this.seg2_p0_distToEdge,this.seg2_p1_distToEdge,this.seg2_width);
    }
    //------------------------------------------------------------------//
    void BuildArmSegment(int id, Point A, Point B, float A_distToEdge, float B_distToEdge, float Seg_width){
        // Make new 'origin'
        Point T = new Point(B.X-A.X,-(B.Y-A.Y)); // Note the -() is because: (height-B.Y-(height-A.Y))
        float length_AB = T.SqrtSumSq();
        float angle_AB = T.GetCurrentAngle();
        // Update CLASS internal vars:
        this.ArmLengths[id] = length_AB;
        // Build points as if angle where zero
        Point P0 = new Point(length_AB+B_distToEdge,Seg_width/2.0);
        Point P1 = new Point(-A_distToEdge,Seg_width/2.0);
        Point P2 = new Point(-A_distToEdge,-Seg_width/2.0);
        Point P3 = new Point(length_AB+B_distToEdge,-Seg_width/2.0);
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
    void UpdateAngles() {
        Point Orig = new Point(this.Points[0].X + 100, this.Points[0].Y);
        this.Angles[0] = this.RelativeAngle(Orig,this.Points[0],this.Points[1]);
        this.Angles[1] = this.RelativeAngle(this.Points[0],this.Points[1],this.Points[2]);
        this.Angles[2] = this.RelativeAngle(this.Points[1],this.Points[2],this.Points[3]);
    }
    //------------------------------------------------------------------//
    float RelativeAngle(Point A, Point B, Point C) {
        // Put B at the origin and translate A and C
        Point A_offset = new Point(A.X-B.X,A.Y-B.Y);
        Point C_offset = new Point(C.X-B.X,C.Y-B.Y);
        // Compute angle diff and return
        float AngleA = A_offset.GetCurrentAngle();
        float AngleC = C_offset.GetCurrentAngle();
        float temp = AngleA-AngleC;
        if(temp < 0) temp += 2.*PI;
        return temp*180./PI;
    }
    //------------------------------------------------------------------//
    void RunMotors() {
        String ToSend = "B_" + this.Motors[0] + "_" + this.Motors[1] + "_" + this.Motors[2] + "_" + this.Motors[3] + "_" + this.Duration + "_E";
        myPort.write(ToSend);
        if(this.DisplayStatus > 2) println("Serial Send: " + ToSend);
        delay(this.Duration);
    }
    //------------------------------------------------------------------//
    void CloseHand() {
        int NumBursts=0;
        String ToSend = "B_128_0_0_0_20_E";
        this.ChangingHandState = true;
        while((this.Pressure < this.OnPressure)&&(NumBursts < 80)) {
            myPort.write(ToSend);
            delay(40);
            NumBursts++;
        }
        println("Done CloseHand");
        this.ChangingHandState = false;
    }
    //------------------------------------------------------------------//
    void OpenHandSmallBit() {
        String ToSend = "B_-255_0_0_0_88_E";
        this.ChangingHandState = true;
        myPort.write(ToSend);
        delay(100);
        this.ChangingHandState = false;
    }
    //------------------------------------------------------------------//
    void OpenHand() {
        int NumBursts=0;
        String ToSend = "B_-255_0_0_0_50_E";
        this.ChangingHandState = true;
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
        this.ChangingHandState = false;
    }
    //------------------------------------------------------------------//
    void MoveTowardsAngles(float [] FeedbackAngles, boolean [] Violators, int numAngles) {
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
    void MoveTowardsAngles(float [] DestAngles, float [] FeedbackAngles, boolean [] Violators, int numAngles) {
        boolean RunMotorsIsWorthIt = false;
        float [] DeltaAngles = {0,0,0};
        int MaxDeltaIndex = 0;
        for(int i=0;i < numAngles;i++) {
            // Get delta angle in and clip to static limits
            float DestAngleClipped = DestAngles[i];
            if(DestAngleClipped > this.MaxAngles[i]) DestAngleClipped = this.MaxAngles[i];
            if(DestAngleClipped < this.MinAngles[i]) DestAngleClipped = this.MinAngles[i];
            DeltaAngles[i] = DestAngleClipped - FeedbackAngles[i];
            if(DeltaAngles[i] > DeltaAngles[MaxDeltaIndex]) MaxDeltaIndex = i;
        }
        for(int i=0;i < numAngles;i++) {
            // Angle->Motor function
            this.Motors[i+1] = (int)(DeltaAngles[i]*255./this.Damper);
            // Clip Motor speeds
            if(this.Motors[i+1] >  255) this.Motors[i+1] =  255;
            if(this.Motors[i+1] < -255) this.Motors[i+1] = -255;
        }
        // Now to apply violation correction
        boolean Violation = false;
        for(int i=numAngles-1;i>=0;i--) {
            Violation |= Violators[i];
            if(Violation) this.Motors[i+1] *= -0.5;
        }
        // Determin if it's all even worth it
        for(int i=0;i < numAngles;i++) {
            if(abs(this.Motors[i+1]) > this.MagicThreshold) RunMotorsIsWorthIt = true;
        }
        RobotArm.Motors[0] = 0; // Only used in Hand Open/Close
        RobotArm.Duration = this.MagicDuration;
        if(RunMotorsIsWorthIt) RobotArm.RunMotors();
    }
    //------------------------------------------------------------------//
    void AlignHandToPoint(Point ExtraIn, Point Origin) {
        // Copy the point and re-offset to be relative to this arm's Origin (i.e. Points[0])
        Point AdjustedIn = new Point(ExtraIn.X,ExtraIn.Y,ExtraIn.Z);
        AdjustedIn.SubtractOffset(Origin);
        // AdjustedIn.rotateCWAboutOrigin(10./180*PI);
        boolean LeftSide = (AdjustedIn.X>0);
        float FullDist = AdjustedIn.SqrtSumSq();
        AdjustedIn.AddOffset(this.Points[0]);
        if(FullDist > (this.seg2_p1_distToEdge+this.ArmLengths[0]+this.ArmLengths[1]+this.ArmLengths[2])) {
            this.Points[1] = this.Points[0].FindPointAtDistInDirOfAnother(this.ArmLengths[0],AdjustedIn);
            this.Points[2] = this.Points[1].FindPointAtDistInDirOfAnother(this.ArmLengths[1],AdjustedIn);
            this.Points[3] = this.Points[2].FindPointAtDistInDirOfAnother(this.ArmLengths[2],AdjustedIn);
            this.BuildArmSegments();
        } else {
            // Place new point3 this.seg2_p1_distToEdge (in the direction of point 2) away from AdjustedIn
            Point NewP3 = AdjustedIn.FindPointAtDistInDirOfAnother(this.seg2_p1_distToEdge,this.Points[2]);
            // Place new point2 this.ArmLengths[2] away from new point3 (in the direction of Point2)
            Point NewP2 = NewP3.FindPointAtDistInDirOfAnother(this.ArmLengths[2], this.Points[2]);
            // Solve for the last point (because the base can't move, Points[0] will be unchanged)
            Point NewP1 = this.SolveForPoint(this.Points[0],this.ArmLengths[0],NewP2,this.ArmLengths[1],LeftSide);
            if(NewP1.Z != -1) { // Then was solvable
                // Now to update the points
                this.Points[3] = new Point(NewP3.X,NewP3.Y,this.Points[3].Z);
                this.Points[2] = new Point(NewP2.X,NewP2.Y,this.Points[2].Z);
                this.Points[1] = new Point(NewP1.X,NewP1.Y,this.Points[1].Z);
                if(MassageAngles) this.MassageAnglesIfInvalid(AdjustedIn);
                this.BuildArmSegments();
            }
        }
    }
    //------------------------------------------------------------------//
    Point SolveForPoint(Point Origin, float DistToOrig, Point C, float DistToC, boolean LeftSide){
        Point ToReturn = new Point(0,0,-1);
        // boolean LeftSide = (C.X>Origin.X);
        float DistCToOrigin = C.RelativeDist(Origin);
        if(DistCToOrigin <= (DistToC+DistToOrig)) { // Then solution exists
            // Get Point2's angle relative to Point0 and the axis there
            Point temp = new Point(Origin.X + 100, Origin.Y);
            float AngleToPoint2 = this.RelativeAngle(temp,Origin,C)*PI/180.;
            // Get the angle of the triangle (P0.P1.P2) at P2
            float AngleForPoint2 = acos(((DistToC*DistToC)+(DistCToOrigin*DistCToOrigin)-(DistToOrig*DistToOrig)) / (2.*DistToC*DistCToOrigin));
            // Place P1 on x-axis and rotate CW to build X,Y values (relative to P2)
            ToReturn = new Point(DistToC, 0.0, 0);
            float rotateAngle = (PI-AngleToPoint2-AngleForPoint2);
            ToReturn.rotateCWAboutOrigin(rotateAngle); // Note the 'origin' is C
            if(LeftSide) ToReturn.rotateCWAboutOrigin(2*AngleForPoint2);
            // Offset back to where it should be
            ToReturn.AddOffset(C);
        } else if(this.DisplayStatus > 2){
            println("Impossibly grabbable Extra point! " + DistCToOrigin + " >= " + (DistToC+DistToOrig));
        }
        return ToReturn;
    }
    //------------------------------------------------------------------//
     void MassageAnglesIfInvalid(Point Target) {
        float TrickleAngle = 0;
        boolean LeftSide = (this.Points[2].X>this.Points[0].X);
        this.UpdateAngles();
        TrickleAngle = (this.Angles[2] > this.MaxAngles[2])? this.Angles[2]-this.MaxAngles[2] :
                       (this.Angles[2] < this.MinAngles[2])? this.Angles[2]-this.MinAngles[2] : 0;
        TrickleAngle /= 16.;
        if(TrickleAngle != 0) {
            // Rotate P3 and P2 about Target by TrickleAngle
            Point NewP3 = new Point(this.Points[3].X,this.Points[3].Y);
            NewP3.rotateCWAboutRefOrigin(TrickleAngle,Target);
            Point NewP2 = new Point(this.Points[2].X,this.Points[2].Y);
            NewP2.rotateCWAboutRefOrigin(TrickleAngle,Target);
            Point NewP1 = this.SolveForPoint(this.Points[0],this.ArmLengths[0],NewP2,this.ArmLengths[1],LeftSide);
            if(NewP1.Z != -1) { // Then was solvable
                // Now to test for Delta angles past realistic
                float maxDeltaAngle = 45; // No jumping to the other side
                Point Orig = new Point(this.Points[0].X + 100, this.Points[0].Y);
                float Angle0 = this.RelativeAngle(Orig,this.Points[0],NewP1);
                float Angle1 = this.RelativeAngle(this.Points[0],NewP1,NewP2);
                float Angle2 = this.RelativeAngle(NewP1,NewP2,NewP3);
                if((abs(Angle0-this.Angles[0])<maxDeltaAngle)&&(abs(Angle1-this.Angles[1])<maxDeltaAngle)&&(abs(Angle2-this.Angles[2])<maxDeltaAngle)) {
                    this.Points[3] = new Point(NewP3.X,NewP3.Y,this.Points[3].Z);
                    this.Points[2] = new Point(NewP2.X,NewP2.Y,this.Points[2].Z);
                    this.Points[1] = new Point(NewP1.X,NewP1.Y,this.Points[1].Z);
                } else {
                    println("Unable to Massage Angles:  Deltas(0,1,2) are: " + (int)abs(Angle0-this.Angles[0]) + "," + (int)abs(Angle1-this.Angles[1]) + "," + (int)abs(Angle2-this.Angles[2]));
                }
            }
        }
    }
    //------------------------------------------------------------------//
    void DrawAll(int r, int g, int b) {
        if(this.ArmLinesDefined) {
            for (int i=0;i < this.numArmLines;i++) {
                this.ArmLines[i].DrawLine(r,g,b);
            }
        }
        if(this.DisplayStatus >= 1) this.DebugInfo(r,g,b);
    }
    //------------------------------------------------------------------//
    // DEBUG
    void DebugInfo(int r, int g, int b) {
        stroke(r,g,b);
        fill  (r,g,b);
        // Angles
        for (int i=0;i < this.numPoints-1;i++) text("      Angle" + i + ":" + this.Angles[i], this.Points[i].X,this.Points[i].Y);
        if(this.DisplayStatus > 1) {
            // Motors:
            text("M0(" + this.Motors[0] + "), M1(" + this.Motors[1] + "), M2(" + this.Motors[2] + "), M3(" + this.Motors[3] + "), Duration(" + this.Duration + ")", 0, height-20);
            // Settings:
            text("EnableArmUpdate:" + this.EnableArmUpdate, 0, height-40);
            text("Pressure:" + this.Pressure + "  Openness:" + this.Openness, 0, height-60);
            text("ConstantPressureUpdate:" + this.ConstantPressureUpdate, 0, height-80);
            text("MoveTowardsPreprogramedPosition:" + this.MoveTowardsPPP, 0, height-100);
        }
        if(this.DisplayStatus > 2) {
            text("Damper:" + this.Damper + "  MagicThreshold:" + this.MagicThreshold + "  MagicDuration:" + this.MagicDuration, 0, height-120);
            // Lines and Points
            for (int i=0;i < this.numPoints-1;i++) {
                text("   Line" + i + ":" + (int)this.ArmLengths[i],
                    (this.Points[i].X+this.Points[i+1].X)/2.0,
                    (this.Points[i].Y+this.Points[i+1].Y)/2.0);
                this.Points[i].PrintID(i);
                this.Points[i].DrawSq(r,g,b);
            }
            this.Points[this.numPoints-1].PrintID(this.numPoints-1);
            this.Points[this.numPoints-1].DrawSq(r,g,b);
        }
    }
    //------------------------------------------------------------------//
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ConstraintsArrayList extends ArrayList {
    int ErrorOn = 0;
    //------------------------------------------------------------------//
    Line Pop(int index) {
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
    int TestForIntersection(Line In) {
        ErrorOn = 0; // Assume pass
        for(int i=0;i < this.size();i++) {
            if(In.Intersects((Line)this.get(i))) {
                ErrorOn++;
                break;
            }
        }
        return ErrorOn;
    }
    int TestForIntersection(Line[] In, int size) {
        ErrorOn = 0; // Assume pass
        for(int i=0;i < this.size();i++) {
            for(int j=0;j < size;j++) {
                if(In[j].Intersects((Line)this.get(i))) {
                    ErrorOn++;
                    break;
                }
            }
        }
        return ErrorOn;
    }
    //------------------------------------------------------------------//
    void DrawAll(int r, int g, int b) {
        for(int i=0;i < this.size();i++) ((Line)this.get(i)).DrawLine(r,g,b);
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
    float LineLength() {
        return sqrt((this.A.X-this.B.X)*(this.A.X-this.B.X)+(this.A.Y-this.B.Y)*(this.A.Y-this.B.Y));
    }
    //------------------------------------------------------------------//
    boolean Intersects(Line In) {
        return ((this.DeltaSlopeTest(In.A)^this.DeltaSlopeTest(In.B))&&(In.DeltaSlopeTest(this.A)^In.DeltaSlopeTest(this.B)));
    }
    //------------------------------------------------------------------//
    boolean DeltaSlopeTest(Point In) {
        return (((In.Y-A.Y)*(B.X-A.X))>((B.Y-A.Y)*(In.X-A.X)));
    }
    //------------------------------------------------------------------//
    void DrawLine(int r, int g, int b) {
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
    void rotateCWAboutOrigin(float Angle) {
        this.rotateCCWAboutOrigin((2*PI)-Angle);
    }
    //------------------------------------------------------------------//
    void rotateCCWAboutOrigin(float Angle) {
        float tempLength = this.SqrtSumSq();
        float currentAngle = this.GetCurrentAngle();
        float NewX = tempLength*cos(currentAngle-Angle);
        float NewY = tempLength*sin(currentAngle-Angle);
        this.X = NewX;
        this.Y = NewY;
    }
    //------------------------------------------------------------------//
    void rotateCWAboutRefOrigin(float Angle, Point RefOrigin) {
        this.rotateCCWAboutRefOrigin((2*PI)-Angle, RefOrigin);
    }
    //------------------------------------------------------------------//
    void rotateCCWAboutRefOrigin(float Angle, Point RefOrigin) {
        this.SubtractOffset(RefOrigin);
        this.rotateCCWAboutOrigin(Angle);
        this.AddOffset(RefOrigin);
    }
    //------------------------------------------------------------------//
    void AddOffset(Point Offset) {
        this.X += Offset.X;
        this.Y += Offset.Y;
    }
    void AddOffset(float X_offset, float Y_offset) {
        this.X += X_offset;
        this.Y += Y_offset;
    }
    //------------------------------------------------------------------//
    void SubtractOffset(Point Offset) {
        this.X -= Offset.X;
        this.Y -= Offset.Y;
    }
    void SubtractOffset(float X_offset, float Y_offset) {
        this.X -= X_offset;
        this.Y -= Y_offset;
    }
    //------------------------------------------------------------------//
    float SqrtSumSq() {
        return sqrt((this.X*this.X)+(this.Y*this.Y));
    }
    //------------------------------------------------------------------//
    float RelativeDist(Point Ref) {
        return sqrt(((this.X-Ref.X)*(this.X-Ref.X))+((this.Y-Ref.Y)*(this.Y-Ref.Y)));
    }
    //------------------------------------------------------------------//
    float GetCurrentAngle() {
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
    Point FindPointAtDistInDirOfAnother(float Distance, Point Direction) {
        float SimilarTriangleRatio = Distance / this.RelativeDist(Direction);
        Point ToReturn = new Point(SimilarTriangleRatio*(Direction.X-this.X)+this.X,SimilarTriangleRatio*(Direction.Y-this.Y)+this.Y);
        return ToReturn;
    }
    //------------------------------------------------------------------//
    void DrawX(int r, int g, int b) {
        stroke(r,g,b);
        line(this.X-this.Z/2,this.Y-this.Z/2,this.X+this.Z/2,this.Y+this.Z/2);
        line(this.X-this.Z/2,this.Y+this.Z/2,this.X+this.Z/2,this.Y-this.Z/2);
    }
    void DrawX(int r, int g, int b, float Height) {
        stroke(r,g,b);
        Height/=2; // Scale once in begining is more efficient, but I guess no scale is better :)
        line(this.X-Height,this.Y-Height,this.X+Height,this.Y+Height);
        line(this.X-Height,this.Y+Height,this.X+Height,this.Y-Height);
    }
    //------------------------------------------------------------------//
    void DrawO(int r, int g, int b) {
        stroke(r,g,b);
        fill  (r,g,b);
        ellipse(this.X,this.Y,this.Z,this.Z);
    }
    void DrawO(int r, int g, int b, float Radius) {
        stroke(r,g,b);
        fill  (r,g,b);
        ellipse(this.X,this.Y,Radius,Radius);
    }
    //------------------------------------------------------------------//
    void DrawOX(int r, int g, int b) {
        stroke(r,g,b);
        noFill();
        ellipse(this.X,this.Y,this.Z,this.Z);
        this.DrawX(r,g,b);
    }
    void DrawOX(int r, int g, int b, float Radius) {
        stroke(r,g,b);
        noFill();
        ellipse(this.X,this.Y,Radius,Radius);
        this.DrawX(r,g,b,Radius);
    }
    //------------------------------------------------------------------//
    void DrawSq(int r, int g, int b) {
        stroke(r,g,b);
        fill  (r,g,b);
        rect(this.X-this.Z/4,this.Y-this.Z/4,this.Z/2,this.Z/2);
    }
    void DrawSq(int r, int g, int b, float Height) {
        stroke(r,g,b);
        fill  (r,g,b);
        Height/=2; // Scale once in begining is more efficient, but I guess no scale is better :)
        rect(this.X-Height/2,this.Y-Height/2,Height,Height);
    }
    //------------------------------------------------------------------//
    void PrintID(int ID) {
        text("ID:" + ID, this.X-20,this.Y-20);
    }
    //------------------------------------------------------------------//
    void Print(String InStr) {
        text(InStr, this.X-InStr.length()*6,this.Y-20);
    }
    //------------------------------------------------------------------//
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

