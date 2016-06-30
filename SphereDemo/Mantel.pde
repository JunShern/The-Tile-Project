
class Mantel {
  int radius;
  color colour;
  Globe parentGlobe;
  
  Mantel (Globe parentGlobe_, int radius_, color colour_) {
    parentGlobe = parentGlobe_;
    radius = radius_;
    colour = colour_;
  }
  
  void drawMantel() {
    // Mesh sphere
    noFill();
    colorMode(HSB, 255);
    stroke(hue(colour), 20, 120);
    colorMode(RGB, 255);
    strokeWeight(1);
    sphereDetail(int(parentGlobe.privateLayerZoom)); 
    sphere(radius);
    // Low-opacity white sphere to fade out the inside
    sphereDetail(100);
    fill(brightness(colour), 255*parentGlobe.privateLayerZoom/70);
    noStroke();
    sphere(radius);
    // Protrusions
    stroke(100,100,105);
    strokeWeight(1);
    fill(100,100,105);
    
    for (int phi=0; phi<360; phi+=10) {
      for (int theta=0; theta<360; theta+=5) {
        int r = 240;
        beginShape();
        vertex(0,0,0);
        for (int i=0; i<1; i++) {
          for (int j=0; j<1; j++) {
            int p = constrain(phi+i,0,360);
            int t = constrain(theta+j,0,360);
            float x = getX(r, p, t);
            float y = getY(r, p, t); 
            float z = getZ(r, p, t);
            vertex(x, y, z);
          }
        }
        endShape();
      }
    }
      
  }
  
  float getX(int r, int phi, int theta) {
    return r*sinLUT[phi]*sinLUT[theta];
  }
  float getY(int r, int phi, int theta) {
    return r*cosLUT[phi];
  }
  float getZ(int r, int phi, int theta) {
    return r*sinLUT[phi]*cosLUT[theta];
  }
  
}

