/* 
   using the LiveInput UGen to patch 
   the audio input from your computer (usually the microphone) to the output.
*/

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.spi.*; // for AudioStream
import ddf.minim.effects.*; // for low pass filter

// a standard test string
final String ENCODER_DATA = "It worked oh my gosh! My whole life, from conception to birth to death has its climax at this very moment. Thank you programming gods.";

// minim audio vars
Minim minim;
AudioOutput out;
LiveInput in;
HighPassSP hpf;

// FSK Modem
Ajm ajm;
FSKModem fskModem;

// images
PImage logo;

// scenes
int menuScene = 0;
int serverScene = 1;
int clientScene = 2;
int browserScene = 3;
int currentScene = menuScene;

// menu scene
Button sendButton;
Button receiveButton;
Button backToMenuButton;

// sending/server scene

// client scene
boolean typingURL = false;
String URLTyped = "";
Button typingButton;
Button sendURLButton;


void setup()
{
  size(400, 640);
  minim = new Minim(this);
  out = minim.getLineOut();
  
  ajm = new Ajm(this);
  fskModem = ajm.createFSKModem(7350, 4900, 1225);
  
  logo = loadImage("logo.png");
  
  backToMenuButton = new Button(10, 10, "<- To Menu");
  
  sendButton = new Button((int) (width/5.0), (int) (height*3.0/4.0), "Server");
  receiveButton = new Button((int) (width - 100 - width/5.0), (int) (height*3.0/4.0), "Client");
  
  typingButton = new Button((int) (width/2.0-50), (int) (height/4.0), "Enter URL");
  sendURLButton = new Button((int) (width/2.0-50), (int) (height*3.0/4.0), "Send URL");
  //for(int i = 0; i < ENCODER_DATA,length; i++) {
  //  fskModem.write(ENCODER_DATA[i]);
  //  sleep();
  //}
  
  // we ask for an input with the same audio properties as the output.
  //AudioStream inputStream = minim.getInputStream( out.getFormat().getChannels(), 
  //                                                out.bufferSize(), 
  //                                                out.sampleRate(), 
  //                                                out.getFormat().getSampleSizeInBits());
                                                 
  // construct a LiveInput by giving it an InputStream from minim.                                                  
  // in = new LiveInput( inputStream );
  
  // create granulate UGen so we can hear the input being modfied before it goes to the output
  // GranulateSteady grain = new GranulateSteady();
  
  // make a low pass filter with a cutoff frequency of 100 Hz
  // the second argument is the sample rate of the audio that will be filtered
  // it is required to correctly compute values used by the filter
  // hpf = new HighPassSP(1000, in.sampleRate());
  
  // // patch the input through the grain effect to the output
  //in.patch(grain).patch(out);
  
  // patch the input through the low pass filter to the output
  // in.patch(hpf).patch(out);
  
  // in.patch(out);
}

// draw is run many times
void draw()
{
  
  if(currentScene == menuScene) {
    background(255);
    
    imageMode(CENTER);
    image(logo, width/2.0, height/3.0, logo.width/8.0, logo.height/8.0);
    
    sendButton.draw();
    receiveButton.draw();
  } else if(currentScene == serverScene) {
    background(255);
    
    textMode(CENTER);
    fill(0);
    text("Waiting for URLs to send", width/2.0, height/2.0);
    
    while(fskModem.available() > 0) {
      int read = fskModem.read();
      println("read: \t" + ((char)read) + " \t" + read);
    }
     
    backToMenuButton.draw();
  } else if(currentScene == clientScene) {
    background(255);
    
    typingButton.draw();
    sendURLButton.draw();
    backToMenuButton.draw();
    
    textMode(CENTER);
    fill(0);
    text(URLTyped + (typingURL && frameCount%60 < 30 ? "|" : ""), width/2.0, height/2.0);
  } else if(currentScene == browserScene) {
    background(255);
    
    backToMenuButton.draw();
  }
  
  
  /* mic -> speaker output
  // erase the window to black
  background( 0 );
  // draw using a white stroke
  stroke( 255 );
  // draw the waveforms
  for( int i = 0; i < out.bufferSize() - 1; i++ )
  {
    // find the x position of each buffer value
    float x1  =  map( i, 0, out.bufferSize(), 0, width );
    float x2  =  map( i+1, 0, out.bufferSize(), 0, width );
    // draw a line from one buffer position to the next for both channels
    line( x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50);
    line( x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
    
    System.out.println(out.left.get(i));
  }*/
}

void keyPressed() {
  if(currentScene == clientScene) {
    if(typingURL) {
      if(keyCode == DELETE && URLTyped.length() > 0) {
        URLTyped = URLTyped.substring(URLTyped.length()-1);
      } else if(keyCode != SHIFT && keyCode != ENTER && keyCode != TAB) {
        URLTyped += key;
      }
    }
  }
}

void mouseReleased() {
  if(currentScene == menuScene) {
    if(sendButton.isHoveredOver()) {
      currentScene = serverScene;
      println("switched to send scene");
    }
    if(receiveButton.isHoveredOver()) {
      currentScene = clientScene;
      println("switched to receive scene");
    }
  } else if(currentScene == clientScene) {
    if(typingButton.isHoveredOver()) {
      typingURL = !typingURL;
    }
    if(sendURLButton.isHoveredOver()) {
      //if(URLTyped.toLowerCase().contains('wikipedia')) {
      //  
      //}
      
      String[] website = loadStrings(URLTyped);
      for(String line : website) {
        //long start = millis();
        fskModem.write(line);
        //long end = millis();
        //println((end - start)/1000.0);
      }
      
      currentScene = browserScene;
      println("switched to browser scene");
    }
    if(backToMenuButton.isHoveredOver()) {
      currentScene = menuScene;
      println("switched to menu scene");
    }
  } else if(currentScene == serverScene) {
    if(backToMenuButton.isHoveredOver()) {
      currentScene = menuScene;
      println("switched to menu scene");
    }
  }
}
