/*******************************************************************************

 Bare Conductive MPR121 library
 ------------------------------
 
 DataStream.ino - prints capacitive sense data from MPR121 to serial port
 
 Based on code by Jim Lindblom and plenty of inspiration from the Freescale 
 Semiconductor datasheets and application notes.
 
 Bare Conductive code written by Stefan Dzisiewski-Smith and Peter Krige.
 
 This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 
 Unported License (CC BY-SA 3.0) http://creativecommons.org/licenses/by-sa/3.0/
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

*******************************************************************************/

// serial rate
#define baudRate 9600

#include <MPR121.h>
#include <Wire.h>

// this is the touch threshold - setting it low makes it more like a proximity trigger
// default value is 40 for touch
const int touchThreshold = 40;
// this is the release threshold - must ALWAYS be smaller than the touch threshold
// default value is 20 for touch
const int releaseThreshold = 20;

void setup(){  
  Serial.begin(baudRate);
  while(!Serial); // only needed for Arduino Leonardo or Bare Touch Board 

  // 0x5C is the MPR121 I2C address on the Bare Touch Board
  if(!MPR121.begin(0x5C)){ 
    Serial.println("error setting up MPR121");  
    switch(MPR121.getError()){
      case NO_ERROR:
        Serial.println("no error");
        break;  
      case ADDRESS_UNKNOWN:
        Serial.println("incorrect address");
        break;
      case READBACK_FAIL:
        Serial.println("readback failure");
        break;
      case OVERCURRENT_FLAG:
        Serial.println("overcurrent on REXT pin");
        break;      
      case OUT_OF_RANGE:
        Serial.println("electrode out of range");
        break;
      case NOT_INITED:
        Serial.println("not initialised");
        break;
      default:
        Serial.println("unknown error");
        break;      
    }
    while(1);
  }


  MPR121.setTouchThreshold(touchThreshold);
  MPR121.setReleaseThreshold(releaseThreshold);  
}

void loop(){
   readRawInputs();  
}

void readRawInputs(){
    int i;
    
    if(MPR121.touchStatusChanged()) MPR121.updateTouchData();
    MPR121.updateBaselineData();
    MPR121.updateFilteredData();
    

    
//    Serial.print("FDAT: ");
      Serial.print(MPR121.getFilteredData(0), DEC); //0
      Serial.print(",");
      Serial.print(MPR121.getFilteredData(5), DEC); //1
      Serial.print(",");
      Serial.print(MPR121.getFilteredData(9), DEC); //2
      Serial.print(",");
      Serial.print(MPR121.getFilteredData(11), DEC); //3
      Serial.print(",");
      Serial.print(MPR121.getFilteredData(3), DEC); //4
      Serial.print(",");
//      Serial.print(analogRead(0)); //5
      Serial.print(MPR121.getFilteredData(7), DEC); //5
      Serial.print(",");
      

    Serial.println();
    
 
}
