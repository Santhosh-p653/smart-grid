<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="model.User"%>
<%@ page import="model.GridNode"%>
<%@ page import="model.PowerReading"%>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Grid System - Load Balancing</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-brand">
            <span>⚡</span> SmartGrid System
        </div>
        <ul class="nav-links">
            <li><a href="dashboard">Dashboard</a></li>
            <li><a href="grids">Grid Nodes</a></li>
            <li class="active"><a href="load">Load Balancing</a></li>
            <li><a href="faults">Faults</a></li>
            <li><a href="outages">Outages</a></li>
            <li><a href="consumption">Consumption</a></li>
            <li><a href="analytics">Analytics</a></li>
        </ul>
        <div class="nav-profile">
            <div class="user-badge">
                <span><%= currentUser.getUsername() %></span>
                <span class="role"><%= currentUser.getRole() %></span>
            </div>
            <a href="logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Load Balancing Management</h1>
            <p class="page-subtitle">Log instantaneous voltage & current draw, analyze capacities, and safeguard substations from overload</p>
        </div>

        <div class="content-grid">
            <div class="glass-card">
                <h2 class="card-title">📉 Instantaneous Substation Power Readings</h2>
                <div class="table-wrapper">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Reading ID</th>
                                <th>Substation Node</th>
                                <th>Voltage (V)</th>
                                <th>Current Draw (A)</th>
                                <th>Power Draw (kW)</th>
                                <th>Reading Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<PowerReading> readings = (List<PowerReading>) request.getAttribute("readings");
                                if (readings != null && !readings.isEmpty()) {
                                    for (PowerReading pr : readings) {
                            %>
                                        <tr>
                                            <td style="font-family: var(--font-mono);"><%= pr.getReadingId() %></td>
                                            <td style="font-weight: 600;"><%= pr.getNodeName() %></td>
                                            <td style="font-family: var(--font-mono);"><%= String.format("%.2f", pr.getVoltage()) %> V</td>
                                            <td style="font-family: var(--font-mono);"><%= String.format("%.2f", pr.getCurrentDraw()) %> A</td>
                                            <td style="font-family: var(--font-mono); font-weight: 600; color: var(--neon-blue);"><%= String.format("%.2f", pr.getPowerKw()) %> kW</td>
                                            <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= pr.getReadingTime() %></td>
                                        </tr>
                            <%
                                    }
                                } else {
                            %>
                                    <tr>
                                        <td colspan="6" style="text-align: center; color: var(--text-muted);">No power telemetry logged yet.</td>
                                    </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div>
                <div class="glass-card">
                    <h2 class="card-title">📡 Log Power Telemetry</h2>
                    <form action="load" method="post">
                        <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                            <div class="form-group">
                                <label for="nodeId">Select Target Substation</label>
                                <select id="nodeId" name="nodeId" class="form-control" required>
                                    <%
                                        List<GridNode> nodes = (List<GridNode>) request.getAttribute("nodes");
                                        if (nodes != null) {
                                            for (GridNode gn : nodes) {
                                    %>
                                                <option value="<%= gn.getNodeId() %>"><%= gn.getNodeName() %> (Cap: <%= gn.getCapacityKw() %> kW)</option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="voltage">Measured Voltage (V)</label>
                                <input type="number" step="0.1" min="0" id="voltage" name="voltage" class="form-control" placeholder="e.g. 240.0" required>
                            </div>
                            <div class="form-group">
                                <label for="currentDraw">Measured Current (A)</label>
                                <input type="number" step="0.1" min="0" id="currentDraw" name="currentDraw" class="form-control" placeholder="e.g. 150.0" required>
                            </div>
                            <button type="submit" class="btn btn-primary" style="margin-top: 0.5rem; width: 100%;">Record Telemetry</button>
                        </div>
                    </form>
                </div>
                
                <div class="glass-card" style="border-color: rgba(245, 158, 11, 0.2);">
                    <h3 style="font-size: 1rem; font-weight: 600; margin-bottom: 0.75rem; color: var(--accent-orange);">💡 Capacity Calculation Formula</h3>
                    <p style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.5;">
                        Power Draw in Kilowatts is calculated automatically using the formula:
                    </p>
                    <code style="display: block; background: rgba(0,0,0,0.3); padding: 0.5rem; border-radius: 6px; font-family: var(--font-mono); margin: 0.5rem 0; font-size: 0.8rem; text-align: center; border: 1px solid var(--card-border);">
                        kW = (Voltage * Current) / 1000
                    </code>
                    <p style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.5;">
                        If computed kW exceeds the substation capacity, the node status transitions to <strong style="color: var(--accent-orange);">OVERLOADED</strong> and signals a control warning alert.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer">
        © 2026 Smart Electricity Grid Monitoring System • Connected to Database Port 3307
    </footer>
</body>
</html>
