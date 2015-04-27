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
  int defaultSize = 100;
  int expansion = 30;

  PVector position = new PVector();

  LinkedList<Integer> rateHistory = new LinkedList<Integer>();

  private SecondaryMode mode;
  private PGraphics graphics;

  public BeatingHeart() {
    checkImages();
    initModes();
  }

  private void checkImages() {
    if (shadow == null || whiteHeart == null) {
      whiteHeart = loadImage("heart.png");
      shadow = loadImage("shadow.png");
      monitor = loadImage("monitor1.png");
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

  public void setPosition(int x, int y) {
    this.position.x = x;
    this.position.y = y;
  }

  public void setSize(int size, int expansion) {
    this.defaultSize = size;
    this.expansion = expansion;
  }


  public void drawSelf(PGraphics graphics) {
    this.graphics = graphics;
    if (pulse()) {
      lastPulse = millis();
      findNextPulse();
      mode.set("beatUp");
    }

    drawHeart();
    drawRate();
  }

  private void drawHeart() {
    graphics.pushStyle();
    graphics.imageMode(CENTER);
    graphics.ellipseMode(CENTER);

    graphics.fill(255, 0, 0);
    graphics.strokeWeight(3);
    graphics.stroke(183, 83, 83);

    int x = (int) position.x;
    int y = (int) position.y;

    int trX = -1;
    int trY = -5;
    float scale = 2.0;
    graphics.ellipse(x + trX, y + trY, defaultSize * scale, defaultSize * scale);

    graphics.image(shadow, x, y, defaultSize, defaultSize);

    int heartSize = getHeartSize();
    graphics.image(whiteHeart, x, y, heartSize, heartSize);
    graphics.popStyle();
  }


  int HISTORY_SIZE = 400;
  int MAX_RATE = 250;
  int MIN_RATE = 40;

  private void drawRate() {

    graphics.pushMatrix();

    graphics.translate(position.x, position.y);

    // Get down by 100, top of the table
    graphics.translate(-defaultSize, defaultSize * 1.3f);

    graphics.scale(0.36);

    graphics.noFill();
    graphics.stroke(128);
    graphics.strokeWeight(2);
    //  graphics.rect(0, 0, HISTORY_SIZE,  MAX_RATE - MIN_RATE);
    graphics.image(monitor, 0, 0, HISTORY_SIZE, MAX_RATE - MIN_RATE);

    // get to the bottom. 

    //  graphics.fill(255, 100);
    graphics.stroke(255, 66);

    int xPos = HISTORY_SIZE;
    for (int rate : rateHistory) {
      int rateSize = rate - MIN_RATE;
      graphics.line(xPos, MAX_RATE - MIN_RATE, xPos, MAX_RATE - MIN_RATE - rateSize);
      xPos--;
    }

    graphics.popMatrix();
  }



  void findNextPulse() {
    int timeBetweenHeartBeats = (int) ((60.0f / heartRate) * 1000f); // for ms 
    nextPulse = lastPulse + timeBetweenHeartBeats;
  }

  boolean pulse() {
    return millis() >= nextPulse;
  }

  int getHeartSize() {

    checkMode();

    if (mode.is("rest"))
      return defaultSize;


    if (mode.is("beatUp")) {
      return (int) map(millis(), 
      lastPulse, lastPulse + pulseDurationUp, 
      defaultSize, defaultSize + expansion);
    }

    if (mode.is("beatDown")) {
      return (int) map(millis(), 
      lastPulse + pulseDurationUp, lastPulse + pulseDurationUp + pulseDurationDown, 
      defaultSize + expansion, defaultSize);
    }

    return defaultSize - 50; // SICK ERRROR
  }


  void checkMode() {
    int currentTime = millis();

    if (currentTime > lastPulse + pulseDurationUp)
      mode.set("beatDown");

    if (currentTime > lastPulse +  pulseDurationUp + pulseDurationDown)
      mode.set("rest");
  }
}

