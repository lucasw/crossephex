/**
 *Description: CrossePhex is a Processing-based, Gehpex-inspired VJ app
 *Authors: BinaryMillenium, VirtualFlavius
 *Notes: this is very preliminary code
 *
 * 
 */
import java.util.ArrayList;

//ArrayList<module> mlist = new ArrayList<module>();
ArrayList mlist = new ArrayList();

// index into mlist
int moduleSelected = -1;

void setup(){
  size(720, 576);
  frameRate(60);
  background(0);
  fill(128);
  
  
  println("Press the 'a' key to add a new module to the screen");
  
  rectMode(CENTER);

}

int findClosestModuleInDragRange(int x, int y) {
  float minDist = dist(0,0,width,height);
  int minInd = -1;
  
   for (int i = 0; i < mlist.size(); i++) {
     Module thisModule =  (Module) mlist.get(i);
     float testDist = dist(thisModule.rectX,thisModule.rectY,x,y);
     
     if ((testDist < minDist) && thisModule.inDragRange(x,y) ) {
       minDist = testDist; 
       minInd  = i; 
     }
   }
   
   return minInd;
}

void draw(){
  background(0);
  
  for (int i = 0; i < mlist.size(); i++) {
    Module thisModule =  (Module) mlist.get(i);
    
    thisModule.display(i == moduleSelected);  
    
    /// draw the lines that connect ports
    for (int j = 0; j < thisModule.outport.mlist.size(); j++) {
      Module endModule = (Module) thisModule.outport.mlist.get(j);
      line(thisModule.rectX+thisModule.outport.x,thisModule.rectY,
           endModule.rectX,endModule.rectY);
    }
  }
  
}

void keyPressed() {
  if (key == 'a') {
      mlist.add(new Module(mouseX,mouseY,48,48,32)  );
  }
  
  if (key == 's') {
      mlist.add(new ImageSourceModule(mouseX,mouseY,48,48,32,"test.png")  );
  }
}



public void mouseDragged(){
  
  if (mouseButton == LEFT) {
  int ind = findClosestModuleInDragRange(mouseX,mouseY);
  
  if (ind >= 0) {
    Module thisModule = (Module) mlist.get(ind);
    thisModule.drag(mouseX,mouseY); 
    moduleSelected = ind;
  } else {
    moduleSelected = -1;
  }
  }
}

public void mousePressed() {
  
   if (mouseButton == LEFT) {
  int ind = findClosestModuleInDragRange(mouseX,mouseY);
  
  if (ind >= 0) {
    moduleSelected = ind;
  } else {
    moduleSelected = -1;
  }
  }
  
   if (mouseButton == RIGHT) {
     /// connect an output port to another module
     int ind = findClosestModuleInDragRange(mouseX,mouseY);
  
     if ((moduleSelected >= 0) && (ind >= 0)) {
       Module startModule = (Module) mlist.get(moduleSelected);
       Module endModule   = (Module) mlist.get(ind);
       
       startModule.outport.mlist.add(endModule);
     }
     
   }
}
 
public void mouseReleased(){
 cursor(ARROW);
 
}
