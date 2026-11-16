<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Usuario" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
 Usuario uPerfil = (Usuario) session.getAttribute("usuario");
 if (uPerfil == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Meu Perfil - Gestão de Estoque</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/dashboard.css" rel="stylesheet">
</head>
<body class="app-body">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

    <main class="main-content">
    <div class="container-fluid page-container">
        <div class="page-heading">
            <div>
                <h1>Meu Perfil</h1>
                <p>Gerencie suas informações pessoais e configurações de acesso.</p>
            </div>
        </div>
        
        <div class="row justify-content-center">
            <div class="col-md-8">
                
                <!-- Alertas de Informações Pessoais -->
                <c:if test="${not empty sessionScope.erroPerfil}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <strong>Atenção:</strong> ${sessionScope.erroPerfil}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <% session.removeAttribute("erroPerfil"); %>
                </c:if>
                <c:if test="${not empty sessionScope.sucessoPerfil}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <strong>Sucesso:</strong> ${sessionScope.sucessoPerfil}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <% session.removeAttribute("sucessoPerfil"); %>
                </c:if>

                <!-- Informações Pessoais -->
                <div class="card shadow-sm mb-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><i class="bi bi-person-badge me-2"></i>Informações Pessoais</h5>
                    </div>
                    <div class="card-body">
                        <form action="PerfilController" method="POST">
                            <div class="mb-3">
                                <label class="form-label">Nome Completo:</label>
                                <input type="text" class="form-control" name="nome" value="${uPerfil.nome}" required maxlength="150">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">CPF / Login (Identificação):</label>
                                <input type="text" class="form-control bg-light" value="${uPerfil.cpf}" disabled readonly>
                                <div class="form-text text-muted">O CPF/Login não pode ser alterado por motivos de segurança.</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Número Pessoal (Telefone / Contato):</label>
                                <input type="text" class="form-control" name="telefone" value="${uPerfil.telefone}" maxlength="20" placeholder="(00) 00000-0000">
                            </div>
                            <button type="submit" class="btn btn-primary">Salvar Alterações Pessoais</button>
                        </form>
                    </div>
                </div>

                <!-- Alertas de Senha -->
                <c:if test="${not empty sessionScope.erroSenha}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <strong>Atenção:</strong> ${sessionScope.erroSenha}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <% session.removeAttribute("erroSenha"); %>
                </c:if>
                <c:if test="${not empty sessionScope.sucessoSenha}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <strong>Sucesso:</strong> ${sessionScope.sucessoSenha}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <% session.removeAttribute("sucessoSenha"); %>
                </c:if>

                <!-- Privacidade e Segurança (Alterar Senha com 3 campos) -->
                <div class="card shadow-sm mb-4">
                    <div class="card-header bg-secondary text-white">
                        <h5 class="mb-0"><i class="bi bi-shield-lock me-2"></i>Segurança - Alterar Senha</h5>
                    </div>
                    <div class="card-body">
                        <form action="SenhaController" method="POST" id="formSenha">
                            <div class="mb-3">
                                <label class="form-label">Senha Atual *:</label>
                                <input type="password" class="form-control" name="senhaAtual" required autocomplete="current-password" placeholder="Digite sua senha atual">
                            </div>
                            <hr>
                            <div class="mb-3">
                                <label class="form-label">Nova Senha * (mínimo de 8 caracteres):</label>
                                <input type="password" class="form-control" id="novaSenha" name="novaSenha" required minlength="8" autocomplete="new-password" placeholder="Digite a nova senha">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Confirmar Nova Senha *:</label>
                                <input type="password" class="form-control" id="confirmarSenha" name="confirmarSenha" required minlength="8" autocomplete="new-password" placeholder="Repita a nova senha">
                            </div>
                            <button type="submit" class="btn btn-secondary">Atualizar Senha</button>
                        </form>
                    </div>
                </div>

                <!-- Ação de Sair -->
                <div class="card shadow-sm border-danger mb-5">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="text-danger mb-1">Encerrar Sessão</h5>
                            <p class="text-muted small mb-0">Deslogar da sua conta neste dispositivo.</p>
                        </div>
                        <a href="LoginController" class="btn btn-danger px-4">Sair do Perfil</a>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Script de validação visual para conferência rápida de senhas no navegador -->
    <script>
        document.getElementById('formSenha').addEventListener('submit', function(e) {
            const nova = document.getElementById('novaSenha').value;
            const confirma = document.getElementById('confirmarSenha').value;
            if (nova !== confirma) {
                e.preventDefault();
                alert('A nova senha e a confirmação precisam ser exatamente iguais.');
            }
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</main>
</body>
</html>