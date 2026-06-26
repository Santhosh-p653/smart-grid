<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@ page import="model.User"%>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    Double totalKwh = stats != null && stats.get("totalKwh") != null ? (Double) stats.get("totalKwh") : 0.0;
    Integer openFaults = stats != null && stats.get("openFaults") != null ? (Integer) stats.get("openFaults") : 0;
    Integer activeOutages = stats != null && stats.get("activeOutages") != null ? (Integer) stats.get("activeOutages") : 0;
    List<Map<String, Object>> faultTypes = stats != null ? (List<Map<String, Object>>) stats.get("faultTypes") : null;
    List<Map<String, Object>> highLoads = stats != null ? (List<Map<String, Object>>) stats.get("highLoads") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Grid System - Analytics</title>
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
            <li><a href="consumption">Consumption</a></li>
            <li class="active"><a href="analytics">Analytics</a></li>
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
            <h1 class="page-title">Grid Analytics & Reporting</h1>
            <p class="page-subtitle">Examine aggregate demand, check overload violations, and review fault distribution charts</p>
        </div>

        <div class="stat-grid">
            <div class="stat-card" style="border-color: rgba(14, 165, 233, 0.25);">
                <div class="stat-info">
                    <h3>Aggregate Grid Consumption</h3>
                    <div class="stat-value" style="color: var(--neon-blue);"><%= String.format("%.2f", totalKwh) %> <span style="font-size: 1.2rem; font-weight:500;">kWh</span></div>
                </div>
                <div class="stat-icon">📊</div>
            </div>
            <div class="stat-card" style="border-color: rgba(239, 68, 68, 0.25);">
                <div class="stat-info">
                    <h3>Open Critical Faults</h3>
                    <div class="stat-value" style="color: var(--accent-red);"><%= openFaults %></div>
                </div>
                <div class="stat-icon">🚨</div>
            </div>
            <div class="stat-card" style="border-color: rgba(245, 158, 11, 0.25);">
                <div class="stat-info">
                    <h3>Current Active Outages</h3>
                    <div class="stat-value" style="color: var(--accent-orange);"><%= activeOutages %></div>
                </div>
                <div class="stat-icon">🔋</div>
            </div>
        </div>

        <div class="analytics-grid">
            <div class="glass-card chart-card">
                <div>
                    <h2 class="card-title">📉 Fault Distributions by Classification</h2>
                    <p style="color: var(--text-secondary); font-size: 0.85rem; margin-top: -0.5rem; margin-bottom: 1rem;">Comparison of reported issues grouped by fault category</p>
                    
                    <div class="chart-bar-container">
                        <%
                            int maxCount = 1;
                            if (faultTypes != null && !faultTypes.isEmpty()) {
                                for (Map<String, Object> ft : faultTypes) {
                                    int count = (Integer) ft.get("count");
                                    if (count > maxCount) maxCount = count;
                                }
                                for (Map<String, Object> ft : faultTypes) {
                                    String type = (String) ft.get("type");
                                    int count = (Integer) ft.get("count");
                                    int pct = (int) (((double) count / maxCount) * 100);
                        %>
                                    <div class="chart-bar-row">
                                        <div class="chart-bar-label">
                                            <span><%= type %></span>
                                            <strong style="color: var(--text-primary);"><%= count %> incident<%= count != 1 ? "s" : "" %></strong>
                                        </div>
                                        <div class="chart-bar-outer">
                                            <div class="chart-bar-inner" style="width: <%= pct %>%;"></div>
                                        </div>
                                    </div>
                        <%
                                }
                            } else {
                        %>
                                <p style="text-align: center; color: var(--text-muted); margin: 2rem 0;">No fault distributions recorded.</p>
                        <%
                            }
                        %>
                    </div>
                </div>
            </div>

            <div class="glass-card">
                <h2 class="card-title">⚠️ Substation Peak Capacity Violations</h2>
                <p style="color: var(--text-secondary); font-size: 0.85rem; margin-top: -0.5rem; margin-bottom: 1rem;">Telemetry snapshots where node draw exceeded configured thresholds</p>
                <div class="table-wrapper">
                    <table class="custom-table" style="font-size: 0.9rem;">
                        <thead>
                            <tr>
                                <th>Substation Node</th>
                                <th>Recorded Draw</th>
                                <th>Timestamp</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (highLoads != null && !highLoads.isEmpty()) {
                                    for (Map<String, Object> load : highLoads) {
                            %>
                                        <tr>
                                            <td style="font-weight: 600;"><%= load.get("node") %></td>
                                            <td style="font-family: var(--font-mono); font-weight: 600; color: var(--accent-red);"><%= load.get("power") %> kW</td>
                                            <td style="font-size: 0.8rem; color: var(--text-secondary);"><%= load.get("time") %></td>
                                        </tr>
                            <%
                                    }
                                } else {
                            %>
                                    <tr>
                                        <td colspan="3" style="text-align: center; color: var(--text-muted); padding: 1.5rem 0;">No capacity violations detected.</td>
                                    </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer">
        © 2026 Smart Electricity Grid Monitoring System • Connected to Database Port 3307
    </footer>
</body>
</html>
