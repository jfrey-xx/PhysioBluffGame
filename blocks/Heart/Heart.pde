BeatingHeart heart1, heart2;

void setup(){
    size(400, 400, P3D);
    heart1 = new BeatingHeart();

    heart1.setPosition(55, 100);
    heart1.setHeartRate(80);
    heart1.setSize(30, 10);

    heart2 = new BeatingHeart();

    heart2.setPosition(250, 100);
    heart2.setHeartRate(150);
    heart2.setSize(30, 10);
}

void draw(){
    background(0);

    float sinTime = sin( (float) millis() / 7724.2f * TWO_PI );
    
      // println("Sin Time " + sinTime);
    heart1.setHeartRate((int) (120 + 60 * sinTime));


    heart1.drawSelf(this.g);

    heart2.drawSelf(this.g);
    heart2.setHeartRate(159);
}

