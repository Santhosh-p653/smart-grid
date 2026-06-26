package controller;

import util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        Map<String, Object> stats = new HashMap<>();

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Total Consumption
            try (PreparedStatement ps = conn.prepareStatement("SELECT SUM(kwh_consumed) FROM consumption_history");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("totalKwh", rs.getDouble(1));
            }
            // 2. Active Fault Count
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM fault_records WHERE status='OPEN'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("openFaults", rs.getInt(1));
            }
            // 3. Active Outage Count
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM outage_records WHERE status='ACTIVE'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("activeOutages", rs.getInt(1));
            }

            // 4. Fault distribution by type
            List<Map<String, Object>> faultTypes = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT fault_type, COUNT(*) as cnt FROM fault_records GROUP BY fault_type");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("type", rs.getString("fault_type"));
                    item.put("count", rs.getInt("cnt"));
                    faultTypes.add(item);
                }
            }
            stats.put("faultTypes", faultTypes);

            // 5. High Load Readings
            List<Map<String, Object>> highLoads = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT pr.*, gn.node_name FROM power_readings pr JOIN grid_nodes gn ON pr.node_id = gn.node_id WHERE pr.power_kw > gn.capacity_kw ORDER BY pr.reading_time DESC LIMIT 10");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> load = new HashMap<>();
                    load.put("node", rs.getString("node_name"));
                    load.put("power", rs.getDouble("power_kw"));
                    load.put("time", rs.getTimestamp("reading_time"));
                    highLoads.add(load);
                }
            }
            stats.put("highLoads", highLoads);

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("stats", stats);
        request.getRequestDispatcher("analytics.jsp").forward(request, response);
    }
}
