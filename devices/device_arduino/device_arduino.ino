#define KB_PINS 10
#define WRITE_OK 10
#define WRITE_EN 11
#define PIN_CONST 2

// #define READ_OK 18
// #define READ_EN 19
#define READ_OK WRITE_OK
#define READ_EN WRITE_EN


int val_in;
int val_out;
int kb_pins_arr[KB_PINS];
int scr_pins_arr[KB_PINS];

  char test_str[50];

void setup() {
  // put your setup code here, to run once:
    Serial.begin(9600);
    for(int i = 0; i < KB_PINS; i++)
    {
      kb_pins_arr[i] = i + PIN_CONST;
      pinMode(kb_pins_arr[i], OUTPUT);
      digitalWrite(kb_pins_arr[i], LOW);
    }
    pinMode(WRITE_OK, INPUT_PULLUP);
    // for (int i = 0; i < KB_PINS; i++)
    // {
    //   // scr_pins_arr[i] = i + KB_PINS + PIN_CONST;
    //   scr_pins_arr[i] = i + PIN_CONST;
    //   pinMode(scr_pins_arr[i], INPUT_PULLUP);
    // }
    // pinMode(READ_OK, OUTPUT);
    // digitalWrite(READ_OK, LOW);
}

char prnt_str[50];
void loop() {

   // kb
   //send data only when you receive data:
   if (!digitalRead(WRITE_OK))
   {
     digitalWrite(WRITE_EN, LOW);
   }
   if (Serial.available() > 0) {
     // read the incoming byte:
     val_in = Serial.read();
     for (int i = 0; i < 8; i++)
     {
       if ((val_in >> i) & 1)
       {
         digitalWrite(kb_pins_arr[i], HIGH);
       }
       else
       {
         digitalWrite(kb_pins_arr[i], LOW);
       }
     }
     digitalWrite(WRITE_EN, HIGH);
     Serial.print(val_in, BIN);
     sprintf(prnt_str, " %c", val_in);
     Serial.println(prnt_str);
   }

  //scr
//  if (!digitalRead(READ_EN)) {
//    for (int i = 0; i < 8; i++) {
//      val_out = (val_out) | (!digitalRead(scr_pins_arr[i]) << i);
//    }
//    digitalWrite(READ_OK, HIGH);
//    Serial.println(val_out, BIN);
//      sprintf(prnt_str, " %c", val_out);
//      Serial.println(prnt_str);
//  }
//  else
//  {
//    digitalWrite(READ_OK, LOW);
//    val_out = 0;
//  }
}
