import java.util.*;
HashMap<Character, Point> keyPositions;
Character lastChar;
void setup(){
  fullScreen();
  pixelDensity(displayDensity());
  frameRate(60);
  keyPositions = new HashMap();
}

void draw(){
  println(generateSequence());
  background(255); // clear to white
  fill(0); // fill with black
  initKeyboard();
  noStroke();
  textAlign(LEFT, TOP);
  textSize(24);
  text("User Study", 10, 10);
  textSize(16);
  
  if(mousePressed){
    lastChar = getPressedCharacter();
  }
}

void initKeyboard(){
  for(int i = 0; i < 3; i++){
    for(int j = 0; j<10; j++){
      rect(j * displayWidth / 20 + 5, i * displayWidth / 20 + 5, displayWidth / 20, displayWidth / 20);
    }
  }
  
}

Character getPressedCharacter(){
  
  //Map.Entry<char, Point> currentChar : map.entrySet()
  Set<Character> keySet = keyPositions.keySet();
  for(Character currentChar : keySet){
    Point currentPoint = keyPositions.get(currentChar);
    if(currentPoint.getPosX() < mouseX && currentPoint.getPosX() + (displayWidth/20) > mouseX ){
      if(currentPoint.getPosY() < mouseY && currentPoint.getPosY() + (displayHeight/20)> mouseY){
      return currentChar;
      }
    }
  }
  return null;
}
  String generateSequence(){
  String sequence = "";
  for(int i=0; i<15; i++){
    Random r = new Random();
    char c = (char)(r.nextInt(29) + 'a');
    if(c==123){
      c='.';
    }else if(c==124){
      c=',';
    }else if(c==125){
      c=' ';
    sequence = sequence + c;
    }
  }
  println(sequence);
  return sequence;
}
