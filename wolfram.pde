import processing.video.*;
import processing.sound.*;

int _width = 50;
int _height = 30;
int cellWidth = 10;
boolean wrapY = true;
boolean wrapX = true;
int increment = 10;
int ruleName = 60;

int[][] grid;
int[] rule = new int[8];
int[][] trios = new int[][]{
  new int[]{1, 1, 1}, 
  new int[]{1, 1, 0}, 
  new int[]{1, 0, 1}, 
  new int[]{1, 0, 0}, 
  new int[]{0, 1, 1}, 
  new int[]{0, 1, 0}, 
  new int[]{0, 0, 1}, 
  new int[]{0, 0, 0}
};
Pulse pulse;

boolean recording = false;
int recordingTime = 0;

//https://stackoverflow.com/questions/18348745/decimal-to-binary-8-bits-only-using-append
String get8BitBinaryStringFromInt(int num) {
  StringBuilder buf1=new StringBuilder();
  StringBuilder buf2=new StringBuilder();
  while (num != 0) {
    int digit = num % 2;
    buf1.append(digit); // apend 0101 order
    num = num/2;
  }
  String binary=buf1.reverse().toString();// reverse to get binary 1010
  int length=binary.length();
  if (length<8) {
    while (8-length>0) {
      buf2.append("0");// add zero until length =8
      length++;
    }
  }
  String bin=buf2.toString() + binary;// binary string with leading 0's
  return bin;
}

void setup() {
  String binaryString = get8BitBinaryStringFromInt(ruleName);

  int size = binaryString.length();
  for (int i=0; i < 8; i++) {
    rule[i] = Integer.parseInt(String.valueOf(binaryString.charAt(i)));
  }

  size(1500, 900);

  _width = _width * 3;
  _height = _height * 3;

  grid = new int[_width][_height];

  reset();

  //  // Create and start the sine oscillator.
  //pulse = new Pulse(this);

  ////Start the Pulse Oscillator. 
  //pulse.play();

  grid[_width / 2][0] = 1;
}

void mouseDragged() {
  if ((mouseX >= 0 && mouseX <= width && mouseY >= 0 && mouseY <= height))
  {
    int x = mouseX / cellWidth;
    int y = mouseY / cellWidth;
    grid[x][y] += increment;
  }
}

void keyPressed() {
  if (key == 'r')
    reset();
  else if (key == ENTER)
    recording = !recording;
}

void reset() {
  for (int x = 0; x < _width; x++) {
    for (int y = 0; y < _height; y++) {
      grid[x][y] = 0;
    }
  }
  
  background(255);
}

void record() {
  saveFrame("output/frame_" + String.format("%04d", recordingTime) + ".png");
  noFill();
  ellipse(width - 10, height - 10, 20, 20);
  recordingTime++;
  if (recordingTime >= 240)
  {
    recording = false;
    recordingTime = 0;
  }
}

void draw() {
  //background(255);

  processGrid();

  drawGrid();

  if (recording)
    record();
}

void processGrid() {  
  if (wrapY && wrapX) {
    for (int x = _width - 1; x >= 0; x--) {
      for (int y = _height - 1; y >= 0; y--) {
        updateValues(x, y);
      }
    }
  } else if (wrapY && !wrapX) {
    for (int x = _width - 1; x > 0; x--) {
      for (int y = _height - 1; y >= 0; y--) {
        updateValues(x, y);
      }
    }
  } else if (wrapX && !wrapY) {
    for (int x = _width - 1; x >= 0; x--) {
      for (int y = _height - 1; y > 0; y--) {
        updateValues(x, y);
      }
    }
  } else {
        for (int x = _width - 1; x > 0; x--) {
      for (int y = _height - 1; y > 0; y--) {
        updateValues(x, y);
      }
    }
  }
}

void updateValues(int x, int y) {
  int[] input = new int[3];

  input[0] = getNeighbour(x - 1, y - 1); //left
  input[1] = getNeighbour(x, y - 1); //center
  input[2] = getNeighbour(x + 1, y - 1); //right

  boolean value = getValue(input);

  if (value)
    grid[x][y] += increment;

  if (grid[x][y] > 255)
    grid[x][y] = 0;
}

int getNeighbour(int x, int y) {
  if (x < 0)
    x = _width - 1;

  if (x > _width - 1)
    x = 0;

  if (y < 0)
    y = _height - 1;

  if (y > _height - 1)
    y = 0;

  return grid[x][y];
}

boolean getValue(int[] input) {
  //return left  != (central || right);

  //int input[] = new int[3];
  //input[0] = left ? 1 : 0;
  //input[1] = central ? 1 : 0;
  //input[2] = right ? 1 : 0;

  int ruleIndex = getTrioIndex(input);

  return rule[ruleIndex] != 0;
}

int getTrioIndex(int[] input) {
  int[] flattenedInput = new int[3];
  for (int i = 0; i < input.length; i++) {
    flattenedInput[i] = input[i] == 0 ? 0 : 1;
  }

  for (int i = 0; i < trios.length; i++) {
    if (elementEqual(trios[i], flattenedInput)) {
      return i;
    }
  }
  print(String.valueOf(input[0]) + String.valueOf(input[1]) + String.valueOf(input[2]));
  return -1;
}

boolean elementEqual(int[] array1, int[] array2) {
  for (int i = 0; i < array1.length; i++) {
    if (array1[i] != array2[i]) {
      return false;
    }
  }

  return true;
}


void drawGrid() {

  for (int x = 0; x < _width; x++) {
    for (int y = 0; y < _height; y++) {
      fill(0, grid[x][y]);
      //if (grid[x][y] != 0) {
      //  fill(0);
      //} else {
      //  fill(255);
      //}
      rect(x * cellWidth, y * cellWidth, cellWidth, cellWidth);
    }
  }

  //for (int x = 0; x < _width; x++) {
  //  pulse.width(grid[x][_height - 1]);
  //}

  //background(255);
}
