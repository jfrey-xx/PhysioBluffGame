// PapARt library
import fr.inria.papart.procam.*;
import fr.inria.papart.procam.display.*;
import org.bytedeco.javacpp.*;
import toxi.geom.*;
import fr.inria.guimodes.*;
// import to reduce logging
import java.util.logging.Logger;
import java.util.logging.Level;

Papart papart;

// for debug, we will print FPS every second
int lastFPS = 0;

// One (ambient + heart) feedback per player 
AmbientFeedback[] ambientFeedbacks;
HeartFeedback[] heartFeedbacks;

// same idle animation for all
Idle idle;

// For manual debug, current player
int debugPlayer = 0;

// Undecorated frame 
public void init() {
  // javaCV is kind of verbose by default
  Logger.getLogger("org.bytedeco.javacv").setLevel(Level.OFF);
  Logger.getLogger("org.bytedeco.javacv.ObjectFinder").setLevel(Level.OFF);
  frame.removeNotify(); 
  frame.setUndecorated(true); 
  frame.addNotify(); 
  super.init();
}

void setup() {
  // limit FPS if option is set
  if (limitFPS > 0) {
    frameRate(limitFPS);
  }
  int frameSizeX = 800;
  int frameSizeY = 600;

  if (useProjector) {
    frameSizeX = projectorX;
    frameSizeY = projectorY;
  }

  size(frameSizeX, frameSizeY, OPENGL);
  papart = new Papart(this);

  if (!cameraMode) {
    // with no camera but project: aimed to be positionned by loading previous xml file
    if (useProjector) {
      ProjectorDisplay projector;
      projector = new ProjectorDisplay(this, Papart.proCamCalib);
      projector.setZNearFar(10, 6000);
      projector.setQuality(1);
      projector.init();

      papart.setDisplay(projector);
      papart.setNoTrackingCamera();
    }
    // no camera and no projector: on-screen display, for debug
    else {
      papart.initNoCamera(1);
    }
  } else {
    if (useProjector) {
      papart.initProjectorCamera(str(camNumber), Camera.Type.OPENCV);
    } else {
      papart.initCamera(str(camNumber), Camera.Type.OPENCV);

      BaseDisplay display = papart.getDisplay();
      display.setDrawingSize(width, height);
    }
  }

  idle = new Idle();
  ambientFeedbacks = new AmbientFeedback[nbPlayers];
  heartFeedbacks = new HeartFeedback[nbPlayers]; 

  for (int i = 0; i < nbPlayers; i++) {
    ambientFeedbacks[i] = new AmbientFeedback(i);
    heartFeedbacks[i] = new HeartFeedback(i);
    heartFeedbacks[i].setIdle(idle);
    // space for no camera and no projector
    ambientFeedbacks[i].noCameraLocationX = 200 * i;
    heartFeedbacks[i].noCameraLocationX = 200 * i;
  }

  if (cameraMode) {
    papart.startTracking();
  }
}

void draw() {
  idle.update();
  if (millis() - lastFPS > 5000) {
    println(millis() + " -- FPS: " + frameRate);
    lastFPS = millis();
  }
}

void keyPressed() {

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

  /*** disable / enable tracking for ambient and then heart ***/
  if (key =='a') {
    ambientFeedbacks[debugPlayer].useManualLocation(true);
    println("Stick ambient of player " + str(debugPlayer));
  }
  if (key =='A') {
    ambientFeedbacks[debugPlayer].useManualLocation(false);
    println("Track ambient of player " + str(debugPlayer));
  }
  if (key =='h') {
    heartFeedbacks[debugPlayer].useManualLocation(true);
    println("Stick heart of player " + str(debugPlayer));
  }
  if (key =='H') {
    heartFeedbacks[debugPlayer].useManualLocation(false);
    println("Track heart of player " + str(debugPlayer));
  }

  /*** save/load location for *all* PaperScreen ***/
  // TODO: check that files exists
  if (key == 's') {
    for (int i = 0; i < nbPlayers; i++) {
      ambientFeedbacks[i].saveLocation();
      heartFeedbacks[i].saveLocation();
    }
  }

  // load target
  if (key == 'l') {
    for (int i = 0; i < nbPlayers; i++) {
      ambientFeedbacks[i].loadLocation();
      heartFeedbacks[i].loadLocation();
    }
  }

  /*** debug ***/
  if (key =='c') {
    checkCalibration = !checkCalibration;
    println("switch checkCalibration to: " + checkCalibration);
  }

  /*** set manually ambient feedback ***/
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

