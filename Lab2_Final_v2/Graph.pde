void drawGraphs() {
    background(0xFFD3D3D3); // Clear background for the graphs
    if (currentScreen == "fitness"){
          
    // Draw adjusted ECG graph
    graph(ecgData, 50, 150, 500, 250, "ECG", color(255, 0, 0), 200, 1000);
    if (millis() - start30Sec >= 30000){
          drawActivityGraph(heartRateHistory, 50, 150, 500, 250, "BPM");
    }

    // Draw adjusted Respiration graph
    graph(respData, 50, 500, 500, 250, "Respiration", color(0, 0, 255), 200, 1000);
    
    }else {
    // Draw ECG graph
    graph(ecgData, 250, 150, 500, 250, "ECG", color(255, 0, 0), 200, 1000);

    // Draw Respiration graph
    graph(respData, 250, 500, 500, 250, "Respiration", color(0, 0, 255), 200, 1000);
    }
}

void drawRespGraph(){
   background(0xFFD3D3D3);
   graph(respData, 250, 500, 500, 250, "Respiration", color(0, 0, 255), 200, 1000);

}

void drawActivityGraph(ArrayList<HeartRateData> heartRateHistory, int x, int y, int w, int h, String title) {
    // Create a float array to hold BPM data
    float[] bpmData = new float[heartRateHistory.size()];

    // Fill the bpmData array with BPM values from heartRateHistory
    for (int i = 0; i < heartRateHistory.size(); i++) {
        bpmData[i] = heartRateHistory.get(i).BPM;
    }

    // Call the graph function to draw the activity graph
    graphv2(bpmData, 600, y, 300, h, title, getColorForHeartRate(bpmData), 0, 220); // Get color based on the last BPM value
}

// Function to determine the color based on the last BPM value
color getColorForHeartRate(float[] bpmData) {
    if (bpmData.length == 0) return color(0); // Default color if no data is available

    float lastBpm = bpmData[bpmData.length - 1]; // Get the most recent BPM
    if (lastBpm < 0.6 * maxHeartRate) {
        return color(0, 255, 0); // Green for Resting
    } else if (lastBpm < 0.7 * maxHeartRate) {
        return color(255, 255, 0); // Yellow for Fat Burn
    } else if (lastBpm < 0.85 * maxHeartRate) {
        return color(255, 165, 0); // Orange for Cardio
    } else {
        return color(255, 0, 0); // Red for Peak
    }
}

// Update the graph function to draw data from the right
void graphv2(float[] data, int x, int y, int w, int h, String title, color lineColor, float minValue, float maxValue) {
    // Draw the graph's border
    stroke(0); // Set line color to black
    noFill(); // Do not fill the rectangle
    rect(x, y, w, h); // Draw the rectangle representing the graph area

    // Draw the title
    textSize(24); // Set title font size
    textAlign(CENTER, BOTTOM); // Center align text and place above the graph
    text(title, x + w / 2, y - 20); // Draw title above the graph

    // Draw the data line
    stroke(lineColor); // Set line color for the graph
    noFill();
    beginShape();
    
    // Draw the data points from right to left
    for (int i = data.length - 1; i >= 0; i--) {
        float xPos = map(data.length - 1 - i, 0, data.length - 1, x + w, x); // Map index to x position (right to left)
        float yPos = map(constrain(data[i], minValue, maxValue), minValue, maxValue, y + h, y);
        vertex(xPos, yPos); // Draw vertex at mapped position
    }
    endShape();

    // Draw Y-Axis labels and lines
    drawYAxisLabelsv2(x, y, h, 5, minValue, maxValue); // Draw Y-Axis labels starting from minValue
    // Draw X-Axis labels and lines
}

void drawYAxisLabelsv2(int x, int y, int h, int numTicks, float minValue, float maxValue) {
    textSize(12);
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= numTicks; i++) {
        float value = map(i, 0, numTicks, minValue, maxValue);
        float yPos = map(i, 0, numTicks, y + h, y);
        line(x - 5, yPos, x, yPos); // Draw tick mark on the Y-axis
        text(nf(value, 0, 1), x - 10, yPos); // Draw the label for the Y-axis
    }
}



// Generic graphing function
void graph(float[] data, int x, int y, int w, int h, String title, color lineColor, float minValue, float maxValue) {
    // Draw the graph's border
    stroke(0); // Set line color to black
    noFill(); // Do not fill the rectangle
    rect(x, y, w, h); // Draw the rectangle representing the graph area

    // Draw the title
    textSize(24); // Set title font size
    textAlign(CENTER, BOTTOM); // Center align text and place above the graph
    text(title, x + w / 2, y - 20); // Draw title above the graph

    // Draw the data line
    stroke(lineColor); // Set line color for the graph
    noFill();
    beginShape();
    for (int i = 0; i < data.length; i++) {
        float xPos = map(i, 0, data.length, x, x + w); // Map index to x position within graph
        float yPos = map(constrain(data[i], minValue, maxValue), minValue, maxValue, y + h, y);
        vertex(xPos, yPos); // Draw vertex at mapped position
    }
    endShape();

    // Draw Y-Axis labels and lines
    drawYAxisLabels(x, y, h, 4, minValue); // Draw Y-Axis labels starting from minValue
    // Draw X-Axis labels and lines
}

// Function to draw Y-Axis labels
void drawYAxisLabels(int x, int y, int h, int numLabels, float startValue) {
    textSize(14); // Set font size for axis labels
    for (int i = 0; i <= numLabels; i++) {
        int yPos = y + h - i * (h / numLabels); // Calculate y-position based on interval
        line(x, yPos, x - 5, yPos); // Draw small tick lines on y-axis
        textAlign(RIGHT, CENTER); // Align text to the right of the tick lines
        text(int(startValue + i * (800 / numLabels)), x - 10, yPos); // Label y-axis values
    }
}

// Function to draw X-Axis labels
void drawXAxisLabels(int x, int y, int w, int interval) {
    int numLabels = w / interval; // Number of labels based on width and interval
    for (int i = 0; i <= numLabels; i++) {
        int xPos = x + i * interval; // Calculate x-position based on interval
        line(xPos, y, xPos, y + 5); // Draw small tick lines on x-axis
        textAlign(CENTER, TOP); // Align text below the tick lines
        text(i * 200, xPos, y + 15); // Label x-axis values in milliseconds
    }
}
