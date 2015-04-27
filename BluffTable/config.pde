
/** centralize configuration for teegi **/

// webcam that will monitor markers
final int camNumber = 0;

// main XP
final boolean noCameraMode = true;
// if true, will project white screen on puppet paper to check calibration
boolean checkCalibration = true;

// feedback for HR and ambient: enable reading from LSL
final boolean feedbackFromNetwork = true;
// first channel: idx, second: bpm
final String LSLBPMStream = "BPM";
// one channel: face detected or fot
final String LSLDetectionStream = "detection";

// limit main program FPS (0 to disable)
final int limitFPS = 30;

final int nbPlayers = 2;

// condition for feedback
// -1 no feedback
// 1 ambient feedback
// 2 explicit feedback
// 0 not set (typically, feedbackReadFromTCP == false)
int condition = 0;

// Below this value we consider Idx to be noisy
double ThresholdIdx = 90f;

