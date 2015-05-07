
import processing.net.*;

public class Target  extends PaperScreen {

  // one feedback that'll be dublicated upon drawing
  BeatingHeart heart;



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

    float imWidth = 210;
    float imHeight = 150;

    // position for noCamera
    int noCameraLocationX = 200;
    int noCameraLocationY = 150;

    if (!cameraMode) {
      setLocation(noCameraLocationX, noCameraLocationY, 0 );
    }

    if (isBeatingSet) {
      markerBoard.blockUpdate(cameraTracking, 1000);
    }

    float sinTime = sin( (float) millis() / 7724.2f * TWO_PI );
    heart.setHeartRate((int) (120 + 60 * sinTime));
    //heart.setHeartRate(50);
    heart.setHeartRatio(0.5);
    heart.update();

    // for t.weak mode
    conditionFeedback = 2;

    textSize(25);
    //imageMode(CENTER);

    //rectMode(CENTER);
    beginDraw3D();
    background(0);

    if (testCalibration) {
      fill(255);
      rect(0, 0, 420, 297);
    }
    
    // TODO: positionning of one feedback and the other could be way simpler rotating around paperscreen center

    /** View self **/

    // center, set border, lift plane
    pushMatrix();
    translate(imWidth/2, (297 - imWidth) / 2, 0.0); // imWidth == imHeight * sqrt(2), ie square base
    rotateX(HALF_PI*0.5);
    rotateY(HALF_PI*0.0);
    rotateZ(HALF_PI*0.0);

    // mirror / flip
    pushMatrix();
    translate(imWidth/2, imHeight/2, 0.0);
    rotateX(HALF_PI*0.0);
    rotateY(HALF_PI*2.0);
    rotateZ(HALF_PI*2.0);
    translate(-imWidth/2, -imHeight/2, 0.0);

    if (testCalibration) {
      pushStyle();
      fill(128);
      rect( 0, 0, imWidth, imHeight);
      popStyle();
    }

    // some margin for junction
    pushMatrix();
    translate(imWidth/2, imHeight/2, 0.0);
    scale(0.8);
    translate(-imWidth/2, -imHeight/2, 0.0);

    // finally, the image
    if (conditionFeedback >= 2) {
      image(heart.graphics, 0, 0, imWidth, imHeight);
    }
    fill(255);
    text("self", 105, 50); 

    popMatrix();
    popMatrix();
    popMatrix();

    /** View from others **/

    // center, set border, lift plane
    pushMatrix();
    translate(imWidth/2, 297 - (297 - imWidth) / 2, 0.0);
    rotateX(HALF_PI*-2.5);
    rotateY(HALF_PI*0.0);
    rotateZ(HALF_PI*0.0);

    // mirror / flip
    pushMatrix();
    translate(imWidth/2, imHeight/2, 0.0);
    rotateX(HALF_PI*0.0);
    rotateY(HALF_PI*0.0);
    rotateZ(HALF_PI*2.0);
    translate(-imWidth/2, -imHeight/2, 0.0);

    if (testCalibration) {
      pushStyle();
      fill(128);
      rect( 0, 0, imWidth, imHeight);
      popStyle();
    }

    // some margin for junction
    pushMatrix();
    translate(imWidth/2, imHeight/2, 0.0);
    scale(0.8);
    translate(-imWidth/2, -imHeight/2, 0.0);

    // finally, the image
    if (conditionFeedback >= 1) {
      image(heart.graphics, 0, 0, imWidth, imHeight);
    }
    fill(255);
    text("ID " + str(playerID), 105, 50); 

    popMatrix();
    popMatrix();
    popMatrix();

    endDraw();
  }

  // position... location... I don't know
  public PMatrix3D getPosition() {
    // same as this.screen.getPosition() ??;
    return getLocation();
  }

  public void setPosition(PMatrix3D mat) {
    //this.screen.setPos(mat);
    //screen.setTransformation(mat);
    setProjection(mat);
  }
}

