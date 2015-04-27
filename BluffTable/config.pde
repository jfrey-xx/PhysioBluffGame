
/** centralize configuration for teegi **/

// webcam that will monitor markers
final int camNumber = 0;

// main XP
final boolean noCameraMode = true;
boolean isMiniTeegiManual = false;
// if true, will project white screen on puppet paper to check calibration
boolean checkCalibration = true;

// feedback: IP and port of openvibe scenario, flag to enable reading or not (as a client, will connect to)
final boolean feedbackReadFromTCP = false;
final String feedbackTCPServerIP = "localhost";
final int feedbackTCPServerPort = 5678;

// limit main program FPS (0 to disable)
final int limitFPS = 30;

final int nbPlayers = 2;

// condition for feedback
// -1 no feedback
// 1 ambient feedback
// 2 explicit feedback
// 0 not set (typically, feedbackReadFromTCP == false)
int condition = 0;
