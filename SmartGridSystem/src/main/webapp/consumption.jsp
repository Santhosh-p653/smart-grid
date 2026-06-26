<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="model.User"%>
<%@ page import="model.Consumer"%>
<%@ page import="model.ConsumptionRecord"%>
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
    <title>Smart Grid System - Energy Consumption</title>
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
            <li><a href="load">Load Balancing</a></li>
            <li><a href="faults">Faults</a></li>
            <li><a href="outages">Outages</a></li>
            <li class="active"><a href="consumption">Consumption</a></li>
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
            <h1 class="page-title">Energy Consumption Registry</h1>
            <p class="page-subtitle">Log consumer meter index metrics, power readings, and audit historical electricity usage</p>
        </div>

        <div class="content-grid">
            <div class="glass-card">
                <h2 class="card-title">📊 Meter Consumption Index</h2>
                <div class="table-wrapper">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>History ID</th>
                                <th>Consumer Name</th>
                                <th>Meter ID</th>
                                <th>Usage (kWh)</th>
                                <th>Reading Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<ConsumptionRecord> histories = (List<ConsumptionRecord>) request.getAttribute("histories");
                                if (histories != null && !histories.isEmpty()) {
                                    for (ConsumptionRecord r : histories) {
                            %>
                                        <tr>
                                            <td style="font-family: var(--font-mono);"><%= r.getHistoryId() %></td>
                                            <td style="font-weight: 600;"><%= r.getConsumerName() %></td>
                                            <td style="font-family: var(--font-mono); font-weight: 500;"><%= r.getMeterId() %></td>
                                            <td style="font-family: var(--font-mono); font-weight: 600; color: var(--neon-blue);"><%= r.getKwhConsumed() %> kWh</td>
                                            <td style="font-family: var(--font-mono);"><%= r.getReadingDate() %></td>
                                        </tr>
                            <%
                                    }
                                } else {
                            %>
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: var(--text-muted);">No consumption history logged yet.</td>
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
                    <h2 class="card-title">📝 Log Meter Reading</h2>
                    <form action="consumption" method="post">
                        <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                            <div class="form-group">
                                <label for="consumerId">Select Consumer Meter</label>
                                <select id="consumerId" name="consumerId" class="form-control" required>
                                    <%
                                        List<Consumer> consumers = (List<Consumer>) request.getAttribute("consumers");
                                        if (consumers != null) {
                                            for (Consumer c : consumers) {
                                    %>
                                                <option value="<%= c.getConsumerId() %>"><%= c.getConsumerName() %> (Meter: <%= c.getMeterId() %>)</option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="kwhConsumed">Consumption Index (kWh)</label>
                                <input type="number" step="0.01" min="0" id="kwhConsumed" name="kwhConsumed" class="form-control" placeholder="e.g. 14.5" required>
                            </div>
                            <div class="form-group">
                                <label for="readingDate">Date of Reading</label>
                                <input type="date" id="readingDate" name="readingDate" class="form-control" required value="<%= new java.sql.Date(System.currentTimeMillis()).toString() %>">
                            </div>
                            <button type="submit" class="btn btn-primary" style="margin-top: 0.5rem; width: 100%;">Record Daily kWh</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer">
        © 2026 Smart Electricity Grid Monitoring System • Connected to Database Port 3307
    </footer>
</body>
</html>
