/**
 *Description: CrossePhex is a Processing-based, Gehpex-inspired VJ app
 *Authors: BinaryMillenium, VirtualFlavius
 *Notes: this is very preliminary code
 *
 */

int rectX;
int rectY;
int rectHeight;
int rectWidth;
int dragMargin; 

void setup(){
  size(720, 576);
  frameRate(60);
  background(0);
  fill(128);
  stroke(255);


  rectHeight=48;
  rectWidth=48;
  rectX=width/2;
  rectY=height/2;
  dragMargin=32; //this is used in order to keep dragging during fast mouse movement
  
  rectMode(CENTER);

}

void draw(){
  background(0);
  rect(rectX, rectY, rectWidth, rectWidth);
}

public void mouseDragged(){

  if ((mouseX>=rectX-rectWidth/2-dragMargin && mouseX<=rectX+rectWidth/2+dragMargin) && (mouseY>=rectY-rectHeight/2-dragMargin && mouseY<=rectY+rectHeight/2+dragMargin)){
   cursor(HAND);
   fill(168);
   stroke(224);
   rectX = mouseX;
   rectY = mouseY;
  }
 
}
 
public void mouseReleased(){
 cursor(ARROW);
 fill(128);

}
