
import processing.net.*;

public class Target  extends PaperScreen {

  // one feedback that'll be dublicated upon drawing
  BeatingHeart heart;

  // position for noCamera
  int noCameraLocationX = 0;
  int noCameraLocationY = 0;

  int playerID = 0;

  // 0: no feedback, 1: feedback others, 2: feedback all
  int conditionFeedback = 0;

  void setup() {
    // load A3 marker board
    setDrawingSize(420, 297);
    loadMarkerBoard(sketchPath + "/data/markers/frame4.png", 420, 297);

    heart = new BeatingHeart();
    heart.setPosition(0, 0);
    heart.setHeartRate(70);
    heart.setSize(30, 10);
  }

  void draw() {

    if (noCameraMode) {
      setLocation(noCameraLocationX, noCameraLocationY, 0 );
    }

    conditionFeedback = 2; /// for tweak mode...

    textSize(25);

    beginDraw3D();

    // one heart toward others
    pushMatrix(); 
    translate(250.0, 150.0, 105.0);
    pushMatrix(); 
    rotateX(HALF_PI*-0.5);
    rotateY(HALF_PI*2.0);
    if (conditionFeedback >= 1) {
      heart.drawSelf(currentGraphics);
    }
    fill(255);
    text("ID " + str(playerID), 40, 30);
    popMatrix();
    popMatrix();

    // one heart toward self
    pushMatrix(); 
    translate(170.0, 100.0, 105.0);
    pushMatrix(); 
    rotateX(HALF_PI*-1.5);
    rotateY(HALF_PI*0.0);
    if (conditionFeedback >= 2) {
      heart.drawSelf(currentGraphics);
    }
    fill(255);
    text("self", 40, 30); 
    popMatrix();
    popMatrix();

    endDraw();
  }
}
