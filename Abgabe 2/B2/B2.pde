import java.util.Iterator;
import java.util.Collections;
import java.util.Random;


int errors;
int errorsRed;
int errorsYellow;
int noAction;
PrintWriter outputFile;

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
ArrayList<Long> timesRed = new ArrayList();
ArrayList<Long> timesYellow = new ArrayList();
ArrayList<String> colors = new ArrayList();
ArrayList<String> shapes = new ArrayList();

// last time the experiment was updated.
// used to calculate elapsed time
long lastUpdateTime;

boolean isCircle;
boolean isRed;
float xpos;
float ypos;
float size;
float triangleHeight;
float triangleLength;

void setup() {
  fullScreen();
  pixelDensity(displayDensity());
  frameRate(60);
}


void draw() {
  background(255); // clear to white
  fill(0); // fill with black
  noStroke();

  textAlign(LEFT, TOP);
  textSize(24);
  text("User Study", 10, 10);
  textSize(16);

  if (experimentActive) {
    text("only Press Space when a Triangle appears!", 10, 40);
    updateExperiment();
    if (stimulusIsVisible) {
      if (isRed) {
        fill(255, 0, 0);
      } else {
        fill(255, 255, 0);
      }
      if (isCircle) {
        circle(xpos, ypos, size); // size = 2*pi*radius
      } else {
        triangle(xpos, ypos, xpos + triangleLength, ypos, xpos + (0.5 * triangleLength), ypos - triangleHeight);
      }

      if (System.currentTimeMillis() - stimulusTimestamp > 3000) {
        if (!isCircle) {
          errors++;
          if (isRed){
            errorsRed++;
          }else{
            errorsYellow++;
          }
        } else {
          noAction++;
        }
        print(noAction);
        if (times.size() + errors + noAction == 30) {
          stopExperiment();
        }
        startTestTrial(); //Start next iteration if more than 3 sec passed without user input
      }
    }
    // show previous time if available
    if (!times.isEmpty()) {
      long lastTime = times.get(times.size() - 1);
      fill(0);
      text(("Trial:" + (times.size() + errors + noAction) + "/30"), 10, 90);
      text(lastTime + " ms", 10, 110);
    }
  } else {
    text("Press space to start!", 10, 40);
    // we have some experiment results#
    if (!times.isEmpty()) {
      writeResultsToFile();

      text("Count: " + (times.size() + errors + noAction), 10, 60);
      text("Mean: " + Math.round(getMean(times)) + " ms", 10, 80);
      text("Mean red: " + Math.round(getMean(timesRed)) + " ms", 10, 100);
      text("Mean yellow: " + Math.round(getMean(timesYellow)) + " ms", 10, 120);
      text("SD: " + Math.round(getStandardDeviation(times)) + " ms", 10, 140);
      text("SD red: " + Math.round(getStandardDeviation(timesRed)) + " ms", 10, 160);
      text("SD yellow: " + Math.round(getStandardDeviation(timesYellow)) + " ms", 10, 180);
      text("Error-Rate: " + errors + "/30", 10, 200);
      text("Error-Rate red: " + errorsRed + "/30", 10, 220);
      text("Error-Rate yellow: " + errorsYellow + "/30", 10, 240);
      text("Median: " + getMedian(times) + "ms", 10, 260);
      noLoop();
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    // the user pressed the space key
    if (!experimentActive) {
      // start the experiment if it wasn't active
      startExperiment();
      return;
    }

    if (stimulusIsVisible && !isCircle) {
      // record reaction time
      recordData();

      if (times.size() + errors + noAction == 30) {
        stopExperiment();
      }
      // start next trial
      startTestTrial();
    } else {
      errors++;
      if (isRed){
            errorsRed++;
          }else{
            errorsYellow++;
          }
      if (times.size() + errors + noAction == 30) {
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



long getMedian(ArrayList<Long> times) {
  Collections.sort(times);
  return times.get((int) Math.floor(times.size() / 2));
}

void startTestTrial() {
  stimulusIsVisible = false;
  float timeToWaitInSeconds = random(2, 6);
  testStimulusTimeout = (long) (timeToWaitInSeconds * 1000);
  Random random = new Random();
  isCircle = random.nextBoolean();
  isRed = random.nextBoolean();
  xpos = random(150, displayWidth - 150);
  ypos = random(150, displayHeight - 150);
  size = random(100, 300);
  triangleLength = size;
  triangleHeight = size;
}

void showStimulus() {
  stimulusIsVisible = true;
  stimulusTimestamp = System.currentTimeMillis();
}


void recordData() {
  long deltaTime = System.currentTimeMillis() - stimulusTimestamp;
  times.add(deltaTime);
  if (isRed) {
    colors.add("Red");
    timesRed.add(deltaTime);
  } else {
    colors.add("Yellow");
    timesYellow.add(deltaTime);
  }
  if (isCircle) {
    shapes.add("Circle");
  } else {
    shapes.add("Triangle");
  }
}

void startExperiment() {
  times.clear();
  timesRed.clear();
  timesYellow.clear();
  colors.clear();
  shapes.clear();
  experimentActive = true;
  outputFile = createWriter("results.txt");
  errors = 0;
  errorsRed = 0;
  errorsYellow = 0;
  noAction = 0;
  lastUpdateTime = System.currentTimeMillis();
  startTestTrial();
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

void writeResultsToFile() {
  int counter = 1;
  Iterator<Long> timesIterator = times.iterator();
  Iterator<String> colorsIterator = colors.iterator();
  Iterator<String> shapesIterator = shapes.iterator();
  outputFile.println("iteration  " + "time  " + "colors  " + "shapes");
  while (timesIterator.hasNext()) {
    outputFile.println(counter + "  " + timesIterator.next() + "  " + colorsIterator.next() + "  " + shapesIterator.next());
    counter++;
  }
  outputFile.flush();
  outputFile.println("Errors:" + errors);
  outputFile.println("ErrorsRed:" + errorsRed);
  outputFile.println("ErrorsYellow:" + errorsYellow);
  outputFile.println("Count: " + (times.size() + errors + noAction));
  outputFile.println("Mean: " + Math.round(getMean(times)));
  outputFile.println("Mean red: " + Math.round(getMean(timesRed)));
  outputFile.println("Mean yellow: " + Math.round(getMean(timesYellow)));
  outputFile.println("SD: " + Math.round(getStandardDeviation(times)));
  outputFile.println("SD red: " + Math.round(getStandardDeviation(timesRed)));
  outputFile.println("SD yellow: " + Math.round(getStandardDeviation(timesYellow)));
  outputFile.println("Median: " + getMedian(times));
  outputFile.close();
}
