

class ImageMixerModule extends Module {
   
  float mix = 0.5;
  float oldMix = 0.0;
  
  PImage msk;
  PImage mskbig;
  
  int mode = BLEND;
  
  ImageMixerModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    fillColor = color(110,150,149);
    
    /// a 1x1 image doesn't work
    msk = createImage(2,2,RGB);
    mskbig = createImage(2,2,RGB);
    
     outport = new Port(this,rectWidth/2-10/2, 0, fillColor,IMAGE_PORT);
     
     Port inport1 = new Port(this,-rectWidth/2+10/2, 0, fillColor,IMAGE_PORT);
     inports.add(inport1);
     
     Port inport2 = new Port(this,-rectWidth/2+10/2,12, fillColor,IMAGE_PORT);
     inports.add(inport2);
     
     
     Port number_port_mix = new Port(this,0,-rectHeight/2+10/2, fillColor, NUM_PORT);
     number_inports.add(number_port_mix);
  }

  void right() {
    super.right();
    mix += 0.01;
    if (mix > 1.0) mix = 1.0;

  }
  
  void left() {
    super.left();
    mix -= 0.01;
    if (mix < 0.0) mix = 0.0;

  }
  
  void up() {
    mode *= 2;
    
    
    if (mode > 8192) mode = 1;
    println("blendmode " + mode);
  }
  
  void down() {
    mode /= 2;
    
    if (mode < 1) mode = 8192;
    println("blendmode " + mode);
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
             mix = 0.5*(numModule.value +1.0);
             if (mix < 0.0) mix = 0.0;
             if (mix > 1.0) mix = 1.0;
             
             //println(offsetX);
           }
        } 
        }
        }
    
    

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
        
    
    
    if (im1 == null) return false;
    if (im2 == null) return false;
   
    if (!dirty && !cport1.parentModule.dirty && !cport2.parentModule.dirty) {
        return true;
    }
    
    dirty = true;
    
    PImage newim;
    
    int w;
    int h;
    if ( im != null) {
    newim = createImage(im.width,im.height,RGB);
    
     w = min(im1.width, im2.width,im.width);
     h = min(im1.height,im2.height,im.height);
    
    } else {
         
    
     w = min(im1.width, im2.width);
     h = min(im1.height,im2.height);
     newim = createImage(w,h,RGB);
    }
    //println(im1.width + " " + im2.width + " " + im.width);
    
    newim.copy( im1, 0,0, im1.width,im1.height,  0,0, newim.width, newim.height);
    
    // no tint for pimage
    //im2.tint(255,255,255,int(mix*255.0));
    
    /// quickest tint I could come up with
    if ((abs(255.0*(mix - oldMix)) >= 1.0) || 
        (mskbig.width != im2.width) || 
        (mskbig.height != im2.height)) { 
      msk.pixels[0] = color(mix*255.0,mix*255.0,mix*255.0,mix*255.0);
      msk.pixels[1] = color(mix*255.0,mix*255.0,mix*255.0,mix*255.0);
      msk.pixels[2] = color(mix*255.0,mix*255.0,mix*255.0,mix*255.0);
      msk.pixels[3] = color(mix*255.0,mix*255.0,mix*255.0,mix*255.0);
       
      mskbig = createImage(im2.width,im2.height,RGB);
      mskbig.copy(msk,0,0,msk.width,msk.height, 0,0,mskbig.width,mskbig.height);
      
      oldMix = mix;
    }
    
    

    
    PImage newim2 = createImage(im2.width,im2.height,RGB);
    newim2.copy(im2,0,0,im2.width,im2.height, 0,0,newim2.width,newim2.height);
    newim2.mask(mskbig);
    
    newim.blend(newim2, 0,0, newim2.width,newim2.height, 0,0, newim.width, newim.height, mode );
    
   //// newim.copy(msk,0,0,msk.width,msk.height,  0,0, newim.width, newim.height);
    
    /// buffer the output in case one of the inputs is also the output
     if ((im == null) || 
             (newim.width  != im.width) || 
             (newim.height != im.height)) {
             im = createImage(newim.width,newim.height,RGB); 
     }
     im.copy(newim,0,0,newim.width, newim.height, 0,0,im.width, im.height);
     
     
     pushMatrix();
     fill(100,220,100);
     text( mode, 0,0);
     popMatrix();

     return true;
  }
}
