
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

  // will be created by main sketch since it's shared by every one
  private Idle idle = null;

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

  // self: change orientation / text / image if side seen by self or others
  private void drawFeedback(boolean selfSide) {
    // feedback is a A5 paper sheet, folded at a 90° angle to make a stand and put in the middle of a A3 paper sheet
    float imWidth = 210;
    float imHeight = 150;

    // TODO: positionning of one feedback and the other could be way simpler rotating around paperscreen center

    String playerText;
    if (selfSide) {
      playerText = textSelf;
    } else {
      if (playerID < textPlayers.length) {
        playerText = textPlayers[playerID];
      } else {
        playerText = "ID " + str(playerID);
      }
    }

    // center, set border, lift plane
    pushMatrix();
    if (selfSide) {
      translate(imWidth/2, (297 - imWidth) / 2, 0.0); // imWidth == imHeight * sqrt(2), ie square base
      rotateX(HALF_PI*0.5);
    } else {
      translate(imWidth/2, 297 - (297 - imWidth) / 2, 0.0); // imWidth == imHeight * sqrt(2), ie square base
      rotateX(HALF_PI*-2.5);
    }

    // mirror / flip
    pushMatrix();
    translate(imWidth/2, imHeight/2, 0.0);
    rotateX(HALF_PI*0.0);
    if (selfSide) {
      rotateY(HALF_PI*2.0);
    } else {
      rotateY(HALF_PI*0.0);
    }
    rotateZ(HALF_PI*2.0);
    translate(-imWidth/2, -imHeight/2, 0.0);

    if (checkCalibration) {
      pushStyle();
      fill(0, 128, 0, 128);
      rect( 0, 0, imWidth, imHeight);
      popStyle();
    }

    // some margin for junction
    pushMatrix();
    translate(imWidth/2, imHeight/2, 0.0);
    scale(0.8);
    translate(-imWidth/2, -imHeight/2, 0.0);

    fill(255);

    // we display HR if condition for all or others side and condition others
    if (conditionHR >= 2 || (conditionHR == 1 && !selfSide)) {
      image(heart.graphics, 0, 0, imWidth, imHeight);
      text(playerText, imWidth/4*3, imHeight/4);
    }
    // otherwise idle animation
    else {
      if (idle != null) {
        image(idle.graphics, 0, 0, imWidth, imHeight);
      }
      text(playerText, imWidth/2, imHeight/2);
    }

    popMatrix();
    popMatrix();
    popMatrix();
  }

  void draw() {

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

    beginDraw3D();
    pushStyle();
    textSize(25);
    textAlign(CENTER, CENTER);

    if (checkCalibration) {
      fill(0, 192, 0, 128);
      rect(0, 0, 420, 297);
    }

    // two sides of the same coin
    drawFeedback(true);
    drawFeedback(false);

    popStyle();
    endDraw();
  }

  public void saveLocation() {
    String filename = "data/heart_" + str(playerID) + "_position.xml";
    println("heart " + str(playerID) + ", saving location to: " + filename);
    saveLocationTo(filename);
  }

  public void loadLocation() {
    // reset any manual location before applying a previous state
    setLocation(0, 0, 0 );
    String filename = "data/heart_" + str(playerID) + "_position.xml";
    println("heart " + str(playerID) + ", loading location from: " + filename);
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

  public void setIdle(Idle idle) {
    this.idle = idle;
  }
}

