
int _detail = 5;
int _ballRadius = 100;
int heightMultiplier = 3;

void setup() {
  size(800, 500, P3D);
}

void draw() {
  background(0);
  beginShape();
  float x, y, z;

  for (float zi = -_detail * PI / 2; zi < _detail * PI; zi++) {
    for (float r = 0; r < TWO_PI; r += TWO_PI / _detail) {
      x = cos(r);
      y = sin(r);
      z = zi / _detail;
      float heightMultiplier = sqrt(1 - sq(z-.5));
      curveVertex(x * heightMultiplier * _ballRadius, y * heightMultiplier * _ballRadius, z * _ballRadius - _ballRadius/2);
    }
  }
  endShape();
  
}
