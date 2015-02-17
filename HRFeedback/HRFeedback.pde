import fr.inria.openvibelink.read.*;
import processing.net.*; 

// TCP client
private ReadAnalog myClient;

// holder for hearts
private Agent masterHeart;
// current state of hearts
private int[] heartsState;

// which file gives info about available body parts
final String CSV_BODY_FILENAME = "body_parts.csv";

// deals with window properties
void init() {
  // if going fullscreen, we do not need decoration
  if (START_FULLSCREEN) {
    frame.removeNotify();
    frame.setUndecorated(true); 
    frame.addNotify();
  }
  // if not fullscreen, enable resize
  // WARNING: dangerous behavior, will probably crash upon resize (dppend on graphic card/driver it seems)
  else if (ENABLE_RESIZE) {
    if (frame != null) {
      frame.setResizable(true);
    }
  }
  super.init();
}

void setup() { 
  // two possible size if we go fullscreen or not
  if (START_FULLSCREEN) {
    // using 2D backend as we won't venture in 3D realm
    size(displayWidth, displayHeight, P2D);
  } else {
    size(WINDOW_X, WINDOW_Y, P2D);
  }

  // explicit framerate if option is set
  if (FPS > 0) {
    frameRate(FPS);
  }
  // init client, first attempt to connect
  myClient = new ReadAnalog(this, TCPServerIP, TCPServerPort);

  // init for body parts randomness -- got headers, fields separated by tabs
  Table body_parts = loadTable(CSV_BODY_FILENAME, "header, tsv");
  println("Loaded " + CSV_BODY_FILENAME + ", nb rows: " + body_parts.getRowCount());
  Body.setTableParts(body_parts);

  // start up Ess for BodyPart (heartbeat)
  Ess.start(this);

  masterHeart = new Agent(nbHearts, heartsState);
}

// return for a chunks the number of beats detected in each channels (number of times we got positive values in a row)
// NB: if a "beat" is split among 2 chunks, then between two calls will think there's 2 distinct beats 
int[] detectBeats(double[][] data) {
  int nbChans = data.length;
  int [] beats = new int[nbChans]; // init with 0s by default
  println("Nb Chans: " + nbChans);
  if (nbChans > 0) {
    int chunkSize = data[0].length;
    for (int i=0; i < nbChans; i++) {
      // flag for current beat
      boolean isBeating = false;
      for (int j=0; j < chunkSize; j++) {
        if (data[i][j] > 0 && !isBeating) {
          isBeating = true;
          beats[i]++;
        }
        if (data[i][j] < 0) {
          isBeating = false;
        }
      }
    }
  }
  return beats;
}

void draw() { 
  background(128);
  println("-- FPS:" + frameRate + " --");
  double[][] data = myClient.read();

  if (data == null) {
    println("Waiting for data...");
  }
  // nice output to stdout
  else {
    int nbChans = myClient.getNbChans();
    int chunkSize = myClient.getChunkSize();
    println("Read " + chunkSize + " samples from " + nbChans + " channels:");
    heartsState = detectBeats(data);
    for (int i=0; i < nbChans; i++) {
      print(heartsState[i] + "\t");
    }
  }

  // update agent
  // update every part, deals all animations
  masterHeart.update(heartsState);
  shape(masterHeart.getPShape(), 0, 0);
}

// close ESS on exit
// TODO: cleanup other things...
// TODO: should use handler...
public void dispose () {
  println("Exiting...");
  // TODO: this one seems to freeze regurarely app :\
  Ess.stop();
}

