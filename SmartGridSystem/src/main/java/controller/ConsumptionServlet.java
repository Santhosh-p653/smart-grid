package controller;

import model.ConsumptionRecord;
import model.Consumer;
import util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/consumption")
public class ConsumptionServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        List<ConsumptionRecord> histories = new ArrayList<>();
        List<Consumer> consumers = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT ch.*, c.consumer_name, c.meter_id FROM consumption_history ch JOIN consumers c ON ch.consumer_id = c.consumer_id ORDER BY ch.reading_date DESC");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ConsumptionRecord r = new ConsumptionRecord();
                    r.setHistoryId(rs.getInt("history_id"));
                    r.setConsumerId(rs.getInt("consumer_id"));
                    r.setConsumerName(rs.getString("consumer_name"));
                    r.setMeterId(rs.getInt("meter_id"));
                    r.setKwhConsumed(rs.getDouble("kwh_consumed"));
                    r.setReadingDate(rs.getDate("reading_date"));
                    histories.add(r);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM consumers");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Consumer c = new Consumer();
                    c.setConsumerId(rs.getInt("consumer_id"));
                    c.setConsumerName(rs.getString("consumer_name"));
                    c.setMeterId(rs.getInt("meter_id"));
                    consumers.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("histories", histories);
        request.setAttribute("consumers", consumers);
        request.getRequestDispatcher("consumption.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        int consumerId = Integer.parseInt(request.getParameter("consumerId"));
        double kwh = Double.parseDouble(request.getParameter("kwhConsumed"));
        Date date = Date.valueOf(request.getParameter("readingDate"));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO consumption_history (consumer_id, kwh_consumed, reading_date) VALUES (?, ?, ?)")) {
            ps.setInt(1, consumerId);
            ps.setDouble(2, kwh);
            ps.setDate(3, date);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        response.sendRedirect("consumption");
    }
}
