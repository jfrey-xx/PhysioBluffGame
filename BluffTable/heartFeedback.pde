
import processing.net.*;

public class HeartFeedback  extends PaperScreen {

  BeatingHeart heart;

  // position for noCamera
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
    setDrawingSize(297, 210);
    loadMarkerBoard(sketchPath + "/data/patient.cfg", 297, 210);

    heart = new BeatingHeart();

    heart.setPosition(50, 50);
    heart.setHeartRate(70);
    heart.setSize(30, 10);

    if (feedbackFromNetwork) {
      initNetwork();
    }
  }

  void draw() {

    if (noCameraMode) {
      setLocation(noCameraLocationX, noCameraLocationY, 0 );
    }

    // only read data from network (and update accordingly mode) if option set, otherwise use a sin
    if (feedbackFromNetwork) {
      updateNetwork();
    } else {
      float sinTime = sin( (float) millis() / 7724.2f * TWO_PI / (1 + playerID));
      heart.setHeartRate((int) (120 + 60 * sinTime));
    }

    beginDraw2D();

    heart.drawSelf(currentGraphics);

    endDraw();
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

