HashMap<char, Point> keyPositions;
char lastChar;
void setup(){
  fullScreen();
  pixelDensity(displayDensity());
  frameRate(60);
  keyPositions = new Hashmap();
}

void draw(){
  background(255); // clear to white
  fill(0); // fill with black
  noStroke();
  initKeyboard();
  textAlign(LEFT, TOP);
  textSize(24);
  text("User Study", 10, 10);
  textSize(16);
  
  if(mousePressed){
    lastChar = getPressedChar();
  }
}

void initKeyboard(){
  
  
}

char getPressedChar(){
  
}
