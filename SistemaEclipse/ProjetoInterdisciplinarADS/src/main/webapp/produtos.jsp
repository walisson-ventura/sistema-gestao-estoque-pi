<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Usuario" %>
<% Usuario uProdutos=(Usuario)session.getAttribute("usuario"); if(uProdutos==null){response.sendRedirect("login.jsp");return;} if(!"ADMIN".equals(uProdutos.getPerfil())){response.sendError(403);return;} %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gestão de Produtos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/dashboard.css" rel="stylesheet">
</head>
<body class="app-body">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-content">
    <div class="container-fluid page-container">
        <div class="page-heading">
            <div><h1>Gestão de Produtos</h1><p>Acompanhe seu catálogo, custos, preços e estoque.</p></div>
        </div>

        <c:if test="${not empty sessionScope.erroProduto}">
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <strong>Atenção:</strong> ${sessionScope.erroProduto}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% session.removeAttribute("erroProduto"); session.removeAttribute("produtoDuplicadoId"); %>
        </c:if>

        <div class="row">
            <!-- COLUNA DA ESQUERDA: FORMULÁRIO DE CADASTRO / EDIÇÃO -->
            <div class="col-md-4 mb-4">
                <div class="card shadow-sm">
                    <div class="card-header ${empty produtoEdit ? 'bg-success' : 'bg-primary'} text-white">
                        <h5 class="mb-0">${empty produtoEdit ? 'Cadastrar Produto' : 'Editar Produto'}</h5>
                    </div>
                    <div class="card-body">
                        <form action="produtos?action=${empty produtoEdit ? 'inserir' : 'atualizar'}" method="POST">
                            <input type="hidden" name="id" value="${produtoEdit.id}">
                            
                            <div class="mb-3">
                                <label for="nome" class="form-label">Nome do Produto:</label>
                                <input type="text" class="form-control" id="nome" name="nome" value="${produtoEdit.nome}" required>
                            </div>
                            
                            <div class="mb-3">
                                <label for="descricao" class="form-label">Descrição:</label>
                                <textarea class="form-control" id="descricao" name="descricao" rows="2">${produtoEdit.descricao}</textarea>
                            </div>

                            <div class="mb-3">
                                <label for="fornecedorId" class="form-label">Fornecedor:</label>
                                <select class="form-select" id="fornecedorId" name="fornecedorId" required>
                                    <option value="" disabled ${empty produtoEdit ? 'selected' : ''}>Selecione o fornecedor...</option>
                                    <c:forEach var="f" items="${listaFornecedores}">
                                        <option value="${f.id}" ${produtoEdit.fornecedorId == f.id ? 'selected' : ''}>${f.nome}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="custo" class="form-label">Custo (R$):</label>
                                    <input type="number" step="0.01" class="form-control" id="custo" name="custo" value="${produtoEdit.custo}" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="preco" class="form-label">Preço (R$):</label>
                                    <input type="number" step="0.01" class="form-control" id="preco" name="preco" value="${produtoEdit.preco}" required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="quantidade" class="form-label">Quantidade / Estoque:</label>
                                <input type="number" class="form-control" id="quantidade" name="quantidade" min="0" value="${produtoEdit.quantidadeEstoque}" required>
                            </div>
                            
                            <button type="submit" class="w-100 btn ${empty produtoEdit ? 'btn-success' : 'btn-primary'} fw-bold mb-2">
                                ${empty produtoEdit ? 'Salvar Produto' : 'Atualizar Produto'}
                            </button>
                            
                            <c:if test="${not empty produtoEdit}">
                                <a href="produtos" class="w-100 btn btn-secondary fw-bold">Cancelar Edição</a>
                            </c:if>
                        </form>
                    </div>
                </div>
            </div>

            <!-- COLUNA DA DIREITA: TABELA DE ESTOQUE ATUAL -->
            <div class="col-md-8">
                <div class="card shadow-sm">
                    <div class="card-header bg-secondary text-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Estoque Atual</h5>
                        <div class="d-flex align-items-center">
                            <a href="produtos?action=gerarTxtProdutos" class="btn btn-sm btn-success fw-bold me-2 text-decoration-none">
                                <i class="bi bi-file-earmark-text"></i> Exportar TXT
                            </a>
                            <form action="produtos" method="GET" class="d-flex mb-0">
                                <input type="hidden" name="action" value="pesquisar">
                                <input type="text" name="termo" class="form-control form-control-sm me-2" placeholder="Pesquisar produto...">
                                <button class="btn btn-sm btn-light" type="submit">Buscar</button>
                            </form>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover align-middle">
                                <thead class="table-dark">
                                    <tr>
                                        <th>ID</th>
                                        <th>Produto</th>
                                        <th>Fornecedor</th>
                                        <th>Custo</th>
                                        <th>Preço</th>
                                        <th>Estq</th>
                                        <th>Ações</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="p" items="${listaProdutos}">
                                        <tr>
                                            <td>${p.id}</td>
                                            <td>${p.nome}</td>
                                            <td>${empty p.nomeFornecedor ? 'Não vinculado' : p.nomeFornecedor}</td>
                                            <td>R$ ${p.custo}</td>
                                            <td>R$ ${p.preco}</td>
                                            <td>${p.quantidadeEstoque}</td>
                                            <td>
                                                <a href="produtos?action=editar&id=${p.id}" class="btn btn-sm btn-outline-primary fw-bold me-1">Editar</a>
                                                <a href="produtos?action=zerar&id=${p.id}" class="btn btn-sm btn-danger fw-bold" onclick="return confirm('Zerar estoque?')">Zerar</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaProdutos}">
                                        <tr><td colspan="7" class="text-center text-muted">Nenhum produto encontrado.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL DE VISUALIZAÇÃO DO TXT DE PRODUTOS -->
    <c:if test="${param.modal == 'visualizarTxtProdutos'}">
    <div class="modal fade show" tabindex="-1" style="display: block; background: rgba(0,0,0,0.7);" aria-modal="true" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content bg-dark text-light border-secondary">
                <div class="modal-header border-secondary">
                    <h5 class="modal-title"><i class="bi bi-file-earmark-text me-2 text-success"></i>Relatório de Produtos, Custo e Estoque (TXT)</h5>
                    <a href="produtos?action=listar" class="btn-close btn-close-white"></a>
                </div>
                <div class="modal-body">
                    <pre id="textoTxtProdutos" class="form-control bg-black text-success p-3" style="height: 350px; overflow-y: auto; font-family: monospace; font-size: 0.85rem;"><%=session.getAttribute("conteudoTxtProdutos")%></pre>
                </div>
                <div class="modal-footer border-secondary justify-content-between">
                    <button type="button" class="btn btn-outline-light btn-sm" onclick="baixarTxtProdutos()"><i class="bi bi-download"></i> Baixar .TXT</button>
                    <div>
                        <button type="button" class="btn btn-info btn-sm me-2" onclick="imprimirTxtProdutos()"><i class="bi bi-printer"></i> Imprimir</button>
                        <a href="produtos?action=listar" class="btn btn-success btn-sm fw-bold">Concluir</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        function baixarTxtProdutos() {
            const blob = new Blob([document.getElementById("textoTxtProdutos").innerText], { type: "text/plain;charset=utf-8" });
            const link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = "relatorio_produtos_custo.txt";
            link.click();
        }
        function imprimirTxtProdutos() {
            const conteudo = document.getElementById("textoTxtProdutos").innerText;
            const janela = window.open('', '', 'height=500,width=400');
            janela.document.write('<html><head><title>Imprimir Relatório</title></head><body><pre style="font-family:monospace;">' + conteudo + '</pre></body></html>');
            janela.document.close();
            janela.print();
        }
    </script>
    </c:if>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</main>
</body>
</html>