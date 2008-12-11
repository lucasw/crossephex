

class Module {
  int rectX;
  int rectY;
  int rectHeight;
  int rectWidth;
  
  //this is used in order to keep dragging during fast mouse movement
  int dragMargin; 
  
  Module(int rX, int rY, int rH, int rW, int dM) {
     rectX = rX;
     rectY = rY;
     rectHeight = rH;
     rectWidth= rW;
     dragMargin = dM;
  } 
 
   boolean inDragRange(int newX, int newY){
    /// keep within screen borders for now, later support larger workspace with scrollbars
    if (newX < 0) newX = 0;
    if (newY < 0) newY = 0;
    if (newX > width)  newX = width;
    if (newY > height) newY = height;
      
    if ((newX>=rectX-rectWidth/2-dragMargin && newX<=rectX+rectWidth/2+dragMargin) && 
        (newY>=rectY-rectHeight/2-dragMargin && newY<=rectY+rectHeight/2+dragMargin) ){
       
       return true;
    }  
    
    return false;
  }
  
  
  void drag(int newX, int newY){
    
    if (newX < 0) newX = 0;
    if (newY < 0) newY = 0;
    if (newX > width)  newX = width;
    if (newY > height) newY = height;
    
     cursor(HAND);
     fill(168);
     stroke(224);
     rectX = newX;
     rectY = newY;      
  }
  
  void display() {
     rect(rectX, rectY, rectWidth, rectWidth);
  }
}
