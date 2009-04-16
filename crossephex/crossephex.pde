/**
 *Description: CrossePhex is a Processing-based, Gehpex-inspired VJ app
 *Authors: BinaryMillenium, VirtualFlavius
 *Notes: this is very preliminary code
 *
 * GNU GPL version 3
 */
import java.util.ArrayList;


// list of all modules
ArrayList mlist = new ArrayList();
// this holds all outputs that if active need to be updated, and all
// modules connected to them need to be updated.
ArrayList activeOutputs = new ArrayList();

// index into mlist of module that is currently selected
int moduleSelected = -1;

// increment on every update
int updateCount = 0;

void setup(){
  size(720, 576,P3D);
  frameRate(30);
  background(0);
  fill(128);
  
   PFont fontA = loadFont("AlArabiya-14.vlw");
  // textMode(SCREEN);

  // Set the font and its size (in units of pixels)
  textFont(fontA, 18);
  
  println("Press the 'a' key to add a new module to the screen \n" +
   "'s' image source\n" +
   "'m' image mixer\n" +
   "'n' number source\n" +
   "'r' image translate\n" +
   "'p' image passthrough\n" +
   "'d' key to add a new display module\n" +
   "'t' to toggle when a module is selected\n" +
   "arrow keys to change module parameters\n" +

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

Port findClosestPort(int x, int y, int type) {
  
  int ind = findClosestModuleInDragRange(x,y);
  if (ind < 0) return null;
  println("close module");
  
  Module closeModule = (Module)mlist.get(ind);
  
  float minDist = dist(0,0,width,height);
  int minInd = -1;
  
  if (type == IMAGE_PORT) {
  for (int i = 0; i < closeModule.inports.size(); i++) {
    Port inport = (Port)closeModule.inports.get(i);
      
    float testDist = dist(closeModule.rectX + inport.x,closeModule.rectY + inport.y,x,y);
    
    if (testDist < minDist) {
       minDist = testDist; 
       minInd  = i; 
    }
    
  }
         
    if (minInd >=0) return (Port)closeModule.inports.get(minInd);
  } else if (type == NUM_PORT) {
      for (int i = 0; i < closeModule.number_inports.size(); i++) {
    Port inport = (Port)closeModule.number_inports.get(i);
      
    float testDist = dist(closeModule.rectX + inport.x,closeModule.rectY + inport.y,x,y);
    
    if (testDist < minDist) {
       minDist = testDist; 
       minInd  = i; 
    }
  }
     
  if (minInd >=0) return (Port)closeModule.number_inports.get(minInd);
  
  }
  
  
  return null;
  
}

float avgtime = 0.0;

void draw(){
  
  int stime = millis();
  
  pushMatrix();
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
    if ( thisModule.outport != null) {
    for (int j = 0; j < thisModule.outport.mlist.size(); j++) {
      Port endPort = (Port) thisModule.outport.mlist.get(j);
      
      line(thisModule.rectX+thisModule.outport.x,thisModule.rectY+thisModule.outport.y,
            endPort.parentModule.rectX+endPort.x,  endPort.parentModule.rectY+endPort.y);
    }
    
    /// if all parents aren't dirty, this one isn't either.
    /// TBD probably a more robust way of doing this by traversing the graph, may be a few
    /// wasted cycles of updating 
    boolean any_dirty = false;
    for (int k = 0; k < thisModule.inports.size(); k++) {
        Port inport = (Port)thisModule.inports.get(k);
        
        for (int j = 0; j < inport.mlist.size(); j++) {  // should be only one
          Module otherConnectedModule = ((Port) inport.mlist.get(j)).parentModule;
          if (otherConnectedModule.dirty) {
              any_dirty = true;
              break;
          }    
        }
        
        if (any_dirty) break;
      } 
      
      /// tbd make this a function of the inports later
      for (int k = 0; k < thisModule.number_inports.size(); k++) {
        Port inport = (Port)thisModule.number_inports.get(k);
        
        for (int j = 0; j < inport.mlist.size(); j++) {  // should be only one
          Module otherConnectedModule = ((Port) inport.mlist.get(j)).parentModule;
          if (otherConnectedModule.dirty) {
              any_dirty = true;
              break;
          }    
        }
        
        if (any_dirty) break;
      } 
          
      thisModule.dirty = any_dirty;
  }
  }
    
  popMatrix();

//saveFrame("frames/cphex_#######.png");
  pushMatrix();
  
    translate(20,20);
        fill(100,200,100);
        
        avgtime =int( 0.15*(millis() - stime) + 0.85*avgtime);
        text(avgtime , 0,0);
   popMatrix();
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

/////////////////////////////////////////////////
/// TBD need to prevent modules that have no input capability from being connected
boolean connectModule() {
   /// connect an output port to another module's input port
 
   if (moduleSelected < 0) return false;
 
   Port startPort = ((Module) mlist.get(moduleSelected)).outport;
     
   if (startPort == null) return false;
   
   Port endPort = findClosestPort(mouseX, mouseY, startPort.type);
   
   if (endPort == null) return false;
      
   if (startPort.type != endPort.type) return false;
     
   removeConnection(endPort);
     
     /// add links going in both direction
     startPort.mlist.add(endPort);
     endPort.mlist.add(startPort);
     
     /// TBD slightly inefficient to dirty the parent, since other things connected
     /// don't need to be updated
     ((Module) mlist.get(moduleSelected)).dirty = true;
     return true;
   
}
///////////////////////////////////////////////////

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
  
   Module thisModule = null;
   if (moduleSelected >= 0) {
       thisModule = (Module) mlist.get(moduleSelected);
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
  
  if (key == 'n') {
      mlist.add(new NumModule(mouseX,mouseY,48,48,32)  );
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
  
  if (key == 'd') {
      ImageOutputModule newmod = new ImageOutputModule(mouseX,mouseY,250,250,32)  ;
      mlist.add(newmod);
      activeOutputs.add(newmod);
  }
  
    if (key == 't') {
    if (moduleSelected >= 0) {
      if (thisModule != null) thisModule.toggle();
    }
  }
  
  if (key == CODED) {
    if (thisModule != null) {
      if (keyCode == LEFT)  { thisModule.dirty = true; thisModule.left(); }
      if (keyCode == RIGHT) { thisModule.dirty = true; thisModule.right(); }
      if (keyCode == UP)    { thisModule.dirty = true; thisModule.up(); }
      if (keyCode == DOWN)  { thisModule.dirty = true; thisModule.down(); }
    }
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


