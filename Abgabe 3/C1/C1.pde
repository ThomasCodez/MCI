import java.util.*;
HashMap<Character, Point> keyPositions;
Character lastPressedChar;
int sequencePosition;
boolean experimentActive;
char[] sequence;
String pressedString;
int trials;
ArrayList<Long> IDlist = new ArrayList();
ArrayList<Long> MTlist = new ArrayList();
long timestamp;
PrintWriter outputFile;

void setup(){
  fullScreen();
  pixelDensity(displayDensity());
  frameRate(60);
  keyPositions = new HashMap();
  experimentActive = false;
  trials = 0;
  outputFile = createWriter("results.txt");
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
  text("Trials: " + trials + "/20", 50,200);
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
    IDlist.add(getID()); //Aufruf auf was?
    MTlist.add(getMT());
    timestamp=System.currentTimeMillis();
    sequencePosition++;
    pressedString = pressedString + lastPressedChar.toString();
  }
  
  if(pressedString.equals(new String(sequence)) && (trials<20)){
    startExperiment();
  }else{
    writeResultsToFile();
    //TODO
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
  timestamp = System.currentTimeMillis();
  pressedString = "";
  trials++;
}
Long getID(){
  double xNew = keyPositions.get(sequence[sequencePosition]).getPosX(); 
  double yNew = keyPositions.get(sequence[sequencePosition]).getPosY();
  double xOld = 0; //TODO Was wenn 1. sequencepos???
  double yOld = 0;
  if(sequence[sequencePosition]==1){
    xOld = keyPositions.get(sequence[sequencePosition-1]).getPosX(); 
    yOld = keyPositions.get(sequence[sequencePosition-1]).getPosY(); 
  }
  double d = Math.sqrt((yOld - yNew) * (yOld - yNew) + (xOld - xNew) * (xOld - xNew));    
  Long iD = (long)(Math.log((1+(d/40))/Math.log(2)));
  return iD;
}
Long getMT(){
  Integer a= 0; //ms
  Integer b= 150; //ms/bit
  Long MT = a+b*this.getID();  
  return MT;
}
void writeResultsToFile() {
  int counter = 1;
  Iterator<Long> MTIterator = MTlist.iterator();
  Iterator<Long> IDIterator = IDlist.iterator();
  outputFile.println("iteration  " + "MTI  " + "ID  ");
  while (MTIterator.hasNext()) {
    outputFile.println(counter + "  " + MTIterator.next() + "  " + IDIterator.next());
    counter++;
  }
  outputFile.flush();
  outputFile.close();
}
