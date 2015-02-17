
// A body part will draw and animate a specific element of the agent

// Possible to trigger an audio sound via ESS with each beat
// WARNING: In this case ESS need to be initialized beforehand ; put "Ess.start(this)" in setup()
// WARNING: should call cleanup() when BodyPart not needed anymore in order to free ESS resources

public class BodyPart {

  private Body.Type type;
  private Body.Genre genre;
  // parent for all parts
  private PShape bodyPart;
  // use an array of frames for animations, faster to access to part
  private ArrayList<PShape> frames;
  private int current_frame = 0;
  // once cleanup() is called, will cease to update()
  // 3 states: 0 (not cleaning), 1 (cleaning), 2 (cleaned)
  private int cleaning = 0;

  // "state of the heart" (should be 0 or 1)
  private boolean beating = false;
  // flag to start animation on next draw
  private boolean start_anim = false;

  // the time in ms between each frame of the animation
  private float animation_speed = 100;
  // during animation, when last frame occured
  private int last_keyframe = 0;

  // which part ID we are
  private int part_number;

  // use ESS r2 lib to read audio file, using rotating buffer to enable burst
  private AudioChannel[] beats;
  // how may of that buffer we'll use (depends on max BPM and audio file duration)
  // WARNING: for memory sake, don't go too high with big files!
  // TODO: if number too high, will prevent other parts to beat --  "32 AudioChannels and AudioStreams (combined) per sketch", will crash the whole sound system in fact. Centralize sound engine to prevent that.
  private final int NB_BUFFERS = 6;
  // for cycling, which buffer is currently played
  private int curBuffer;


  // set type and load model (randomize part if loadParts() has been called)
  BodyPart(Body.Type type, Body.Genre genre) {
    // no ref to an audio file by default
    this(type, genre, null);
  }

  // For heart: will use trigger to send stim code for effective beat
  // NB: it's a bit messy but you'll want to use HeartManager as a Trigger, as it will computes the actual HR for debug
  BodyPart(Body.Type type, Body.Genre genre, String beatAudioFile) {
    this.type = type;
    this.genre = genre;
    // get randomized number
    part_number = Body.getRandomPart(type, genre);

    println("Selected part number: " + part_number);
    // one master to rule them all
    bodyPart = new PShape();
    // load frames
    frames = new ArrayList();
    loadModel();
    // If we have at laest one frame, let's show it!
    if (frames.size() > 0) {
      current_frame = 0;
      frames.get(current_frame).setVisible(true);
    }

    // if option is set, will use audio
    if (beatAudioFile != null && !beatAudioFile.equals("")) {
      // let's try an array of buffer
      beats = new AudioChannel[NB_BUFFERS];
      // load audio beat into buffers
      for (int i = 0; i < beats.length; i++) {
        beats[i] = new AudioChannel(beatAudioFile);
      }
      curBuffer = 0;
    }
  }

  // load svg on creation
  private void loadModel() {
    PShape img;
    // build filename step by step
    // if parts list have been loaded, choose a random one
    String filename = Body.getTypeName(type) +  "_" + Body.getGenreName(genre) + "_" + part_number + ".svg";
    // load file
    println("Loading: " +  filename);
    img = loadShape(filename);
    println(img.getChildCount() + " children found.");
    // Counting the number of frames -- each layer should be named "Layer X"
    int nbFrames = 0;
    PShape frame = null;
    // will loop and push to "frames" as long as finds layers
    do {
      String layerName = "layer" + Integer.toString(nbFrames+1);
      //println("Look for " + layerName);
      frame = img.findChild(layerName);
      if (frame != null) {
        // hide it by default
        frame.setVisible(false);
        // add to list and to parent
        frames.add(frame);
        bodyPart.addChild(frame);
        nbFrames++;
      }
    } 
    while (frame != null);
    println("Found " + nbFrames + " frames.");
  }

  // update frame if needed, changing visibility of the right layer
  // returns true if has been updated
  public boolean update(int heartState) {
    // quit immidiatly if there's nothing to show or cleanup() has been called
    if (cleaning > 0 || frames.size() == 0) {
      return false;
    }

    // no more beat
    if (heartState == 0) {
      beating = false;
    }
    // new beat
    else if (heartState > 0 && !beating) {
      animate();
    }

    // timestamp for animations
    int tick = millis();

    if (
    // if an animation should start and is not already taking place...
    (start_anim && current_frame == 0)
      // OR if an animation is already taking place and it is time so show a new frame...
    || (current_frame != 0 && tick > last_keyframe + animation_speed)
      )
      // THEN we go for a cartoon
    {
      start_anim = false;
      // backup to toggle on one and off the previous
      int last_frame = current_frame;
      // next frame... but don't go too far
      current_frame++;
      if (current_frame >= frames.size()) {
        current_frame = 0;
      }
      // reset timestamp for keyframe
      last_keyframe = tick;
      frames.get(last_frame).setVisible(false);
      frames.get(current_frame).setVisible(true);

      return true;
    }

    return false;
  }

  // set coordinates in screen space: translates every frame
  // (careful, it's absolute, reset matrix before that)
  public void setPos(float x, float y) {
    for (int i = 0; i < frames.size (); i++) {
      frames.get(i).resetMatrix();
      frames.get(i).translate(x, y);
    }
  }

  // a hint of true java under the hood
  public String toString() {
    return type + "_" + genre + "_" + part_number;
  }

  // start a new animation, triggers beat sound for heart
  // return false if it is not possible -- already ocurring or no more than 1 frame
  public boolean animate() {
    if (current_frame != 0 || frames.size() < 2) {
      return false;
    }
    // tries to trigger audio
    beat();
    // return and set flag to true for update()
    return start_anim = true;
  }

  // setter for animation speed, time in ms between two frames
  public void setAnimationSpeed(float speed) {
    animation_speed = speed;
  }

  public PShape getPShape() {
    return bodyPart;
  }

  // Plays the heartbeat sound if option set. If all audio buffer are already playing, returns silentely.
  // (does not interrupt program)
  private void beat() {
    // don't go further if no audio file has been set or cleaning
    if (beats == null || cleaning > 0) {
      return;
    }

    int i = curBuffer;
    // look for next available buffer
    while (beats[i].state != Ess.STOPPED) {
      i++;
      // reset counter if gone too far
      if (i == beats.length) {
        i = 0;
      }
      // if we have done one complete loop: we pass
      if (i == curBuffer) {
        println("No available buffer.");
        return;
      }
    }
    // at this point we have an available buffer
    curBuffer = i;
    // make some noise!
    beats[curBuffer].play();
  }

  // will free ESS resources, if any. Return true when done (have to wait that all sound are played)
  // TODO: not a nice way to clean asynchronously -- trying to work with a playing audiochannel make the program freeze :\ 
  public boolean cleanup() {
    // already clean, don't wait to return
    if (cleaning == 2)
      return true;
    println("Cleaning " + this);
    // put a halt on everything
    cleaning = 1;
    if (beats != null) {
      for (int i=0; i<beats.length; i++) {
        // once a left audiostream is stopped
        if (beats[i]!= null) {
          if (beats[i].state == Ess.STOPPED) {
            // destroy it
            beats[i].destroy();
            // remove from array
            beats[i] = null;
          } else {
            // one is pending: return false
            return false;
          }
        }
        // here nothing more in beat[i], can skip it
      }
    }
    // all clear
    cleaning = 2;
    return true;
  }
}

