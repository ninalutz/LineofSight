// The Wall and Walls classes contain 2-dimensional line segments that represent walls that are opaque to light.  
// Variables within Wall and Walls classes assist in the calculation of an area of sight calculated from a single light "source" location fed into the "sweep()" function.
// The bulk of the logic for the area of sight algorithm is located within the "sweep()" method.
// This Algorithm was adapted by Ira Winder after viewing the blog posted by RedBlobGames: http://www.redblobgames.com/articles/visibility/

class Walls {
  
  // a "Wall" is a line defined by two points
  ArrayList<Wall> walls;
  
  // The "endPoints" are the set of points describing where walls begin in end.
  // Redundant endPoints (where two or more walls share an endPoint) are combined.  
  // endPoints are sorted radially and clockwise.
  ArrayList<EndPoint> endPoints, sortedEndPoints;
  
  int counter = 0; // counts how many walls have been added to class
  
  Walls() {
    walls = new ArrayList<Wall>();
    endPoints = new ArrayList<EndPoint>();
    sortedEndPoints = new ArrayList<EndPoint>();
  }
  
  void addWall(PVector begin, PVector end) {
    
    walls.add(new Wall(begin, end, counter));
    addEndPoint(begin, counter);
    addEndPoint(end, counter);
    
    counter++;
  }
  
  void addEndPoint(PVector point, int index) {
    boolean duplicate = false;
    for (int i=0; i<endPoints.size(); i++) {
      if (point.x == endPoints.get(i).location.x && point.y == endPoints.get(i).location.y) {
        duplicate = true;
        endPoints.get(i).addIndex(index);
        break;
      }
    }
    if (!duplicate) {
      endPoints.add(new EndPoint(point, index));
    }
  }
  
  int lastNearest;
  int lastDrawn;
  
  ArrayList<PVector> sweep(PVector source) {
    
    ArrayList<PVector> LineOfSight = new ArrayList<PVector>();
    
    // Calculate EndPoint angels from source
    for (int i=0; i<endPoints.size(); i++) {
      endPoints.get(i).sourceAngle(source);
    }
    
    // Calculate Average Distance of each wall from Source
    for (int i=0; i<walls.size(); i++) {
      walls.get(i).sweepStatus = 0;
      walls.get(i).sourceAvgDistance(source);
    }
    
    // Sort endPoints by angle from source
    sortedEndPoints.clear();
    boolean sorted;
    sortedEndPoints.add(endPoints.get(0));
    for (int i=1; i<endPoints.size(); i++) {
      sorted = false;
      for (int j=0; j<sortedEndPoints.size(); j++) {
        if (sortedEndPoints.get(j).angle > endPoints.get(i).angle) {
          sortedEndPoints.add(j, endPoints.get(i));
          sorted = true;
          break;
        }
      }
      if (!sorted) { // Adds to end of array since no large value found
        sortedEndPoints.add(endPoints.get(i));
      }
    } // Finished Sorting endPoints
    
    // Iterate through Endpoints, finding wall intersections
    ArrayList<Integer> intersectedWalls = new ArrayList<Integer>();
    ArrayList<Boolean> intersectedEndPoint = new ArrayList<Boolean>();
    for (int p=0; p<sortedEndPoints.size()+1; p++) {
      int e = p%sortedEndPoints.size();
      intersectedWalls.clear();
      intersectedEndPoint.clear();
      
      // Adds walls already known to be associated with selected endPoints
      for (int i=0; i<sortedEndPoints.get(e).indices.size(); i++) {
        intersectedWalls.add(sortedEndPoints.get(e).indices.get(i));
        intersectedEndPoint.add(true);
        walls.get(sortedEndPoints.get(e).indices.get(i)).intersect = sortedEndPoints.get(e).location;
        walls.get(sortedEndPoints.get(e).indices.get(i)).sourceDistance(source, sortedEndPoints.get(e).location);
        walls.get(sortedEndPoints.get(e).indices.get(i)).sweepStatus++;
      }
      
      // Looks for Wall Intersections that aren't already at endpoints
      for (int w=0; w<walls.size(); w++) {
        boolean duplicate = false;
        for (int i=0; i<intersectedWalls.size(); i++) {
          if (intersectedWalls.get(i) == w) {
            duplicate = true;
          }
        }
        if (!duplicate) {
          
          if ( rayLineIntersect(walls.get(w), source, sortedEndPoints.get(e)) ) {
            intersectedWalls.add(walls.get(w).index);
            intersectedEndPoint.add(false);
          }
        }
      } // Finished populating walls with intersections for a given endpoint
      
      // Sort Wall Intersections by distance.  First by absolute distance, then by avgDistance if absolute distance is the same.
      ArrayList<Integer> sortedIntersectedWalls = new ArrayList<Integer>();
      ArrayList<Boolean> sortedIntersectedEndPoint = new ArrayList<Boolean>();

      sortedIntersectedWalls.clear();
      sortedIntersectedEndPoint.clear();
      sortedIntersectedWalls.add(intersectedWalls.get(0));
      sortedIntersectedEndPoint.add(intersectedEndPoint.get(0));
      for (int i=1; i<intersectedWalls.size(); i++) {
        sorted = false;
        for (int j=0; j<sortedIntersectedWalls.size(); j++) {
          if (walls.get(sortedIntersectedWalls.get(j)).distance > walls.get(intersectedWalls.get(i)).distance) {
            sortedIntersectedWalls.add(j, intersectedWalls.get(i));
            sortedIntersectedEndPoint.add(j, intersectedEndPoint.get(i));
            sorted = true;
            break;
          }
        }
        if (!sorted) { // Adds to end of array since no large value found
          sortedIntersectedWalls.add(intersectedWalls.get(i));
          sortedIntersectedEndPoint.add(intersectedEndPoint.get(i));
        }
      } // Finished Sorting endPoints
      
      // Calculate nearest wall for each endpoint
      int nearest = sortedIntersectedWalls.get(0);
      boolean nearestIsEndpoint = sortedIntersectedEndPoint.get(0);
      
      int secondNearest = 0;
      boolean secondNearestIsEndpoint = true;
      
      if (sortedIntersectedWalls.size() > 1) {
        secondNearest = sortedIntersectedWalls.get(1);
        secondNearestIsEndpoint = sortedIntersectedEndPoint.get(1);
      }
      
      if (debug) {
        println("endPoint " + e + "; nearest: " + nearest);
        println("endPoint " + e + "; nearestIsEndpoint: " + nearestIsEndpoint);
        println("endPoint " + e + "; secondNearest: " + secondNearest);
        println("endPoint " + e + "; secondNearestIsEndpoint: " + secondNearestIsEndpoint);
        println(".");
      }
      
      // Add Points to LineOfSite based upon current step of sweep 
      // Line of Sight Draw Logic ...
        if (p == 0) {
          LineOfSight.add(walls.get(nearest).intersect);
        } else {
          if (nearest != lastDrawn) {
            if (!secondNearestIsEndpoint) {
              LineOfSight.add(walls.get(secondNearest).intersect);
            }
            LineOfSight.add(walls.get(nearest).intersect);
            lastDrawn = nearest;
          } else if (nearest == lastDrawn && nearestIsEndpoint) {
            LineOfSight.add(walls.get(nearest).intersect);
            lastDrawn = nearest;
            if (!secondNearestIsEndpoint) {
              LineOfSight.add(walls.get(secondNearest).intersect);
              lastDrawn = secondNearest;
            }
          }
        }
        
        lastNearest = nearest;
    }
    
    if (debug) {
      println("---");
    }
    return LineOfSight;
  }
  
  // Function that calculates a possible intersection point of a ray to a given Wall
  boolean rayLineIntersect(Wall wall, PVector source, EndPoint point) {
    
//    println("rayLineTesting..");
    boolean over = false;
    
    float x1 = wall.begin.x;
    float y1 = wall.begin.y;
    float x2 = wall.end.x;
    float y2 = wall.end.y;
    
    float x3 = source.x;
    float y3 = source.y;
    
    PVector direction = new PVector(point.location.x, point.location.y);
    direction.sub(source);
    direction.setMag(width+height);
    float x4 = source.x+direction.x;
    float y4 = source.y+direction.y;
    
    if (debug) {
      stroke(#0000FF);
      line(x1, y1, x2, y2);
      line(x3, y3, x4, y4);
    }

    float a1 = y2 - y1;
    float b1 = x1 - x2;
    float c1 = a1*x1 + b1*y1;
  
    float a2 = y4 - y3;
    float b2 = x3 - x4;
    float c2 = a2*x3 + b2*y3;
  
    float det = a1*b2 - a2*b1;
    if(det == 0){
      // Lines are parallel
    } 
    else {
      float x = (b2*c1 - b1*c2)/det;
      float y = (a1*c2 - a2*c1)/det;
//      println(x, y);
      float tolerance = 0.01;
      if(x >= min(x1, x2) -tolerance && x <= max(x1, x2) +tolerance && 
         x >= min(x3, x4) -tolerance && x <= max(x3, x4) +tolerance &&
         y >= min(y1, y2) -tolerance && y <= max(y1, y2) +tolerance &&
         y >= min(y3, y4) -tolerance && y <= max(y3, y4) +tolerance ){
        over = true; 
        wall.intersect = new PVector(x, y);
        wall.distance = sqrt(sq(x-source.x) + sq(y-source.y));
      }
    }
    return over;
  }
  
  void display() {
    for (int i=0; i<walls.size(); i++)
      walls.get(i).display();
    for (int i=0; i<endPoints.size(); i++) {
      if (debug)
        sortedEndPoints.get(i).display(i);
    }
  }
  
  class EndPoint {
    PVector location;
    float angle, distance;
    ArrayList<Integer> indices; // variable to cross-reference endpoint with wall or walls that it corresponds to
    
    EndPoint(PVector location, int index) {
      this.location = new PVector();
      this.location = location;
      
      indices = new ArrayList<Integer>();
      indices.add(index);
      
      angle = 0;
    }
    
    void addIndex(int index) {
      boolean duplicate = false;
      for (int i=0; i<indices.size(); i++) {
        if (index == indices.get(i)) 
          duplicate = true;
      }
      if (!duplicate) 
        indices.add(index);
    }
    
    void sourceAngle(PVector source) {
      angle = atan( (location.x-source.x) / (location.y-source.y) );
      angle += 0.5*PI;
      angle = PI-angle;
      if (location.y-source.y > 0)
        angle += PI;
    }
    
    void display(int id) {
      fill(#FF0000);
      noStroke();
      ellipse(location.x, location.y, 10, 10);
      for (int i=0; i<indices.size(); i++) {
        text(indices.get(i), location.x+10, location.y+(1+i)*15);
        text(angle, location.x+10, location.y+(-1)*15);
      }
      fill(#FFFFFF);
      // Display clockwise ranking of EndPoint, starting from 9 o'clock
      text(id, location.x+10, location.y+(-2)*15);
     
    }
  }
 
}

class Wall {
  PVector begin;
  PVector end;
  PVector intersect;
  float avgDistance, distance;
  int index;
  int sweepStatus = 0; // 0 = not swept; 1 = first endpoint swept; 2 = second endpoint swept
  
  Wall(PVector begin, PVector end, int index) {
    this.begin = begin;
    this.end = end;
    this.index = index;
  }
  
  void sourceAvgDistance(PVector source) {
    float avgX = 0.5 * ( begin.x + end.x );
    float avgY = 0.5 * ( begin.y + end.y );   
    avgDistance = sqrt(sq(avgX-source.x) + sq(avgY-source.y));
  }
  
  void sourceDistance(PVector source, PVector point) {
    distance = sqrt(sq(point.x-source.x) + sq(point.y-source.y));
  }
  
  void display() {
    stroke(#00FF00);
    strokeWeight(7);
    fill(#00FF00);
    line(begin.x, begin.y, end.x, end.y);
    strokeWeight(1);
    if (debug) {
      text(index, (begin.x + end.x ) / 2.0 + 10, (begin.y + end.y ) / 2.0 + 15);
      text(avgDistance, (begin.x + end.x ) / 2.0 + 10, (begin.y + end.y ) / 2.0 + 2*15);
      text(distance, (begin.x + end.x ) / 2.0 + 10, (begin.y + end.y ) / 2.0 + 3*15);
    }
  }
}
