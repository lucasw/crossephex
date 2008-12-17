


class Port {
  int x;
  int y;
  int h = 10;
  int w = 10;
  
  color fillCol;
  
  ArrayList mlist; 
    
  Port(int nx, int ny, color nc) {
    x = nx;
    y = ny; 
    fillCol = nc;
    mlist = new ArrayList();
  }
  
  void display( ) {
    pushMatrix();
    if (mlist.size() > 0) fill(color(red(fillCol)+25,green(fillCol)+50,blue(fillCol)+35));
    else fill(fillCol);
    rect(x,y, 10, 10);
    popMatrix();
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
  
  int lastUpdateCount = 0;
  
  Module(int rX, int rY, int rH, int rW, int dM) {
     rectX = rX;
     rectY = rY;
     rectHeight = rH;
     rectWidth= rW;
     dragMargin = dM;
      
     fillColor = color(150,150,149);
     
     outport = new Port(rectWidth/2-10/2, 0, fillColor);
     
     inport = new Port(-rectWidth/2+10/2, 0, fillColor);
  } 
 
   /// recursive update every module that's an input to this module
   void update(int updateCount) {
     if (lastUpdateCount == updateCount) return;
     lastUpdateCount = updateCount;  
     
      for (int j = 0; j < inport.mlist.size(); j++) {  // should be only one
        Module otherConnectedModule = (Module) inport.mlist.get(j);
        otherConnectedModule.update(updateCount);
        
        /// by putting the image copying and processing code after the recursive update
        /// we should have 1-cycle forward propagation of changes that don't involve loops
        /// TBD - is this desirable?  It may be useful if every module is also a unit delay
        if (otherConnectedModule.im != null) {
          // TBD add a flag that either propagates the inherited image size forward or always
          // resizes at this step.
          if (im == null) im = createImage(otherConnectedModule.im.width,otherConnectedModule.im.height,RGB);
          im.copy(otherConnectedModule.im,0,0,otherConnectedModule.im.width, otherConnectedModule.im.height,
                                        0,0,im.width, im.height);
        }
      }
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

  /// do something when the module is selected 
  void toggle(){
    
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
    
    
    inport.display();
    outport.display();
    
    /// draw a green active rect to show this module has been updated this cycle
    if (lastUpdateCount == updateCount) { 
      
      fill(0,255,0);
      rect(-rectWidth/2+10/2,-rectHeight/2+10/2,10,10);
    }
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
      
      pushMatrix();
      translate(rectX,rectY);
      /// probably get generalize this with im width/height parameters
      if (im != null) image(im, -rectWidth*0.4, -rectHeight*0.4, 
                                 rectWidth*0.8, rectHeight*0.8);
      popMatrix();
      
   }
}

///////////////////////////////////////////////////////////////////

class ImageSourceModule extends Module {
  
  File dir;
  String[] files;
  int curind = -1;
  
  String folderName;
  
  ImageSourceModule(int rX, int rY, int rH, int rW, int dM, String folderName) {
    super(rX, rY, rH, rW, dM);
    
    this.folderName = folderName;
    
    fillColor = color(190,160,157);
  
    dir = new File( folderName);
    files = dir.list();
    
    
    if (files == null) {
      println(folderName + " dir not found"); 
      return;
    }
    
    toggle();
    
  }
  
  void toggle() {
    for (int i = curind+1; i < curind+files.length; i++) {
      int newind = i%files.length;
      im = loadImage(folderName + "/" + files[newind]);
      if (im != null) { curind = newind; break; }
    }
  }
  
  void display(boolean isSelected) {
    super.display(isSelected);
    
    //pushMatrix();
    //translate(rectX,rectY);
    
    //text("source");
    //popMatrix();
  }
}

