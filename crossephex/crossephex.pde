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

  int newX = mouseX;
  int newY = mouseY;
      
  /// keep within screen borders for now, later support larger workspace with scrollbars
  if (newX < 0) newX = 0;
  if (newY < 0) newY = 0;
  if (newX > width)  newX = width;
  if (newY > height) newY = height;
      
  if ((newX>=rectX-rectWidth/2-dragMargin && newX<=rectX+rectWidth/2+dragMargin) && 
      (newY>=rectY-rectHeight/2-dragMargin && newY<=rectY+rectHeight/2+dragMargin) ){
        
   cursor(HAND);
   fill(168);
   stroke(224);
   rectX = newX;
   rectY = newY;
  }
 
}
 
public void mouseReleased(){
 cursor(ARROW);
 fill(128);

}
