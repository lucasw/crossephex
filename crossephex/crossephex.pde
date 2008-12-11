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
//Module theModule;

void setup(){
  size(720, 576);
  frameRate(60);
  background(0);
  fill(128);
  stroke(255);
  
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
    thisModule.display();  
  }
  
}

void keyPressed() {
  if (key == 'a') {
      mlist.add(new Module(mouseX,mouseY,48,48,32)  );
  }
}



public void mouseDragged(){
  int ind = findClosestModuleInDragRange(mouseX,mouseY);
  
  if (ind >= 0) {
    Module thisModule = (Module) mlist.get(ind);
    thisModule.drag(mouseX,mouseY); 
  }
}
 
public void mouseReleased(){
 cursor(ARROW);
 fill(128);
}
