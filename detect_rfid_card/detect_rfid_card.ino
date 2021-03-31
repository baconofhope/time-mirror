#include<SPI.h>
#include<MFRC522.h>

//creating mfrc522 instance
#define RSTPIN 9
#define SSPIN 10
MFRC522 rc(SSPIN, RSTPIN);

int readsuccess;

/* Following code is adapted from Sooncheng https://www.instructables.com/id/Arduino-RFID-Reader-MFRC522-Turorial/ */

byte card1[4]={0xC7,0x46,0xBF,0xEB}; //card on one side of hourglass
byte card2[4]={0xC7,0x68,0xBE,0xEB}; //card on other side of hourglass
int current; //record state of hourglass
byte readcard[4]; //stores the UID of current tag which is read

void setup() {
  Serial.begin(9600);
  SPI.begin();
  rc.PCD_Init(); //initialize the receiver  
  // rc.PCD_DumpVersionToSerial(); //show details of card reader module
}

void loop() {
  
  readsuccess = getid();
  
  if(readsuccess){
    int flip = 0;
    
    //Compare the current tag with pre defined tags
    if(!memcmp(readcard,card1,4)){
      flip = current + 1;
      current = 1;
     } else if (!memcmp(readcard,card2,4)){
      flip = current - 1;
      current = -1;
     }
    
     if(abs(flip) <= 1)
        {Serial.print("1");
          delay(2000);        
        }
       else {
        //Serial.println("UNKNOWN CARD"); //for testing
          delay(2000);
        }
    }
  }

//Read card and store UID in readcard
int getid(){  
  if(!rc.PICC_IsNewCardPresent()){
    return 0;
  }
  if(!rc.PICC_ReadCardSerial()){
    return 0;
  }
 
  //Serial.println("THE UID OF THE SCANNED CARD IS:");
  for(int i=0;i<4;i++){
    readcard[i]=rc.uid.uidByte[i];   
    //Serial.print(readcard[i],HEX);   
  }

  rc.PICC_HaltA();
  
  return 1;
}



