/**
 *Description: CrossePhex is a Processing-based, Gehpex-inspired VJ app
 *Authors: BinaryMillenium, VirtualFlavius
 *Notes: this is very preliminary code
 *
 * 
 */
import java.util.ArrayList;

ArrayList mlist = new ArrayList();
// this holds all outputs that if active need to be updated, and all
// modules connected to them need to be updated.
ArrayList activeOutputs = new ArrayList();

// index into mlist
int moduleSelected = -1;

void setup(){
  size(720, 576);
  frameRate(60);
  background(0);
  fill(128);
  
  
  println("Press the 'a' key to add a new module to the screen \n" +
 "select a module with the left mouse button and connect it to another module with \n" +
 "the right mouse button");
  
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

int updateCount = 0;

void draw(){
  
  background(0);
  
  updateCount++;
  
  /// recursively update modules that are connected to active displays
  for (int i = 0; i < activeOutputs.size(); i++) {
    Module thisModule =  (Module) activeOutputs.get(i);
      
    thisModule.update(updateCount);
    

  }
  
  /// draw all modules, even if they aren't being updated
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


/// TBD need to prevent modules that have no input capability from being connected
boolean connectModule() {
  /// connect an output port to another module's input port
     int ind = findClosestModuleInDragRange(mouseX,mouseY);
  
     if ((moduleSelected >= 0) && (ind >= 0)) {
       Module startModule = (Module) mlist.get(moduleSelected);
       Module endModule   = (Module) mlist.get(ind);
        
       /// inports can only support one input,
       // so clear out anything connected to it before adding this one
       for (int j = 0; j < endModule.inport.mlist.size(); j++) {
          Module otherConnectedModule = (Module) endModule.inport.mlist.get(j);
          int removeind = otherConnectedModule.outport.mlist.indexOf(endModule);
          
          if (removeind >= 0) { 
            otherConnectedModule.outport.mlist.remove(removeind);
             /// TBD may screw up for loop?  But for loop should only ever run once
            endModule.inport.mlist.remove(j); 
          } else {
            println("failed to find module for removal, probably a bug"); 
            return false;  
          }
       }
       
       /// add links going in both direction
       startModule.outport.mlist.add(endModule);
       endModule.inport.mlist.add(startModule);
       return true;
     }
     
     return false;
}

boolean selectModule() {
    int ind = findClosestModuleInDragRange(mouseX,mouseY);
  
  if (ind >= 0) {
    moduleSelected = ind;
  } else {
    moduleSelected = -1;
    return false;
  }
  
  return true;
}

///////////////////////////////////////////////////////////////////////////////
// UI stuff

void keyPressed() {
  if (key == 'a') {
      mlist.add(new Module(mouseX,mouseY,48,48,32)  );
  }
  
  if (key == 's') {
      mlist.add(new ImageSourceModule(mouseX,mouseY,48,48,32,"test.png")  );
  }
  
   
  if (key == 'd') {
      ImageOutputModule newmod = new ImageOutputModule(mouseX,mouseY,88,88,32)  ;
      mlist.add(newmod);
      activeOutputs.add(newmod);
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
    selectModule();
  }
  
   if (mouseButton == RIGHT) {
     connectModule();
   }
}
 
public void mouseReleased(){
 cursor(ARROW);
 
}


