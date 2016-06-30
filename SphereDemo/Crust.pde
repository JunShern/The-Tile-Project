
class Crust {
  float x, y, z, r, radius, angle, a, b;
  float xRadius, yRadius, zRadius, xCenter, yCenter, zCenter;
  float xLast, yLast, zLast;
  float res, force = 0;
  boolean showVectors;

  float jelliness = 0.1;
  
  float noiseCounter = 0;
  boolean unwrap = false;
  
  float alpha = 220;
  int forceThreshold = 10000;
  color colour;
  Globe parentGlobe;
  
  Crust(Globe parentGlobe_, int radius_, color colour_) {
    xCenter = 0;
    yCenter = 0;
    zCenter = 0;
    radius = yRadius = xRadius = zRadius = radius_;
    r = 0;
    res = PI/72;
    showVectors = false;
    colour = colour_;
    parentGlobe = parentGlobe_;
  }

  void drawCrust() {
    if (force >= forceThreshold) return; // This is after unwrapping, so no need to draw this layer
    
    pushStyle();
    colorMode(HSB, 255);
    if (!unwrap && alpha < 220) {
      alpha += 1;
    } 
    if (parentGlobe.privateLayerZoom < 60) {
      alpha = 0;
    } else {
      alpha = 220*(parentGlobe.privateLayerZoom-60)/40;
    }
    if (alpha == 0) return;
    fill(hue(colour)-10 + 20*noise(noiseCounter), 255, 140, int(alpha));
    noiseCounter += 0.01;
    noStroke();

    r += jelliness;
    if (r > TWO_PI*2) {
      r -= TWO_PI*2;
    }

    // First half-sphere
    for (float i = 0; i <= PI; i += res) {
      xRadius = radius - force + force*cos(i + r);
      yRadius = radius - force + force*sin(i - r);
      zRadius = radius - force + force*cos(i - r);
      xRadius = constrain(xRadius, parentGlobe.mantelLayer.radius+1, 1000);
      yRadius = constrain(yRadius, parentGlobe.mantelLayer.radius+1, 1000);
      zRadius = constrain(zRadius, parentGlobe.mantelLayer.radius+1, 1000);
      beginShape();
      for (float j = 0; j <= PI; j += res) {
        x = xRadius * sin(i) * cos(j) + xCenter;
        y = yRadius * sin(i) * sin(j) + yCenter;
        z = zRadius * cos(i) + zCenter;

        // Skin
        vertex(x, y, z);
      }

      for (float j = 0; j <= PI; j += res) {
        x = xRadius * sin(i - res) * cos(PI - j) + xCenter;
        y = yRadius * sin(i - res) * sin(PI - j) + yCenter;
        z = zRadius * cos(i - res) + zCenter;

        // Skin
        vertex(x, y, z);
      }
      endShape();
    }

    // Second half-sphere
    for (float i = -PI; i <= 0; i += res) {
      xRadius = radius - force + force*cos(r - i);
      yRadius = radius - force + force*sin(i + r);
      zRadius = radius - force + force*cos(r + i);
      xRadius = constrain(xRadius, parentGlobe.mantelLayer.radius+1, 1000);
      yRadius = constrain(yRadius, parentGlobe.mantelLayer.radius+1, 1000);
      zRadius = constrain(zRadius, parentGlobe.mantelLayer.radius+1, 1000);
      beginShape();
      for (float j = 0; j <= PI; j += res) {
        x = xRadius * sin(i) * cos(j) + xCenter;
        y = yRadius * sin(i) * sin(j) + yCenter;
        z = zRadius * cos(i) + zCenter;

        // Skin
        vertex(x, y, z);
      }

      for (float j = 0; j <= PI; j += res) {
        x = xRadius * sin(i - res) * cos(PI - j) + xCenter;
        y = yRadius * sin(i - res) * sin(PI - j) + yCenter;
        z = zRadius * cos(i - res) + zCenter;

        // Skin
        vertex(x, y, z);
      }
      endShape();
    }
    
    if (unwrap) {
      //force *= 1.05; // Fancy implosion
    } else {
      force *= 0.98;
      float prob = random(100);
      if (prob >= 99) {
        force += 2;
      } else if (prob >= 80) {
        force *= 1.07;
      }
    }
    
    // Fancy bubble rebirth
    if (!unwrap && force > 10) {
      //force -= 1;
    }
    
    popStyle();
  }
  
  void reset() {
    force = 200;
    unwrap = false;
  }
  
}

