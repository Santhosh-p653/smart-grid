package model;
import java.sql.Date;

public class ConsumptionRecord {
    private int historyId;
    private int consumerId;
    private String consumerName;
    private int meterId;
    private double kwhConsumed;
    private Date readingDate;

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }
    public int getConsumerId() { return consumerId; }
    public void setConsumerId(int consumerId) { this.consumerId = consumerId; }
    public String getConsumerName() { return consumerName; }
    public void setConsumerName(String consumerName) { this.consumerName = consumerName; }
    public int getMeterId() { return meterId; }
    public void setMeterId(int meterId) { this.meterId = meterId; }
    public double getKwhConsumed() { return kwhConsumed; }
    public void setKwhConsumed(double kwhConsumed) { this.kwhConsumed = kwhConsumed; }
    public Date getReadingDate() { return readingDate; }
    public void setReadingDate(Date readingDate) { this.readingDate = readingDate; }
}
