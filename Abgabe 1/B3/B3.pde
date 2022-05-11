import java.util.Iterator;
import java.util.Collections;
import java.util.Random;


int errors;
int errorsChina;
int errorsMexico;
int errorsItaly;
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
ArrayList<Long> timesItaly = new ArrayList();
ArrayList<Long> timesMexico = new ArrayList();
ArrayList<Long> timesChina= new ArrayList();

ArrayList<String> nations = new ArrayList();

// last time the experiment was updated.
// used to calculate elapsed time
long lastUpdateTime;

boolean isChina;
boolean isItaly;
boolean isMexico;

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
    text("Press 1 if the food is from China, 2 if from Mexico, 3 if from Italy", 10, 40);
    updateExperiment();
    if (stimulusIsVisible) {
    }
    // show previous time if available
    if (!times.isEmpty()) {
      long lastTime = times.get(times.size() - 1);
      fill(0);
      text(("Trial:" + (times.size() + errors) + "/30"), 10, 90);
      text(lastTime + " ms", 10, 110);
    }
  } else {
    text("Press space to start!", 10, 40);
    // we have some experiment results#
    if (!times.isEmpty()) {
      writeResultsToFile();

      text("Count: " + (times.size() + errors), 10, 60);
      text("Mean: " + Math.round(getMean(times)) + " ms", 10, 80);
      text("Mean China: " + Math.round(getMean(timesChina)) + " ms", 10, 100);
      text("Mean Mexico: " + Math.round(getMean(timesMexico)) + " ms", 10, 120);
      text("Mean Italy: " + Math.round(getMean(timesItaly)) + " ms", 10, 120);
      text("SD: " + Math.round(getStandardDeviation(times)) + " ms", 10, 140);
      text("SD China: " + Math.round(getStandardDeviation(timesChina)) + " ms", 10, 160);
      text("SD Mexico: " + Math.round(getStandardDeviation(timesMexico)) + " ms", 10, 180);
      text("SD Italy: " + Math.round(getStandardDeviation(timesItaly)) + " ms", 10, 180);
      text("Error-Rate: " + errors + "/30", 10, 200);
      text("Error-Rate China: " + errorsChina + "/30", 10, 220);
      text("Error-Rate Mexico: " + errorsMexico + "/30", 10, 240);
      text("Error-Rate Italy: " + errorsItaly + "/30", 10, 240);
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

    if (stimulusIsVisible) {
      // record reaction time
      recordData();

      if (times.size() + errors >= 30) {
        stopExperiment();
      }
      // start next trial
      startTestTrial();
    } else {
      errors++;
      if (times.size() + errors >= 30) {
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
}

void showStimulus() {
  stimulusIsVisible = true;
  stimulusTimestamp = System.currentTimeMillis();
}


void recordData() {
  long deltaTime = System.currentTimeMillis() - stimulusTimestamp;
  times.add(deltaTime);
  if (isChina) {
    timesChina.add(deltaTime);
  } else if (isMexico) {
    timesMexico.add(deltaTime);
  } else {
    timesItaly.add(deltaTime); 
  }
}

void startExperiment() {
  times.clear();
  timesChina.clear();
  timesMexico.clear();
  timesItaly.clear();
  experimentActive = true;
  outputFile = createWriter("results.txt");
  errors = 0;
  errorsChina = 0;
  errorsMexico = 0;
  errorsItaly = 0;
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
  outputFile.println("iteration  " + "time  " + "Nation  ");
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
