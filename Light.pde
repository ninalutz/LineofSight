// The Light class is a composite of a PVector defining a point light's location and an Obstacle class, "lightPolygon" used to store the line of sight from the light source.
// The class needs to be used in conjuntion with the Wall and Walls classes in ourder to calculate the area covered by light in the "shineLight()" method

class Light {
  PVector location;
  Obstacle lightPolygon;
  
  Light() {
    location = new PVector();
    lightPolygon = new Obstacle();
  }
  
  void display() {
    // Draw Area of Sight
    lightPolygon.display();
  
    fill(#FFFF00);
    noStroke();
    ellipse(location.x, location.y, 10, 10);
  }

  void setLocation(float x, float y) {
    location.x = x;
    location.y = y;
  }
  
  void shineLight(Walls w) {
    // Based upon walls (w) and light source (location) Constructs a polygon of area covered by light and allocates it to an Obstacle
    lightPolygon = new Obstacle(w.sweep(location));
  }
}
