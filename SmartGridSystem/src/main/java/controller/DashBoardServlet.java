package controller;

import model.User;
import model.GridNode;
import model.FaultRecord;
import util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/dashboard")
public class DashBoardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        List<GridNode> nodes = new ArrayList<>();
        List<FaultRecord> activeAlerts = new ArrayList<>();
        int activeOutages = 0;
        int totalNodes = 0;
        int activeMeters = 0;

        try (Connection conn = DBConnection.getConnection()) {
            // Load nodes
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM grid_nodes ORDER BY node_id")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        GridNode n = new GridNode();
                        n.setNodeId(rs.getInt("node_id"));
                        n.setNodeName(rs.getString("node_name"));
                        n.setZone(rs.getString("zone"));
                        n.setStatus(rs.getString("status"));
                        n.setCapacityKw(rs.getDouble("capacity_kw"));
                        nodes.add(n);
                    }
                }
            }

            // Load active alerts (Open Faults)
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT f.*, n.node_name FROM fault_records f JOIN grid_nodes n ON f.node_id = n.node_id WHERE f.status='OPEN' ORDER BY f.reported_at DESC")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        FaultRecord fr = new FaultRecord();
                        fr.setFaultId(rs.getInt("fault_id"));
                        fr.setNodeName(rs.getString("node_name"));
                        fr.setFaultType(rs.getString("fault_type"));
                        fr.setDescription(rs.getString("description"));
                        fr.setReportedAt(rs.getTimestamp("reported_at"));
                        activeAlerts.add(fr);
                    }
                }
            }

            // Load counts
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM grid_nodes")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalNodes = rs.getInt(1);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM outage_records WHERE status='ACTIVE'")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) activeOutages = rs.getInt(1);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM consumers")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) activeMeters = rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("nodes", nodes);
        request.setAttribute("activeAlerts", activeAlerts);
        request.setAttribute("totalNodes", totalNodes);
        request.setAttribute("activeOutages", activeOutages);
        request.setAttribute("activeMeters", activeMeters);

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}