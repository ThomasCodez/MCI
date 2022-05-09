import java.util.Iterator;

void setup() {
  fullScreen();
  pixelDensity(displayDensity());
  frameRate(60);
}

float xpos;
float ypos;
float colorCircle;
void draw() {
  background(255); // clear to white
  fill(0); // fill with black
  noStroke();
  
  textAlign(LEFT, TOP);
  textSize(24);
  text("User Study", 10, 10);
  textSize(16);
  
  if (experimentActive) {
    text("Press space when the circle appears! Press 'a' for results!", 10, 40);
    updateExperiment();
    fill(255, 255, colorCircle);
    if(stimulusIsVisible){
      colorCircle--;
    }
    circle(xpos, ypos, 100);
    // show previous time if available
    if (!times.isEmpty()) {
      
      long lastTime = times.get(times.size() - 1);
      fill(0);
      text(("Trial:" + (times.size() + errors) + "/30"), 10,90);
      text(lastTime + " ms", 10, 110);
    }
  } else {
    text("Press space to start!", 10, 40);
    
    if (!times.isEmpty()) {
      // we have some experiment results#
      text("Count: " + times.size(), 10, 60);
      text("Mean: " + Math.round(getMean(times)) + " ms", 10, 80);
      text("SD: " + Math.round(getStandardDeviation(times)) + " ms", 10, 100);
      text("Corr: " + getCorrelation(times, distances), 10,140);
      text("Errors: " + errors, 10, 120);
    }
  }
}
  int errors;
void keyPressed() {
  if (key == ' ') {
    // the user pressed the space key
    if (!experimentActive) {
      // start the experiment if it wasn't active
      startExperiment();
      return;
    }
    
    if (stimulusIsVisible) {
      // record reaction time
      recordStimulusReactionTime();
      
      if(times.size() + errors == 30){
      stopExperiment();
      }
      // start next trial
      startTestTrial();
    } else {
      errors++;
      if(times.size() + errors == 30){
      stopExperiment();
      }
      startTestTrial();
    }
  } else if (key == 'a') {
    if (experimentActive) {
      // stop the experiment and show results
      stopExperiment();
    }
  } else if (key == 'b') {
    // ...
  }

}

// if true, the experiment is currently active
boolean experimentActive = false;

// if true, the stimulus is currently visible
boolean stimulusIsVisible = false;

// timestamp at which the stimulus last appeared (in milliseconds since program start)
long stimulusTimestamp;

// timeout where, if it reaches 0, the stimulus will appear. In milliseconds.
// will be ignored if negative
long testStimulusTimeout = -1;

// recorded reaction times in milliseconds
ArrayList<Long> times = new ArrayList();

ArrayList<Long> distances = new ArrayList();

double getMean(ArrayList<Long> data) {
  double sum = 0;
  for (long value : data) sum += value;
  return sum / data.size();
}
double getStandardDeviation(ArrayList<Long> data) {
  double mean = getMean(data);
  double squareSum = 0;
  for (long value : data) squareSum += Math.pow(value - mean, 2);
  return Math.sqrt(squareSum / data.size());
}

void addDistance(){
 float deltaX = xpos - displayWidth;
 float deltaY = ypos - displayHeight;
 double distance = Math.pow(deltaX, 2) + Math.pow(deltaY, 2);
 distance = Math.sqrt(distance);
 distances.add((long) distance);
}


void startTestTrial() {
  stimulusIsVisible = false;
  float timeToWaitInSeconds = random(2, 6);
  testStimulusTimeout = (long) (timeToWaitInSeconds * 1000);
  
  xpos = random(50,450);
  ypos = random(50,450);
  colorCircle = 255;
}

void showStimulus() {
  stimulusIsVisible = true;
  stimulusTimestamp = System.currentTimeMillis();
}

double getCorrelation(ArrayList<Long> times, ArrayList<Long> distances){
   double timesMean = getMean(times);
   double distanceMean = getMean(distances);
   double timesSTD = getStandardDeviation(times);
   double distanceSTD = getStandardDeviation(distances);
   Iterator<Long> timeIterator = times.iterator();
   Iterator<Long> distanceIterator = distances.iterator();
   double cov = 0;
   while(distanceIterator.hasNext() && timeIterator.hasNext()){
     cov = cov + (((double) distanceIterator.next() - distanceMean) * ((double) timeIterator.next() - timesMean));
   }
   cov = cov / times.size();
   return cov / (timesSTD * distanceSTD);
}

void recordStimulusReactionTime() {
  long deltaTime = System.currentTimeMillis() - stimulusTimestamp;
  times.add(deltaTime);
  addDistance();
}

// last time the experiment was updated.
// used to calculate elapsed time
long lastUpdateTime;

void startExperiment() {
  times.clear();
  distances.clear();
  experimentActive = true;
  lastUpdateTime = System.currentTimeMillis();
  startTestTrial();
  errors = 0;
}

void updateExperiment() {
  long deltaTime = System.currentTimeMillis() - lastUpdateTime;
  lastUpdateTime = System.currentTimeMillis();
  
  if (testStimulusTimeout > 0) {
    testStimulusTimeout -= deltaTime;
    if (testStimulusTimeout <= 0) showStimulus();
  }
}

void stopExperiment() {
  // cancel any ongoing tests
  stimulusTimestamp = -1;
  stimulusIsVisible = false;
  experimentActive = false;
}
