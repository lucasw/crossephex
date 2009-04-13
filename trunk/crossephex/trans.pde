

class ImageTranslateModule extends Module {

  float offsetX = 0;
  float offsetY = 0;
  
  ImageTranslateModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    
    outport = new Port(this,rectWidth/2-10/2, 0, fillColor, IMAGE_PORT);
   
    Port inport1 = new Port(this,-rectWidth/2+10/2, 0, fillColor, IMAGE_PORT);
    inports.add(inport1);
    
    Port number_port_lr = new Port(this,0,-rectHeight/2+10/2, fillColor, NUM_PORT);
    number_inports.add(number_port_lr);
    Port number_port_ud = new Port(this,15,-rectHeight/2+10/2, fillColor, NUM_PORT);
    number_inports.add(number_port_ud);
  }
     
  void right() {
    offsetX += 0.1;
    if (offsetX > 1.0) offsetX = 1.0; 
  }
  
  void left() {
    offsetX -= 0.1; 
    if (offsetX < -1.0) offsetX = -1.0;
  }

  void down() {
    offsetY += 0.1;
    if (offsetY > 1.0) offsetY = 1.0; 
  }
  
  void up() {
    offsetY -= 0.1; 
    if (offsetY < -1.0) offsetY = -1.0;
  }
  
  boolean update(int updateCount) {
    if (super.update(updateCount) == false) return false;
  
        
        /// get number inputs if any
        {
        Port numport = (Port) number_inports.get(0);
        
        if (numport.mlist.size() > 0) {
        Port numconn = ((Port)numport.mlist.get(0));
        if (numconn != null) {
              
           NumModule numModule = (NumModule) numconn.parentModule;
           
           if (numModule != null) {
             dirty = true;       
             offsetX = numModule.value;
             
             //println(offsetX);
           }
        } 
        }
        
        }
        {
                /// get number inputs if any
        Port numport = (Port) number_inports.get(1);
        
        if (numport.mlist.size() > 0) {
        Port numconn = ((Port)numport.mlist.get(0));
        if (numconn != null) {
              
           NumModule numModule = (NumModule) numconn.parentModule;
           
           if (numModule != null) {
             dirty = true;       
             offsetY = numModule.value;
           }
        } 
        }
        }
  
       // copy image from parent
         if (inports.size() < 1)  return false;  
         
         Port inport = (Port) inports.get(0);
         
         if (inport.mlist.size() < 1)  return false;
       
         Module parent =  ((Port) inport.mlist.get(0)).parentModule;
           
           if (parent.im == null) return false;
           
           //println("trans");
           if (!dirty && !parent.dirty) return true;
           //println("trans dirty");
           dirty = true;       
           
            if ((im == null) || 
             (parent.im.width  != im.width) || 
             (parent.im.height != im.height)) {
             im = createImage(parent.im.width,parent.im.height,RGB); 
            }
            im.copy(parent.im,(int)(im.width*offsetX),
                              (int)(im.height*offsetY),parent.im.width,
                              parent.im.height, 0,0,im.width, im.height);
    
    
    
    return true;
  }
}

