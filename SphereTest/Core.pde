
class Core {

  // System data
  int num;
  float pt[];
  int style[];
  int radius;
  
  Core(int radius_, color colour) {
    num = 150;
    pt = new float[6*num]; // rotx, roty, deg, rad, w, speed
    style = new int[2*num]; // color, render style
    radius = radius_;
    
    // Set up arc shapes
    int index=0;
    float prob;
    for (int i=0; i<num; i++) {
      pt[index++] = random(PI*2); // Random X axis rotation
      pt[index++] = random(PI*2); // Random Y axis rotation
   
      pt[index++] = random(50,200); // Short to quarter-circle arcs
      if (random(100)>90) pt[index]=(int)random(8,27)*10;
   
      pt[index++] = radius;//int(random(2,50)*5); // Radius. Space them out nicely
   
      pt[index++] = random(4,6); // Width of band
      //if (random(100)>90) pt[index]=random(40,60); // Width of band
   
      pt[index++] = radians(random(5,30))/2; // Speed of rotation
   
      // get colors
      prob = random(100);
      pushStyle();
      colorMode(HSB, 255);
      if (prob<30) style[i*2] = color(hue(colour), 60, 170);
      else if (prob<70) style[i*2] = color(hue(colour), saturation(colour), brightness(colour)-20);
      else if (prob<90) style[i*2] = color(hue(colour), saturation(colour)+30, brightness(colour)+20);
      else style[i*2] = colour; //color(105,105,255, 220);
      style[i*2+1] = (int)(random(100))%3;
      popStyle();
    }
  }
    
  void drawCore() {      
    int index=0;
    //rotateX(PI/6);
    //rotateY(PI/6);

     
    for (int i = 0; i < num; i++) {
      pushMatrix();
      rotateX(pt[index++]);
      rotateY(pt[index++]);
  
      if (style[i*2+1]==0) {
        stroke(style[i*2]);
        noFill();
        strokeWeight(1);
        arcLine(0,0, pt[index++],pt[index++],pt[index++]);
      } else {
        fill(style[i*2]);
        noStroke();
        arc(0,0, pt[index++],pt[index++],pt[index++]);
      }
   
      // increase rotation
      pt[index-5]+=pt[index]/10;
      pt[index-4]+=pt[index++]/20;
   
      popMatrix();
    }
  }
  // Draw arc line
  void arcLine(float x,float y,float deg,float rad,float w) {
    int a=(int)(min (deg/SINCOS_PRECISION,SINCOS_LENGTH-1));
    int numlines=(int)(w/2);
   
    for (int j=0; j<numlines; j++) {
      beginShape();
      for (int i=0; i<a; i++) { 
        vertex(cosLUT[i]*rad+x,sinLUT[i]*rad+y);
      }
      endShape();
      rad += 2;
    }
  }
   
  // Draw arc line with bars
  void arcLineBars(float x,float y,float deg,float rad,float w) {
    int a = int((min (deg/SINCOS_PRECISION,SINCOS_LENGTH-1)));
    a /= 4;
   
    beginShape(QUADS);
    for (int i=0; i<a; i+=4) {
      vertex(cosLUT[i]*(rad)+x,sinLUT[i]*(rad)+y);
      vertex(cosLUT[i]*(rad+w)+x,sinLUT[i]*(rad+w)+y);
      vertex(cosLUT[i+2]*(rad+w)+x,sinLUT[i+2]*(rad+w)+y);
      vertex(cosLUT[i+2]*(rad)+x,sinLUT[i+2]*(rad)+y);
    }
    endShape();
  }
  
  // Draw solid arc
  void arc(float x,float y,float deg,float rad,float w) {
    int a = int(min (deg/SINCOS_PRECISION,SINCOS_LENGTH-1));
    beginShape(QUAD_STRIP);
    for (int i = 0; i < a; i++) {
      vertex(cosLUT[i]*(rad)+x,sinLUT[i]*(rad)+y);
      vertex(cosLUT[i]*(rad+w)+x,sinLUT[i]*(rad+w)+y);
    }
    endShape();
  }
  
}
