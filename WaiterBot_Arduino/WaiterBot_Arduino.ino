//const int pinON = 6;         // connect pin 6 to ON/OFF switch, active HIGH
const int pinCW_Left = 7;    // connect pin 7 to clock-wise PMOS gate
const int pinCC_Left = 8;    // connect pin 8 to counter-clock-wise PMOS gate
const int pinSpeed_Left = 9; // connect pin 9 to speed reference
// define pins
const int pinON = 6;         // connect pin 6 to ON/OFF switch, active HIGH
const int pinCW_Right = 11;    // connect pin 7 to clock-wise PMOS gate, right
const int pinCC_Right = 12;    // connect pin 8 to counter-clock-wise PMOS gate
const int pinSpeed_Right = 10; // connect pin 9 to speed reference
int val = 0;
int vRef = 80;
volatile int encL_count = 0;
volatile int encR_count = 0;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  attachInterrupt(0, ISR_L_count, RISING);
  attachInterrupt(1, ISR_R_count, RISING);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(pinCW_Left,OUTPUT);
  pinMode(pinCC_Left,OUTPUT);
  pinMode(pinSpeed_Left,OUTPUT);
  pinMode(pinCW_Right,OUTPUT);
  pinMode(pinCC_Right,OUTPUT);
  pinMode(pinSpeed_Right,OUTPUT);
  pinMode(13,OUTPUT);             // on-board LED
  digitalWrite(pinCW_Left,LOW);   // stop clockwise
  digitalWrite(pinCC_Left,LOW);   // stop counter-clockwise
  analogWrite(pinSpeed_Left,vRef); // set speed reference, duty-cycle = 100/255
  digitalWrite(pinCW_Right,LOW);   // stop clockwise
  digitalWrite(pinCC_Right,LOW);   // stop counter-clockwise
  analogWrite(pinSpeed_Right,vRef-6);
  digitalWrite(4, LOW);
  digitalWrite(5, LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available())
  {
    adjust();
    recieved(); 
  }
 }

void recieved(){
  val = Serial.read();
  if(val == 1){
    forward();
   }
  else if(val == 2){
    backward();
  }
  else if(val == 3){
    left();
  }
  else if(val == 4){
    right();
  }
  else if(val == 5){
    armUp();
  }
  else if(val == 6){
    armDown();
  }
  else
  {
    Stop();
  }
}

void forward()
{
  adjust();
  digitalWrite(pinCW_Right,HIGH); 
  digitalWrite(pinCC_Right,LOW);
  digitalWrite(pinCW_Left,LOW);  
  digitalWrite(pinCC_Left,HIGH); 
}

void backward()
{
  adjust();
  digitalWrite(pinCW_Right,LOW); 
  digitalWrite(pinCC_Right,HIGH);
  digitalWrite(pinCW_Left,HIGH); 
  digitalWrite(pinCC_Left,LOW); 
}
void right()
{
  digitalWrite(pinCW_Left,LOW);  
  digitalWrite(pinCC_Left,HIGH);
}

void left()
{
  digitalWrite(pinCW_Right,HIGH); 
  digitalWrite(pinCC_Right,LOW);
}
void Stop()
{
  encR_count = 0;
  encL_count = 0;
  digitalWrite(pinCW_Right,LOW);   // stop clockwise
  digitalWrite(pinCC_Right,LOW);
  digitalWrite(pinCW_Left,LOW);   // stop clockwise
  digitalWrite(pinCC_Left,LOW); 
}

void armUp()
{
  int t = 0;
  while(t < 200)
  {
  digitalWrite(4, LOW);
  digitalWrite(5, LOW);
  delayMicroseconds(300);
  digitalWrite(5, HIGH);
  t++;
  }
}
void armDown()
{
  int t = 0;
  while(t < 200)
  {
  digitalWrite(4, HIGH);
  digitalWrite(5, LOW);
  delayMicroseconds(300);
  digitalWrite(5, HIGH);
  t++;
  }
}

void ISR_L_count()
{
  encL_count++;
}

void ISR_R_count()
{
  encR_count++;
}

void adjust()
{
  if(abs(encL_count-encR_count) > 8)
  {
    if(encL_count < encR_count)
    { 
      vRef ++;
      analogWrite(pinSpeed_Left, vRef); 
    }
    if(encL_count > encR_count) 
    {
      vRef --;
      analogWrite(pinSpeed_Left, vRef); 
    }
  }
}
