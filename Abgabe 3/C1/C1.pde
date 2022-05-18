HashMap<char, Point> keyPositions;
char lastChar;
void setup(){
  fullScreen();
  pixelDensity(displayDensity());
  frameRate(60);
 keyPositions = new HashMap();
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
