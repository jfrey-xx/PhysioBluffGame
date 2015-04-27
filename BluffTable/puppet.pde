
import processing.net.*;
public Puppet puppet;

public class Puppet  extends PaperScreen {


  void setup() {
    setDrawingSize(297, 210);
    loadMarkerBoard(sketchPath + "/data/patient.cfg", 297, 210);


    // if (!noCameraMode) {
    //   markerBoard.setDrawingMode(cameraTracking, false, 20);
    //   markerBoard.setFiltering(cameraTracking, 44, 0.5);
    // }
    puppet = this;
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

    drawTeegi();


    endDraw();
  }

  void drawTeegi() {

    // white recangle to check calibration
    if (checkCalibration) {
      rect(0, 0, drawingSize.x, drawingSize.y);
    }

  }
}
