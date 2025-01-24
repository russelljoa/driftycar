class Gate {
  float x, y;
  int difficulty;
  int bottom = height;
  int top = 0;
  int start = width;
  int thickness = 150;
  int gapstart;
  boolean collision;
  boolean passed = false;
  
  
  
  Gate(int difficulty) {
    this.difficulty = difficulty;
    gapstart = (int)random(0, start - (difficulty));
    x = start;
    y = top - thickness;
    
    
  }

  void display() {
    fill(0);
    rectMode(CORNER);
    rect(0, y, gapstart, thickness);
    
    rect(gapstart + difficulty, y, width, thickness);
    fill(255, 0, 0);
    textAlign(CORNER);
    text(gapstart, x, gapstart); 
  }
  
  void update(float speedRate) {
    y += speedRate;
  }
  
  boolean checkCollision(float x, float y){
    
    if ((x-20 < gapstart || x + 20 > gapstart + difficulty) == true && (y + 20  > this.y && y-20 < this.y + thickness)){
      return true;
    }
    return false;
  }
}
