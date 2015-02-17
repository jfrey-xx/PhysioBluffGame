
// will create an "agent" from different body parts -- here taken from PhyCS HR project, should rename / update
// NB: call Body.setTableParts() beforehand fore randomness
// NB: see AGENT_WIDTH and AGENT_HEIGHT for supposed image size
// WARNING: should call cleanup() when the agent is not needed
public class Agent {

  // The screen space occupied by agents is believed to be a certain size (in pixels).
  public static final int AGENT_WIDTH = 800;
  public static final int AGENT_HEIGHT = 850;

  // we need some spare parts to make a functional body
  private BodyPart[] hearts;
  // is agent currently cleaning?
  private boolean cleaning = false;

  // Every elemet will be connected to it
  private PShape wholeBody;

  // number of hearts we're dealing with
  private int nbHearts = 0;
  // beatings state
  private int[] heartsState;

  // Create the different parts.
  // nbHearts: number of hearts to create -- at least 1
  // heartsState: pointer to int array
  Agent(int nbHearts, int [] heartsState) {
    assert(nbHearts > 0);

    this.nbHearts = nbHearts;
    this.heartsState = heartsState;  

    hearts = new  BodyPart[nbHearts];


    // but hearts in circle
    float radius=AGENT_WIDTH/2;
    float angle=TWO_PI/(float)this.nbHearts;

    for (int i = 0; i < nbHearts; i++) {
      hearts[i] = new BodyPart(Body.Type.HEART, Body.Genre.BOTH, "beat.wav");
      // the original SVG is a bit too big
      hearts[i].getPShape().scale(0.66);
      hearts[i].setPos(radius*sin(angle*i) + AGENT_WIDTH, radius*cos(angle*i) + AGENT_HEIGHT/2);
      hearts[i].setAnimationSpeed(45);
    }

    // time to add every part to the agent
    wholeBody = new PShape();
    for (BodyPart h : hearts) {
      wholeBody.addChild(h.getPShape());
    }
  }

  // will call recursively body parts + make mouth animate if speaking
  // halt if cleaning
  public void update(int [] heartsState) {
    // useless to update parts if cleanup() has been called: they won't do anything anymore
    if (cleaning) {
      return;
    }
    // update every heart with current heart condition
    for (int i = 0;  i < nbHearts; i++) {
      // update with available data
      if (heartsState != null && heartsState.length > i) {
        hearts[i].update(heartsState[i]);
      }
      // if some are missing (because of readings error for example), then stop beat
      else {
        hearts[i].update(0);
      }
    }
  }

  // access to master shape for transformations and drawing
  public PShape getPShape() {
    return wholeBody;
  }

  // will build an indenty from HR type, genre and every body parts details
  public String toString() {
    String out = "hearts: ";
    for (BodyPart h : hearts) {
      out += h + ", ";
    }
    return out;
  }

  // cleanup every body parts -- needed for audio stream. Return true when all parts are cleaned.
  // once called, will freeze agent (no more updates)
  public boolean cleanup() {
    println("Cleaning agent " + this); 
    cleaning = true; 
    boolean clean = true; 
    // call all cleanup + check that has effectively cleaned
    for (BodyPart h : hearts) {
      clean = clean && h.cleanup();
    }
    return clean;
  }
}

