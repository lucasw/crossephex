  final int IMAGE_PORT = 0;
  final int NUM_PORT = 1; 
  
class Port {
  
  int type;
  int x;
  int y;
  int h = 10;
  int w = 10;
  
  color fillCol;
  
  // other ports that are connected to this port
  ArrayList mlist; 
  
  Module parentModule;
    
  Port(Module parent, int nx, int ny, color nc, int ntype) {
    parentModule = parent;
    type = ntype;
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

////////////////////////////////////////////////////////

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
  ArrayList number_inports;
  //Port inport;
  Port outport;
  
  //this is used in order to keep dragging during fast mouse movement
  int dragMargin; 
  
  int lastUpdateCount = 0;
  
  /// is this redundant with lastUpdateCount?
  /// set dirty to true when the im has changed
  boolean dirty;
  boolean was_dirty;
  
  Module(int rX, int rY, int rH, int rW, int dM) {
     rectX = rX;
     rectY = rY;
     rectHeight = rH;
     rectWidth= rW;
     dragMargin = dM;
      
     fillColor = color(150,150,149);
     
    dirty = true;
    was_dirty = dirty;
     
     inports = new ArrayList();
     
     number_inports = new ArrayList();
         
  } 
 
   /// recursive update every module that's an input to this module
   boolean update(int updateCount) {
     was_dirty = dirty;
     
     if (lastUpdateCount == updateCount) return false;
     lastUpdateCount = updateCount;   
     
     for (int i = 0; i < inports.size(); i++) {
        Port inport = (Port)inports.get(i);
        
        /// TBD probably can combine inports and number_inports into one list
        /// and really simplify 
        for (int j = 0; j < inport.mlist.size(); j++) {  // should be only one
          Module otherConnectedModule = ((Port) inport.mlist.get(j)).parentModule;
          otherConnectedModule.update(updateCount);
        }
        

      }
      
      for (int i = 0; i < number_inports.size(); i++) {
        Port inport = (Port)number_inports.get(i);
        
        /// TBD probably can combine inports and number_inports into one list
        /// and really simplify 
        for (int j = 0; j < inport.mlist.size(); j++) {  // should be only one
          Module otherConnectedModule = ((Port) inport.mlist.get(j)).parentModule;
          otherConnectedModule.update(updateCount);
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
      dirty = true;
  }
  
  void right() {
  }
  
  void left() {
  }
  
  void up() {
  }
  
  void down() {
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
    
    for (int i = 0; i < number_inports.size(); i++) {
      Port numport = (Port)number_inports.get(i);
      numport.display();
    }
    
    
    
    /// draw a green active rect to show this module has been updated this cycle
    if (lastUpdateCount == updateCount) { 
      
      if (was_dirty) {
        fill(0,255,0);
 
      } else {
        fill(0,128,0);
      }
      was_dirty = false;
      
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
    
     Port inport = new Port(this,-rectWidth/2+10/2, 0, fillColor, IMAGE_PORT);
     inports.add(inport);
     
     outport = new Port(this,rectWidth/2-10/2, 0, fillColor, IMAGE_PORT);
  }
  
  boolean update(int updateCount) {
    if (super.update(updateCount) == false) return false;
   
         // copy image from parent
         if (inports.size() < 1) {
            return false; 
         }
         
         Port inport = (Port) inports.get(0);
         
         if (inport.mlist.size() < 1) {
             return false;
         }
         
         Module parent =  ((Port) inport.mlist.get(0)).parentModule;
         
       if (parent.im == null) return false;
       
       if (parent.dirty == false) return true;
         
         
       dirty = true;
            if ((im == null) || 
             (parent.im.width  != im.width) || 
             (parent.im.height != im.height)) {
             im = createImage(parent.im.width,parent.im.height,RGB); 
            }
            im.copy(parent.im,0,0,parent.im.width, parent.im.height, 0,0,im.width, im.height);
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
    
     Port inport1 = new Port(this,-rectWidth/2+10/2, 0, fillColor, IMAGE_PORT);

     inports.add(inport1);
  }
  
    boolean update(int updateCount) {
       if (super.update(updateCount) == false) return false;
     
         // copy image from parent
         if (inports.size() < 1) {
            return false; 
         }
         
         Port inport = (Port) inports.get(0);
         
         if (inport.mlist.size() < 1) {
             return false;
         }
         
         Module parent =  ((Port) inport.mlist.get(0)).parentModule;
         
           
         if (parent.im == null) return false;
           
         if (parent.dirty == false) return true;   
           
            if ((im == null) || 
             (parent.im.width  != im.width) || 
             (parent.im.height != im.height)) {
             im = createImage(parent.im.width,parent.im.height,RGB); 
            }
            im.copy(parent.im,0,0,parent.im.width, parent.im.height, 0,0,im.width, im.height);
            return true;

    }
  
   void display(boolean isSelected) {
       /// TBD this module always seems to be dirty, but others don't
      super.display(isSelected);
        
      pushMatrix();
      translate(rectX,rectY);
      /// probably get generalize this with im width/height parameters
      if (im != null) image(im, -rectWidth*0.4, -rectHeight*0.4, 
                                 rectWidth*0.8, rectHeight*0.8);
      popMatrix();
      
   }
}


////



class NumModule extends Module {
  
  float value = 0;
  
  NumModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    
     
     outport = new Port(this,rectWidth/2-10/2, 0, fillColor, NUM_PORT);
  }
  
  boolean update(int updateCount) {
    if (super.update(updateCount) == false) return false;
   
       float time = (float)updateCount/300.0;
       
       
       value = noise(time);
       dirty = true;
         
       return true;
   
  }
}
