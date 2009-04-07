


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
     

     
     inports = new ArrayList();
         
  } 
 
   /// recursive update every module that's an input to this module
   boolean update(int updateCount, Module toUpdate) {
     if (lastUpdateCount == updateCount) return false;
     lastUpdateCount = updateCount;   
     
     for (int i = 0; i < inports.size(); i++) {
        Port inport = (Port)inports.get(i);
        
        for (int j = 0; j < inport.mlist.size(); j++) {  // should be only one
          Module otherConnectedModule = ((Port) inport.mlist.get(j)).parentModule;
          otherConnectedModule.update(updateCount,this);
        }
      }
      
      return true;
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
  void toggle() {
  }
  
  void right() {
  }
  
  void left() {
  }
    
  void display(boolean isSelected) {
    pushMatrix();
    translate(rectX,rectY);
    
    if (isSelected) stroke(150);
    else stroke(255);
    
    fill(fillColor);
    
    rect(0, 0, rectWidth, rectWidth);
    
     //translate(rectX,rectY);
    if (im != null) {
      image(im, -rectWidth*0.4, -rectHeight*0.4, 
                               rectWidth*0.4, rectHeight*0.4);
        
        //
        pushMatrix();
        fill(100,200,100);
        text( im.width + " " + im.height, 0,0);
        popMatrix();
    }
    
    for (int i = 0; i < inports.size(); i++) {
      Port inport = (Port)inports.get(i);
      inport.display();
    }
    
    
    
    /// draw a green active rect to show this module has been updated this cycle
    if (lastUpdateCount == updateCount) { 
      
      fill(0,255,0);
      rect(-rectWidth/2+10/2,-rectHeight/2+10/2,10,10);
    }
    
    if (outport != null) outport.display();
    
    popMatrix();
  }
}

/////////////////////////////////////////////////////////////////////////////////

class PassthroughModule extends Module {
  PassthroughModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    
     Port inport = new Port(-rectWidth/2+10/2, 0, fillColor);
     inport.parentModule = this;
     inports.add(inport);
     
     outport = new Port(rectWidth/2-10/2, 0, fillColor);
     outport.parentModule = this;
  }
  
  boolean update(int updateCount, Module toUpdate) {
    if (super.update(updateCount,toUpdate) == false) return false;
    
    /// by putting the image copying and processing code after the recursive update
    /// we should have 1-cycle forward propagation of changes that don't involve loops
    /// TBD - is this desirable?  It may be useful if every module is also a unit delay
    if (im != null) {
      // TBD add a flag that either propagates the inherited image size forward or always
      // resizes at this step.
      /// TBD this is not correct in all modules that inherit from this, like the mixer
     if ((toUpdate.im == null) || 
         (toUpdate.im.width  != im.width) || 
         (toUpdate.im.height != im.height)) {
       toUpdate.im = createImage(im.width,im.height,RGB); 
     }
      toUpdate.im.copy(im,0,0,im.width, im.height, 0,0,toUpdate.im.width, toUpdate.im.height);
    }
    
    return true;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////

class ImageMixerModule extends Module {
   
  float mix = 0.5;
  
  ImageMixerModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    fillColor = color(110,150,149);
    
     outport = new Port(rectWidth/2-10/2, 0, fillColor);
     outport.parentModule = this;
     
     Port inport1 = new Port(-rectWidth/2+10/2, 0, fillColor);
     inport1.parentModule = this;
     inports.add(inport1);
     
     Port inport2 = new Port(-rectWidth/2+10/2,12, fillColor);
     inport2.parentModule = this;
     inports.add(inport2);
  }

  void right() {
    mix += 0.01;
    if (mix > 1.0) mix = 1.0;
  }
  
  void left() {
    mix -= 0.01;
    if (mix < 0.0) mix = 0.0;
  }

  void display(boolean isSelected) {
    super.display(isSelected);
    
    pushMatrix();
    translate(rectX,rectY);
    outport.display();
    //text("source");
    
    fill(120,160,140);
    rect(-rectWidth/2+rectWidth*mix/2,rectHeight/2, rectWidth*mix, 10);
    
    popMatrix();
  }
 
  boolean update(int updateCount, Module toUpdate) {
    if (super.update(updateCount,toUpdate) == false) return false;

    if (inports.size() != 2) return false;

    Port port1 = (Port)inports.get(0);
    Port port2 = (Port)inports.get(1);

    if ((port1 == null) && (port2 == null)) return false;
    
    PImage im1, im2;
     
    /*
    /// copy image through if other input is null
    if (port1 == null) {
      if (port2.mlist.get(0) == null) return; 
      im1 = ( (Port) (port2.mlist.get(0)) ).parentModule.im;
    } else {
   
    }
    if (port2 == null) {
      if (port1.mlist.get(0) == null) return;
      im2 = ( (Port) (port1.mlist.get(0)) ).parentModule.im;
    } else {    

    }
    */
    
    if (port1.mlist.size() < 1) return false;
    if (port2.mlist.size() < 1) return false;
    
    /// The ports connected to the inports
    Port cport1 = (Port) port1.mlist.get(0);
    Port cport2 = (Port) port2.mlist.get(0);
    
    if (cport1 == null) return false;
    im1 = cport1.parentModule.im;
    if (cport2 == null) return false; 
    im2 = cport2.parentModule.im;
        
    if (im  == null) return false;
    if (im1 == null) return false;
    if (im2 == null) return false;
    
    PImage newim;
    newim = createImage(im.width,im.height,RGB);
    
    int w = min(im1.width, im2.width,im.width);
    int h = min(im1.height,im2.height,im.height);
    
    //println(im1.width + " " + im2.width + " " + im.width);

    
    /*
    /// use blend instead
    for (int i = 0; i < h; i++) {
    for (int j = 0; j < w; j++) {
      int pixind0 = i*im.width+j;
      int pixind1 = i*im1.width+j;
      int pixind2 = i*im2.width+j;
      
      color c1 = im1.pixels[pixind1];
      color c2 = im2.pixels[pixind2];
      
      newim.pixels[pixind0] = color(
        mix*red(c1)   + (1.0-mix)*red(c2),
        mix*green(c1) + (1.0-mix)*green(c2),
        mix*blue(c1)  + (1.0-mix)*blue(c2)
      );
      
      //if (pixind0 ==0) println(red(c1) + " " + red(c2) + " " +  red(newim.pixels[pixind0]));
    }}
    */

    
    newim.copy( im1, 0,0, im1.width,im1.height,  0,0, newim.width, newim.height);
    
    for (int i = 0; i <im2.height; i++) {
    for (int j = 0; j <im2.width; j++) {
      int pixind = i*im2.width+j;
      im2.pixels[ pixind ] = color(red( im2.pixels[ pixind ]),
                                     green( im2.pixels[ pixind ]),
                                     blue( im2.pixels[ pixind ]),mix*255.09);    
    }}
    newim.blend(im2, 0,0, im2.width,im2.height, 0,0, newim.width, newim.height, BLEND );
    
    
    /// buffer the output in case one of the inputs is also the output
    im = newim;
    
    /// by putting the image copying and processing code after the recursive update
    /// we should have 1-cycle forward propagation of changes that don't involve loops
    /// TBD - is this desirable?  It may be useful if every module is also a unit delay
      // TBD add a flag that either propagates the inherited image size forward or always
      // resizes at this step.
      /// TBD this is not correct in all modules that inherit from this, like the mixer
     if ((toUpdate.im == null) || 
         (toUpdate.im.width  != im.width) || 
         (toUpdate.im.height != im.height)) {
       toUpdate.im = createImage(im.width,im.height,RGB); 
     }
     
     toUpdate.im.copy(im,0,0,im.width, im.height, 0,0,toUpdate.im.width, toUpdate.im.height);

     return true;
  }
}

////////////////////////////////////////////////////////////////////////

class ImageTranslateModule extends Module {

  int offsetX = 0;
  int offsetY = 0;
  
  ImageTranslateModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    
    outport = new Port(rectWidth/2-10/2, 0, fillColor);
    outport.parentModule = this;
     
    Port inport1 = new Port(-rectWidth/2+10/2, 0, fillColor);
    inport1.parentModule = this;
    inports.add(inport1);
  }
     
  void right() {
    offsetX += 5;
    if (offsetX > im.width) offsetX = im.width;
    
    println(offsetX);
  }
  
  void left() {
    offsetX -= 4;
    
    if (offsetX < -im.width) offsetX = -im.width;
  }
  
  boolean update(int updateCount, Module toUpdate) {
    if (super.update(updateCount,toUpdate) == false) return false;
  
    if (im != null) {
      if ((toUpdate.im == null) || 
         (toUpdate.im.width  != im.width) || 
         (toUpdate.im.height != im.height)) {
            toUpdate.im = createImage(im.width, im.height, RGB);
      }
      toUpdate.im.copy(im,offsetX,offsetY,im.width, im.height, 0,0,toUpdate.im.width, toUpdate.im.height);
    }
    
    return true;
  }
}

////////////////////////////////////////////////////////////////////////

// this module doesn't need an output, maybe it should extend a base 
// class that doesn't have any?
class ImageOutputModule extends Module {
  
   ImageOutputModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    fillColor = color(70,150,149);
    
     Port inport1 = new Port(-rectWidth/2+10/2, 0, fillColor);
     inport1.parentModule = this;
     inports.add(inport1);
  }
  
    boolean update(int updateCount, Module toUpdate) {
       if (super.update(updateCount,toUpdate) == false) return false;
       
          return true;
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
    
     outport = new Port(rectWidth/2-10/2, 0, fillColor);
     outport.parentModule = this;
    
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
    
     
  
  }
  
  boolean update(int updateCount, Module toUpdate ) {
     if (super.update(updateCount,toUpdate) == false) return false;
    
    /// by putting the image copying and processing code after the recursive update
    /// we should have 1-cycle forward propagation of changes that don't involve loops
    /// TBD - is this desirable?  It may be useful if every module is also a unit delay
    if (im != null) {
      // TBD add a flag that either propagates the inherited image size forward or always
      // resizes at this step.
      /// TBD this is not correct in all modules that inherit from this, like the mixer
      if ((toUpdate.im == null) || 
         (toUpdate.im.width  != im.width) || 
         (toUpdate.im.height != im.height)) {
           toUpdate.im = createImage(im.width,im.height,RGB); 
      }
      toUpdate.im.copy(im,0,0,im.width, im.height, 0,0,toUpdate.im.width, toUpdate.im.height);
    }
    
 
    return true;   
  }
}

