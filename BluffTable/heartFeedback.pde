
import processing.net.*;

public class HeartFeedback  extends PaperScreen {

  BeatingHeart heart;

  int noCameraLocationX = 0;
  int noCameraLocationY = 0;

  void setup() {
    setDrawingSize(297, 210);
    loadMarkerBoard(sketchPath + "/data/patient.cfg", 297, 210);

    heart = new BeatingHeart();

    heart.setPosition(50, 50);
    heart.setHeartRate(80);
    heart.setSize(30, 10);
  }

  void draw() {

    if (noCameraMode) {
      setLocation(noCameraLocationX, noCameraLocationY, 0 );
    }

    beginDraw2D();

    float sinTime = sin( (float) millis() / 7724.2f * TWO_PI );
    heart.setHeartRate((int) (120 + 60 * sinTime));
    heart.drawSelf(currentGraphics);

    endDraw();
  }
}

