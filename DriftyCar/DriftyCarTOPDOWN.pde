import java.util.*;
int time = millis();
PFont def;
float textW, textH;
int hardness = 9000;
float angle = 2*PI;
float angleChange = 0;
float angleAccel = 0;
float x;
float y;
float driftx;
float drifty;
float speedRate = 1.5;
float driftThreshold;
float speed, accel, velocityX, velocityY;
float centerX;
float centerY;
float centerSize;
float carDirection;
float carAngle;
float angleDeg;
float circleAngleX;
float circleAngleY;
int carSize;
float squareVal;
int imgW, imgH;
int lineW, lineH;
int frameMillis = millis();
int frame = 0;
float carMultiplier;
float textAnim;
PImage carImg, nitroFlame, explosion, spedometer;
PImage line;
boolean touchingMid;
boolean crashed = false;
boolean devTools = false;
boolean aPressed, dPressed, nitro, started;
boolean inRed, inGreen, inBlue, inPink;
boolean permRed, permGreen, permBlue, permPink;

int count, score, scoreHolder, highScore;
int scoreMultiplier = 1;
float driftScore, scoreAccel, driftScoreCap;
ArrayList<Rubber> tireMarks = new ArrayList<Rubber>();
ArrayList<Gate> gates = new ArrayList<Gate>();
String[] cars =  {"ferarri.png", "porche.png", "lambo.png"};
int carSelection;


void setup() {
  textAlign(CENTER);
  carSelection = 0;
  score = 0;
  driftScore = 0;
  scoreMultiplier = 1;
  crashed = false;
  started = false;
  size(1200, 1400);
  carImg = loadImage(cars[carSelection]);
  nitroFlame = loadImage("fire.png");
  spedometer = loadImage("spedometer.png");
  crashed = false;
  speed = 1;
  centerX = width/2;
  centerY = height/2;
  centerSize = 200;
  x = 400;
  y = centerY;
  carSize = 20;
  imgH = carImg.height;
  imgW = carImg.width;
  squareVal = centerY;
  driftThreshold = 0.0015;
  scoreHolder = 5;
  def = createFont("Poppins-Medium.ttf", 500);
  textFont(def);
}

void draw() {
  background(255);

  // START MENU
  if (started == false) {
    imageMode(CENTER);
    carImg = loadImage(cars[carSelection]);
    imgH = carImg.height;
    imgW = carImg.width;
    textSize(160);
    fill(0);
    textAlign(CENTER);

    text("DRIFTY CAR", width/2, height/2);
    textSize(50);
    fill(0);
    text("CLICK TO START", width/2, height/2 + 100);
    textW = textWidth("CLICK TO START");
    text("< SELECT CAR >", width/2, height/2 + 200);

    // sets the image scales so cars are the same size
    if (carSelection == 0) {
      carMultiplier = 3;
    }
    if (carSelection == 1) {
      carMultiplier = 4;
    }

    if (carSelection == 2) {
      carMultiplier = 5.5;
    }
    pushMatrix();
    translate(centerX, 1100);
    rotate(PI);
    image(carImg, 0, 0, imgW/(carMultiplier-1.5), imgH/(carMultiplier-1.5));
    popMatrix();
  }

  // if the game is started
  if (started == true) {



    if (crashed == false) {
      if (score >= scoreHolder) {
        scoreHolder += (2* scoreMultiplier);
        if (hardness > 2500) {
          hardness -= 300 + (300*(1/score));
        }
        
        speedRate += 0.2;
      }

      if (millis() > time + hardness) {
        gates.add(new Gate(hardness/15));
        time = millis();
      }

      rectMode(CORNER);
      fill (0);

      if (tireMarks.size() > 500) {
        //for (int i=0; i < tireMarks.size()-250; i++){} REMOVE TIREMARKS PAST 250 BUT ITS CLUNKY
        tireMarks.remove(0);
        tireMarks.remove(0);
      }
      for (Rubber mark : tireMarks) {
        mark.display(speedRate);
      }

      if (gates.size() > 0 && ((gates.get(0).x + gates.get(0).thickness) < 0)) {
        gates.remove(0);
      }
      for (Gate obj : gates) {
        obj.update(speedRate);
        obj.display();
        if (obj.checkCollision(x, y)) {

          crashed = true;
          speed = 0;
          speedRate = 0;
          accel = 0;
          angleChange = 0;
          angleAccel = 0;
        }
        if (obj.passed == false && y< obj.y) {
          obj.passed = true;
          score += scoreMultiplier;
        }
      }







      // displays the dev info so I can edit stuff easier
      if (devTools) {
        textSize(20);
        fill(0);
        text(
          //"(" + (int)(x-(height/2)) + ", " + (int)(-y+(height/2)) +")"
          "Score: " + score +"\n" +
          "Drift Score: " + (int) driftScore +"\n" +
          "Collisions: " + inRed + inGreen + inPink + inBlue +"\n" +
          "TouchingMid: " + touchingMid +"\n" +
          "Coords: (" + x + ", " + y +")\n" +
          "Speed: " + ((double)((int) (speed * 100))) /100 +"\n" +
          "Angle: " + ((double)((int) (angleDeg * 100))) /100 +"\n" +
          "AngleChange: " + angleChange +"\n" +
          "angleAccel: " + angleAccel +"\n" +
          "carAngle: " + angle +"\n" +
          "Accel: " + accel +"\n" +
          "Multipl: " + scoreMultiplier +"\n" +
          "carDirection: " + carDirection +"\n"

          , 10, 40);
      }

      fill(0, 100, 255);



      // doubles the acceleration if nitro button is pressed
      if ((nitro == true)) {
        speed += accel*2;
      }
      
      // if nitro is not pressed, changes the speed based on how hard you are turning
      if ((nitro == false && speed < 8 *(1-abs(angleChange * 2))) || accel <= 0) {
        speed += accel;
      }
      // caps speed when nitro is active
      if (speed > 12 *(1.02-abs(angleChange * 4))) {
        speed = 12 *(1.02-abs(angleChange * 4));
      }
      
      // changing the turning acceleration and capping it
      angleChange += angleAccel;
      if (angleChange > .1) {
        angleChange = .1;
      }
      if (angleChange < -0.1) {
        angleChange = -0.1;
      }
      
      // changeing the angle of the car based on the velocity of the turn
      angle += angleChange;
      if (angleChange>0) {
        angleChange-= driftThreshold;
      }
      if (angleChange<-0) {
        angleChange+= driftThreshold;
      }
      
      // makes sure the car stays going stright when not turning
      if (angleChange > -driftThreshold && angleChange < driftThreshold && aPressed == false && dPressed == false) {
        angleChange= 0;
      }



      // sets speed at a constant rate of 1
      
      if (speed <1 && crashed == false) {
        speed = 1;
      }
      

      // keeps angle within a 2PI radian range
      
      if (angle > (float) (2 * PI)) {
        angle = angle - (float) (2 * PI);
      }
      if (angle < 0) {
        angle = (float)(2 * PI)-angle;
      }
      
      // calculates velocity vector based off of angle and speed
      
      velocityY = speed *cos(angle);

      velocityX = speed * sin(angle);
      
      // applies the velocity to x and y
      if (crashed == false) {
        x += velocityX;
        y += velocityY;
      }
      
      // collisions with map borders
      if (x > width - (carSize/2)) {
        x = width - (carSize/2);
      }
      if (x < 0 + (carSize/2)) {
        x = 0 + (carSize/2);
      }
      if (y > height - (carSize/2)) {
        y = height - (carSize/2);
      }
      if (y < 0 + (carSize/2)) {
        y = 0 + (carSize/2);
      }

      
      // Drift multiplier UI
      rectMode(CORNER);
      // Border rectangle
      fill(255);
      strokeWeight(4);
      stroke(0);
      rect(width/2 - 300  - 150, height - 80, 600, 60);

      //Drift score calculator
      // If the drift is over the threshold, it sets the drift cap higher and drift score is always going up so the UI looks smooth as it goes up

      if ((angleChange > 0.03 || angleChange < -0.03) && speed > 2.5) {
        scoreAccel = speed * abs(angleChange);
        driftScoreCap += scoreAccel;
      }

      if (driftScore >= driftScoreCap ) {
        driftScore = driftScoreCap;
      } else {

        driftScore += (.10 + .15/scoreMultiplier) * sqrt(driftScoreCap - driftScore);
      }


      if (driftScore >= 148) {
        driftScore = 0;
        driftScoreCap = 0;
        scoreMultiplier += 1;
      }
      fill(150, 200, 0);
      noStroke();
      
      // fills the inner green rectangle with driftscore
      rect(width/2 - 296  - 150, height - 75, (driftScore * 4) + 10, 51);
      textSize(50);
      fill(0);
      textAlign(LEFT);
      
      // displays the multiplier as a number
      text("x" + scoreMultiplier, width/2 - 290  - 150, height - 32);
      textAlign(CENTER);

      fill(255);
      rect(width/2 - 120  - 150, height - 125, 240, 31);
      
      // UI labeling
      textSize(30);
      fill(0);
      text("Drift Multiplier:", width/2 - 150, height - 100);
      textSize(50);
      textAlign(LEFT);
      fill(74, 191, 199);
      text("Score: " + score, 10, 50);
      fill(0);
      textAlign(CENTER);
      imageMode(CORNER);
      
      // Places the spedometer image
      image(spedometer, width - (spedometer.width/1.5) - 20, height - (spedometer.height/1.5) - 20, spedometer.width/1.5, spedometer.height/1.5);
        
      // Sets the hand on the spedometer 
      pushMatrix();
      // sets 0,0 to the middle of the spedometer
      translate(((width - 20 - (spedometer.width/3))), (height - 20 - (spedometer.width/3)));
      // rotates based on the speed and stops at just above 0 and ends at end of spedometer display
      rotate((sqrt(speed)*1.75)-(0.7));
      fill(255, 0, 0);
      // displays the spedometer hand
      rect(0, 0, 7, (spedometer.height)/3 - 20);

      popMatrix();
      imageMode(CENTER);
      rectMode(CENTER);
      // moves the car downwards at the same rate as the other screen items
      y += speedRate;
      
      pushMatrix();
      // sets 0,0 to the middle of the car
      translate(x, y);
      //angle is negative and overrotates the car to make it look like its drifting
      rotate(-angle - (angleChange*(speed *1.7)));
      fill(100);
      //rect(0, 0, 20, 30);
      imageMode(CENTER);
      
      if (crashed == false) {
        image(carImg, 0, 0, imgW/carMultiplier, imgH/carMultiplier);
        
         // displays the fire when nitro is pressed
        if (nitro) {
          image(nitroFlame, 0, -80, nitroFlame.width/5, nitroFlame.height/5);
        }
        
        // if the car is drifting
        if ((angleChange > .025 || angleChange < -0.025) && speed > 2.5) {
          
          // adds the left and right tire drift marks to the arrayList
          tireMarks.add(new Rubber(x, y, -15, -50, angle, angleChange, speed));

          tireMarks.add(new Rubber(x, y, 15, -50, angle, angleChange, speed));
        }
      }

      rectMode(CENTER);
      fill(255, 50, 50);
      //rect(5,-10, 5, 3);

      popMatrix();


    }
    
    //Crash exposion and pregame menu
    if (crashed == true) {
      fill(255);
      rect(-400, 400, 800, 400);
      
      // display the rubber marks for a cool look in the end screen
      for (Rubber mark : tireMarks) {
        mark.display(speedRate);
      }

      // iterate explosion frames
      if (millis() > frameMillis + 100 && frame < 23) {
        explosion = loadImage("explosion/frame_" + frame + "_delay-0.05s.png");
        frameMillis = millis();
        frame += 1;
      }
      // display the frame itself
      image(explosion, x, y);

      // set highscore
      if (score > highScore) {
        highScore = score;
      }
      
      // display UI
      textSize(100);
      fill(255, 0, 0);
      textAlign(CENTER, CENTER);

      text("YOU CRASHED!", width/2, height/2 - 100);
      fill(0);
      textSize(50);
      text("YOUR SCORE: " + score + "\nHIGHSCORE: " + highScore, width/2, height/2 + 100);
      text("CLICK ANYWHERE TO START OVER", width/2, height/2 + 300);
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    nitro = true;
  }

  if (key == '.') {
    if (devTools) {
      devTools = false;
    }
    if (!devTools) {
      devTools = true;
    }
  }

  if (keyCode == LEFT) {
    aPressed = true;
    if (speed < 1.9) {
      if (angleChange < 0.023) {
        angleAccel = 0.0025;
      } else {
        angleAccel = 0;
      }
    } else if (speed < 3 && speed > 1.5) {
      angleAccel = 0.0025;
    } else if (speed >= 3) {
      angleAccel = 0.003 + (sqrt(speed)/2000);
    }
  }
  if (keyCode == RIGHT) {
    dPressed = true;
    if (speed < 1.9) {
      if (angleChange > -0.023) {
        angleAccel = -0.0025;
      } else {
        angleAccel = 0;
      }
    } else if (speed < 3 && speed > 1.5) {
      angleAccel = -0.0025;
    } else if (speed >= 3) {
      angleAccel = -0.003 - (sqrt(speed)/2000);
    }
  }
  if (keyCode == UP) {
    if (nitro == false && accel < 0.35) {
      accel = 0.04 - (sqrt(speed)/80);
    }
  }

  if (keyCode == DOWN) {
    if (speed > 1) {
      accel = -.07;
    }
  }
}


void keyReleased() {
  if (key == ' ') {
    nitro = false;
  }

  if (keyCode == LEFT) {
    aPressed = false;
    angleAccel = 0;
  }

  if (keyCode == RIGHT) {
    dPressed = false;
    angleAccel = 0;
  }
  if (keyCode == UP) {

    if (speed > 1) {
      accel = -.04;
    }
  }
  if (keyCode == DOWN) {
  }
}

void mousePressed() {
  if (started == false && (mouseX > (centerX - (textW/2)) && mouseX < (centerX + (textW/2)) && mouseY < height/2 + 150 && mouseY > height/2 - 150) ) {
    wipe();
    start();
  }

  if (started == false && (mouseX < (centerX + (300)) && mouseX > (centerX + (100)) && mouseY < height/2 + 225 && mouseY > height/2 - + 175) ) {

    if (carSelection == 2) {
      carSelection = 0;
    } else if (carSelection < cars.length - 1) {
      carSelection += 1;
    }
  }

  if (started == false && (mouseX > (centerX - (300)) && mouseX < (centerX - (100)) && mouseY < height/2 + 225 && mouseY > height/2 - + 175) ) {
    if (carSelection == 0) {
      carSelection = 2;
    } else if (carSelection <= cars.length - 1) {
      carSelection -= 1;
    }
  }

  if (crashed == true) {
    wipe();
  }
}

void wipe() {
  textAlign(CENTER);
  tireMarks.clear();
  gates.clear();
  if (score > highScore) {
    highScore = score;
  }
  score = 0;
  angle = PI/2;
  driftScore = 0;
  scoreMultiplier = 0;
  crashed = false;
  started = false;
  carImg = loadImage(cars[carSelection]);
  nitroFlame = loadImage("fire.png");
  spedometer = loadImage("spedometer.png");

  speed = 1;
  centerX = width/2;
  centerY = height/2;
  centerSize = 200;

  carSize = 20;
  imgH = carImg.height;
  imgW = carImg.width;
  squareVal = centerY;
  driftThreshold = 0.0015;
  scoreHolder = 5;
}

void start() {
  x = centerX;
  y = height - 300;
  crashed = false;
  started = true;
  time = millis();
  angle = PI;
  gates.clear();
  tireMarks.clear();
  gates.add(new Gate(800));
  speedRate = 1.5;
  frame = 0;
  hardness = 9000;
  score = 0;
  scoreMultiplier = 1;
  driftScore = 0;
  driftScoreCap = 0;
}
