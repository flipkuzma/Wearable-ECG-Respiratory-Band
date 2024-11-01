void setup() {
  // Initialize the serial communication:
  Serial.begin(115200);
  
  // Setup pins for AD8232 leads off detection
  pinMode(10, INPUT); // Setup for leads off detection LO+
  pinMode(11, INPUT); // Setup for leads off detection LO-
  
  // Optional: Define pin for FSR
  pinMode(A1, INPUT); // FSR connected to analog pin A1
}

void loop() {
  int ecgValue = 0;  // Variable to hold ECG value
  int fsrValue = 0;  // Variable to hold FSR value

  // Check if ECG leads are off
  if ((digitalRead(10) == 1) || (digitalRead(11) == 1)) {
    Serial.println("!"); // Print leads-off warning
  } else {
    // Read ECG value from analog pin A0
    ecgValue = analogRead(A0);
  }
  
  // Read FSR value from analog pin A1
  fsrValue = analogRead(A1);

  // Send both ECG and FSR data over serial in comma-separated format
  Serial.print(ecgValue); // Print ECG value
  Serial.print(",");      // Separator
  Serial.println(fsrValue); // Print FSR value and end line

  // Wait briefly to avoid overwhelming the serial communication
  delay(20);
}
