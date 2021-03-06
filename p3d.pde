import java.util.LinkedList;
import processing.serial.*;

/**
 * UINOCART DISPLAY CODE
 * Annemaayke Ammerlaan and Matthew Weidman
 * Uses Processing API to show a car moving around. 
 * Communicates with Arduino using Serial port COM3. 
 */
 
String portName = "COM3";

void xRectangle(float x, float y, float z, float ylen, float zlen) {
  beginShape();
  vertex(x, y, z);
  vertex(x, y+ylen, z);
  vertex(x, y+ylen, z+zlen);
  vertex(x, y, z+zlen);
  vertex(x, y, z);
  endShape();
}

void xRectangleImage(float x, float y, float z, float ylen, float zlen, PImage img) {
  beginShape();
  texture(img);
  vertex(x, y, z, 0, img.height);
  vertex(x, y+ylen, z, img.width, img.height);
  vertex(x, y+ylen, z+zlen, img.width, 0);
  vertex(x, y, z+zlen, 0, 0);
  vertex(x, y, z, 0, img.height);
  endShape();
}

void yRectangle(float x, float y, float z, float xlen, float zlen) {
  beginShape();
  vertex(x, y, z);
  vertex(x+xlen, y, z);
  vertex(x+xlen, y, z+zlen);
  vertex(x, y, z+zlen);
  endShape();
}

void zRectangle(float x, float y, float z, float xlen, float ylen) {
  beginShape();
  vertex(x, y, z);
  vertex(x+xlen, y, z);
  vertex(x+xlen, y+ylen, z);
  vertex(x, y+ylen, z);
  endShape();
}

void rectangularPrism(float x, float y, float z, float xlen, float ylen, float zlen) {
  xRectangle(x, y, z, ylen, zlen);
  xRectangle(x+xlen, y, z, ylen, zlen);
  yRectangle(x, y, z, xlen, zlen);
  yRectangle(x, y+ylen, z, xlen, zlen);
  zRectangle(x, y, z, xlen, ylen);
  zRectangle(x, y, z+zlen, xlen, ylen);
}

void yCircle(float cx, float y, float cz, float r, int subdivs) {
  float angle = 360 / subdivs;
  beginShape();
  for (int i=0; i<=subdivs; i++) {
    float dx = cos(radians(i*angle)) * r;
    float dz = sin(radians(i*angle)) * r;
    vertex(cx+dx, y, cz+dz);
  }
  endShape();
}

void yCylinder(float cx, float ymin, float cz, float r, float h, int subdivs) {
  yCircle(cx, ymin, cz, r, subdivs);
  yCircle(cx, ymin+h, cz, r, subdivs);
  
  noStroke();
  beginShape(TRIANGLE_STRIP);
  float angle = 360 / subdivs;
  for (int i=0; i<=subdivs; i++) {
    float dx = cos(radians(i*angle)) * r;
    float dz = sin(radians(i*angle)) * r;
    vertex(cx+dx, ymin, cz+dz);
    vertex(cx+dx, ymin+h, cz+dz);
  }
  endShape();
}

class Car {
  
  float stroke;
  float tireColor;
  int bodyColor;
  
  float pWidth;
  float pLength;
  float pHeight;
  float topWidth;
  float pBottom;
  
  float rotZ;
  
  float bodyHeight;
  float bodyLength;
  float bodyWidth;
  float bodyBottom;
  
  float tireX;
  float tireZ;
  float tireRadius;
  float tireGirth;
  
  float moveX;
  float moveZ;
  
  float plateWidth;
  float plateHeight;
  PImage plateImg;
  
  Car(float bottomZ) {
    // colors
    stroke = 0;
    bodyColor = 0x0000ff;
    tireColor = 100;
    
    // rotation
    rotZ = PI/2;
    
    // tires
    tireX = 75;
    tireRadius = 30;
    tireGirth = 30;
    tireZ = bottomZ + tireRadius;
    
    // body
    bodyBottom = tireZ + 20;
    bodyHeight = 50;
    bodyLength = 150;
    bodyWidth = 75;
    
    // windows
    pWidth = bodyWidth;
    pLength = bodyLength - 50;
    pHeight = 50;
    topWidth = 50;
    pBottom = bodyBottom + bodyHeight;
    
    // displacement
    moveX = 0;
    moveZ = 0;
    
    // license plate
    plateHeight = bodyHeight * 0.7;
    plateWidth = plateHeight * 1.5;
    plateImg = loadImage("licenseplate.png");
  }
  
  void windows() {
    fill(127, 127);
    stroke(stroke);

    beginShape();
    vertex(-pLength, -pWidth, pBottom);
    vertex(pLength, -pWidth, pBottom);
    vertex(topWidth, -topWidth, pBottom + pHeight);
    vertex(-topWidth, -topWidth, pBottom + pHeight);
    endShape();
    
    beginShape();
    vertex(pLength, -pWidth, pBottom);
    vertex(pLength,  pWidth, pBottom);
    vertex(topWidth, topWidth, pBottom + pHeight);
    vertex(topWidth, -topWidth, pBottom + pHeight);
    endShape();
    
    beginShape();
    vertex(pLength, pWidth, pBottom);
    vertex(-pLength, pWidth, pBottom);
    vertex(-topWidth, topWidth, pBottom + pHeight);
    vertex(topWidth, topWidth, pBottom + pHeight);
    endShape();
    
    beginShape();
    vertex(-pLength,  pWidth, pBottom);
    vertex(-pLength, -pWidth, pBottom);
    vertex(-topWidth, -topWidth, pBottom + pHeight);
    vertex(-topWidth, topWidth, pBottom + pHeight);
    endShape();
    
    zRectangle(-topWidth, -topWidth, pBottom + pHeight, topWidth*2, topWidth*2);
  }
  
  void body() {
    fill(10, 40, 125);
    rectangularPrism(-bodyLength, -bodyWidth, bodyBottom, 
      bodyLength*2, bodyWidth*2, bodyHeight);
  }
  
  void tires() {
    fill(tireColor);
    stroke(stroke);
    yCylinder(tireX, -bodyWidth+1, tireZ, tireRadius, tireGirth, 20);
    stroke(stroke);
    yCylinder(tireX, bodyWidth-1-tireGirth, tireZ, tireRadius, tireGirth, 20);
    stroke(stroke);
    yCylinder(-tireX, -bodyWidth+1, tireZ, tireRadius, tireGirth, 20);
    stroke(stroke);
    yCylinder(-tireX, bodyWidth-1-tireGirth, tireZ, tireRadius, tireGirth, 20);
  }
  
  void licensePlate() {
    beginShape();
    fill(0);
    xRectangleImage(-bodyLength-1, -plateWidth/2, 
      bodyBottom + bodyHeight/2 - plateHeight/2, 
      plateWidth, plateHeight, plateImg);
    endShape();
  }
  
  void display() {
    pushMatrix();
    translate(moveX, 0, moveZ);
    rotateX(PI/2);
    rotateZ(rotZ);
    windows();
    body();
    licensePlate();
    tires();
    popMatrix();
  }
  
  /** Sets car position to be a little in front of camera. */
  void setToCamera(VirtualCamera cam) {
    moveX = cam.centerX - 320;
    moveZ = cam.centerZ;
    rotZ = cam.getCarDir();
  }
  
}

class Ground {
  
  float level;
  float gwidth = 6000;
  PImage img;
  
  Ground(float lev) {
    level = -lev;
    img = loadImage("track1.png");
  }
  
  void display() {
    float x = -gwidth/2, y = level, z = -gwidth/2, xlen = gwidth, zlen = gwidth;
    beginShape();
    texture(img);
    stroke(0);
    //fill(0x66, 0xCD, 0x00);
    vertex(x, y, z, 0, 0);
    vertex(x+xlen, y, z, 0, img.height);
    vertex(x+xlen, y, z+zlen, img.width, img.height);
    vertex(x, y, z+zlen, img.width, 0);
    endShape();
  }
  
}

class VirtualCamera {
  
  // x, y, z coordinates of center of car, where camera is pointing
  float centerX, centerY, centerZ;
  
  // Last directions that eye was pointing. A queue is used instead
  // of a single value so that the camera lags behind the car, so
  // you can see all of the car.
  LinkedList<Float> eyeDirs;
  int numEyeDirs = 7;
  int numRestingFrames = 0;
  
  // speed of moving forward or backward
  static final float MOVE_SPEED = 50;
  
  // speed of turning left or right
  static final float TURN_SPEED = PI/40;
  
  // distance from camera to car
  float EYE_DIST = 500;
  
  public VirtualCamera(float x, float y, float z) {
    centerX = x;
    centerY = y;
    centerZ = z;
    
    eyeDirs = new LinkedList();
    for (int i=0; i<numEyeDirs; i++) {
      eyeDirs.add(PI/2);
    }
  }
  
  public void setCamera() {
    float eyeDir = eyeDirs.getFirst();
    float rx = cos(eyeDir);
    float rz = sin(eyeDir);
    float cx = centerX + EYE_DIST * rx;
    float cz = centerZ + EYE_DIST * rz;
    float eyeX = centerX - EYE_DIST * rx;
    float eyeZ = centerZ - EYE_DIST * rz;
    camera(eyeX, centerY, eyeZ - 100, cx, centerY, cz, 0, 1, 0);
  }
  
  public void forward() {
    float eyeDir = getCarDir();
    centerX += MOVE_SPEED * cos(eyeDir);
    centerZ += MOVE_SPEED * sin(eyeDir);
  }
  
  public void backward() {
    float eyeDir = getCarDir();
    centerX -= MOVE_SPEED * cos(eyeDir);
    centerZ -= MOVE_SPEED * sin(eyeDir);
  }
  
  public void turnLeft() {
    float prevEyeDir = eyeDirs.getLast();
    eyeDirs.removeFirst();
    eyeDirs.addLast(prevEyeDir - TURN_SPEED);
    numRestingFrames = 0;
  }
  
  public void turnRight() {
    float prevEyeDir = eyeDirs.getLast();
    eyeDirs.removeFirst();
    eyeDirs.addLast(prevEyeDir + TURN_SPEED);
    numRestingFrames = 0;
  }
  
  public float getCarDir() {
    return eyeDirs.getLast();
  }
  
  /* */
  public void changeDir(float rads) {
    float prevEyeDir = eyeDirs.getLast();
    eyeDirs.removeFirst();
    eyeDirs.addLast(prevEyeDir + rads);
    numRestingFrames = 0;
  }
  
  /** Keep the queue flipping after car stops turning.  */
  public void adjustWhileResting() {
    if (numRestingFrames < numEyeDirs) {
      float prevEyeDir = eyeDirs.getLast();
      eyeDirs.removeFirst();
      eyeDirs.addLast(prevEyeDir);
      numRestingFrames += 1;
    }
  }
  
}

class Block {
  float w, h, d;
  float x, y, z;
  
  Block (float x, float z) {
    this.x = x;
    this.z = z;
    w = 100;
    h = 100;
    d = 100;
    y = 85;
  }
  
  void display (){
   pushMatrix();
   translate(x, y, z);
   fill(0, 240, 100);
   stroke(0, 0, 0);
   box(w, h, d);
   popMatrix();
  }
}

class Bullet {
  
  float rBig; // radius of biggest ball
  float rMid; // radius of medium balls
  float rSmall; // radius of smallest balls
  
  float centerHeight; // height of center biggest ball
  float separation; // distance between balls
  float distMid; // distance from center to center of medium balls
  float distSmall; // distance from center to center of small balls
  
  float moveX;
  float moveZ;
  float moveDir;
  static final float SPEED = 150;
  
  /** size: radius of center ball */
  Bullet(float size, float x, float y, float z, float dir) {
    rBig = size;
    rMid = size*2/3;
    rSmall = size/3;
    centerHeight = y;
    moveX = x;
    moveZ = z;
    moveDir = dir;
    
    separation = size / 4;
    distMid = rBig + rMid + separation;
    distSmall = rBig + rMid*2 + separation*2 + rSmall;
    
  }
  
  void makeSphere(float cx, float cy, float cz, float r) {
    pushMatrix();
    translate(cx, cy, cz);
    sphere(r);
    popMatrix();
  }
  
  
  void display() {
    
    fill(255, 0, 0);
    noStroke();
    makeSphere(moveX, centerHeight, moveZ, rBig);
    
    fill(255, 165, 0);
    makeSphere(moveX - distMid * cos(moveDir), centerHeight, 
      moveZ - distMid * sin(moveDir), rMid);
    
    fill(255, 255, 0);
    makeSphere(moveX - distSmall * cos(moveDir), centerHeight,
      moveZ - distSmall * sin(moveDir), rSmall);
  }  
  
  void move() {
    moveX += cos(moveDir)*SPEED;
    moveZ += sin(moveDir)*SPEED; 
  }
}

class ControllerData {
  
  int accy;
  boolean leftButton, midButton, rightButton;
  
  ControllerData(String s) {
    String[] parts = split(s, ' ');
    accy = int(parts[0]);
    leftButton = parts[1].equals("1");
    midButton = parts[2].equals("1");
    rightButton = parts[3].equals("1");
  }
  
  int getAccy() {
    return accy;
  }
  
  boolean leftButtonOn() {
    return leftButton;
  }
  
  boolean midButtonOn() {
    return midButton;
  }
  
  boolean rightButtonOn() {
    return rightButton;
  }
  
}

final float MAX_ACC = pow(2, 16);

Car car;
Ground ground;
VirtualCamera vc;
Bullet bullet;
Serial port;

int turnThreshold = 1000;

void setup() {
  frameRate(40);
  size(640,360,P3D);
  float groundLevel = -150;
  car = new Car(groundLevel);
  ground = new Ground(groundLevel);
  vc = new VirtualCamera(width/2, height/2, 0);
  vc.centerX = 2800;
  car.setToCamera(vc);
  vc.setCamera();
  port = new Serial(this, portName, 9600);
}

void draw() {
  background(0x7ec0ee);
  translate(width/2, height/2, -100);
  ground.display();
  car.display();
  if (bullet != null) { 
    bullet.display();
    bullet.move();
  }
  if (0 < port.available()) {
    String readVal = port.readStringUntil('\n');
    if (readVal != null) {
      try {
        ControllerData cd = new ControllerData(readVal);
        
        // turn
        float turnRads = asin(- cd.getAccy() / MAX_ACC);
        vc.changeDir(turnRads);
        
        // move forward/backward
        if (cd.leftButtonOn()) {
          vc.forward();
        }
        if (cd.midButtonOn()) {
          vc.backward();
        }
        if (cd.rightButtonOn()) {
          bullet = new Bullet(50, car.moveX, -50, car.moveZ, car.rotZ);   
        }
        
        // set camera and car
        car.setToCamera(vc);
        vc.setCamera();
      } catch (IndexOutOfBoundsException ioobe) {}
    }
  }
}