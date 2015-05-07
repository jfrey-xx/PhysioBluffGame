
// various config for the experiment

// if true, will spam stdout with sent values
final boolean debug = false;

final String TCPServerIP = "localhost";
final int TCPServerPort = 5678;

// greater than 0 to explicitely set framerate
final int FPS = 0;

// how many hearts we got for our experiment?
final int nbHearts = 3;

// start experiment in fullscreen or not
final boolean START_FULLSCREEN = false;
// in window mode, let resize magic happen
// WARNING: dangerous behavior, will probably crash quickly while resizing
final boolean ENABLE_RESIZE = true;
// default size for window fode
final int WINDOW_X = 1000;
final int WINDOW_Y = 700;
