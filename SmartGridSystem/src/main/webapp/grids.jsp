<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="model.User"%>
<%@ page import="model.GridNode"%>
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
    <title>Smart Grid System - Grid Nodes</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-brand">
            <span>⚡</span> SmartGrid System
        </div>
        <ul class="nav-links">
            <li><a href="dashboard">Dashboard</a></li>
            <li class="active"><a href="grids">Grid Nodes</a></li>
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
            <h1 class="page-title">Power Grid Nodes Management</h1>
            <p class="page-subtitle">Configure, provision, and review substation nodes across sectors</p>
        </div>

        <div class="content-grid">
            <div class="glass-card">
                <h2 class="card-title">🔌 Active Substation Nodes</h2>
                <div class="table-wrapper">
                    <table class="custom-table">
                        <thead>
                            <tr>
                               <th>Node ID</th>
                               <th>Node Name</th>
                               <th>Zone</th>
                               <th>Capacity</th>
                               <th>Current Status</th>
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
                                            <td><span class="badge <%= badgeClass %>"><%= node.getStatus() %></span></td>
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

            <div>
                <div class="glass-card">
                    <h2 class="card-title">⚙️ Add Substation Node</h2>
                    <% if ("ADMIN".equals(currentUser.getRole())) { %>
                        <form action="grids" method="post">
                            <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                                <div class="form-group">
                                    <label for="nodeName">Node Name</label>
                                    <input type="text" id="nodeName" name="nodeName" class="form-control" placeholder="e.g. Substation Delta" required>
                                </div>
                                <div class="form-group">
                                    <label for="zone">Operational Zone</label>
                                    <input type="text" id="zone" name="zone" class="form-control" placeholder="e.g. Zone D" required>
                                </div>
                                <div class="form-group">
                                    <label for="capacityKw">Capacity (kW)</label>
                                    <input type="number" step="0.1" id="capacityKw" name="capacityKw" class="form-control" placeholder="e.g. 400.0" required>
                                </div>
                                <div class="form-group">
                                    <label for="status">Initial Status</label>
                                    <select id="status" name="status" class="form-control">
                                        <option value="ACTIVE">ACTIVE</option>
                                        <option value="FAULT">FAULT</option>
                                        <option value="OVERLOADED">OVERLOADED</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-primary" style="margin-top: 0.5rem; width: 100%;">Provision Node</button>
                            </div>
                        </form>
                    <% } else { %>
                        <div style="text-align: center; padding: 2rem 1rem; color: var(--text-muted);">
                            <span style="font-size: 2.5rem; display: block; margin-bottom: 1rem;">🔒</span>
                            <p style="font-size: 0.95rem; font-weight: 500; line-height: 1.4;">Only administrators have authorization to register or edit grid substations.</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer">
        © 2026 Smart Electricity Grid Monitoring System • Connected to Database Port 3307
    </footer>
</body>
</html>
