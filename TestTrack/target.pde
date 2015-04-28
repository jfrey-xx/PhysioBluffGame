
import processing.net.*;

public class Target  extends PaperScreen {


  // position for noCamera
  int noCameraLocationX = 0;
  int noCameraLocationY = 0;


  void setup() {
    setDrawingSize(420, 297);
    //loadMarkerBoard(sketchPath + "/data/patient.cfg", 297, 210);
    loadMarkerBoard(sketchPath + "/data/markers/frame4.png",420, 297);
    
    //loadMarkerBoard(sketchPath + "/data/markers/frame4.png", 297, 210);
  }

  void draw() {

    if (noCameraMode) {
      setLocation(noCameraLocationX, noCameraLocationY, 0 );
    }


    beginDraw2D();

   
 
    rect(100, 100, 20, 100);

    endDraw();
  }
}

