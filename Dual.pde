// Title: Duel
// Author: FAL ( https://www.fal-works.com/ )
// Made with Processing 3.3.6
/* Change log:
    Ver. 0.1 (30. Sep. 2017)  First version.
    Ver. 0.2 ( 1. Oct. 2017)  Bug fix (unintended change of strokeWeight), minor update (enabled to hide instruction window).
    Ver. 0.3 (10. Feb. 2018)  Minor fix (lack of semicolon).
    Ver. 0.4 (12. Feb. 2018)  Enabled scaling.
*/

/* @pjs font="Lato-Regular.ttf"; */
/*
  The font "Lato" is designed by Łukasz Dziedzic (http://www.latofonts.com/).
  This font is licensed under the SIL Open Font License 1.1 (http://scripts.sil.org/OFL).
*/


// CAUTION: spaghetti code!!!

private static final float FPS = 60.0;
private static final int INTERNAL_CANVAS_SIDE_LENGTH = 640;
private static final boolean USE_WEB_FONT = false;

KeyInput currentKeyInput;
GameSystem system;
PFont smallFont, largeFont;
boolean paused;

int canvasSideLength = INTERNAL_CANVAS_SIDE_LENGTH;
float scaleFactor;

/* For processing.js
const containerRect = window.document.getElementById("Duel").getBoundingClientRect();
canvasSideLength = min(containerRect.width, containerRect.height);
*/

/* For OpenProcessing */
//canvasSideLength = min(window.innerWidth, window.innerHeight);

/* For Processing Java mode
void settings() {
  size(canvasSideLength, canvasSideLength);
}
*/

void setup() {
  /* For processing.js */
  size(640, 640);

  scaleFactor = (float)canvasSideLength / (float)INTERNAL_CANVAS_SIDE_LENGTH;

  frameRate(FPS);

  // Prepare font
  final String fontFilePath = "Lato-Regular.ttf";
  final String fontName = "Lato";
  smallFont = createFont(USE_WEB_FONT ? fontName : fontFilePath, 20.0, true);
  largeFont = createFont(USE_WEB_FONT ? fontName : fontFilePath, 96.0, true);
  textFont(largeFont, 96.0);
  textAlign(CENTER, CENTER);

  rectMode(CENTER);
  ellipseMode(CENTER);

  currentKeyInput = new KeyInput();
  
  newGame(true, true);  // demo play (computer vs computer), shows instruction window
}

void draw() {
  background(255.0);
  scale(scaleFactor);
  system.run();
}

void newGame(boolean demo, boolean instruction) {
  system = new GameSystem(demo, instruction);
}

void mousePressed() {
  system.showsInstructionWindow = !system.showsInstructionWindow;
}

void keyPressed() {
  if (key != CODED) {
    if (key == 'z' || key == 'Z') {
      currentKeyInput.isZPressed = true;
      return;
    }
    if (key == 'x' || key == 'X') {
      currentKeyInput.isXPressed = true;
      return;
    }
    if (key == 'p') {
      if (paused) loop();
      else noLoop();
      paused = !paused;
    }
    return;
  }
  switch(keyCode) {
  case UP:
    currentKeyInput.isUpPressed = true;
    return;
  case DOWN:
    currentKeyInput.isDownPressed = true;
    return;
  case LEFT:
    currentKeyInput.isLeftPressed = true;
    return;
  case RIGHT:
    currentKeyInput.isRightPressed = true;
    return;
  }
}

void keyReleased() {
  if (key != CODED) {
    if (key == 'z' || key == 'Z') {
      currentKeyInput.isZPressed = false;
      return;
    }
    if (key == 'x' || key == 'X') {
      currentKeyInput.isXPressed = false;
      return;
    }
    return;
  }
  switch(keyCode) {
  case UP:
    currentKeyInput.isUpPressed = false;
    return;
  case DOWN:
    currentKeyInput.isDownPressed = false;
    return;
  case LEFT:
    currentKeyInput.isLeftPressed = false;
    return;
  case RIGHT:
    currentKeyInput.isRightPressed = false;
    return;
  }
}
