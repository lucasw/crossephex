


class Port {
  int x;
  int y;
  int h = 10;
  int w = 10;
  
  color fillCol;
  
  // other ports that are connected to this port
  ArrayList mlist; 
  
  Module parentModule;
    
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
  
  ArrayList inports;
  //Port inport;
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
     outport.parentModule = this;
     
      inports = new ArrayList();
      
     Port inport = new Port(-rectWidth/2+10/2, 0, fillColor);
     inport.parentModule = this;
     inports.add(inport);
     
  } 
 
   /// recursive update every module that's an input to this module
   void update(int updateCount) {
     if (lastUpdateCount == updateCount) return;
     lastUpdateCount = updateCount;  
     
      for (int i = 0; i < inports.size(); i++) {
        Port inport = (Port)inports.get(i);
        
      for (int j = 0; j < inport.mlist.size(); j++) {  // should be only one
        Module otherConnectedModule = ((Port) inport.mlist.get(j)).parentModule;
        otherConnectedModule.update(updateCount);
        
        /// by putting the image copying and processing code after the recursive update
        /// we should have 1-cycle forward propagation of changes that don't involve loops
        /// TBD - is this desirable?  It may be useful if every module is also a unit delay
        if (otherConnectedModule.im != null) {
          // TBD add a flag that either propagates the inherited image size forward or always
          // resizes at this step.
          /// TBD this is not correct in all modules that inherit from this, like the mixer
          if (im == null) im = createImage(otherConnectedModule.im.width,otherConnectedModule.im.height,RGB);
          im.copy(otherConnectedModule.im,0,0,otherConnectedModule.im.width, otherConnectedModule.im.height,
                                        0,0,im.width, im.height);
        }
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
    
    
    for (int i = 0; i < inports.size(); i++) {
      Port inport = (Port)inports.get(i);
      inport.display();
    }
    outport.display();
    
    /// draw a green active rect to show this module has been updated this cycle
    if (lastUpdateCount == updateCount) { 
      
      fill(0,255,0);
      rect(-rectWidth/2+10/2,-rectHeight/2+10/2,10,10);
    }
    popMatrix();
  }
}

/////////////////////////////////////////////////////////////////


class ImageMixerModule extends Module {
  
  
  float mix = 0.5;
  
  
  ImageMixerModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    fillColor = color(110,150,149);
    
     Port inport = new Port(-rectWidth/2+10/2,12, fillColor);
     inport.parentModule = this;
     inports.add(inport);
  }

  void display(boolean isSelected) {
    super.display(isSelected);
    
  }
 
  void update(int updateCount) {
    super.update(updateCount);
    
    if (inports.get(0) == null) return;
    if (inports.get(1) == null) return;
    
    PImage im1 = ((Port)inports.get(0)).parentModule.im;
    PImage im2 = ((Port)inports.get(1)).parentModule.im;
    
    if (im == null) return;
    if (im1 == null) return;
    if (im2 == null) return;
    
    int w = min(im1.width, im2.width,im.width);
    int h = min(im1.height,im2.height,im.height);
    
    //println(im1.width + " " + im2.width + " " + im.width);
    for (int i = 0; i < h; i++) {
    for (int j = 0; j < w; j++) {
      int pixind0 = i*im.width+j;
      int pixind1 = i*im1.width+j;
      int pixind2 = i*im2.width+j;
      
      color c1 = im1.pixels[pixind1];
      color c2 = im2.pixels[pixind2];
      
      im.pixels[pixind0] = color(
        mix*red(c1)   + (1.0-mix)*red(c2),
        mix*green(c1) + (1.0-mix)*green(c2),
        mix*blue(c1)  + (1.0-mix)*blue(c2)
      );
      
    }}
  }
  
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

