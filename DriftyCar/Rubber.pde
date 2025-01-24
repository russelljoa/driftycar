class Rubber {
  float carX, carY, x, y, angle, angleChange, speed;
  int opacity = 0;
  
  Rubber(float carX, float carY, float x, float y, float angle, float angleChange, float speed) {
    this.x = x;
    this.y = y;
    this.carX = carX;
    this.carY = carY;
    this.angle = angle;
    this.angleChange = angleChange;
    this.speed = speed;
  }

  void display(float speedRate) {
    
    pushMatrix();
    carY += speedRate;
    translate(carX, carY);
    
    rotate(-angle - (angleChange*(speed *1.5)));
    opacity =  255 - (int) pow(speed * (abs(angleChange)*20), 3);
    if (opacity < 0){
      opacity = 0;
    }
    fill(opacity);
    //
    noStroke();
    
    ellipse(x, y, 12, 12);
    //tint(255,255,255,255);
    popMatrix();
  }
}
