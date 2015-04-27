
import processing.net.*;
public Puppet puppet;

public class Puppet  extends PaperScreen {

  BeatingHeart heart1, heart2;

  void setup() {
    setDrawingSize(297, 210);
    loadMarkerBoard(sketchPath + "/data/patient.cfg", 297, 210);


    // if (!noCameraMode) {
    //   markerBoard.setDrawingMode(cameraTracking, false, 20);
    //   markerBoard.setFiltering(cameraTracking, 44, 0.5);
    // }
    puppet = this;

    heart1 = new BeatingHeart();

    heart1.setPosition(55, 100);
    heart1.setHeartRate(80);
    heart1.setSize(30, 10);

    heart2 = new BeatingHeart();

    heart2.setPosition(250, 100);
    heart2.setHeartRate(150);
    heart2.setSize(30, 10);
  }


  void draw() {
    //background(255);

    // TEST for TWEAK, the instruction setFiltering 
    // is not instantaneous. 
    if (test && !noCameraMode) {
      markerBoard.setDrawingMode(cameraTracking, false, 20);
      markerBoard.setFiltering(cameraTracking, 60, 1.6);
    }

    if (noCameraMode) {
      setLocation(450, 85, 0 );
    }
    beginDraw3D();

    drawHearts();


    endDraw();
  }

  void drawHearts() {

    // white recangle to check calibration
    if (checkCalibration) {
      rect(0, 0, drawingSize.x, drawingSize.y);
    }

    float sinTime = sin( (float) millis() / 7724.2f * TWO_PI );

    // println("Sin Time " + sinTime);
    heart1.setHeartRate((int) (120 + 60 * sinTime));


    heart1.drawSelf(currentGraphics);

    heart2.drawSelf(currentGraphics);
    heart2.setHeartRate(159);
  }
}

