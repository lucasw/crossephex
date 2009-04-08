/**
 *Description: CrossePhex is a Processing-based, Gehpex-inspired VJ app
 *Authors: BinaryMillenium, VirtualFlavius
 *Notes: this is very preliminary code
 *
 * GNU GPL version 3
 */
import java.util.ArrayList;

ArrayList mlist = new ArrayList();
// this holds all outputs that if active need to be updated, and all
// modules connected to them need to be updated.
ArrayList activeOutputs = new ArrayList();

// index into mlist of module that is currently selected
int moduleSelected = -1;

// increment on every update
int updateCount = 0;

void setup(){
  size(720, 576);
  frameRate(30);
  background(0);
  fill(128);
  
   PFont fontA = loadFont("AlArabiya-14.vlw");
  // textMode(SCREEN);

  // Set the font and its size (in units of pixels)
  textFont(fontA, 18);
  
  println("Press the 'a' key to add a new module to the screen \n" +
   "'s' key to add a new image source\n" +
    "'d' key to add a new display module\n" +
        "'m' key to add a mixer\n" +
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

Port findClosestPort(int x, int y) {
  
  int ind = findClosestModuleInDragRange(x,y);
  if (ind < 0) return null;
  Module closeModule = (Module)mlist.get(ind);
  
  float minDist = dist(0,0,width,height);
  int minInd = -1;
  
  for (int i = 0; i < closeModule.inports.size(); i++) {
    Port inport = (Port)closeModule.inports.get(i);
      
    float testDist = dist(closeModule.rectX + inport.x,closeModule.rectY + inport.y,x,y);
    
    if (testDist < minDist) {
       minDist = testDist; 
       minInd  = i; 
    }
  }
  
  
  if (minInd >=0) return (Port)closeModule.inports.get(minInd);
  else return null;
  
}


void draw(){
  
  background(0);
  
  updateCount++;
  
  /// recursively update modules that are connected to active displays
  for (int i = 0; i < activeOutputs.size(); i++) {
    Module thisModule =  (Module) activeOutputs.get(i);
      
    thisModule.update(updateCount,null);
    

  }
  
  /// draw all modules, even if they aren't being updated
  for (int i = 0; i < mlist.size(); i++) {
    Module thisModule =  (Module) mlist.get(i);
    
    thisModule.display(i == moduleSelected);  
    
    /// draw the lines that connect ports
    if ( thisModule.outport != null) {
    for (int j = 0; j < thisModule.outport.mlist.size(); j++) {
      Port endPort = (Port) thisModule.outport.mlist.get(j);
      
      line(thisModule.rectX+thisModule.outport.x,thisModule.rectY+thisModule.outport.y,
            endPort.parentModule.rectX+endPort.x,  endPort.parentModule.rectY+endPort.y);
    }
  }
  }
    

}


/// harmless if there is no connection
boolean removeConnection(Port inport) {
   /// inports can only support one input,
   // so clear out anything connected to it before adding this one
   for (int j = 0; j < inport.mlist.size(); j++) {
      Port otherConnectedPort = (Port) inport.mlist.get(j);
      int removeind = otherConnectedPort.mlist.indexOf(inport);
      
      if (removeind >= 0) { 
        otherConnectedPort.mlist.remove(removeind);
         /// TBD may screw up for loop?  But for loop should only ever run once
        inport.mlist.remove(j); 
      } else {
        println("failed to find module for removal, probably a bug"); 
        return false;  
      }
   }
   
   return true;
}

/// TBD need to prevent modules that have no input capability from being connected
boolean connectModule() {
  /// connect an output port to another module's input port
   
   Port endPort = findClosestPort(mouseX,mouseY);
   
   if (endPort == null) return false;

   if (moduleSelected >= 0) {
     Port startPort = ((Module) mlist.get(moduleSelected)).outport;
     
     if (startPort == null) return false;
     
     removeConnection(endPort);
     
     /// add links going in both direction
     startPort.mlist.add(endPort);
     endPort.mlist.add(startPort);
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
  
  if (key == CODED) {
    if (keyCode == LEFT) {
      if (moduleSelected >= 0) {
        Module thisModule = (Module) mlist.get(moduleSelected);
        thisModule.left();
      }
    }
    if (keyCode == RIGHT) {
      if (moduleSelected >= 0) {
        Module thisModule = (Module) mlist.get(moduleSelected);
        thisModule.right();
      }
    }
  }
  
  if (key == 'a') {
      mlist.add(new Module(mouseX,mouseY,48,48,32) );
      moduleSelected = mlist.size() - 1;
  }
  
  if (key == 's') {
      mlist.add(new ImageSourceModule(mouseX,mouseY,48,48,32,sketchPath("") + "/images")  );
      moduleSelected = mlist.size() - 1;
  }
  
  if (key == 'm') {
      mlist.add(new ImageMixerModule(mouseX,mouseY,48,48,32)  );
      moduleSelected = mlist.size() - 1;
  }
  
  if (key == 'r') {
      mlist.add(new ImageTranslateModule(mouseX,mouseY,48,48,32)  );
      moduleSelected = mlist.size() - 1;
  }
  if (key == 'p') {
      mlist.add(new PassthroughModule(mouseX,mouseY,48,48,32)  );
      moduleSelected = mlist.size() - 1;
  }
  
  if (key == 't') {
    if (moduleSelected >= 0) {
      Module thisModule = (Module) mlist.get(moduleSelected);
      thisModule.toggle();
    }
  }
   
  if (key == 'd') {
      ImageOutputModule newmod = new ImageOutputModule(mouseX,mouseY,320,240,32)  ;
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


