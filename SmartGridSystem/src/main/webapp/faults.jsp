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
    <title>Smart Grid System - Fault Registry</title>
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
            <li class="active"><a href="faults">Faults</a></li>
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
            <h1 class="page-title">Fault Detection & Alerts</h1>
            <p class="page-subtitle">Track, register, and resolve active grid malfunctions and physical component faults</p>
        </div>

        <div class="content-grid">
            <div class="glass-card">
                <h2 class="card-title">🚨 System Fault Logs</h2>
                <div class="table-wrapper">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Affected Node</th>
                                <th>Type</th>
                                <th>Description</th>
                                <th>Reported</th>
                                <th>Resolved</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<FaultRecord> faults = (List<FaultRecord>) request.getAttribute("faults");
                                if (faults != null && !faults.isEmpty()) {
                                    for (FaultRecord f : faults) {
                                        String badgeClass = "OPEN".equalsIgnoreCase(f.getStatus()) ? "badge-fault" : "badge-resolved";
                            %>
                                        <tr>
                                            <td style="font-family: var(--font-mono);"><%= f.getFaultId() %></td>
                                            <td style="font-weight: 600;"><%= f.getNodeName() %></td>
                                            <td><span style="color: var(--neon-blue); font-weight: 500;"><%= f.getFaultType() %></span></td>
                                            <td><%= f.getDescription() %></td>
                                            <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= f.getReportedAt() %></td>
                                            <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= f.getResolvedAt() != null ? f.getResolvedAt() : "—" %></td>
                                            <td><span class="badge <%= badgeClass %>"><%= f.getStatus() %></span></td>
                                            <td>
                                                <% if ("OPEN".equalsIgnoreCase(f.getStatus())) { %>
                                                    <form action="faults" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="resolve">
                                                        <input type="hidden" name="faultId" value="<%= f.getFaultId() %>">
                                                        <input type="hidden" name="nodeId" value="<%= f.getNodeId() %>">
                                                        <button type="submit" class="btn btn-success btn-sm">Resolve</button>
                                                    </form>
                                                <% } else { %>
                                                    <span style="color: var(--text-muted); font-size: 0.85rem;">Completed</span>
                                                <% } %>
                                            </td>
                                        </tr>
                            <%
                                    }
                                } else {
                            %>
                                    <tr>
                                        <td colspan="8" style="text-align: center; color: var(--text-muted);">No fault records found.</td>
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
                    <h2 class="card-title">⚠️ Log Substation Fault</h2>
                    <form action="faults" method="post">
                        <input type="hidden" name="action" value="log">
                        <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                            <div class="form-group">
                                <label for="nodeId">Select Substation</label>
                                <select id="nodeId" name="nodeId" class="form-control" required>
                                    <%
                                        List<GridNode> nodes = (List<GridNode>) request.getAttribute("nodes");
                                        if (nodes != null) {
                                            for (GridNode gn : nodes) {
                                    %>
                                                <option value="<%= gn.getNodeId() %>"><%= gn.getNodeName() %></option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="faultType">Fault Severity Type</label>
                                <select id="faultType" name="faultType" class="form-control">
                                    <option value="Short Circuit">Short Circuit</option>
                                    <option value="Overvoltage Spill">Overvoltage Spill</option>
                                    <option value="Transformer Burnout">Transformer Burnout</option>
                                    <option value="Physical Line Damage">Physical Line Damage</option>
                                    <option value="Phase Disbalance">Phase Disbalance</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="description">Detailed Description</label>
                                <textarea id="description" name="description" class="form-control" rows="4" placeholder="Describe the physical status and actions taken..." required></textarea>
                            </div>
                            <button type="submit" class="btn btn-danger" style="margin-top: 0.5rem; width: 100%;">Dispatch Fault Warning</button>
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
