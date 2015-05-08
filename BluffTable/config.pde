
/** centralize configuration for teegi **/

// webcam that will monitor markers
final int camNumber = 0;

// main XP
final boolean cameraMode = false;
final boolean useProjector = false;
// if true, will project white screen on puppet paper to check calibration
boolean checkCalibration = false;

// feedback for HR and ambient: enable reading from LSL
final boolean feedbackFromNetwork = false;
// first channel: idx, second: bpm
final String LSLBPMStream = "BPM";
// one channel: face detected or fot
final String LSLDetectionStream = "detection";

// limit main program FPS (0 to disable)
final int limitFPS = 30;

// condition for feedback
// -1 no feedback
// 1 ambient feedback
// 2 explicit feedback
// 0 not set (typically, feedbackReadFromTCP == false)
int conditionAmbient = 0;

// Below this value we consider Idx to be noisy
double ThresholdIdx = 90f;

// 0: no HR feedback, 1: HR feedback others, 2: HR feedback all
int conditionHR = 2;

final static String textSelf = "moi";

final int nbPlayers = 3;
// change this according to actual players' name -- replaced by generic term if too short compared to nbPlayers
final static String[] textPlayers = {"Jane", "René", "William"};

