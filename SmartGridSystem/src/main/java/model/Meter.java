package model;

public class Meter {

    private int meterId;
    private String customerName;
    private double currentLoadKw;
    private String status;
    private double voltage;
    private double currentDraw;

    public int getMeterId() {
        return meterId;
    }

    public void setMeterId(int meterId) {
        this.meterId = meterId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public double getCurrentLoadKw() {
        return currentLoadKw;
    }

    public void setCurrentLoadKw(double currentLoadKw) {
        this.currentLoadKw = currentLoadKw;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getVoltage() {
        return voltage;
    }

    public void setVoltage(double voltage) {
        this.voltage = voltage;
    }

    public double getCurrentDraw() {
        return currentDraw;
    }

    public void setCurrentDraw(double currentDraw) {
        this.currentDraw = currentDraw;
    }
}