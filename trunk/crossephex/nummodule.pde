


class NumModule extends Module {
  
  float value = 0;
  float fspeed = 1.0;
   float fscale = 2.0;
  
  NumModule(int rX, int rY, int rH, int rW, int dM) {   
    super(rX, rY, rH, rW, dM);
    
     
     outport = new Port(this,rectWidth/2-10/2, 0, fillColor, NUM_PORT);
  }
  
  void right() {
    fspeed *= 1.1;
  }
  
  void left() {
    fspeed /= 1.1;
  }
  
  void up() {
    fscale *= 1.05;
  }
  
  void down() {
    fscale /= 1.05;
  }
  
    void display(boolean isSelected) {
    super.display(isSelected);
    
    pushMatrix();
    translate(rectX,rectY);
   
    
    fill(120,160,140);
    rect(-rectWidth/2+rectWidth*value/2,rectHeight/2, rectWidth*value, 10);
    
    popMatrix();
  }
  
  boolean update(int updateCount) {
    if (super.update(updateCount) == false) return false;
   
       float time = (float)updateCount/30.0*fspeed;
       
       
       value = fscale*(noise(time)-0.5);
       dirty = true;
         
       return true;
   
  }
}
