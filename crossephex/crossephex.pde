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
            return;  
          }
       }
       
       /// add links going in both direction
       startModule.outport.mlist.add(endModule);
       endModule.inport.mlist.add(startModule);
     } 
   }
}
 
public void mouseReleased(){
 cursor(ARROW);
 
}
