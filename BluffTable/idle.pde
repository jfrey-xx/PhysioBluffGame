import java.util.LinkedList;

class Idle {

  private PGraphics graphics;
  private int texWidth;
  private int texHeight;

  // the animation will consist in fading points
  private int nbPoints = 18;
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
    float period = 20000f / nbPoints; 
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

      // each point its color, vary hue
      float hue = 255f/(nbPoints) * (i);
      graphics.colorMode(HSB, 255);
      graphics.fill(hue, 255, 255, val);

      // space points equally around a circle
      float angle=TWO_PI/(float)nbPoints;
      //float radius=map(val, 0, 255, 0, texWidth/5); // animation from/toward center
      float radius=texWidth/4; // animation from/toward center

      float slice = ((radius * PI * 2) / nbPoints) * 0.75;
      // slight zooming effect
      float wid = map(val, 0, 255, slice/3, slice);

      // the circle will be spinning (WARNING: crazy overall effect)
      float toto = millis()/10000f % TWO_PI; // sin( millis() / 7724.2f * PI) * PI;

      graphics.ellipse(radius*sin(angle*i - toto) + texWidth/2, radius*cos(angle*i - toto) + texHeight/2, wid, wid);
    }

    graphics.endDraw();
  }
}

