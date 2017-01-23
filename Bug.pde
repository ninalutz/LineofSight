// This is a class of "bugs" that are sensitive to light

class Bug {

  // location, velocity, and acceleration
  PVector loc;
  PVector vel;
  PVector acc;
  
  float repel = 1.9;
  
  // Vector from bug to source
  PVector srcVector;
  
  // Vector describing position of head relative to loc
  PVector headLoc;
  
  Bug(float x, float y) {
    loc = new PVector();
    loc.x = x;
    loc.y = y;
    
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    headLoc = new PVector();
  }
  
  void update(boolean inLight, int X_MIN, int X_MAX, int Y_MIN, int Y_MAX, PVector source) {
    if (inLight) {
      // Hide!
      
      acc.x = random(-1, 1);
      acc.y = random(-1, 1);
      
      // Avoid Light Source
      srcVector = new PVector(source.x - loc.x, source.y - loc.y);
      if (srcVector.mag() < 100) {
        srcVector.setMag(100);
        acc.sub(srcVector);
      }
      acc.setMag(0.1);
      vel.add(acc);
      loc.add(vel);
      
    }
    
    
    // Can't hide against outer walls
    if (loc.x <= X_MIN) {
      vel.x += repel;
      loc.add(vel);
    }
    
    if (loc.x >= X_MAX) {
      vel.x -= repel;
      loc.add(vel);
    }
    
    if (loc.y <= Y_MIN) {
      vel.y += repel;
      loc.add(vel);
    }
    
    if (loc.y >= Y_MAX) {
      vel.y -= repel;
      loc.add(vel);
    }
    
  }
  
  void display() {
    
    int bodyWidth = 7;
    
    headLoc.x = vel.x;
    headLoc.y = vel.y;
    headLoc.setMag(0.75*bodyWidth);
    headLoc.add(loc);
    
    fill(#D4C3E3);
    noStroke();
    ellipse(loc.x, loc.y, bodyWidth, bodyWidth);
    ellipse(headLoc.x, headLoc.y, 0.75*bodyWidth, 0.75*bodyWidth);
  }
}
