HashMap<char, Point> keyPositions;
char lastChar;
void setup(){
  fullScreen();
  pixelDensity(displayDensity());
  frameRate(60);
  keyPositions = new Hashmap();
  initKeyboard();
}

void draw(){
  println(getSequence());
  background(255); // clear to white
  fill(0); // fill with black
  noStroke();
  textAlign(LEFT, TOP);
  textSize(24);
  text("User Study", 10, 10);
  textSize(16);
  
  if(mousePressed){
    lastChar = getPressedChar();
  }
}

void initKeyboard(){
  for(int i = 0; i < 3; i++){
    for(int j = 0; j<10; j++){
      rect(j * displayWidth / 20 + 5, i * displayWidth / 20 + 5, displayWidth / 20, displayWidth / 20);
    }
  }
  
}

char getPressedChar(){
  
  //Map.Entry<char, Point> currentChar : map.entrySet()
  Set<char> keySet = keyPositions.keySet();
  for(char currentChar : keySet){
    Point currentPoint = keyPositions.get(currentChar);
    if(currentPoint.getPosX < mouseX && currentPoint.getPosX + (displayWidth/20) > mouseX ){
      if(currentPoint.getPosY < mouseY && currentPoint.getPosY + (displayHeight/20)> mouseY){
      return currentChar;
      }
    }
  }
}
