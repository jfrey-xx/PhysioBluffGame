import java.util.LinkedList;
import fr.inria.guimodes.SecondaryMode;

int nbSecondsInAMinute = 60;

PImage whiteHeart = null;
PImage shadow = null;
PImage monitor = null;

class BeatingHeart {

  // input
  int heartRate;    // BPM

  // Time management
  int pulseDurationUp = 100;
  int pulseDurationDown = 200;
  int lastPulse = 0;
  int nextPulse = 0;

  // Graphics, default values
  private float heartExpansion = 1.2;

  private PGraphics graphics;
  private int texWidth;
  private int texHeight;
  private float heartRatio = 0.5;

  PVector position = new PVector();

  LinkedList<Integer> rateHistory = new LinkedList<Integer>();

  private SecondaryMode mode;

  // default texture size: 800x600 pixels
  public BeatingHeart() {
    this(800, 600);
  }

  // set custom texture size (in pixels)
  public BeatingHeart(int texWidth, int texHeight) {
    this.texWidth = texWidth;
    this.texHeight = texHeight;
    checkImages();
    initModes();
    graphics = createGraphics(texWidth, texHeight, P2D);
  }

  public void setHeartRatio(float heartRatio) {
    this.heartRatio = heartRatio;
  }

  private void checkImages() {
    if (shadow == null || whiteHeart == null) {
      whiteHeart = loadImage("heart.png");
      shadow = loadImage("shadow.png");
      monitor = loadImage("monitor.png");
    }
  }

  private void initModes() {
    mode = new SecondaryMode();

    mode.add("rest");
    mode.add("beatUp");
    mode.add("beatDown");

    mode.set("rest");
  }

  public void setHeartRate(int bpm) {
    this.heartRate = bpm;
    rateHistory.push(bpm);
    checkHistory();
  }

  private void checkHistory() {
    if (rateHistory.size() >= HISTORY_SIZE)
      rateHistory.removeLast();
  }

  // to be called once per draw()
  public void update() {
    if (pulse()) {
      lastPulse = millis();
      findNextPulse();
      mode.set("beatUp");
    }

    //graphics.fill(255);
    graphics.beginDraw();
    // reset background
    background(0, 0, 0, 0);
    drawHeart();
    drawRate();
    graphics.endDraw();
  }

  private void drawHeart() {
    graphics.pushMatrix();
    graphics.pushStyle();
    graphics.imageMode(CENTER);
    graphics.ellipseMode(CENTER);

    graphics.fill(255, 0, 0);
    graphics.strokeWeight(3);
    graphics.stroke(183, 83, 83);

    // heart will not take all space left
    float heartSpace = graphics.height * heartRatio;
    float ellipseSize = heartSpace / 1.5;

    // put in first corner
    graphics.translate(graphics.width / 4, heartSpace / 2);

    // heart at rest inside ellipse
    float heartRest = ellipseSize * 0.75;

    graphics.ellipse(0, 0, ellipseSize, ellipseSize);
    graphics.image(shadow, 0, 0, heartRest, heartRest);

    float heartSize = getHeartSize() * heartRest;
    graphics.image(whiteHeart, 0, 0, heartSize, heartSize);
    graphics.popStyle();
    graphics.popMatrix();
  }


  int HISTORY_SIZE = 400;
  int MAX_RATE = 250;
  int MIN_RATE = 40;

  private void drawRate() {

    // draw rate in its dedicated space, under heart
    graphics.pushMatrix();
    graphics.translate(0, graphics.height * heartRatio);
    graphics.scale(1, 1 - heartRatio);

    graphics.noFill();
    graphics.stroke(128);
    graphics.strokeWeight(1);

    graphics.image(monitor, 0, 0, graphics.width, graphics.height);

    graphics.stroke(255, 240);

    // ...scale the history to maximum space
    graphics.pushMatrix();
    graphics.scale(((float) graphics.width)/HISTORY_SIZE, ((float) graphics.height)/(MAX_RATE - MIN_RATE));

    int xPos = HISTORY_SIZE;
    for (int rate : rateHistory) {
      int rateSize = rate - MIN_RATE; // clamp bottom
      graphics.line(xPos, MAX_RATE - MIN_RATE, xPos, MAX_RATE - MIN_RATE - rateSize);
      xPos--;
    }

    graphics.popMatrix();
    graphics.popMatrix();
  }

  void findNextPulse() {
    int timeBetweenHeartBeats = (int) ((60.0f / heartRate) * 1000f); // for ms 
    nextPulse = lastPulse + timeBetweenHeartBeats;
  }

  boolean pulse() {
    return millis() >= nextPulse;
  }

  // return ratio of heart size (1 at rest, up to heartExpansion)
  float getHeartSize() {

    checkMode();

    if (mode.is("rest"))
      return 1.0;


    if (mode.is("beatUp")) {
      return map(millis(), 
      lastPulse, lastPulse + pulseDurationUp, 
      1.0, heartExpansion);
    }

    if (mode.is("beatDown")) {
      return map(millis(), 
      lastPulse + pulseDurationUp, lastPulse + pulseDurationUp + pulseDurationDown, 
      heartExpansion, 1.0);
    }

    return  0.5; // SICK ERRROR
  }

  void checkMode() {
    int currentTime = millis();

    if (currentTime > lastPulse + pulseDurationUp)
      mode.set("beatDown");

    if (currentTime > lastPulse +  pulseDurationUp + pulseDurationDown)
      mode.set("rest");
  }
}

