class PWindowSlider extends PApplet {
  PWindowSlider() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(640, 360);
  }

  int barWidth = 20;
  int lastBar = -1;

  //String whatever = "";

  //void setWhatever(String w) {
  //  whatever = w;
  //}

  void setup() {
    background(0);
    colorMode(HSB, height, height, height);  
    noStroke();
    background(0);
    smooth();
  }

  void draw() {

    //float a; 
    //for (float z

    int movementBar = sensor[2] / barWidth;

    if (movementBar != lastBar) {
      int barX = movementBar * barWidth;
      fill(sensor[2], height, height);
      rect(barX, 0, barWidth, height);
      lastBar = movementBar;
    }
  }
}