
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
  
  color fillColor;
  
  /// how to handle these more generically?
  // some module have one or the other or none
  // TBD make them arrays of default size zero
  Port inport;
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
     
     inport = new Port(-rectWidth/2, 0);
     
     fillColor = color(150,150,149);
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
    
    fill(fillColor);
    
    rect(0, 0, rectWidth, rectWidth);
    
     //translate(rectX,rectY);
    if (im != null) image(im, -rectWidth*0.4, -rectHeight*0.4, 
    rectWidth*0.4, rectHeight*0.4);
    
    outport.display();
    popMatrix();
  }
}

class ImageMixerModule extends Module {
  //PImage inport1;
  PImage inport2;
  
  float mix = 1.0;
  
  
  ImageMixerModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    fillColor = color(110,150,149);
  }
  
  //for (int i = 0;
  
}


// this module doesn't need an output, maybe it should extend a base 
// class that doesn't have any?
class ImageOutputModule extends Module {
  
   ImageOutputModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    fillColor = color(70,150,149);
  }
  
  
   void display(boolean isSelected) {
      super.display(isSelected);
      
      /// probably get generalize this with im width/height parameters
      if (im != null) image(im, -rectWidth*0.4, -rectHeight*0.4, 
                                 rectWidth*0.8, rectHeight*0.8);
      
   }
}


class ImageSourceModule extends Module {
  
  ImageSourceModule(int rX, int rY, int rH, int rW, int dM, String fileName) {
    super(rX, rY, rH, rW, dM);
    
    fillColor = color(190,160,157);
    
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

