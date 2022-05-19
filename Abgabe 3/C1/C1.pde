import java.util.*;
HashMap<Character, Point> keyPositions;
Character lastPressedChar;
int sequencePosition;
boolean experimentActive;
char[] sequence;
String pressedString;
int trials;
void setup(){
  fullScreen();
  pixelDensity(displayDensity());
  frameRate(60);
  keyPositions = new HashMap();
  experimentActive = false;
  trials = 0;
}

void draw(){
  background(255); // clear to white
  fill(0); // fill with black
  initKeyboard();
  noStroke();
  textAlign(LEFT, TOP);
  textSize(24);
  text("User Study", 10, 10);
  textSize(16); 
  if(!experimentActive){
  startExperiment();
  }
  text("Trials: " + trials + "/30", 50,200);
  text("Type: " + new String(sequence), 50, 220);
  text("Already typed: " + pressedString, 50, 240);
}

void initKeyboard(){
  char currentChar;
  int iterator = 0;
  for(int i = 0; i < 3; i++){
    for(int j = 0; j<10; j++){
      noFill();
      stroke(153);
      if(iterator < 29){
        rect(j * 50 + 50, i * 50 + 50, 40,40);
        currentChar = (char)('a' + iterator);
      if(currentChar ==123){
        currentChar = '.';
      }
      if(currentChar == 124){
        currentChar = ',';
      }
      if(currentChar == 125){
        currentChar = ' ';
      }
      text(currentChar, j* 50 + 65, i*50 + 60);
      keyPositions.put(currentChar, new Point(j * 50 + 50, i * 50 + 50));
      iterator++;
      }
      
    }
  }
  
}

void mousePressed(){
  lastPressedChar = getPressedCharacter();
  if(lastPressedChar == sequence[sequencePosition]){
    sequencePosition++;
    pressedString = pressedString + lastPressedChar.toString();
  }
  
  if(pressedString.equals(new String(sequence))){
    startExperiment();
  }
}

Character getPressedCharacter(){
  //Map.Entry<char, Point> currentChar : map.entrySet()
  Set<Character> keySet = keyPositions.keySet();
  for(Character currentChar : keySet){
    Point currentPoint = keyPositions.get(currentChar);
    if(currentPoint.getPosX() < mouseX && currentPoint.getPosX() + 40 > mouseX ){
      if(currentPoint.getPosY() < mouseY && currentPoint.getPosY() + 40> mouseY){
      return currentChar;
      }
    }
  }
  return null;
}
  char[] generateSequence(){
  char[] sequence = new char[15];
  for(int i=0; i<15; i++){
    Random r = new Random();
    char c = (char)(r.nextInt(29) + 'a');
    if(c==123){
      c='.';
    }else if(c==124){
      c=',';
    }else if(c==125){
      c=' ';
    }
    sequence[i] = c;
  }
  return sequence;
}


void startExperiment(){
  sequence = generateSequence();
  sequencePosition = 0;
  experimentActive = true;
  pressedString = "";
  trials++;
}
