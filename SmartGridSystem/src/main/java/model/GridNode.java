package model;

public class GridNode {
    private int nodeId;
    private String nodeName;
    private String zone;
    private String status;
    private double capacityKw;

    public int getNodeId() { return nodeId; }
    public void setNodeId(int nodeId) { this.nodeId = nodeId; }
    public String getNodeName() { return nodeName; }
    public void setNodeName(String nodeName) { this.nodeName = nodeName; }
    public String getZone() { return zone; }
    public void setZone(String zone) { this.zone = zone; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public double getCapacityKw() { return capacityKw; }
    public void setCapacityKw(double capacityKw) { this.capacityKw = capacityKw; }
}
