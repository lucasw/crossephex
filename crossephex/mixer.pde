

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
        
    
    if (im1 == null) return false;
    if (im2 == null) return false;
    
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
    
    for (int i = 0; i <im2.height; i++) {
    for (int j = 0; j <im2.width; j++) {
      int pixind = i*im2.width+j;
      im2.pixels[ pixind ] = color(red( im2.pixels[ pixind ]),
                                     green( im2.pixels[ pixind ]),
                                     blue( im2.pixels[ pixind ]),mix*255.09);    
    }}
    newim.blend(im2, 0,0, im2.width,im2.height, 0,0, newim.width, newim.height, BLEND );
    
    
    /// buffer the output in case one of the inputs is also the output
     if ((im == null) || 
             (newim.width  != im.width) || 
             (newim.height != im.height)) {
             im = createImage(newim.width,newim.height,RGB); 
     }
     im.copy(newim,0,0,newim.width, newim.height, 0,0,im.width, im.height);


    
    
    /*
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
*/


     return true;
  }
}
