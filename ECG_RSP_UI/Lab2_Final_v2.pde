import processing.serial.*;

String currentScreen = "selection";  
String cardioZone;

// Sim Data 
float[] simulatedECGData = new float[500];  // Buffer for simulated ECG data
int simulatedTime = 0;  // Counter for simulated time
float rrInterval = 923;  // RR interval for 65 BPM (923 ms between R-peaks)
int sampleRate = 250;  // Sample rate of 250 Hz (typical for ECG sensors)

boolean restingPeriodComplete = false; // Flag to indicate if the resting period is complete


Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
float height_old = 0;
float height_new = 0;
float inByte = 0;
int beat_old = 0;
float threshold = 620.0;  // Threshold for BPM calculation
boolean belowThreshold = true;
boolean belowRespThreshold = true;
PFont font;
String tempVal;
boolean simulationMode = false;
int userAge;
float restingBPM = 0.0;
int maxHeartRate;
int restingBreathe = 0; // Variable to hold resting respiratory rate
int breathCount = 0;         // Counter for detected breaths
boolean timerStarted = false;
int startTime = 0;
float[] ecgData = new float[500]; // Array to hold ECG values
float[] respData = new float[500]; // Array to hold Respiration values
int beatCount = 0;
float totalBPM = 0;
int start30Sec = 0;
float BPM = 0;
int RPM = 0;
int respThreshold = 350;
boolean restingHRCalculated = false;
boolean restingRespCalculated = false; 
// Breathing variables
boolean isInhaling = true; // Track whether currently inhaling or exhaling
long lastChangeTime; // Last time the breathing phase changed
float breathDuration; // Total breath duration in seconds
float inhalationDuration; // Inhalation duration in seconds
float exhalationDuration; // Exhalation duration in seconds
int breathCounter = 0; // Counter for breaths
int wrongPatternCount = 0; // Count of incorrect patterns
int maxWrongPattern = 3; // Maximum allowed wrong breaths
boolean isBreathingPatternCorrect = true; // Indicator for breathing pattern correctness

void setup() {
    String ageInput = prompt("Please enter your age:");  // Prompt box for age
    try {
        userAge = Integer.parseInt(ageInput); 
        maxHeartRate = 220 - userAge;  // Calculate max heart rate
    } catch (NumberFormatException e) {
        println("Invalid age input. Setting age to 0.");
        userAge = 0;  
        maxHeartRate = 220;
    }

    String cardioZone = "";
    size(1000, 900);
    if (!simulationMode) {
        println(Serial.list());
        myPort = new Serial(this, Serial.list()[0], 115200);
        myPort.bufferUntil('\n');
    } else {
        simulateECGData();
    }
    
    //restingBreathe = 12; 

    //lastChangeTime = millis();

    // Set initial background:
    font = createFont("Times New Roman", 12, true);
}

void draw() {
    
    background(0xFFD3D3D3);
    if (simulationMode) {
        updateSimulatedData();
    }
    if (currentScreen.equals("selection")) {
    drawSelectionScreen();  
    } else if (currentScreen.equals("fitness")) {
    drawGraphs();//Fitness Graphs
    drawFitnessScreen();  
    fitnessScreenAverages();
    } else if (currentScreen.equals("meditation")) {
    drawRespGraph();
    drawFitnessScreen();  
    fitnessScreenAverages();
    drawBreathingIndicator();
    } else if (currentScreen.equals("stress")) {
    drawGraphs();//Fitness Graphs
    drawStressScreen();
    fitnessScreenAverages();
    calculateStressMode();
    }
}




void serialEvent(Serial myPort) {
    if (!simulationMode) {  // Only read from serial if not in simulation mode
        String tempVal = myPort.readStringUntil('\n');

        if (tempVal != null) {
            processSensorData(tempVal);
        }
    } else {
        // Simulated data mode
        float simulatedECG = 600 + 200 * sin(PI * millis() / 500) + 100 * sin(2 * PI * millis() / 1000) + random(-50, 50);
        float simulatedRespiration = 400 + 100 * sin(PI * millis() / 1500) + random(-20, 20);
        
        String simulatedData = nf(simulatedECG, 0, 2) + "," + nf(simulatedRespiration, 0, 2) + "\n";
        
        // Process the simulated data
        processSensorData(simulatedData);
    }
}
ArrayList<Integer> beatTimestamps = new ArrayList<>();  
ArrayList<Integer> breathTimestamps = new ArrayList<>(); 

int lastBeatTime = 0;  
int lastBreathTime = 0;
void processSensorData(String tempval) {
    tempval = trim(tempval);
    String[] values = split(tempval, ",");

    if (values.length >= 2) {
        if (start30Sec == 0) {
            start30Sec = millis();
            println("Timer started at: " + start30Sec);
            beatCount = 0;
            breathCount = 0;
        }

        try {
            float ecgValues = float(values[0]);
            float respValues = float(values[1]);
            println(ecgValues);
            println(respValues);
            addData(ecgData, ecgValues);
            addData(respData, respValues);

            // Detect heartbeats and calculate instantaneous heart rate
            if (ecgValues > threshold && belowThreshold) {
                // Beat detected
                println("Beat detected");
                int currentBeatTime = millis();
                beatCount++;
                if (lastBeatTime > 0) {
                    int interval = currentBeatTime - lastBeatTime;
                    BPM = float(nf(60000.0 / interval, 0, 1));
                    updateHeartRateHistory();
                }

                lastBeatTime = currentBeatTime; // Update the last beat time
                belowThreshold = false;
            }
            if (ecgValues < threshold) {
                belowThreshold = true;
            }

            // Detect breaths using a threshold of 200
            if (respValues > 200 && belowRespThreshold) {
              isInhaling = true;
                breathCount++;
                println("Breath detected");
                int currentBreathTime = millis();
                if (lastBreathTime > 0) {
                    int breathInterval = currentBreathTime - lastBreathTime;
                    RPM = int(nf(60000.0 / breathInterval, 0, 1));
                }
                lastBreathTime = currentBreathTime; // Update the last breath time
                belowRespThreshold = false;
            }
            if (respValues < 200) {
                isInhaling = false;
                belowRespThreshold = true;
            }

            // Print heartbeat and RPM for debugging
            println("Current Heartbeat: " + BPM + " BPM");
            println("Current RPM: " + RPM);

        } catch (Exception e) {
            println("Error parsing values: " + e);
        }
    }
}
