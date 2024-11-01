void drawFitnessScreen(){      
      //Box to hold Main Info
      fill(200,220,50);
      rect(25, 25, 950, 50);
      //Text for Main Box
      fill(0);
      textAlign(CENTER, CENTER); 
      textSize(22); // Set the font size
      String displayText = "Age: " + userAge + "        Resting BPM: " + restingBPM +  "        Resting Breathe: " + restingBreathe + "        Max BPM: " + maxHeartRate + "        Cardio Zone: " + cardioZone;
      text(displayText, 75 + 825 / 2, 25 + 50 / 2); 

      if (currentScreen == "fitness"){
        fill(200,220,50);
        rect(600, 450, 350, 150);
        fill(0);
        text("Inhale Duration: (Seconds)" + nf(inhalationDuration, 0 ,2), 775, 500);
        text("Exhale Duration: (Seconds)" + nf(exhalationDuration, 0 , 2), 775, 550);
      }
      drawBackButton();

}

void drawSelectionScreen() {
  fill(0);
  textSize(24);
  text("Select Mode", width / 2 - 70, height / 4);

  fill(200);
  rect(width / 2 - 100, height / 2 - 100, 200, 50);  // Fitness Button
  rect(width / 2 - 100, height / 2, 200, 50);  // Meditation Button
  rect(width / 2 - 100, height / 2 + 100, 200, 50);  // Stress Button

  fill(0);
  textSize(18);
  text("Fitness Mode", width / 2 - 50, height / 2 - 65);
  text("Meditation Mode", width / 2 - 60, height / 2 + 35);
  text("Stress Mode", width / 2 - 50, height / 2 + 135);
}

void drawMeditationScreen(){
   
   drawBackButton();
}

void drawStressScreen(){

      //Box to hold Main Info
      fill(200,220,50);
      rect(75, 25, 825, 50);
      //Text for Main Box
      fill(0);
      textAlign(CENTER, CENTER); // Center the text horizontally and vertically
      textSize(22); // Set the font size
      String displayText = "Age: " + userAge + "          Resting BPM: " + restingBPM +  "          Resting Breathe: " + restingBreathe + "          Max BPM: " + maxHeartRate;
      text(displayText, 75 + 825 / 2, 25 + 50 / 2); // (x, y) position is the center of the rectangle
      fill(0, 255, 0);
      //Stress Box
      rect(50, 150, 100, 600);
      pushMatrix(); 
      translate(100, 450);  
      rotate(-HALF_PI);  
      fill(255);
      textSize(35);
      text("Not Stressed", 0, 0);  // Draw the text at the new origin

      popMatrix();  // Restore the original transformation

      drawBackButton();
  
}

String prompt(String message) {
  return javax.swing.JOptionPane.showInputDialog(message);
}

void drawBackButton() {
  fill(200);
  rect(50, height - 100, 100, 50);

  fill(0);
  textSize(18);
  text("Back", 80, height - 70);
}

long inhaleStartTime = 0;
long exhaleStartTime = 0;
float currentInhaleTime = 0; 
float currentExhaleTime = 0;  

int incorrectPatternCount = 0;

void drawBreathingIndicator() {
    fill(173, 216, 230);
    ellipse(width / 2, 300, 200, 200);

    // Start the breathing pattern check after 30 seconds
    if (millis() - start30Sec >= 30000) {
        long currentTime = millis();

        if (isInhaling) {
            if (inhaleStartTime == 0) {
                inhaleStartTime = currentTime; // Record the start time of inhalation
            }
            // Calculate current inhalation duration
            currentInhaleTime = (currentTime - inhaleStartTime) / 1000.0;
        } else {
            if (exhaleStartTime == 0) {
                exhaleStartTime = currentTime; // Record the start time of exhalation
                if (currentInhaleTime > 0) {
                    breathCounter++;
                }
                inhaleStartTime = 0; 
            }
            currentExhaleTime = (currentTime - exhaleStartTime) / 1000.0;
        }

        fill(0);
        textSize(32);
        textAlign(CENTER, CENTER);
        text(isInhaling ? "Inhale" : "Exhale", width / 2, 300);

        if (breathCounter > 0) {
            if (currentInhaleTime > 0 && currentExhaleTime < 3 * currentInhaleTime) {
                incorrectPatternCount++;
                if (incorrectPatternCount >= 3) {
                    fill(255, 0, 0);
                    textSize(32);
                    textAlign(CENTER, CENTER);
                    text("Pattern Incorrect", width / 2, height - 50);
                }
            }
            }
        }
    }
