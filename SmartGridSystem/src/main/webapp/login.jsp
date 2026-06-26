<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Grid System - Login</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            justify-content: center;
            align-items: center;
            display: flex;
        }
        .login-container {
            width: 100%;
            max-width: 420px;
            padding: 1rem;
        }
        .login-card {
            border: 1px solid var(--card-border);
            background: var(--card-bg);
            border-radius: 16px;
            padding: 2.5rem;
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.4), 0 0 50px rgba(14, 165, 233, 0.1);
            text-align: center;
        }
        .login-logo {
            font-size: 3rem;
            margin-bottom: 1rem;
            animation: bounce 2s infinite ease-in-out;
        }
        .login-title {
            font-size: 1.75rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--neon-blue) 0%, var(--neon-purple) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
        }
        .login-subtitle {
            color: var(--text-secondary);
            font-size: 0.9rem;
            margin-bottom: 2rem;
        }
        .error-message {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: var(--accent-red);
            padding: 0.75rem;
            border-radius: 8px;
            font-size: 0.85rem;
            margin-bottom: 1.5rem;
            font-weight: 500;
        }
        .form-group-login {
            text-align: left;
            margin-bottom: 1.25rem;
        }
        .form-group-login label {
            display: block;
            margin-bottom: 0.5rem;
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .btn-login {
            width: 100%;
            margin-top: 1rem;
            padding: 0.8rem;
        }
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="login-logo">⚡</div>
            <h1 class="login-title">Smart Grid System</h1>
            <p class="login-subtitle">Control Room Portal Authentication</p>
            
            <% 
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <div class="error-message">
                    <%= error %>
                </div>
            <% 
                }
            %>
            
            <form action="login" method="post">
                <div class="form-group-login">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" class="form-control" placeholder="Enter operator/admin name" required autocomplete="off">
                </div>
                <div class="form-group-login">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>
                <button type="submit" class="btn btn-primary btn-login">Authorize Connection</button>
            </form>
        </div>
    </div>
</body>
</html>
