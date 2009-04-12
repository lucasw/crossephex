
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
    
     outport = new Port(this,rectWidth/2-10/2, 0, fillColor, IMAGE_PORT);
    
  }
  
  void toggle() {
    super.toggle();
    
    for (int i = curind+1; i < curind+files.length; i++) {
      int newind = i%files.length;
      im = loadImage(folderName + "/" + files[newind]);
      if (im != null) { 
        curind = newind; 
        break;
      }
    }
  }
  
  void display(boolean isSelected) {
    super.display(isSelected);
    
     
  
  }
  
  boolean update(int updateCount) {
     if (super.update(updateCount) == false) return false;  
 
    return true;   
  }
}

