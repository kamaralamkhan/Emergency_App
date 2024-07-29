#include <TinyGPS++.h>
#include <HardwareSerial.h>

// Define UART interfaces for SIM module and GPS Neo
HardwareSerial simSerial(2); // UART2 for SIM module
HardwareSerial gpsSerial(1); // UART1 for GPS Neo

const int RXPin = 19; // Connect GPS TX to this pin
const int TXPin = 18; // Connect GPS RX to this pin

// Define emergency contact number
String emergencyNumber = "+917557662302";

// The TinyGPS++ object
TinyGPSPlus gps;

bool firstMessageSent = false; // Flag to track if the first message has been sent
unsigned long lastSMSTime = 0; // Variable to store the time when the last SMS was sent
const unsigned long smsInterval = 10000; // Interval between SMS messages (10 seconds)

void setup() {
  Serial.begin(9600); // Initialize serial monitor
  simSerial.begin(9600, SERIAL_8N1, 16, 17); // Initialize SIM module serial communication
  gpsSerial.begin(9600, SERIAL_8N1, RXPin, TXPin); // Initialize GPS serial communication
  Serial.println("System initialized. Checking modules...");
  
  // Check if SIM module is ready
  if (isSimReady()) {
    Serial.println("SIM module ready.");
  } else {
    Serial.println("SIM module not ready.");
  }

  // Check if GPS module is ready
  if (isGpsReady()) {
    Serial.println("GPS module ready.");
  } else {
    Serial.println("GPS module not ready.");
  }
}

void loop() {
  // Keep reading from GPS and update data
  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
  }

  // If new GPS data is available and it's time to send a message
  if (gps.location.isUpdated() && (millis() - lastSMSTime >= smsInterval)) {
    // Print GPS data
    Serial.print("Latitude: ");
    Serial.println(gps.location.lat(), 6);
    Serial.print("Longitude: ");
    Serial.println(gps.location.lng(), 6);
    Serial.print("Altitude (meters): ");
    Serial.println(gps.altitude.meters());

    // Print speed (in km/h)
    if (gps.speed.isValid()) {
      Serial.print("Speed (km/h): ");
      Serial.println(gps.speed.kmph());
    }

    // Print course (in degrees)
    if (gps.course.isValid()) {
      Serial.print("Course (degrees): ");
      Serial.println(gps.course.deg());
    }

    // Print number of satellites
    if (gps.satellites.isValid()) {
      Serial.print("Satellites: ");
      Serial.println(gps.satellites.value());
    }

    // Send emergency SMS with GPS location
    if (!firstMessageSent) {
      sendEmergencySMS();
      firstMessageSent = true; // Set the flag to true after sending the first message
    } else {
      // Send the next message after the interval
      sendEmergencySMS();
    }

    // Update the time when the last SMS was sent
    lastSMSTime = millis();
  }

  // You can access more GPS data using other TinyGPS++ functions as needed
}

bool isSimReady() {
  simSerial.println("AT");
  delay(500); // Increased delay to ensure command processing
  while (simSerial.available()) {
    String response = simSerial.readStringUntil('\n');
    if (response.indexOf("OK") != -1) {
      return true;
    }
  }
  return false;
}

bool isGpsReady() {
  gpsSerial.println("AT");
  delay(500); // Increased delay to ensure command processing
  while (gpsSerial.available()) {
    String response = gpsSerial.readStringUntil('\n');
    if (response.indexOf("OK") != -1) {
      return true;
    }
  }
  return false;
}

void sendEmergencySMS() {
  bool locationFound = false;
  String latitude = "";
  String longitude = "";

  // Check if GPS location is available
  if (gps.location.isValid() && gps.location.age() < 2000) {
    latitude = String(gps.location.lat(), 6);
    longitude = String(gps.location.lng(), 6);
    locationFound = true;
  }

  // Construct the message
  String message = "Emergency! Need assistance.";
  if (locationFound) {
    message += " Current Location: https://maps.google.com/maps?q=" + latitude + "," + longitude;
  }

  // Send the message
  simSerial.println("AT+CMGF=1"); // Set SMS mode to text
  delay(500); // Increased delay
  simSerial.println("AT+CMGS=\"" + emergencyNumber + "\"\r"); // Set recipient number
  delay(500); // Increased delay
  simSerial.print(message); // Send message
  delay(500); // Increased delay to ensure message is sent
  simSerial.write(26); // End message with Ctrl+Z
  delay(500); // Increased delay to ensure command is processed
  Serial.println("Emergency SMS sent.");
}