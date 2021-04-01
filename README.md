# Time Mirror

Time Mirror is an interactive installation based on the concept of “time reversal symmetry” in theoretical physics. It was created for the Tsung-Dao Lee Library at Shanghai Jiaotong University, which hosts an annual ‘Science and Art’ competition. The main technologies used were Processing and Arduino. The project utilizes facial recognition, RFID, and video processing.

## Time reversal symmetry 

In time reversal symmetry or T-symmetry, the laws of physics are observed as time runs in reverse. In a thought experiment, we consider any point of time as the initial state and observe what happens as time runs forward and backwards. I am interested in this theoretical split in time, where time begins to run in both directions. In terms of motion, the events mirror each other: the ball falls when time is played ‘forward' and rises when it is played ‘backward’.  To encapsulate this idea of symmetry across time, I wanted to create a mirror which reflects through spacetime rather than just physical space.


## Concept

The mirror gives the viewer a glimpse of time reversed. A digital display combined with a web camera creates a digital mirror. The mirror initially shows the viewer’s image like a normal mirror would. When the viewer flips the hourglass on the stand, the display becomes a ‘time reversal’ mirror, showing time flowing backwards. The display begins playing the last seconds of video capture backwards, showing the viewer what just happened. 


## Implementation

### Setup

The web camera is attached on top of the digital display to capture the viewer's image. The hourglass has RFID tags attached to both ends so that we can identify which end is on the stand. The hourglass stand contains a RFID reader, and the information is processed by an Arduino microcontroller. When the hourglass is flipped, the Arduino notifies the Processing program to start showing the "time reversal" effect video. 

### Code logic
The digital display was programmed using Processing. The program displays the video feed from the web camera. When a viewer is present (accomplished using facial detection from the OpenCV library), the program begins recording. When the viewer flips the hourglass, the Arduino notifies the Processing program, and the recording of the viewer is exported (using VideoExport and ffmpeg). The recording is then played backwards on the screen.
