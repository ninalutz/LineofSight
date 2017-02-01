//  The following class allows a user to define a polygon in 2D space.  
//  Key utility method of the class allows one to test whether or not a point lies inside or outside of the polygon
//
//  USAGE:
//  Call precalc_values() to initialize the constant[] and multiple[] arrays,
//  then call pointInPolygon(x, y) to determine if the point is in the polygon.
//
//  The function will return YES if the point x,y is inside the polygon, or
//  NO if it is not.  If the point is exactly on the edge of the polygon,
//  then the function may return YES or NO.
//
//  Note that division by zero is avoided because the division is protected
//  by the "if" clause which surrounds it.
  
boolean editObstacles = false;

class Obstacle {
  
  //vertices and of a polygon obstacles
  ArrayList<PVector> v;
  
  //lengths of side of a polygon obstacle
  ArrayList<Float> l;
  
  boolean active = true;
  
  boolean drawOutline;
  
  int polyCorners; //  =  how many corners the polygon has (no repeats)
  int index;
  float minX, minY, maxX, maxY;
  
  //
  //  The following global arrays should be allocated before calling these functions:
  //
  ArrayList<Float>  constant; // = storage for precalculated constants (same size as polyX)
  ArrayList<Float>  multiple; // = storage for precalculated multipliers (same size as polyX)
  
  Obstacle (ArrayList<PVector> vert) {
    
    v = new ArrayList<PVector>();
    l = new ArrayList<Float>();
    
    constant = new ArrayList<Float>();
    multiple = new ArrayList<Float>();
    
    drawOutline = false;
    
    polyCorners = vert.size();
    index = 0;
    
    for (int i=0; i<vert.size(); i++) {
      v.add(new PVector(vert.get(i).x, vert.get(i).y));
    }
    
    if (polyCorners > 2) {
      calc_lengths();
      precalc_values();
    }
    
  }
  
  Obstacle () {

    v = new ArrayList<PVector>();
    l = new ArrayList<Float>();
    
    constant = new ArrayList<Float>();
    multiple = new ArrayList<Float>();
    
    drawOutline = false;
    
    polyCorners = 0;
    index = 0;
      
    }
  
  void calc_lengths() {
    
    l.clear();
    
    // Calculates the length of each edge in pixels
    for (int i=0; i<v.size(); i++) {
      if (i < v.size()-1 ){
        l.add(sqrt( sq(v.get(i+1).x-v.get(i).x) + sq(v.get(i+1).y-v.get(i).y)));
      } else {
        l.add(sqrt( sq(v.get(0).x-v.get(i).x) + sq(v.get(0).y-v.get(i).y)));
      }
    }
  }
  
  void nextIndex() {
    index = afterIndex();
  }
  
  int priorIndex() {
    if (v.size() == 0) {
      return 0;
    } else if (index == 0) {
      return v.size()-1;
    } else {
      return index - 1;
    }
  }
  
  int afterIndex() {
    if (v.size() == 0) {
      return 0;
    } else if (index >= v.size()-1) {
      return 0;
    } else {
      return index + 1;
    }
  }
  
  void precalc_values() {
  
    int   i, j=polyCorners-1 ;
  
    constant.clear();
    multiple.clear();
  
    for(i=0; i<polyCorners; i++) {
      if(v.get(j).y==v.get(i).y) {
        constant.add(v.get(i).x);
        multiple.add(0.0); 
      } else {
        constant.add(v.get(i).x-(v.get(i).y*v.get(j).x)/(v.get(j).y-v.get(i).y)+(v.get(i).y*v.get(i).x)/(v.get(j).y-v.get(i).y));
        multiple.add((v.get(j).x-v.get(i).x)/(v.get(j).y-v.get(i).y)); 
      }
      j=i; 
    }
  }
  
  void addVertex(PVector vert) {
    polyCorners++;
    if(index == v.size()-1) {
      v.add(vert);
    } else {
      v.add(afterIndex(), vert);
    }
    index = afterIndex();
    if (polyCorners > 2) {
      calc_lengths();
      precalc_values();
    }
  }
  
  void nudgeVertex(int x, int y) {
   PVector vert = v.get(index);
   vert.x += x;
   vert.y += y;
   
   v.set(index, vert);
  }
  
  void removeVertex(){
    if (polyCorners > 0) {
      polyCorners--;
      v.remove(index);
      index = priorIndex();
      if (polyCorners > 2) {
        calc_lengths();
        precalc_values();
      }
    }
  }
  
  // Calculates whether a given point is inside of an Obstacle
  boolean pointInPolygon(float x, float y) {
    
    if (polyCorners > 2) {
      int   i, j = polyCorners-1;
      boolean  oddNodes = false;
    
      for (i=0; i<polyCorners; i++) {
        if ((v.get(i).y< y && v.get(j).y>=y
        ||   v.get(j).y< y && v.get(i).y>=y)) {
          oddNodes^=(y*multiple.get(i) + constant.get(i)<x); 
        }
        j=i; 
      }
    
      return oddNodes; 
    } else {
      return false;
    }
    
  }
  
  
  void display() {
    
    color stroke = #FFFFFF;
    int alpha = 255;
    
    if (polyCorners > 1) {
      // Draws Polygon Ouline
      
      // Display LineOfSight
      beginShape();
      fill(#FFFF00);
      noStroke();
      if (drawOutline) stroke(#FFFFFF);
      for (int i=0; i<v.size(); i++) {
        vertex(v.get(i).x, v.get(i).y);
      }
      endShape();
      
    }
  }
  
}
  
