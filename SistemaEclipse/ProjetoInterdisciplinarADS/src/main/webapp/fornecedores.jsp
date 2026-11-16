<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Fornecedores - Gestão de Estoque</title>
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
                    <h1>Fornecedores</h1>
                    <p>Consulte, pesquise e edite fornecedores parceiros.</p>
                </div>
            </div>

            <c:if test="${not empty sessionScope.erroFornecedor}">
                <div class="alert alert-danger">${sessionScope.erroFornecedor}</div>
                <% session.removeAttribute("erroFornecedor"); %>
            </c:if>
            <c:if test="${not empty sessionScope.sucessoFornecedor}">
                <div class="alert alert-success">${sessionScope.sucessoFornecedor}</div>
                <% session.removeAttribute("sucessoFornecedor"); %>
            </c:if>

            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-truck me-2"></i>Fornecedores Cadastrados</h5>
                    <form action="fornecedores" method="GET" class="d-flex">
                        <input type="hidden" name="action" value="pesquisar">
                        <input type="text" name="termo" class="form-control form-control-sm me-2" placeholder="Buscar fornecedor...">
                        <button class="btn btn-sm btn-light" type="submit">Buscar</button>
                    </form>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Nome da Empresa</th>
                                    <th>CNPJ</th>
                                    <th>Telefone</th>
                                    <th>Ações</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="f" items="${listaFornecedores}">
                                    <tr>
                                        <td>${f.id}</td>
                                        <td>${f.nome}</td>
                                        <td>${f.cnpj}</td>
                                        <td>${f.telefone}</td>
                                        <td>
                                            <a class="btn btn-sm btn-outline-primary" href="fornecedores?action=editar&id=${f.id}">Editar</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty listaFornecedores}">
                                    <tr>
                                        <td colspan="5" class="text-center text-secondary">Nenhum fornecedor cadastrado.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>