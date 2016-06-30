/* //
  Jelly Ball - 2010
  ------------------------------------------------
  CODED FROM SCRATCH BY Richard Wong, Sydney AUS
  If you are going to use this code for something,
  please let me know as I would love to see it.
  
  http://www.rdwong.net
*/ //

float x, y, z, r, radius, angle, a, b;
float xRadius, yRadius, zRadius, xCenter, yCenter, zCenter;
float xLast, yLast, zLast;
float res, force;
boolean showVectors;

float jelliness = 0.3;

void setup() {
  
  size(800, 800, P3D);
  background(255);
  frameRate(60);
  
  xCenter = 0;
  yCenter = 0;
  zCenter = 0;
  radius = yRadius = xRadius = zRadius = width/6;
  r = 0;
  res = PI/32;
  showVectors = false;
  
}

void draw() {
  background(255);
  translate(width/2, height/2, 0);
  directionalLight(200, 200, 200, -1, 0, -1);
  lightSpecular(255, 100, 20);
  emissive(0, 64, 128);
  shininess(12);
  
  
  fill(255, 0, 0, 126);
  noStroke();
  

  
  r += jelliness;
  if (r > TWO_PI*2) {
    r -= TWO_PI*2;
  }
 
  for (float i = 0; i <= PI; i += res) {
    beginShape();
    xRadius = radius - force + force*cos(i + r);
    yRadius = radius - force + force*sin(i - r);
    zRadius = radius - force + force*cos(i - r);
    for (float j = 0; j <= PI; j += res) {
      x = xRadius * sin(i) * cos(j) + xCenter;
      y = yRadius * sin(i) * sin(j) + yCenter;
      z = zRadius * cos(i) + zCenter;
      
      if (showVectors) {
        pushStyle();
        stroke(255, 126);
        point(x, y, z);
        popStyle();
      } else {
        vertex(x, y, z);
      }
    }
    
    for (float j = 0; j <= PI; j += res) {
      x = xRadius * sin(i - res) * cos(PI - j) + xCenter;
      y = yRadius * sin(i - res) * sin(PI - j) + yCenter;
      z = zRadius * cos(i - res) + zCenter;
      
      if (showVectors) {
        pushStyle();
        stroke(255, 126);
        point(x, y, z);
        popStyle();
      } else {
        vertex(x, y, z);
      }
    }
    endShape();
    
  }
  
  for (float i = -PI; i <= 0; i += res) {
    xRadius = radius - force + force*cos(r - i);
    yRadius = radius - force + force*sin(i + r);
    zRadius = radius - force + force*cos(r + i);
    beginShape();
    for (float j = 0; j <= PI; j += res) {
      x = xRadius * sin(i) * cos(j) + xCenter;
      y = yRadius * sin(i) * sin(j) + yCenter;
      z = zRadius * cos(i) + zCenter;
      
      if (showVectors) {
        pushStyle();
        stroke(255, 126);
        point(x, y, z);
        popStyle();
      } else {
        vertex(x, y, z);
      }
    }
    
    for (float j = 0; j <= PI; j += res) {
      x = xRadius * sin(i - res) * cos(PI - j) + xCenter;
      y = yRadius * sin(i - res) * sin(PI - j) + yCenter;
      z = zRadius * cos(i - res) + zCenter;
      
      if (showVectors) {
        pushStyle();
        stroke(255, 126);
        point(x, y, z);
        popStyle();
      } else {
        vertex(x, y, z);
      }
    }
    endShape();
    
  }
  
  force *= 0.98;
  
}

void mouseMoved() {
  force += dist(mouseX, mouseY, pmouseX, pmouseY)/(width/12);
}
