

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
           
            if ((im == null) || 
             (parent.im.width  != im.width) || 
             (parent.im.height != im.height)) {
             im = createImage(parent.im.width,parent.im.height,RGB); 
            }
            im.copy(parent.im,offsetX,offsetY,parent.im.width, parent.im.height, 0,0,im.width, im.height);
            
  /*
    if (im != null) {
      if ((toUpdate.im == null) || 
         (toUpdate.im.width  != im.width) || 
         (toUpdate.im.height != im.height)) {
            toUpdate.im = createImage(im.width, im.height, RGB);
      }
      toUpdate.im.copy(im,offsetX,offsetY,im.width, im.height, 0,0,toUpdate.im.width, toUpdate.im.height);
    }
    */
    
    return true;
  }
}

