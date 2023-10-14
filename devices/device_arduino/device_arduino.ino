#define NUM_PINS 10
#define PIN_CONST 2
#define READ_OK 10
#define READ_EN 11
#define WRITE_OK 10
#define WRITE_EN 11


int val_in;
int val_out;
int pins[NUM_PINS];

void setup() {
  // put your setup code here, to run once:
    Serial.begin(9600);
    for(int i = 0; i < NUM_PINS; i++)
    {
      pins[i] = i + PIN_CONST;
      pinMode(pins[i], INPUT_PULLUP);
    }
    pinMode(READ_OK, OUTPUT);
    digitalWrite(READ_OK, LOW);
}

void loop() {
  //kb
  // send data only when you receive data:
  // if (!digitalRead(WRITE_OK))
  // {
  //   digitalWrite(WRITE_EN, LOW);
  // }
  // if (Serial.available() > 0) {
  //   // read the incoming byte:
  //   val_in = Serial.read();
  //   for (int i = 0; i < 8; i++)
  //   {
  //     if ((val_in >> i) & 1)
  //     {
  //       digitalWrite(pins[i], HIGH);
  //     }
  //     else
  //     {
  //       digitalWrite(pins[i], LOW);
  //     }
  //   }
  //   digitalWrite(WRITE_EN, HIGH);
  // }

  //scr
  if (!digitalRead(READ_EN)) {
  for (int i = 0; i < 8; i++) {
    val_out = (val_out) | !digitalRead(pins[i]) << i;
  }
  digitalWrite(READ_OK, HIGH);
  Serial.println(val_out, DEC);
  }
  else
  {
    digitalWrite(READ_OK, LOW);
  }
}
