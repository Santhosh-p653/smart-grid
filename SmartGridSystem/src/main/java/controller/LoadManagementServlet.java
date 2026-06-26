package controller;

import model.PowerReading;
import model.GridNode;
import util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/load")
public class LoadManagementServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        List<PowerReading> readings = new ArrayList<>();
        List<GridNode> nodes = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT pr.*, gn.node_name FROM power_readings pr JOIN grid_nodes gn ON pr.node_id = gn.node_id ORDER BY pr.reading_time DESC LIMIT 50");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PowerReading pr = new PowerReading();
                    pr.setReadingId(rs.getInt("reading_id"));
                    pr.setNodeId(rs.getInt("node_id"));
                    pr.setNodeName(rs.getString("node_name"));
                    pr.setVoltage(rs.getDouble("voltage"));
                    pr.setCurrentDraw(rs.getDouble("current_draw"));
                    pr.setPowerKw(rs.getDouble("power_kw"));
                    pr.setReadingTime(rs.getTimestamp("reading_time"));
                    readings.add(pr);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM grid_nodes");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GridNode gn = new GridNode();
                    gn.setNodeId(rs.getInt("node_id"));
                    gn.setNodeName(rs.getString("node_name"));
                    gn.setCapacityKw(rs.getDouble("capacity_kw"));
                    gn.setStatus(rs.getString("status"));
                    nodes.add(gn);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("readings", readings);
        request.setAttribute("nodes", nodes);
        request.getRequestDispatcher("load.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        int nodeId = Integer.parseInt(request.getParameter("nodeId"));
        double voltage = Double.parseDouble(request.getParameter("voltage"));
        double current = Double.parseDouble(request.getParameter("currentDraw"));
        // Power (kW) = (Voltage * Current) / 1000
        double power = (voltage * current) / 1000.0;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Log power reading
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO power_readings (node_id, voltage, current_draw, power_kw) VALUES (?, ?, ?, ?)")) {
                    ps.setInt(1, nodeId);
                    ps.setDouble(2, voltage);
                    ps.setDouble(3, current);
                    ps.setDouble(4, power);
                    ps.executeUpdate();
                }

                // Check capacity
                double capacity = 0;
                try (PreparedStatement ps = conn.prepareStatement("SELECT capacity_kw FROM grid_nodes WHERE node_id = ?")) {
                    ps.setInt(1, nodeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            capacity = rs.getDouble("capacity_kw");
                        }
                    }
                }

                if (power > capacity) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE grid_nodes SET status='OVERLOADED' WHERE node_id=?")) {
                        ps.setInt(1, nodeId);
                        ps.executeUpdate();
                    }
                } else {
                    // Update back to Active if currently overloaded
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE grid_nodes SET status='ACTIVE' WHERE node_id=? AND status='OVERLOADED'")) {
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
        response.sendRedirect("load");
    }
}
