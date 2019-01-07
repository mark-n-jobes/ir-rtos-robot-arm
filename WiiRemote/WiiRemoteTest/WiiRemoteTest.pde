import lll.Loc.*;

import lll.wrj4P5.*;

Wrj4P5 wii;

void setup() {
  size(300,300,P3D);
  wii=new Wrj4P5(this);
  wii.connect();
} 
void draw() {
  background(0);
  stroke(255);
  translate(300/2,300/2,0);
  lights();
  rotateX((int) (wii.rimokon.senced.x+300));
  rotateY((int) (wii.rimokon.senced.y+300));
  rotateZ((int) (wii.rimokon.senced.z+300));
  box(100,100,100);
}
	
void buttonPressed(RimokonEvent evt, int rid) {
   if (evt.wasPressed(RimokonEvent.TWO)) println("2");
   if (evt.wasPressed(RimokonEvent.ONE)) println("1");
   if (evt.wasPressed(RimokonEvent.B)) println("B");
   if (evt.wasPressed(RimokonEvent.A)) println("A");
   if (evt.wasPressed(RimokonEvent.MINUS)) println("Minus");
   if (evt.wasPressed(RimokonEvent.HOME)) println("Home");
   if (evt.wasPressed(RimokonEvent.LEFT)) println("Left");
   if (evt.wasPressed(RimokonEvent.RIGHT)) println("Right");
   if (evt.wasPressed(RimokonEvent.DOWN)) println("Down");
   if (evt.wasPressed(RimokonEvent.UP)) println("Up");
   if (evt.wasPressed(RimokonEvent.PLUS)) println("Plus");
}

