import processing.serial.*;
import processing.video.*;
import com.hamoid.*;
import java.awt.Rectangle;
import gab.opencv.*;

VideoExport videoExport;
Capture cam;
Rectangle[] faces;
OpenCV opencv;
PImage frame;
Serial myPort;

//change these values
//--------------------
int usb_port_number = 1; //change this to match the port for "/dev/tty.usbmodem14131"
int camera_number = 0; //change to match the webcam
//~~~~~~~~~~~~~~~~~~~-

int w = 1280;
int h = 720;

int frame_rate = 60;

boolean playback = false;
boolean record = false;
float playback_direction = -1.0;

int face_delay = 1000 * 10;

int face_timer = millis();
boolean face_detected = false;
int tries_count = 0;

boolean flip = false;
int hourglass_delay = 1000 * 60;

Movie myMovie;
Movie overlay_mov;
boolean init_playback = true;

int fade_in_time = 60*4; //framerate * 4 seconds
int fade_in_timer = 0;

void setup() {
  size(1280, 720);
  
  videoExport = new VideoExport(this, "data/hello.avi");
  videoExport.startMovie();
  
  String[] cameras = Capture.list();
  print(cameras);
  
  cam = new Capture(this, cameras[camera_number]);
  opencv = new OpenCV(this, 1280, 720);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); 
  cam.start();
  
  println("Choose usb port from:");
  printArray(Serial.list()); 
  String portName = Serial.list()[usb_port_number]; 
  myPort = new Serial(this, portName, 9600); 
}

void draw() {
  if (flip) {
    flipVideo();
  }
  
  if (playback) {
    scale(1);
    
    if (init_playback == true) { // Setting the speed should be done only once
      init_playback = false;
      background(0);
      myMovie.jump(myMovie.duration());
      println(myMovie.duration());
      myMovie.speed(playback_direction);
      myMovie.play(); //restart movie play in backward direction
    } else if ( myMovie.time() <= 0.1 || overlay_mov.time() > overlay_mov.duration() - 0.1 ) { 
      //once movie playback finishes, start recording
      playback = false;
      myMovie.stop();
      overlay_mov.stop();
      videoExport.startMovie();
    }
    
    PImage m1 = myMovie.get( 0,0,myMovie.width,myMovie.height);
    if (fade_in_timer < fade_in_time) {   
      fade_in_timer++;
      tint(255, 255*fade_in_timer/fade_in_time);
    } 
    PImage m2 = overlay_mov.get( 0,0,overlay_mov.width,overlay_mov.height);  
    m1.blend(m2, 0, 0, width, height, 0, 0, width, height, LIGHTEST);
    image(m1, 0, 0, width, height);
  }
  
  else {
    scale(-1, 1);
    image(cam, -cam.width, 0);
    record = true;
    if(cam.width <= 0 || cam.height <= 0) { //checks if cam is loaded
      record = false;    
      //past 10 seconds of video and haven't found a face in 10 seconds
    } else if ((videoExport.getCurrentFrame() > 6 * frame_rate) && (millis() - face_timer > face_delay)) {
      if (tries_count < 3) {  //still have tries left to find a face
    
        print("looking for face");
        opencv.loadImage(cam);
        faces = opencv.detect(1.1, 3, 0, 150, 500);
        if (faces.length > 0) {
          println("face detected");
          tries_count = 0;
          face_timer = millis();
        } else {
          tries_count++;
        }  
      } else {
        record = false;
        tries_count = 0;
      }
    }
    
    if(record) {
      videoExport.saveFrame();
    } else {
      //restart recording
      println("recorded video with " + videoExport.getCurrentFrame() + " frames");
      videoExport.endMovie();
      videoExport.startMovie();
    }    
  }    
}

void captureEvent(Capture c) {
  c.read();
}

void movieEvent(Movie m) {
  m.read();  
}

void serialEvent(Serial p) { 
  char inString = p.readChar();
  if (inString == '1') {
    println("time to flip");
    flip = true;
  }
  println(inString);
  
} 

void flipVideo() {
  flip = false;
  if (record) {
    record = false;
    videoExport.endMovie();
    playback = true;
    myMovie = new Movie(this, "hello.avi");
    myMovie.play();
    overlay_mov = new Movie(this, "clock_transition.mp4");
    overlay_mov.play();
    playback_direction = -1.0 * 0.4;  
    
    init_playback = true;
    fade_in_timer = 0;
  }
}

//for testing
void keyPressed() {
  if (key == 'q') {
    videoExport.endMovie();
    videoExport.startMovie();
  }
  if (key == 'f') {
    flip = true;
  }
}