
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
    loadMarkerBoard(sketchPath + "/data/markers/nimp.png", 420, 297);
    //loadMarkerBoard(sketchPath + "/data/markers/A3-small1.cfg", 420, 297);

    heart = new BeatingHeart();
    heart.setHeartRate(70);
  }

  void draw() {

    if (cameraMode) {
      setLocation(noCameraLocationX, noCameraLocationY, 0 );
    }

    if (isBeatingSet) {
      markerBoard.blockUpdate(cameraTracking, 1000);
    }

    float sinTime = sin( (float) millis() / 7724.2f * TWO_PI );
    heart.setHeartRate((int) (120 + 60 * sinTime));
    //heart.setHeartRate(50);

    heart.setHeartRatio(0.5);

    // for t.weak mode
    conditionFeedback = 2;

    textSize(25);

    //rectMode(CENTER);
    beginDraw3D();
    background(0);

    //println("Here ");
    //this.getLocation().print();
    //println(this.screen.getPosition()); //.print();

    if (testCalibration) {
      fill(255);
      rect(0, 0, 420, 297);
    }

    // one heart toward self
    pushMatrix(); 
    translate(105.0, 150.0, 110.0);
    pushMatrix(); 
    rotateX(HALF_PI*0.5);
    rotateY(HALF_PI*2.0);
    rotateZ(HALF_PI*2.0);
    if (conditionFeedback >= 2) {
      heart.update();
      image(heart.graphics, 0, 0, 210, 150);
    }
    fill(255);
    text("self", 40, 30); 
    popMatrix();
    popMatrix();

    // one heart toward others
    pushMatrix(); 
    translate(315.0, 150.0, 0.0);
    pushMatrix(); 
    rotateX(HALF_PI*-0.5);
    rotateY(HALF_PI*2.0);
    rotateZ(HALF_PI*0.0);
    if (conditionFeedback >= 1) {
      heart.update();
      image(heart.graphics, 0, 0, 210, 150);
    }
    fill(255);
    text("ID " + str(playerID), 40, 30); 
    popMatrix();
    popMatrix();

    endDraw();
  }
}

