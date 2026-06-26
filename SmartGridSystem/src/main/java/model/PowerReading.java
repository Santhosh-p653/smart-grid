package model;
import java.sql.Timestamp;

public class PowerReading {
    private int readingId;
    private int nodeId;
    private String nodeName;
    private double voltage;
    private double currentDraw;
    private double powerKw;
    private Timestamp readingTime;

    public int getReadingId() { return readingId; }
    public void setReadingId(int readingId) { this.readingId = readingId; }
    public int getNodeId() { return nodeId; }
    public void setNodeId(int nodeId) { this.nodeId = nodeId; }
    public String getNodeName() { return nodeName; }
    public void setNodeName(String nodeName) { this.nodeName = nodeName; }
    public double getVoltage() { return voltage; }
    public void setVoltage(double voltage) { this.voltage = voltage; }
    public double getCurrentDraw() { return currentDraw; }
    public void setCurrentDraw(double currentDraw) { this.currentDraw = currentDraw; }
    public double getPowerKw() { return powerKw; }
    public void setPowerKw(double powerKw) { this.powerKw = powerKw; }
    public Timestamp getReadingTime() { return readingTime; }
    public void setReadingTime(Timestamp readingTime) { this.readingTime = readingTime; }
}
