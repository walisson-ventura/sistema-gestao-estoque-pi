<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Usuario" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
 Usuario usuarioPagina = (Usuario) session.getAttribute("usuario");
 if (usuarioPagina == null) { response.sendRedirect("login.jsp"); return; }
 boolean adminPagina = "ADMIN".equals(usuarioPagina.getPerfil());
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Central de Cadastros - Gestão de Estoque</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/assets/css/dashboard.css" rel="stylesheet">
</head>
<body class="app-body">
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<main class="main-content">
<div class="container-fluid page-container">
<div class="page-heading">
    <div>
        <h1>Central de Cadastros</h1>
        <p>Cadastre e edite clientes, fornecedores e vendedores do sistema.</p>
    </div>
</div>

<c:if test="${not empty sessionScope.erroCliente}">
    <div class="alert alert-danger">${sessionScope.erroCliente}</div>
    <% session.removeAttribute("erroCliente"); %>
</c:if>
<c:if test="${not empty sessionScope.sucessoCliente}">
    <div class="alert alert-success">${sessionScope.sucessoCliente}</div>
    <% session.removeAttribute("sucessoCliente"); %>
</c:if>

<div class="row g-4">
    <!-- COLUNA DA ESQUERDA: FORMULÁRIOS -->
    <div class="col-xl-4 col-lg-5">
        <div class="card">
            <div class="card-header"><h5><i class="bi bi-person-plus me-2"></i>Gerenciar Cadastro</h5></div>
            <div class="card-body">

                <div class="mb-3">
                    <label for="tipoCadastro" class="form-label">O que você deseja gerenciar?</label>
                    <select id="tipoCadastro" class="form-select" onchange="alternarCadastro()">
                        <option value="CLIENTE" <%= !"FORNECEDOR".equals(request.getParameter("tipo")) && !"VENDEDOR".equals(request.getParameter("tipo")) ? "selected" : "" %>>Cliente</option>
                        <option value="FORNECEDOR" <%= "FORNECEDOR".equals(request.getParameter("tipo")) ? "selected" : "" %>>Fornecedor</option>
                        <% if(adminPagina){ %>
                        <option value="VENDEDOR" <%= "VENDEDOR".equals(request.getParameter("tipo")) ? "selected" : "" %>>Vendedor</option>
                        <% } %>
                    </select>
                </div>

                <!-- Formulário Cliente -->
                <form id="formCliente" action="${pageContext.request.contextPath}/clientes?action=${empty cliente ? 'inserir' : 'atualizar'}" method="post">
                    <input type="hidden" name="id" value="${cliente.id}">
                    <h6 class="text-light mb-3">${empty cliente ? 'Dados do cliente' : 'Editar cliente'}</h6>
                    <div class="mb-3">
                        <label class="form-label" for="nome">Nome completo *</label>
                        <input class="form-control" id="nome" name="nome" maxlength="150" value="${cliente.nome}" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="cpf">CPF / CNPJ *</label>
                        <input class="form-control" id="cpf" name="cpf" maxlength="20" value="${cliente.cpf}" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="telefone">Contato *</label>
                        <input class="form-control" id="telefone" name="telefone" maxlength="20" value="${cliente.telefone}" required>
                    </div>
                    <button class="btn btn-primary w-100" type="submit">
                        <i class="bi bi-check2-circle me-1"></i>${empty cliente ? 'Salvar cliente' : 'Atualizar cliente'}
                    </button>
                    <c:if test="${not empty cliente}">
                        <a class="btn btn-secondary w-100 mt-2" href="${pageContext.request.contextPath}/clientes">Cancelar edição</a>
                    </c:if>
                </form>

                <!-- Formulário Fornecedor -->
                <form id="formFornecedor" action="${pageContext.request.contextPath}/fornecedores?action=${empty fornecedorEdit ? 'inserir' : 'atualizar'}" method="post" style="display:none">
                    <input type="hidden" name="id" value="${fornecedorEdit.id}">
                    <h6 class="text-light mb-3">${empty fornecedorEdit ? 'Dados do fornecedor' : 'Editar fornecedor'}</h6>
                    <div class="mb-3">
                        <label class="form-label" for="nomeFornecedor">Nome da Empresa *</label>
                        <input class="form-control" id="nomeFornecedor" name="nome" maxlength="150" value="${fornecedorEdit.nome}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="cnpjFornecedor">CNPJ *</label>
                        <input class="form-control" id="cnpjFornecedor" name="cnpj" maxlength="20" value="${fornecedorEdit.cnpj}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="telefoneFornecedor">Telefone *</label>
                        <input class="form-control" id="telefoneFornecedor" name="telefone" maxlength="20" value="${fornecedorEdit.telefone}">
                    </div>
                    <button class="btn btn-success w-100" type="submit">
                        <i class="bi bi-truck me-1"></i>${empty fornecedorEdit ? 'Salvar fornecedor' : 'Atualizar fornecedor'}
                    </button>
                    <c:if test="${not empty fornecedorEdit}">
                        <a class="btn btn-secondary w-100 mt-2" href="${pageContext.request.contextPath}/clientes?action=listar&tipo=FORNECEDOR">Cancelar edição</a>
                    </c:if>
                </form>

                <% if(adminPagina){ %>
                <!-- Formulário Vendedor -->
                <form id="formVendedor" action="${pageContext.request.contextPath}/usuarios" method="post" style="display:none" autocomplete="off">
                    <input type="hidden" name="action" value="${empty vendedorEdit ? 'inserir' : 'atualizar'}">
                    <input type="hidden" name="id" value="${vendedorEdit.id}">
                    <h6 class="text-light mb-3">${empty vendedorEdit ? 'Dados do vendedor' : 'Editar vendedor'}</h6>
                    
                    <div class="mb-3">
                        <label class="form-label" for="nomeVendedor">Nome completo *</label>
                        <input class="form-control" id="nomeVendedor" name="nome" maxlength="150" value="${vendedorEdit.nome}">
                    </div>
                    
                    <c:if test="${empty vendedorEdit}">
                        <div class="mb-3">
                            <label class="form-label" for="cpfVendedor">CPF / Login *</label>
                            <input class="form-control" id="cpfVendedor" name="cpf" maxlength="14" placeholder="000.000.000-00">
                        </div>
                    </c:if>
                    
                    <div class="mb-3">
                        <label class="form-label" for="telefoneVendedor">Contato *</label>
                        <input class="form-control" id="telefoneVendedor" name="telefone" maxlength="20" value="${vendedorEdit.telefone}">
                    </div>
                    
                    <c:if test="${empty vendedorEdit}">
                        <div class="mb-3">
                            <label class="form-label" for="senha">Senha * (mínimo 8 caracteres)</label>
                            <input class="form-control" type="password" id="senha" name="senha" minlength="8">
                        </div>
                        <div class="mb-3">
                            <label class="form-label" for="confirmarSenha">Confirmar senha *</label>
                            <input class="form-control" type="password" id="confirmarSenha" name="confirmarSenha" minlength="8">
                        </div>
                    </c:if>
                    
                    <button class="btn btn-primary w-100" type="submit">
                        <i class="bi bi-person-check me-1"></i>${empty vendedorEdit ? 'Cadastrar vendedor' : 'Atualizar vendedor'}
                    </button>
                    <c:if test="${not empty vendedorEdit}">
                        <a class="btn btn-secondary w-100 mt-2" href="${pageContext.request.contextPath}/clientes?action=listar&tipo=VENDEDOR">Cancelar edição</a>
                    </c:if>
                </form>
                <% } %>

            </div>
        </div>
    </div>

    <!-- COLUNA DA DIREITA: TABELAS DINÂMICAS (SEM OPÇÃO DE EXCLUIR) -->
    <div class="col-xl-8 col-lg-7">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0" id="tituloTabela"><i class="bi bi-people me-2" id="iconeTabela"></i><span id="textoTituloTabela">Clientes cadastrados</span></h5>
            </div>
            <div class="card-body">
                
                <!-- Tabela de Clientes -->
                <div class="table-responsive" id="tabelaClientesDiv">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr><th>ID</th><th>Nome</th><th>CPF/CNPJ</th><th>Contato</th><%if(adminPagina){%><th>Ações</th><%}%></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${listaClientes}">
                                <tr>
                                    <td>${c.id}</td>
                                    <td>${c.nome}</td>
                                    <td>${c.cpf}</td>
                                    <td>${c.telefone}</td>
                                    <%if(adminPagina){%>
                                    <td>
                                        <a class="btn btn-sm btn-outline-primary" href="clientes?action=editar&id=${c.id}">Editar</a>
                                    </td>
                                    <%}%>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty listaClientes}">
                                <tr><td colspan="5" class="text-center text-secondary">Nenhum cliente cadastrado.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Tabela de Fornecedores -->
                <div class="table-responsive" id="tabelaFornecedoresDiv" style="display:none;">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr><th>ID</th><th>Nome da Empresa</th><th>CNPJ</th><th>Telefone</th><th>Ações</th></tr>
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
                                <tr><td colspan="5" class="text-center text-secondary">Nenhum fornecedor cadastrado.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Tabela de Vendedores -->
                <% if(adminPagina){ %>
                <div class="table-responsive" id="tabelaVendedoresDiv" style="display:none;">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr><th>ID</th><th>Nome</th><th>CPF (Login)</th><th>Contato</th><th>Ações</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${listaVendedores}">
                                <tr>
                                    <td>${v.id}</td>
                                    <td>${v.nome}</td>
                                    <td>${v.cpf}</td>
                                    <td>${v.telefone}</td>
                                    <td>
                                        <a class="btn btn-sm btn-outline-primary" href="usuarios?action=editar&id=${v.id}">Editar</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty listaVendedores}">
                                <tr><td colspan="5" class="text-center text-secondary">Nenhum vendedor cadastrado.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
                <% } %>

            </div>
        </div>
    </div>
</div>
</div></main>

<script>
function alternarCadastro() {
    const tipo = document.getElementById('tipoCadastro').value;
    
    const fc = document.getElementById('formCliente');
    const ff = document.getElementById('formFornecedor');
    const fv = document.getElementById('formVendedor');
    
    const tcDiv = document.getElementById('tabelaClientesDiv');
    const tfDiv = document.getElementById('tabelaFornecedoresDiv');
    const tvDiv = document.getElementById('tabelaVendedoresDiv');
    
    const textoTitulo = document.getElementById('textoTituloTabela');
    const iconeTabela = document.getElementById('iconeTabela');

    fc.style.display = tipo === 'CLIENTE' ? 'block' : 'none';
    ff.style.display = tipo === 'FORNECEDOR' ? 'block' : 'none';
    if(fv) fv.style.display = tipo === 'VENDEDOR' ? 'block' : 'none';

    tcDiv.style.display = tipo === 'CLIENTE' ? 'block' : 'none';
    tfDiv.style.display = tipo === 'FORNECEDOR' ? 'block' : 'none';
    if(tvDiv) tvDiv.style.display = tipo === 'VENDEDOR' ? 'block' : 'none';

    fc.querySelectorAll('input[type="text"]').forEach(x => x.required = (tipo === 'CLIENTE'));
    ff.querySelectorAll('input[type="text"]').forEach(x => x.required = (tipo === 'FORNECEDOR'));
    if(fv) fv.querySelectorAll('input[type="text"]').forEach(x => x.required = (tipo === 'VENDEDOR'));

    if (tipo === 'CLIENTE') {
        textoTitulo.textContent = 'Clientes cadastrados';
        iconeTabela.className = 'bi bi-people me-2';
    } else if (tipo === 'FORNECEDOR') {
        textoTitulo.textContent = 'Fornecedores cadastrados';
        iconeTabela.className = 'bi bi-truck me-2';
    } else if (tipo === 'VENDEDOR') {
        textoTitulo.textContent = 'Vendedores cadastrados';
        iconeTabela.className = 'bi bi-person-badge me-2';
    }
}

window.addEventListener('DOMContentLoaded', () => {
    alternarCadastro();
});
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>