<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="model.User"%>
<%@ page import="model.GridNode"%>
<%@ page import="model.FaultRecord"%>
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
    <title>Smart Grid System - Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-brand">
            <span>⚡</span> SmartGrid System
        </div>
        <ul class="nav-links">
            <li class="active"><a href="dashboard">Dashboard</a></li>
            <li><a href="grids">Grid Nodes</a></li>
            <li><a href="load">Load Balancing</a></li>
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
            <h1 class="page-title">Operational Control Room</h1>
            <p class="page-subtitle">Real-time electricity grid overview, alert dispatch, and status monitoring</p>
        </div>

        <% 
            List<FaultRecord> alerts = (List<FaultRecord>) request.getAttribute("activeAlerts");
            if (alerts != null && !alerts.isEmpty()) {
        %>
            <div class="alert-panel">
                <% for (FaultRecord fr : alerts) { %>
                    <div class="custom-alert">
                        <div class="alert-content">
                            <span class="alert-message">⚠️ GRID ALERT: OPEN FAULT reported on <%= fr.getNodeName() %></span>
                            <span class="alert-meta">Type: <strong><%= fr.getFaultType() %></strong> | Description: <%= fr.getDescription() %> | Reported at: <%= fr.getReportedAt() %></span>
                        </div>
                        <a href="faults" class="btn btn-danger btn-sm">Investigate</a>
                    </div>
                <% } %>
            </div>
        <% } %>

        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Active Grid Nodes</h3>
                    <div class="stat-value"><%= request.getAttribute("totalNodes") %></div>
                </div>
                <div class="stat-icon">🕸️</div>
            </div>
            <div class="stat-card" style="border-color: rgba(245, 158, 11, 0.25);">
                <div class="stat-info">
                    <h3>Active Outages</h3>
                    <div class="stat-value" style="color: var(--accent-orange);"><%= request.getAttribute("activeOutages") %></div>
                </div>
                <div class="stat-icon">🔌</div>
            </div>
            <div class="stat-card" style="border-color: rgba(16, 185, 129, 0.25);">
                <div class="stat-info">
                    <h3>Connected Meters</h3>
                    <div class="stat-value" style="color: var(--accent-green);"><%= request.getAttribute("activeMeters") %></div>
                </div>
                <div class="stat-icon">🎛️</div>
            </div>
        </div>

        <div class="glass-card">
            <h2 class="card-title">🌐 Live Grid Distribution Status</h2>
            <div class="table-wrapper">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Node ID</th>
                            <th>Node Name</th>
                            <th>Zone</th>
                            <th>Capacity (kW)</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<GridNode> nodes = (List<GridNode>) request.getAttribute("nodes");
                            if (nodes != null && !nodes.isEmpty()) {
                                for (GridNode node : nodes) {
                                    String badgeClass = "badge-active";
                                    if ("FAULT".equalsIgnoreCase(node.getStatus())) {
                                        badgeClass = "badge-fault";
                                    } else if ("OVERLOADED".equalsIgnoreCase(node.getStatus())) {
                                        badgeClass = "badge-overloaded";
                                    }
                        %>
                                    <tr>
                                        <td style="font-family: var(--font-mono); font-weight: 500;"><%= node.getNodeId() %></td>
                                        <td style="font-weight: 600;"><%= node.getNodeName() %></td>
                                        <td><%= node.getZone() %></td>
                                        <td style="font-family: var(--font-mono);"><%= node.getCapacityKw() %> kW</td>
                                        <td>
                                            <span class="badge <%= badgeClass %>"><%= node.getStatus() %></span>
                                        </td>
                                    </tr>
                        <%
                                }
                            } else {
                        %>
                                <tr>
                                    <td colspan="5" style="text-align: center; color: var(--text-muted);">No grid nodes registered.</td>
                                </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <footer class="footer">
        © 2026 Smart Electricity Grid Monitoring System • Connected to Database Port 3307
    </footer>
</body>
</html>