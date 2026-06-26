package controller;

import model.GridNode;
import model.User;
import util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/grids")
public class GridManagementServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        List<GridNode> nodeList = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM grid_nodes ORDER BY node_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                GridNode n = new GridNode();
                n.setNodeId(rs.getInt("node_id"));
                n.setNodeName(rs.getString("node_name"));
                n.setZone(rs.getString("zone"));
                n.setStatus(rs.getString("status"));
                n.setCapacityKw(rs.getDouble("capacity_kw"));
                nodeList.add(n);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        request.setAttribute("nodes", nodeList);
        request.getRequestDispatcher("grids.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (!"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only admins can modify grid nodes.");
            return;
        }

        String name = request.getParameter("nodeName");
        String zone = request.getParameter("zone");
        String capacityStr = request.getParameter("capacityKw");
        String status = request.getParameter("status");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO grid_nodes (node_name, zone, status, capacity_kw) VALUES (?, ?, ?, ?)")) {
            ps.setString(1, name);
            ps.setString(2, zone);
            ps.setString(3, status);
            ps.setDouble(4, Double.parseDouble(capacityStr));
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("grids");
    }
}
