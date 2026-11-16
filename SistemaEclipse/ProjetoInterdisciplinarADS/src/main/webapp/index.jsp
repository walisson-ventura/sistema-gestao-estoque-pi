<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Usuario" %>
<% Usuario usuarioInicio=(Usuario)session.getAttribute("usuario"); if(usuarioInicio==null){response.sendRedirect("login.jsp");return;} boolean adminInicio="ADMIN".equals(usuarioInicio.getPerfil()); %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Início - Gestão de Estoque</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/dashboard.css" rel="stylesheet">
    <style>
        .welcome-panel { padding: 30px; border-radius: 14px; background: linear-gradient(120deg,#29243d,#222a35 65%); border:1px solid #443765; }
        .welcome-panel h1 { color:#fff; font-size: clamp(25px,3vw,34px); font-weight:800; }
        .welcome-panel p { color:#b7c0ce; max-width:680px; margin:10px 0 0; }
        .module-card { min-height:220px; display:flex; flex-direction:column; }
        .module-icon { width:48px;height:48px;display:grid;place-items:center;border-radius:12px;background:#332b4c;color:#c4b5fd;font-size:23px;margin-bottom:18px; }
        .module-card h3 { color:#f3f4f6;font-size:17px;font-weight:750; }
        .module-card p { color:#9ca3af;font-size:13px;flex:1; }
        .module-card .btn { align-self:flex-start; }
    </style>
</head>
<body class="app-body">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-content">
        <div class="container-fluid page-container">
            <div class="page-heading">
                <div><h1>Painel Inicial</h1><p>Centralize as principais atividades do seu sistema de gestão.</p></div>
                <span class="badge text-bg-success px-3 py-2"><i class="bi bi-shield-check me-1"></i> Sistema ativo</span>
            </div>

            <section class="welcome-panel mb-4">
                <h1>Bem-vindo ao Gestão de Estoque</h1>
                <p>Gerencie clientes, acompanhe seus produtos, controle as movimentações do estoque e registre vendas em um único ambiente.</p>
            </section>

            <div class="page-heading mb-3"><div><h2 style="font-size:18px">Acesso rápido</h2><p>Selecione o módulo que deseja utilizar.</p></div></div>
            <div class="row g-3">
                <div class="col-md-6 col-xl-4">
                    <div class="card module-card"><div class="card-body">
                        <div class="module-icon"><i class="bi bi-people"></i></div>
                        <h3>Clientes</h3><p>Cadastre novos clientes, consulte informações e mantenha sua base organizada.</p>
                        <a href="clientes?action=listar" class="btn btn-primary"><i class="bi bi-arrow-right me-1"></i> Gerenciar clientes</a>
                    </div></div>
                </div>
                <% if(adminInicio){ %>
                <div class="col-md-6 col-xl-4">
                    <div class="card module-card"><div class="card-body">
                        <div class="module-icon"><i class="bi bi-box-seam"></i></div>
                        <h3>Produtos e Estoque</h3><p>Controle seu catálogo, atualize preços e acompanhe as quantidades disponíveis.</p>
                        <a href="produtos?action=listar" class="btn btn-primary"><i class="bi bi-arrow-right me-1"></i> Gerenciar produtos</a>
                    </div></div>
                </div>
                <% } %>
                <div class="col-md-6 col-xl-4">
                    <div class="card module-card"><div class="card-body">
                        <div class="module-icon"><i class="bi bi-cart3"></i></div>
                        <h3>Vendas</h3><p>Selecione clientes, adicione produtos ao carrinho e acompanhe as vendas realizadas.</p>
                        <a href="vendas?action=listar" class="btn btn-primary"><i class="bi bi-arrow-right me-1"></i> Acessar vendas</a>
                    </div></div>
                </div>
                <div class="col-md-6 col-xl-4">
                    <div class="card module-card"><div class="card-body">
                        <div class="module-icon"><i class="bi bi-bar-chart-line"></i></div>
                        <h3>Relatórios</h3><p>Visualize indicadores, gráficos e informações consolidadas do negócio.</p>
                        <a href="relatorios.jsp" class="btn btn-primary"><i class="bi bi-arrow-right me-1"></i> Abrir relatórios</a>
                    </div></div>
                </div>
                <div class="col-md-6 col-xl-4">
                    <div class="card module-card"><div class="card-body">
                        <div class="module-icon"><i class="bi bi-person-gear"></i></div>
                        <h3>Meu Perfil</h3><p>Consulte a área de perfil e as opções de informações pessoais da conta.</p>
                        <a href="perfil.jsp" class="btn btn-primary"><i class="bi bi-arrow-right me-1"></i> Acessar perfil</a>
                    </div></div>
                </div>
            </div>
            <div class="text-secondary small mt-4">Sistema de Controle e Gestão de Estoque</div>
        </div>
    </main>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
