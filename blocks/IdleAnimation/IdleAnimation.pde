
// for debug, we will print FPS every second
int lastFPS = 0;

Idle idle;

void setup() {
  int frameSizeX = 800;
  int frameSizeY = 600;

  size(frameSizeX, frameSizeY, OPENGL);
  idle = new Idle();
}



void draw() {
  background(128);
  if (millis() - lastFPS > 1000) {
    println(millis() + " -- FPS: " + frameRate);
    lastFPS = millis();
  }

  idle.update();
  image(idle.graphics, 0, 0, width, height);
}

