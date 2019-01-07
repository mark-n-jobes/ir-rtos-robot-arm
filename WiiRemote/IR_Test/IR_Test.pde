import lll.wrj4P5.*;
import lll.Loc.*;

Wrj4P5 wii;

float x,y,w;

 //Size of the window
   int camWidth = 512;
   int camHeight = 384;

 //Number of IR Emmiters that you want to track
   int IREmitters = 4;

void setup() {
  size(camWidth,camHeight);
  wii=new Wrj4P5(this).connect(Wrj4P5.IR);
}
 

void draw() { 
//Defines Background color
  background(0);
//Draws ir emitters
  for (int i=0;i<IREmitters;i++) {
    Loc p=wii.rimokon.irLights[i];
    if (p.x>-1) {
     // Reads the value sent by the wiimote and multiplicities them by the size of the window
       x=((p.x)*camWidth);
       y=((1.-p.y)*camHeight);
       w=p.z*100;
     //Prints the values to the console
       print(w);
       print(" \t @ \t ");
       print(x);
       print(",");
       println(y);
     //Draws the circles
       noStroke();
       fill(255,255,0);
       ellipse(x, y, w, w);
     //Draws the lines
       stroke(255);
       line(x,0,x,camHeight);
       line(0,y,camWidth, y);
       delay(50);
     }
   }
 }
