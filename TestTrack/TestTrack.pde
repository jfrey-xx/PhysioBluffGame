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

Target target;

// toggled by keyboard
boolean isBeatingSet = false;

// will draw 2D rectangles to on whole paperScreen area
boolean testCalibration = false;

// for debug, we will print FPS every second
int lastFPS = 0;

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
  int frameSizeX = 800;
  int frameSizeY = 600;

  if (useProjector) {
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

  target = new Target();

  if (!noCameraMode)
    papart.startTracking();
}



void draw() {
  // if (millis() - lastFPS > 1000) {
  //   println(millis() + " -- FPS: " + frameRate);
  //   lastFPS = millis();
  // }
}


void keyPressed() {
  if (key == ' ') {
    isBeatingSet = !isBeatingSet;
    println("set tracking to: " + str(isBeatingSet));
  }
  if (key == 'c') {
    testCalibration = !testCalibration;
    println("set calibration test to: " + str(testCalibration));
  }
  println("hi!");
}

