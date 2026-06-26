<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="model.User"%>
<%@ page import="model.GridNode"%>
<%@ page import="model.OutageRecord"%>
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
    <title>Smart Grid System - Outage Registry</title>
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
            <li class="active"><a href="outages">Outages</a></li>
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
            <h1 class="page-title">Grid Outage & Maintenance</h1>
            <p class="page-subtitle">Report scheduled grid repairs, track blackouts, and register restoration confirmations</p>
        </div>

        <div class="content-grid">
            <div class="glass-card">
                <h2 class="card-title">🔌 Active & Historical Outages</h2>
                <div class="table-wrapper">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Outage ID</th>
                                <th>Node Name</th>
                                <th>Type</th>
                                <th>Description</th>
                                <th>Started At</th>
                                <th>Restored At</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<OutageRecord> outages = (List<OutageRecord>) request.getAttribute("outages");
                                if (outages != null && !outages.isEmpty()) {
                                    for (OutageRecord o : outages) {
                                        String badgeClass = "ACTIVE".equalsIgnoreCase(o.getStatus()) ? "badge-overloaded" : "badge-resolved";
                            %>
                                        <tr>
                                            <td style="font-family: var(--font-mono);"><%= o.getOutageId() %></td>
                                            <td style="font-weight: 600;"><%= o.getNodeName() %></td>
                                            <td>
                                                <span style="font-weight:600; color: <%= "PLANNED".equalsIgnoreCase(o.getOutageType()) ? "var(--neon-blue)" : "var(--accent-red)" %>;">
                                                    <%= o.getOutageType() %>
                                                </span>
                                            </td>
                                            <td><%= o.getDescription() %></td>
                                            <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= o.getStartedAt() %></td>
                                            <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= o.getRestoredAt() != null ? o.getRestoredAt() : "—" %></td>
                                            <td><span class="badge <%= badgeClass %>"><%= o.getStatus() %></span></td>
                                            <td>
                                                <% if ("ACTIVE".equalsIgnoreCase(o.getStatus())) { %>
                                                    <form action="outages" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="restore">
                                                        <input type="hidden" name="outageId" value="<%= o.getOutageId() %>">
                                                        <button type="submit" class="btn btn-success btn-sm">Restore Power</button>
                                                    </form>
                                                <% } else { %>
                                                    <span style="color: var(--text-muted); font-size: 0.85rem;">Restored</span>
                                                <% } %>
                                            </td>
                                        </tr>
                            <%
                                    }
                                } else {
                            %>
                                    <tr>
                                        <td colspan="8" style="text-align: center; color: var(--text-muted);">No outage reports registered.</td>
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
                    <h2 class="card-title">🔌 Declare Grid Outage</h2>
                    <form action="outages" method="post">
                        <input type="hidden" name="action" value="log">
                        <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                            <div class="form-group">
                                <label for="nodeId">Substation Area</label>
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
                                <label for="outageType">Outage Classification</label>
                                <select id="outageType" name="outageType" class="form-control">
                                    <option value="PLANNED">PLANNED (Maintenance)</option>
                                    <option value="UNPLANNED">UNPLANNED (Failure)</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="description">Cause / Details</label>
                                <textarea id="description" name="description" class="form-control" rows="4" placeholder="Mention repair schedule, overload shutoff or weather impacts..." required></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary" style="margin-top: 0.5rem; width: 100%;">Initiate Outage Protocol</button>
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
