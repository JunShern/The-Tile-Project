class PWindowZoom extends PApplet {
  PWindowZoom() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  PImage img;
  int[][] imgPixels;
  float sval = 2.0;
  float nmx, nmy;
  int res = 5;

  void settings() {
    size(800, 600, P3D);
  }

  void setup() {
    noFill();
    stroke(255);
    img = loadImage("/Users/sasakang/Documents/Processing/mpr121_output_test_two_windows_jeff/data/pollen4.jpg");
    imgPixels = new int[img.width][img.height];
    for (int i = 0; i < img.height; i++) {
      for (int j = 0; j < img.width; j++) {
        imgPixels[j][i] = img.get(j, i);
      }
    }
  }

  void draw() {
    background(255);
    //imageMode(CENTER);
    //image(img, 250, 250, 280, 280);

    //nmx += (mouseX-nmx)/20; 
    //nmy += (mouseY-nmy)/20; 

    if (sensor[1] < 400) { 
      sval += 0.020;
    } else {
      sval -= 0.01;
    }

    sval = constrain(sval, 1.0, 2.0);

    translate(width/2, height/2, 0);
    scale(sval);
    rotateZ(PI/9 - sval + 1.0);
    rotateX(PI/sval/8 - 0.125);
    rotateY(sval/8 - 0.125);

    translate(-width/2+img.width/2, -height/2+img.width/2, 0);

    for (int i = 0; i < img.height; i += res) {
      for (int j = 0; j < img.width; j += res) {
        float rr = red(imgPixels[j][i]); 
        float gg = green(imgPixels[j][i]);
        float bb = blue(imgPixels[j][i]);
        float tt = rr+gg+bb;
        stroke(rr, gg, gg);
        line(i, j, tt/10-20, i, j, tt/10 );
      }
    }
  }
}