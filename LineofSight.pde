// This Script visualizes a 2-dimensional point light's area of covereage within a landscape of opaque wall segments.
// The primary output is a complex polygon that simulates the "line of sight" from the point light.
// Shadows are represented by areas not covered by the complex polygon.

// Ira Winder, jiw@mit.edu, January 2017.

Walls map;
Light src;

// Press 'd' to show debug visualization
boolean debug = false;

// Width of margin, in pixels
int margin;

void setup() {
  size(500, 500);
  margin = 70;
  background(0);
    
  // Constructs Opaque Walls in two dimensional space
  map = new Walls();
  buildTheWalls(map, margin);
  
  // Initializes the light location in the center of the canvas
  src = new Light();
  src.setLocation(0.5*width, 0.5*height);
  src.shineLight(map);
  
  // Draw Walls
  map.display();
  // Draw Point Light with Area of Sight
  src.display();
  
  noLoop();
}

void draw() {
  background(0);
  text("2D Visibility Alorithm, Ira Winder, jiw@mit.edu", 10, 20);
  text("Move mouse within red square. Press 'd' for debug visualization.", 10, width - 20);
    
  src.setLocation(mouseX, mouseY);
  src.shineLight(map);
//  println(lightPolygon.pointInPolygon(250, 250));
  
  // Draw Walls
  map.display();
  // Draw Point Light with Area of Sight
  src.display();
  
  stroke(#FF0000);
  strokeWeight(5);
  noFill();
  rect(margin, margin, width - 2*margin, height - 2*margin);
  strokeWeight(1);
  
  noLoop();
}

// A demonstration of wall configuration
void buildTheWalls(Walls w, int border) {

  // Cursor needs to be inside of enclosed space like this for algorithm to work
  w.addWall(new PVector(border, border), new PVector(width-border, border));
  w.addWall(new PVector(width-border, border), new PVector(width-border, height-border));
  w.addWall(new PVector(width-border, height-border), new PVector(border, height-border));
  w.addWall(new PVector(border, height-border), new PVector(border, border));
  
  // Diagonal Walls
  w.addWall(new PVector(100, 300), new PVector(300, 100));
  w.addWall(new PVector(200, 300), new PVector(400, 200));

//  // Random Horizontal Walls
//  for (int i=0; i<50; i++) {
//    float xRand = random(border, width-border - 15);
//    float yRand = random(border, height-border - 15);
//    w.addWall( new PVector(xRand, yRand), new PVector(xRand + 15, yRand) );
//  }
//  
//  // Random Vertical Walls
//  for (int i=0; i<50; i++) {
//    float xRand = random(border, width-border - 15);
//    float yRand = random(border, height-border - 15);
//    w.addWall( new PVector(xRand, yRand), new PVector(xRand, yRand + 15) );
//  }

  // Dotted Horizonal Walls
  for (int i=1; i<6; i++) {
    w.addWall( new PVector(border + 60*i,350), new PVector(border + 60*i + 30, 350) );
  }

  
}

void mouseMoved() {
  loop();
}

void keyPressed() {
  switch(key) {
    case 'd': // Change horizontal 'slice' layer
      debug = !debug;
      loop();
      break;
  }
}
