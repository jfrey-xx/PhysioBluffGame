// PapARt library
import fr.inria.papart.procam.*;
import fr.inria.papart.procam.display.*;
import org.bytedeco.javacpp.*;
import toxi.geom.*;

import fr.inria.guimodes.*;

Papart papart;

// Frame location. 
int framePosX = 1920;
int framePosY = 0;

boolean useProjector;

// for debug, we will print FPS every second
int lastFPS = 0;

/** FIXME: should stay inside ambientFeedback, quick'n dirty way to read those in puppet **/
// condition for feedback
// -1 no feedback
// 1 ambien feedback
// 2 explicit feedback
// 0 not set (typically, feedbackReadFromTCP == false)
int condition = 0;
// noise levels
double EEGNoise1 = 0f;
double EEGNoise2 = 0f;
// corresponding thresholds for detection 
double ThresholdNoise1 = 0f;
double ThresholdNoise2 = 0f;

// Undecorated frame 
public void init() {
  frame.removeNotify(); 
  frame.setUndecorated(true); 
  frame.addNotify(); 
  super.init();
}

PVector boardSize = new PVector(297, 210);   //  21 * 29.7 cm
float boardResolution = 1;  // 3 pixels / mm

void setup() {
  // limit FPS if option is set
  if (limitFPS > 0) {
    frameRate(limitFPS);
  }

  useProjector = true;
  int frameSizeX = 1280;
  int frameSizeY = 800;

  if (!useProjector) {
    frameSizeX = 640 * 2;
    frameSizeY = 480 * 2;
  }

  if (noCameraMode) {
    frameSizeX = 1280;
    frameSizeY = 800;
  }

  size(frameSizeX, frameSizeY, OPENGL);
  papart = new Papart(this);

  if (noCameraMode) {
    papart.initNoCamera(1);
  } else {
    if (useProjector) {
      papart.initProjectorCamera(str(camNumber), Camera.Type.OPENCV);
    } else {
      papart.initCamera(str(camNumber), Camera.Type.OPENCV);

      BaseDisplay display = papart.getDisplay();
      display.setDrawingSize(width, height);
    }
  }

  AmbientFeedback ambientFeedback = new AmbientFeedback();
  HeartFeedback heartFeedback1 = new HeartFeedback();

  HeartFeedback heartFeedback2 = new HeartFeedback();
  heartFeedback2.noCameraLocationX = 200;

  if (!noCameraMode)
    papart.startTracking();
}



void draw() {
  if (millis() - lastFPS > 1000) {
    println(millis() + " -- FPS: " + frameRate);
    lastFPS = millis();
  }
}

boolean test = false;
boolean isAmbientSet = false;

void keyPressed() {

  // Placed here, bug if it is placed in setup().
  if (key == ' ')
    frame.setLocation(framePosX, framePosY);

  if (key == 't') {
    test = !test;
    println("switch test to: " + test);
  }

  if (key =='a') {
    isAmbientSet = !isAmbientSet;
    println("switch ambientSet to: " + isAmbientSet);
  }
  if (key =='c') {
    checkCalibration = !checkCalibration;
    println("switch checkCalibration to: " + checkCalibration);
  }
  if (key =='g') {
    System.gc();
  }

  if (key == '0') {
    SecondMode.set("clear");
  }
  if (key == '1') {
    SecondMode.set("waves");
    noiseLevel = 0;
  }
  if (key == '2') {
    SecondMode.set("pixelate");
    noiseLevel = 1;
  }
  if (key == '3') {
    SecondMode.set("noise");
    noiseLevel = 2;
  }
  if (key == '4') {
    SecondMode.set("explicit_OK");
    noiseLevel = 0;
  }
  if (key == '5') {
    SecondMode.set("explicit_WARNING");
    noiseLevel = 1;
  }
  if (key == '6') {
    SecondMode.set("explicit_STOP");
    noiseLevel = 2;
  }
}

