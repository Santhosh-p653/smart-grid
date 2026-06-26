package model;
import java.sql.Timestamp;

public class OutageRecord {
    private int outageId;
    private int nodeId;
    private String nodeName;
    private String outageType;
    private String description;
    private String status;
    private Timestamp startedAt;
    private Timestamp restoredAt;

    public int getOutageId() { return outageId; }
    public void setOutageId(int outageId) { this.outageId = outageId; }
    public int getNodeId() { return nodeId; }
    public void setNodeId(int nodeId) { this.nodeId = nodeId; }
    public String getNodeName() { return nodeName; }
    public void setNodeName(String nodeName) { this.nodeName = nodeName; }
    public String getOutageType() { return outageType; }
    public void setOutageType(String outageType) { this.outageType = outageType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getStartedAt() { return startedAt; }
    public void setStartedAt(Timestamp startedAt) { this.startedAt = startedAt; }
    public Timestamp getRestoredAt() { return restoredAt; }
    public void setRestoredAt(Timestamp restoredAt) { this.restoredAt = restoredAt; }
}
