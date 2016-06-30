
class Globe {
  
  //int layerMode = 2; // 0 is innermost, increase for outer layers
  float privateLayerZoom = 0;
  int numLayers = 3;
  color colour;
  int numLabel;
  
  Core coreLayer;
  Mantel mantelLayer;
  Crust crustLayer;
  
  Globe(color colour, int numLabel_) {
    coreLayer = new Core(200, colour);  
    mantelLayer = new Mantel(this, 220, colour);
    crustLayer = new Crust(this, 250, colour);
    numLabel = numLabel_;
  }
  
  void drawGlobe() {
    pushMatrix();
    rotateX(rotateX[numLabel]);
    rotateY(rotateY[numLabel]);
    rotateZ(rotateZ[numLabel]);
    if (privateLayerZoom > 70) {
      mantelLayer.drawMantel(); 
      crustLayer.drawCrust();
    } else {
      coreLayer.drawCore();
      mantelLayer.drawMantel();
      crustLayer.drawCrust();
    }
    // Selection box
    if (focus == numLabel) {
      noFill();
      stroke(180, 250);
      strokeWeight(1);
      box(450);
    }
    popMatrix();

  }
  
}
