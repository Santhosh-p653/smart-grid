package controller;

import model.FaultRecord;
import model.GridNode;
import util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/faults")
public class FaultServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        List<FaultRecord> faults = new ArrayList<>();
        List<GridNode> activeNodes = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            // Fetch faults
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT f.*, n.node_name FROM fault_records f LEFT JOIN grid_nodes n ON f.node_id = n.node_id ORDER BY f.reported_at DESC");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FaultRecord f = new FaultRecord();
                    f.setFaultId(rs.getInt("fault_id"));
                    f.setNodeId(rs.getInt("node_id"));
                    f.setNodeName(rs.getString("node_name") != null ? rs.getString("node_name") : "Unknown Node");
                    f.setFaultType(rs.getString("fault_type"));
                    f.setDescription(rs.getString("description"));
                    f.setStatus(rs.getString("status"));
                    f.setReportedAt(rs.getTimestamp("reported_at"));
                    f.setResolvedAt(rs.getTimestamp("resolved_at"));
                    faults.add(f);
                }
            }
            // Fetch nodes
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM grid_nodes");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GridNode gn = new GridNode();
                    gn.setNodeId(rs.getInt("node_id"));
                    gn.setNodeName(rs.getString("node_name"));
                    activeNodes.add(gn);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        request.setAttribute("faults", faults);
        request.setAttribute("nodes", activeNodes);
        request.getRequestDispatcher("faults.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if ("log".equals(action)) {
            int nodeId = Integer.parseInt(request.getParameter("nodeId"));
            String faultType = request.getParameter("faultType");
            String desc = request.getParameter("description");

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    // Insert Fault
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO fault_records (node_id, fault_type, description, status) VALUES (?, ?, ?, 'OPEN')")) {
                        ps.setInt(1, nodeId);
                        ps.setString(2, faultType);
                        ps.setString(3, desc);
                        ps.executeUpdate();
                    }
                    // Trigger Node Status Update
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE grid_nodes SET status='FAULT' WHERE node_id=?")) {
                        ps.setInt(1, nodeId);
                        ps.executeUpdate();
                    }
                    conn.commit();
                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if ("resolve".equals(action)) {
            int faultId = Integer.parseInt(request.getParameter("faultId"));
            int nodeId = Integer.parseInt(request.getParameter("nodeId"));

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    // Resolve Fault
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE fault_records SET status='RESOLVED', resolved_at=CURRENT_TIMESTAMP WHERE fault_id=?")) {
                        ps.setInt(1, faultId);
                        ps.executeUpdate();
                    }
                    // Reset Node Status if no other open faults
                    boolean hasOtherOpen = false;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "SELECT COUNT(*) FROM fault_records WHERE node_id=? AND status='OPEN'")) {
                        ps.setInt(1, nodeId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next() && rs.getInt(1) > 0) {
                                hasOtherOpen = true;
                            }
                        }
                    }
                    if (!hasOtherOpen) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "UPDATE grid_nodes SET status='ACTIVE' WHERE node_id=?")) {
                            ps.setInt(1, nodeId);
                            ps.executeUpdate();
                        }
                    }
                    conn.commit();
                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect("faults");
    }
}
