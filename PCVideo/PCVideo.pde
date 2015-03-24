/*
PCvideo
https://github.com/monur/ArduCamMonitor
modified to match my camera

*/
import processing.video.*;
import processing.serial.*;

final int lcdWidth = 84;
final int lcdHeight = 48;

final int videoWidth = 176; //Must match camera pissibilities
final int videoHeight = 144; //see available cameras
final int fps=5;
 //176/84=2.0952380952380952380952380952381
 //144/48=3
final int stepx=2;
final int stepy=3;
//must be recalculated 

final int Threshold=80;

color black = color(0);
color white = color(255);

Capture video;
Serial myPort;
int frameStart[] = {0x80, 0x01, 0x80, 0x01};
int[] lcdPixels = new int[lcdWidth * lcdHeight];

public void setup() {
  size(lcdWidth, lcdHeight);
  video = new Capture(this, videoWidth, videoHeight, fps);
  //println(Serial.list());
  myPort = new Serial(this, "COM12", 115200);
  loadPixels();
  //noStroke();
  //noSmooth();
    // Start capturing the images from the camera
  video.start(); 
}

public void captureEvent(Capture c) {
  c.read();
}

void draw() {
  background(0);

  int indexs = 0;
  int indexv = 0;
  for (int y = 0; y < video.height; y=y+stepy) {
    float luminance = 0.0;
    //int luminance;
    for (int x = 0; x < video.width-8; x=x+stepx) {
      indexv=y*videoWidth+x;
      indexs=y/stepy*lcdWidth+x/stepx;
      luminance=brightness(video.pixels[indexv]);
      if(luminance > Threshold){
        lcdPixels[indexs] = 0xffffffff;
        pixels[indexs]=black;
        }
      else{
        lcdPixels[indexs] = 0x00000000;
        pixels[indexs]=white;
        }
    }
  }
  updatePixels();
  
  //send to Serial port
  
  for(int i = 0; i< frameStart.length; i++)
      myPort.write((byte)frameStart[i]);

  for(int y = 0; y < lcdHeight / 8; y++){
     for(int x = 0; x < lcdWidth; x++){
        int by = 0x00;
        for(int a = 0; a < 8; a++){
           by = by >> 1;
           if(lcdPixels[(y*8+a)*lcdWidth+x] == 0x00000000){
              by = by | 0x80;
           } 
        }
        myPort.write((byte)by);
     } 
  }
  delay(50);
}
