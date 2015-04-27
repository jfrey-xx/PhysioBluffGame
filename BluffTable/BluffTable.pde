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

// noise levels
double EEGNoise1 = 0f;
double EEGNoise2 = 0f;
// corresponding thresholds for detection 
double ThresholdNoise1 = 0f;
double ThresholdNoise2 = 0f;

// One (ambient + heart) feedback per player 
AmbientFeedback[] ambientFeedbacks;
HeartFeedback[] heartFeedbacks;

// For manual debug, current player
int debugPlayer = 0;

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

  ambientFeedbacks = new AmbientFeedback[nbPlayers];
  heartFeedbacks = new HeartFeedback[nbPlayers]; 

  for (int i = 0; i < nbPlayers; i++) {
    ambientFeedbacks[i] = new AmbientFeedback();
    heartFeedbacks[i] = new HeartFeedback();
    // space for noCameraMode
    ambientFeedbacks[i].noCameraLocationX = 200 * i;
    heartFeedbacks[i].noCameraLocationX = 200 * i;
  }

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

  // 7/8: select player-- or player++
  if (key == '7') {
    debugPlayer--;
    if (debugPlayer < 0) {
      debugPlayer = 0;
    }
    println("Select player: " + debugPlayer);
  }
  if (key == '8') {
    debugPlayer++;
    if (debugPlayer >= nbPlayers) {
      debugPlayer = nbPlayers-1;
    }
    println("Select player: " + debugPlayer);
  }

  if (key == '0') {
    ambientFeedbacks[debugPlayer].mode.set("clear");
  }
  if (key == '1') {
    ambientFeedbacks[debugPlayer].mode.set("waves");
    ambientFeedbacks[debugPlayer].noiseLevel = 0;
  }
  if (key == '2') {
    ambientFeedbacks[debugPlayer].mode.set("pixelate");
    ambientFeedbacks[debugPlayer].noiseLevel = 1;
  }
  if (key == '3') {
    ambientFeedbacks[debugPlayer].mode.set("noise");
    ambientFeedbacks[debugPlayer].noiseLevel = 2;
  }
  if (key == '4') {
    ambientFeedbacks[debugPlayer].mode.set("explicit_OK");
    ambientFeedbacks[debugPlayer].noiseLevel = 0;
  }
  if (key == '5') {
    ambientFeedbacks[debugPlayer].mode.set("explicit_WARNING");
    ambientFeedbacks[debugPlayer].noiseLevel = 1;
  }
  if (key == '6') {
    ambientFeedbacks[debugPlayer].mode.set("explicit_STOP");
    ambientFeedbacks[debugPlayer].noiseLevel = 2;
  }
}

