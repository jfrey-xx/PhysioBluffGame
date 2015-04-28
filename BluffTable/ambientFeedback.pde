import fr.inria.openvibelink.read.*; //FIXME: temp version of lib
import processing.net.*; 
import fr.inria.papart.drawingapp.DrawUtils;
import fr.inria.guimodes.SecondaryMode;

// codes associated to feeback -- cf initModes() for corresponding names.
// NB: use sequential codes from 0 to nbSecondModes...

final int SECOND_MODE_CLEAR = 0;
// ambient feedback
final int SECOND_MODE_WAVES = 1;
final int SECOND_MODE_PIXELATE = 2;
final int SECOND_MODE_NOISE = 3;
// explicit feedback
final int SECOND_EXPLICIT_OK = 4;
final int SECOND_EXPLICIT_WARNING = 5;

final int SECOND_EXPLICIT_STOP = 6;

final int nbModes = 7;
String[] secondModes = new String[nbModes];

public class AmbientFeedback  extends PaperScreen {

  // position for noCamera
  int noCameraLocationX = 0;
  int noCameraLocationY = 0;

  // we need two stream, one for idx, one for detection
  private ReaderLSL readerBPM, readerDetection;
  // ref for LSL stream
  private int playerID;

  PShader pixelize, waves, white_noise;
  PGraphics feedbackAmbient, feedbackExplicit, scene;

  int ambientWidth = 800;
  int ambientHeight = 800;

  /*** explicit feedback ***/
  // fixed image
  PImage furniture, teegi;
  // 3 images for body, each a noise level (good / warning / stop), pointer to current
  PImage [] bodys;
  // same, for sign
  PImage [] signs;

  // scaling factor applied to images
  float imgScale = 0.5;

  // increase / descrease shacky effect (translation and speed)
  float shakyRatio = 5;
  float shakySpeed = 50;

  // current and max noise level
  int maxNoiseLevel = 2;
  int noiseLevel = 0;
  // triggers shaky movements at this level and upper
  int noiseShakyLevel = 2;

  // feedback state
  SecondaryMode mode;

  // we need an ID to read from LSL
  public AmbientFeedback(int playerID) {
    this.playerID = playerID;
  }

  void setup() {
    setDrawingSize(ambientWidth, ambientHeight);
    loadMarkerBoard(sketchPath + "/data/A3-small1.cfg", ambientWidth, ambientHeight);

    initShaders();
    initModes();
    if (feedbackFromNetwork) {
      initNetwork();
    }

    // we need a dedicated renderer for the waves in order to apply pixelize and noise only on it
    feedbackAmbient = createGraphics(ambientWidth, ambientHeight, P2D);
    // ...and another one to avoid conflict between both types (had frozen waves over explicit)
    feedbackExplicit = createGraphics(ambientWidth, ambientHeight, P2D);

    // explicit feedback, load background images
    furniture = loadImage("furniture.png");
    teegi = loadImage("teegi_sit.png");
    // init array and load the 3 bodys
    bodys = new PImage[maxNoiseLevel+1];
    bodys[0] = loadImage("body_good.png");
    bodys[1] = loadImage("body_warning.png");
    bodys[2] = loadImage("body_stop.png");
    // same for signs
    signs = new PImage[maxNoiseLevel+1];
    signs[0] = loadImage("sign_good.png");
    signs[1] = loadImage("sign_warning.png");
    signs[2] = loadImage("sign_stop.png");
  }

  private void initNetwork() {
    readerBPM = new ReaderLSL(LSLBPMStream, playerID);
    readerDetection = new ReaderLSL(LSLDetectionStream, playerID);
  }

  private void initShaders() {
    pixelize =    loadShader("shaders/pixelize.glsl");
    waves =       loadShader("shaders/waves.glsl");
    white_noise = loadShader("shaders/white_noise.glsl"); 

    pixelize.set(   "iResolution", float(ambientWidth), float(ambientHeight)); 
    waves.set(      "iResolution", float(ambientWidth), float(ambientHeight));
    white_noise.set("iResolution", float(ambientWidth), float(ambientHeight));

    updateShaders();
  }

  private void initModes() {

    mode = new SecondaryMode();

    // put a name of those ints
    secondModes[SECOND_MODE_CLEAR] = "clear";

    secondModes[SECOND_MODE_WAVES] = "waves";
    secondModes[SECOND_MODE_PIXELATE] = "pixelate";
    secondModes[SECOND_MODE_NOISE] = "noise";

    secondModes[SECOND_EXPLICIT_OK] = "explicit_OK";
    secondModes[SECOND_EXPLICIT_WARNING] = "explicit_WARNING";
    secondModes[SECOND_EXPLICIT_STOP] = "explicit_STOP";

    // add modes
    for (int i=0; i < secondModes.length; i++) {
      mode.add(secondModes[i], i);
    }

    // by default show off with nice waves (I wonder who programmed such a nice shader...)
    mode.set("explicit_STOP");
  }

  void draw() {

    // only read data from network (and update accordingly mode) if option set
    if (feedbackFromNetwork) {
      updateNetwork();
    }

    // no feedback... nothing to do
    if (mode.is("clear")) {
      return;
    }

    // one position for dummy teegi
    if (noCameraMode) {
      setLocation(noCameraLocationX, noCameraLocationY, 0 );
    }

    if (isAmbientSet) {
      markerBoard.blockUpdate(cameraTracking, 1000);
    }

    beginDraw3D();
    translate(0, 0, -5);

    if (mode.is("waves") || mode.is("pixelate") || mode.is("noise")) {
      updateShaders();
      drawFeedbackAmbient();
      image(feedbackAmbient, -241, -420, 789, 694);
    } else if (mode.is("explicit_OK") || mode.is("explicit_WARNING") || mode.is("explicit_STOP")) {
      drawFeedbackExplicit();
      // sepecial fuction to put image in right way + draw left to the board
      DrawUtils.drawImage(currentGraphics, feedbackExplicit, 450, 0, 150, 150);
    }

    endDraw();
  }

  // read data from LSL, update internal state
  // TODO: not many verifications about data at the moment...
  void updateNetwork() {
    double[] dataBPM = readerBPM.read();
    double[] dataDetection = readerDetection.read();

    // update something only if we got data
    if (dataBPM != null && dataDetection != null) {
      double idx = dataBPM[0];
      double detection = dataDetection[0];

      // temp variable to detect change; not sure I'd used modes...
      String newMode = "clear";

      // now define new mode (and clamp condition, just in case)
      // NB: very tempting to use switch in there :D
      if (condition <= 0) {
        condition = -1;
        newMode = "clear";
      } else {
        // current stae of noise
        noiseLevel = 0;
        // no face wins
        if (detection < 1) {
          noiseLevel = 2;
        } else if (idx < ThresholdIdx) {
          noiseLevel = 1;
        }
        // would be *really* simpler without modes
        if (condition == 1) {

          if (noiseLevel == 0) {
            newMode = "waves";
          }
          if (noiseLevel == 1) {
            newMode = "pixelate";
          }
          if (noiseLevel == 2) {
            newMode = "noise";
          }
        } else if (condition >= 2) {
          condition = 2;
          if (noiseLevel == 0) {
            newMode = "explicit_OK";
          }
          if (noiseLevel == 1) {
            newMode = "explicit_WARNING";
          }
          if (noiseLevel == 2) {
            newMode = "explicit_STOP";
          }
        }
      }

      // finally, switch only in new mode
      if (!mode.is(newMode)) {
        println("Switching to mode: " + newMode);
        mode.set(newMode);
      }
    }
  }

  void updateShaders() {
    waves.set("iGlobalTime", millis()/1000.0);
    waves.set("rings", 13.10);
    waves.set("velocity", 2.50);
    waves.set("waveColor", 1.00);
    waves.set("iResolution", 800, 800f);
    white_noise.set("iGlobalTime", millis()/1000.0);
  }

  // to be called when mode.is("waves") || mode.is("pixelate") || mode.is("noise")
  void drawFeedbackAmbient() {
    // waves as muscular feedback
    feedbackAmbient.beginDraw();

    feedbackAmbient.filter(waves);

    if (mode.is("pixelate")) {
      feedbackAmbient.filter(pixelize);
    } else {

      if (mode.is("noise")) {
        feedbackAmbient.filter(white_noise);
        feedbackAmbient.filter(pixelize);
      }
    }
    feedbackAmbient.endDraw();
  }

  // For explicit it'll be plain draw... and won't use modes in fact
  // to be called if mode.is("explicit_OK") || mode.is("explicit_WARNING") || mode.is("explicit_STOP")
  void drawFeedbackExplicit() {
    feedbackExplicit.beginDraw();
    // reset background
    background(0, 0, 0, 0);
    // show background images
    feedbackExplicit.image(furniture, 67, 231, furniture.width*imgScale, furniture.height*imgScale);
    feedbackExplicit.image(teegi, 379, 193, teegi.width*imgScale, teegi.height*imgScale);
    // ** begin shacky effect for too noisy signals **
    if (noiseLevel >= noiseShakyLevel) {
      float shakeAmount = sin(millis()*shakySpeed/1000) * shakyRatio;
      // println(shakeAmount); // DEBUG
      // shaky == translation in X
      feedbackExplicit.translate(shakeAmount, 0);
    }
    // point to current sign/body
    PImage currentSign = signs[noiseLevel];
    PImage currentBody = bodys[noiseLevel];
    // show time!
    feedbackExplicit.image(currentSign, 566, 32, currentSign.width*imgScale, currentSign.height*imgScale);
    feedbackExplicit.image(currentBody, 37, 35, currentBody.width*imgScale, currentBody.height*imgScale);
    //feedbackExplicit.resize(imgScale,imgScale);
    feedbackExplicit.endDraw();
  }
}

