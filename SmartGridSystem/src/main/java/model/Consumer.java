package model;

public class Consumer {
    private int consumerId;
    private String consumerName;
    private int meterId;
    private int nodeId;
    private String nodeName;
    private String address;

    public int getConsumerId() { return consumerId; }
    public void setConsumerId(int consumerId) { this.consumerId = consumerId; }
    public String getConsumerName() { return consumerName; }
    public void setConsumerName(String consumerName) { this.consumerName = consumerName; }
    public int getMeterId() { return meterId; }
    public void setMeterId(int meterId) { this.meterId = meterId; }
    public int getNodeId() { return nodeId; }
    public void setNodeId(int nodeId) { this.nodeId = nodeId; }
    public String getNodeName() { return nodeName; }
    public void setNodeName(String nodeName) { this.nodeName = nodeName; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
}
