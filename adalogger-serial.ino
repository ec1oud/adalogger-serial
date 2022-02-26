/*
 Serial data recorder, by Justin Eskridge 2017-8-8.
  Starting with example code from Tom Igoe and Adafruit.
  Simplified for low-speed logging by Shawn Rutledge 2022-02-26

 Hardware
  9600 baud 8N1 serial data source
  SD-card
  Adafruit SAMD21-based Feather Adalogger

 This interrupt-based version works fine, so long as the SERIAL_BUFFER_SIZE is 
 sufficiently large to store all characters while the CPU is busy with the SD card.

 Suggestions and modifications welcome.
*/

// -------------------------------------------
// Overrides
// -------------------------------------------
#define SERIAL_RX_BUFFER_SIZE   4096
#define SERIAL_BUFFER_SIZE      4096

// -------------------------------------------
// Dependencies
// -------------------------------------------
#include <SD.h>
#include <Arduino.h>   // required before wiring_private.h
#include "wiring_private.h" // pinPeripheral() function

// -------------------------------------------
// Parameters
// -------------------------------------------

const char fileName[] = "serial.log";  // filename to save on SD card

#define LOG_BYTE_TRIGGER        SERIAL_BUFFER_SIZE - 40
#define LOG_TIME_TRIGGER        60000

// -------------------------------------------
// Debug LEDs
// -------------------------------------------
#define DBUG_RED_LED_PIN 13
#define DBUG_GRN_LED_PIN 8

#define DBUG_GRN_LED_SET(x)   (digitalWrite(DBUG_GRN_LED_PIN, x))
#define DBUG_RED_LED_SET(x)   (digitalWrite(DBUG_RED_LED_PIN, x))

// -------------------------------------------------------
// Special define to fix virtual serial port issue
// -------------------------------------------------------
#if defined(ARDUINO_SAMD_ZERO) && defined(SERIAL_PORT_USBVIRTUAL)
  // Required for Serial on Zero based boards
  #define Serial SERIAL_PORT_USBVIRTUAL
#endif

// -------------------------------------------------------
// SD Card config
// -------------------------------------------------------
const int chipSelect = 4;

// -------------------------------------------------------
// Create a new serial port on pins 10&11
// https://learn.adafruit.com/using-atsamd21-sercom-to-add-more-spi-i2c-serial-ports/creating-a-new-serial
//   "How about we have D10 be TX and D11 be RX?"
// -------------------------------------------------------
Uart Serial2 (&sercom1, 11, 10, SERCOM_RX_PAD_0, UART_TX_PAD_2);

// -------------------------------------------------------
// Variables for the logger
// -------------------------------------------------------
uint32_t Log_Time = 0;
uint32_t Log_Byte_Count = 0;
File dataFile;

// -------------------------------------------------------
// -------------------------------------------------------
// SETUP
// -------------------------------------------------------
// -------------------------------------------------------
void setup() {
  // Set debug pins as outputs
  pinMode(DBUG_RED_LED_PIN, OUTPUT);
  pinMode(DBUG_GRN_LED_PIN, OUTPUT);
  
  // Set debug pin states
  DBUG_RED_LED_SET(HIGH);
  DBUG_GRN_LED_SET(LOW);

  // https://www.arduino.cc/en/reference/SD
  // See if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    // Flash a fail signal
    while(1) {
      DBUG_RED_LED_SET(HIGH);
      delay(100);
      DBUG_RED_LED_SET(LOW);
      delay(300);
      DBUG_RED_LED_SET(HIGH);
      delay(100);
      DBUG_RED_LED_SET(LOW);
      delay(300);
      DBUG_RED_LED_SET(HIGH);
      delay(100);
      DBUG_RED_LED_SET(LOW);
      delay(1100);
    }
  }

  dataFile = SD.open(fileName, FILE_WRITE); // append
  dataFile.write("\n\n"); // new session marker

  // Setup the serial port that will receive the data for logging
  Serial2.begin(9600);
  
  // Assign pins 10 & 11 SERCOM functionality
  pinPeripheral(10, PIO_SERCOM);
  pinPeripheral(11, PIO_SERCOM);
  
  DBUG_RED_LED_SET(LOW);
}

// -------------------------------------------------------------------------
// MAIN LOOP
// -------------------------------------------------------------------------

void flushWrite() {
  DBUG_RED_LED_SET(HIGH);
  // Reset the byte and time triggers
  Log_Byte_Count = 0;
  Log_Time = millis() + LOG_TIME_TRIGGER;
  dataFile.flush();
  DBUG_RED_LED_SET(LOW);
}

void loop() {
  // If there is data available in serial port buffer
  while(Serial2.available()) {
    DBUG_GRN_LED_SET(HIGH);
    // Transfer one byte from serial receive buffer to SD file buffer
    dataFile.write(Serial2.read());
    // Increment the byte counter
    Log_Byte_Count++;
    // Emergency dump to SD card if exceeded LOG_BYTE_TRIGGER bytes
    if (Log_Byte_Count >= LOG_BYTE_TRIGGER)
      flushWrite();
  }
  delay(10);
  DBUG_GRN_LED_SET(LOW);
  // If it's time according to the log interval, write to SD card
  if (millis() >= Log_Time) 
    flushWrite();
}

void SERCOM1_Handler() {
  Serial2.IrqHandler();
}
