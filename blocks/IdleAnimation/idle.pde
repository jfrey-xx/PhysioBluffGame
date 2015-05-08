import java.util.LinkedList;

class Idle {

  private PGraphics graphics;
  private int texWidth;
  private int texHeight;

  // the animation will consist in fading points
  private int nbPoints = 3;
  private float[] pointColors;
  private int curPoint = 0;

  // first light up from left to right, then reverse
  private boolean goUp = true;

  // default texture size: 800x600 pixels
  public Idle() {
    this(800, 600);
  }

  // set custom texture size (in pixels)
  public Idle(int texWidth, int texHeight) {
    this.texWidth = texWidth;
    this.texHeight = texHeight;
    this.pointColors = new float[nbPoints];
    graphics = createGraphics(texWidth, texHeight, P2D);
  }

  // to be called once per draw()
  public void update() {
    graphics.beginDraw();
    graphics.clear();
    graphics.stroke(0, 0, 0, 0);
    graphics.ellipseMode(CENTER);

    // reduce value to increase frequency
    float period = 1000f; 
    float c = millis() % period;

    if (goUp) {
      c = map(c, 0, period, 0, 255);
    } else {
      c = map(c, 0, period, 255, 0);
    }

    // detect when we reached max value, select following point
    if (c <= pointColors[curPoint] && goUp) {
      curPoint++;
    } else if (c >= pointColors[curPoint] && !goUp) {
      curPoint++;
    }

    // new cycle once last point reached
    if (curPoint == nbPoints) {
      curPoint = 0;
      goUp = !goUp;
    } else {
      pointColors[curPoint] = c;
    }

    // draw points
    for (int i = 0; i < nbPoints; i++) {
      float val = pointColors[i];

      // space points equally on horizontal axis
      float slice = texWidth / nbPoints;
      float pos = slice/2 + slice * i;

      // each point its color, vary hue
      float hue = 255f/(nbPoints) * (i);
      graphics.colorMode(HSB, 255);

      float wid = map(val, 0, 255, slice/3, slice/2);
      
      graphics.fill(hue, 255, 255, val);
      graphics.ellipse(pos, texHeight/2, wid, wid);
    }




    graphics.endDraw();
  }
}

