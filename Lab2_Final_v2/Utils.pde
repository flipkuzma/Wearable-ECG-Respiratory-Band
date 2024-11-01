void mousePressed() {
  if (currentScreen.equals("selection")) {
    // Detect which mode was selected
    if (mouseX > width / 2 - 100 && mouseX < width / 2 + 100) {
      if (mouseY > height / 2 - 100 && mouseY < height / 2 - 50) {
        currentScreen = "fitness";  // Go to fitness mode
        //resetData();  // Reset any data
      } else if (mouseY > height / 2 && mouseY < height / 2 + 50) {
        currentScreen = "meditation";  // Go to meditation mode
        //resetData();  // Reset any data
      } else if (mouseY > height / 2 + 100 && mouseY < height / 2 + 150) {
        currentScreen = "stress";  // Go to stress mode
        //resetData();  // Reset any data
      }
    }
  } else {
    // Detect if the back button was pressed
    if (mouseX > 50 && mouseX < 150 && mouseY > height - 100 && mouseY < height - 50) {
      currentScreen = "selection";  // Go back to the selection screen
      //resetData();  // Reset any data and UI
    }
  }
}

void simulateECGData() {
  // Choose a random heart rate between 60 and 200 BPM
  float heartRateBPM = random(60, 200);
  
  // Calculate the RR interval in milliseconds based on the heart rate
  float rrInterval = 60000 / heartRateBPM;
  
  for (int i = 0; i < simulatedECGData.length; i++) {
    simulatedTime += 4;  // Simulate 4ms per step (assuming 250 Hz sampling rate)

    // Generate a basic ECG waveform with R-peaks
    float baseECG = 600 + 100 * sin(PI * simulatedTime / 100);  // Simulated baseline ECG

    // Add an R-peak at the calculated RR interval
    if (simulatedTime % rrInterval < 10) {
      baseECG += 300;  // R-peak (sharp spike)
    }

    // Add small random noise to make it more realistic
    simulatedECGData[i] = baseECG + random(-10, 10);
  }
  
  // Update the global ECG data buffer
  for (int i = 0; i < ecgData.length; i++) {
    ecgData[i] = simulatedECGData[i];
  }
}

 
void addData(float[] array, float newValue) {
  // Shift all elements to the left to make space for the new value
  for (int i = 0; i < array.length - 1; i++) {
    array[i] = array[i + 1];
  }
  // Add the new value at the end
  array[array.length - 1] = newValue;
}
int sampleInterval = 5;  // Process data every 5th call
int sampleCount = 0;

void updateSimulatedData() {
    sampleCount++;
    if (sampleCount % sampleInterval == 0) { 
        
        float period = 60.0 / 65.0; // Period for 65 BPM in seconds
        float frequency = 1.0 / period; // Frequency in Hz
        
        // Generate new simulated ECG and respiration data points
        float ecgValue = 600 + 200 * sin(TWO_PI * frequency * (millis() / 1000.0)) + random(-50, 50);
        // Adjust respiration value; you can set this based on expected respiratory rates
        float respValue = 400 + 100 * sin(TWO_PI * (millis() / 3000.0)) + random(-20, 20);
        
        // Ensure the ECG value is above the threshold for detection
        if (ecgValue < 600) {
            ecgValue = 600;  // Ensure it meets the threshold
        }
        
        // Create a fake serial input string in the format "ECG_value,Resp_value"
        String simulatedData = nf(ecgValue, 1, 2) + "," + nf(respValue, 1, 2);
        
        // Pass the simulated data to the processSensorData function
        processSensorData(simulatedData);
    }
}



void fitnessScreenAverages() {
    int currentTime = millis();
    if (currentTime - start30Sec >= 30000){
        determineCardioZone();
    }
    
    
    if (!restingHRCalculated && (currentTime - start30Sec) >= 30000) {
        if (beatCount > 0) {
            restingBPM = beatCount * 2; // Calculate resting BPM after 30 seconds
            println("Resting BPM: " + restingBPM);
            restingHRCalculated = true;
        } else {
            println("No beats detected for resting BPM calculation.");
        }
    }

    if (!restingRespCalculated && (currentTime - start30Sec) >= 30000) {

        if (breathCount > 0) {
            restingBreathe = breathCount * 2; // Calculate resting respiratory rate
            println("Resting Respiratory Rate: " + restingBreathe);
            restingRespCalculated = true;
        } else {
            println("No breaths detected for resting Respiratory Rate calculation.");
        }
        
    breathDuration = 60.0 / restingBreathe;
    inhalationDuration = breathDuration / 4.0;
    exhalationDuration = breathDuration * 3.0 / 4.0;
    }

    if (restingHRCalculated && restingRespCalculated) {
        restingPeriodComplete = true;
    }
}


void calculateStressMode(){
    if (restingPeriodComplete) { // Only check if the resting period is complete
        if (BPM > restingBPM + 5 || RPM > restingBreathe + 3) {
            fill(255, 0, 0); 
            rect(50, 150, 100, 600); 
            pushMatrix(); 
            translate(100, 450);  
            rotate(-HALF_PI);  
            fill(255);
            textSize(35);
            text("Stressed", 0, 0);
            popMatrix(); 
        } else {
            fill(0, 255, 0); 
            rect(50, 150, 100, 600); // Stress box
            pushMatrix(); 
            translate(100, 450);  
            rotate(-HALF_PI);  
            fill(255);
            textSize(35);
            text("Not Stressed", 0, 0); 
            popMatrix();
        }
    }
}

void determineCardioZone() {
    if (BPM < 0.5 * maxHeartRate) {
        cardioZone = "Resting";
    } else if (BPM < 0.6 * maxHeartRate) {
        cardioZone = "Fat Burn";
    } else if (BPM < 0.8 * maxHeartRate) {
        cardioZone = "Cardio";
    } else {
        cardioZone = "Peak";
    }
    
    println("Current Cardio Zone: " + cardioZone);
}

ArrayList<HeartRateData> heartRateHistory = new ArrayList<HeartRateData>();

class HeartRateData {
    int timestamp;
    float BPM;
    String zone;

    HeartRateData(int timestamp, float BPM, String zone) {
        this.timestamp = timestamp;
        this.BPM = BPM;
        this.zone = zone;
    }
}

void updateHeartRateHistory() {
    int currentTime = millis();
    determineCardioZone();  // Update the current cardio zone
    heartRateHistory.add(new HeartRateData(currentTime, BPM, cardioZone));
}

void resetData() {
  BPM = 0;
  beatCount = 0;
  breathCount = 0;
  start30Sec = 0;
  restingBreathe = 0;
  restingBPM = 0;
  restingHRCalculated = false;
  restingRespCalculated = false;

}
