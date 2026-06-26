package controller;

import model.OutageRecord;
import model.GridNode;
import util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/outages")
public class OutageServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        List<OutageRecord> outages = new ArrayList<>();
        List<GridNode> nodes = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT o.*, n.node_name FROM outage_records o LEFT JOIN grid_nodes n ON o.node_id = n.node_id ORDER BY o.started_at DESC");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OutageRecord o = new OutageRecord();
                    o.setOutageId(rs.getInt("outage_id"));
                    o.setNodeId(rs.getInt("node_id"));
                    o.setNodeName(rs.getString("node_name") != null ? rs.getString("node_name") : "Unknown Node");
                    o.setOutageType(rs.getString("outage_type"));
                    o.setDescription(rs.getString("description"));
                    o.setStatus(rs.getString("status"));
                    o.setStartedAt(rs.getTimestamp("started_at"));
                    o.setRestoredAt(rs.getTimestamp("restored_at"));
                    outages.add(o);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM grid_nodes");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GridNode n = new GridNode();
                    n.setNodeId(rs.getInt("node_id"));
                    n.setNodeName(rs.getString("node_name"));
                    nodes.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("outages", outages);
        request.setAttribute("nodes", nodes);
        request.getRequestDispatcher("outages.jsp").forward(request, response);
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
            String outageType = request.getParameter("outageType");
            String desc = request.getParameter("description");

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "INSERT INTO outage_records (node_id, outage_type, description, status) VALUES (?, ?, ?, 'ACTIVE')")) {
                ps.setInt(1, nodeId);
                ps.setString(2, outageType);
                ps.setString(3, desc);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if ("restore".equals(action)) {
            int outageId = Integer.parseInt(request.getParameter("outageId"));

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "UPDATE outage_records SET status='RESTORED', restored_at=CURRENT_TIMESTAMP WHERE outage_id=?")) {
                ps.setInt(1, outageId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect("outages");
    }
}
