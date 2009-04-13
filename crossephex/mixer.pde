

class ImageMixerModule extends Module {
   
  float mix = 0.5;
  
  
  int mode = BLEND;
  
  ImageMixerModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    fillColor = color(110,150,149);
    
     outport = new Port(this,rectWidth/2-10/2, 0, fillColor,IMAGE_PORT);
     
     Port inport1 = new Port(this,-rectWidth/2+10/2, 0, fillColor,IMAGE_PORT);
     inports.add(inport1);
     
     Port inport2 = new Port(this,-rectWidth/2+10/2,12, fillColor,IMAGE_PORT);
     inports.add(inport2);
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
    
    /// this sets the alpha channel manually to a single value.
    /// TBD also allow true alpha channel to be used, also be able to manipulate that
    /// alpha channel more.
    for (int i = 0; i <im2.height; i++) {
    for (int j = 0; j <im2.width; j++) {
      int pixind = i*im2.width+j;
      im2.pixels[ pixind ] = color(red( im2.pixels[ pixind ]),
                                     green( im2.pixels[ pixind ]),
                                     blue( im2.pixels[ pixind ]),mix*255.09);    
    }}
    newim.blend(im2, 0,0, im2.width,im2.height, 0,0, newim.width, newim.height, mode );
    
    
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
