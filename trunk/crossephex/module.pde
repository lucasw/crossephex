
class Port {
int x;
int y;
int h = 10;
int w = 10;
  
  ArrayList mlist; 
    
  Port(int nx, int ny) {
    x = nx;
    y = ny; 
    mlist = new ArrayList();
  }
  
  void display( ) {
    rect(x,y, 10, 10);
  }
}

class Module {
  
  PImage im;
  
  int rectX;
  int rectY;
  int rectHeight;
  int rectWidth;
  
  Port outport;
  
  //this is used in order to keep dragging during fast mouse movement
  int dragMargin; 
  
  Module(int rX, int rY, int rH, int rW, int dM) {
     rectX = rX;
     rectY = rY;
     rectHeight = rH;
     rectWidth= rW;
     dragMargin = dM;
     
     outport = new Port(rectWidth/2-10/2, 0);
  } 
 
   boolean inDragRange(int newX, int newY){
    /// keep within screen borders for now, later support larger workspace with scrollbars
    if (newX < 0) newX = 0;
    if (newY < 0) newY = 0;
    if (newX > width)  newX = width;
    if (newY > height) newY = height;
      
    if ((newX>=rectX-rectWidth/2-dragMargin  && newX<=rectX+rectWidth/2+dragMargin) && 
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
   
     
     rectX = newX;
     rectY = newY;      
  }
  
  void display(boolean isSelected) {
    pushMatrix();
    translate(rectX,rectY);
    
    if (isSelected) stroke(150);
    else stroke(255);
    
    rect(0, 0, rectWidth, rectWidth);
    
     //translate(rectX,rectY);
    if (im != null) image(im, -rectWidth*0.4, -rectHeight*0.4, 
    rectWidth*0.4, rectHeight*0.4);
    
    outport.display();
    popMatrix();
  }
}

class ImageSourceModule extends Module {
  
  ImageSourceModule(int rX, int rY, int rH, int rW, int dM, String fileName) {
    super(rX, rY, rH, rW, dM);
    im = loadImage(fileName);  
  }
  
  void display(boolean isSelected) {
    super.display(isSelected);
    
    //pushMatrix();
    //translate(rectX,rectY);
    
    //text("source");
    //popMatrix();
  }
}
