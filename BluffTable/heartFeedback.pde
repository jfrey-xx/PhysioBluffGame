
import processing.net.*;

public class HeartFeedback  extends PaperScreen {

  // one feedback that'll be duplicated upon drawing
  BeatingHeart heart;

  // position when !cameraMode && !useProjector
  int noCameraLocationX = 0;
  int noCameraLocationY = 0;

  // one stream to read current player inner state
  private  ReaderLSL readerBPM;

  // ref for LSL stream
  private int playerID;

  // we need an ID to read from LSL
  public HeartFeedback(int playerID) {
    this.playerID = playerID;
  }

  void setup() {
    // load A3 marker board
    setDrawingSize(420, 297);
    loadMarkerBoard(sketchPath + "/data/markers/nimp.png", 420, 297);
    //loadMarkerBoard(sketchPath + "/data/markers/A3-small1.cfg", 420, 297);

    heart = new BeatingHeart();
    heart.setHeartRate(70);

    if (feedbackFromNetwork) {
      initNetwork();
    }
  }

  void draw() {
    float imWidth = 210;
    float imHeight = 150;

    // equivalent to debug mode
    if (!cameraMode && !useProjector) { 
      setLocation(noCameraLocationX, noCameraLocationY, 0 );
    }

    // only read data from network (and update accordingly mode) if option set, otherwise use a sin
    if (feedbackFromNetwork) {
      updateNetwork();
    } else {
      float sinTime = sin( (float) millis() / 7724.2f * TWO_PI / (1 + playerID));
      heart.setHeartRate((int) (120 + 60 * sinTime));
    }

    heart.setHeartRatio(0.5);
    heart.update();

    textSize(25);

    beginDraw3D();
    background(0);

    if (checkCalibration) {
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

    if (checkCalibration) {
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
    if (conditionHR >= 2) {
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

    if (checkCalibration) {
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
    if (conditionHR >= 1) {
      image(heart.graphics, 0, 0, imWidth, imHeight);
    }
    fill(255);
    text("ID " + str(playerID), 105, 50); 

    popMatrix();
    popMatrix();
    popMatrix();

    endDraw();
  }

  public void saveLocation() {
    String filename = "data/target_" + str(playerID) + "_position.xml";
    println("Saving location to: " + filename);
    saveLocationTo(filename);
  }

  public void loadLocation() {
    // reset any manual location before applying a previous state
    setLocation(0, 0, 0 );
    String filename = "data/target_" + str(playerID) + "_position.xml";
    println("Loading location from: " + filename);
    loadLocationFrom(filename);
  }

  // try to resolve LSL streams
  private void initNetwork() {
    readerBPM = new ReaderLSL(LSLBPMStream, playerID);
  }

  // read data from LSL, update internal state
  private void updateNetwork() {
    double[] dataBPM = readerBPM.read();
    if (dataBPM != null) {
      double bpm = dataBPM[0];
      heart.setHeartRate((int) bpm);
    }
  }
}

