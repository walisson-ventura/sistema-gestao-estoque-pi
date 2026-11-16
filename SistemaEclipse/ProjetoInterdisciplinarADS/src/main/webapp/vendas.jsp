<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="model.Usuario" %>
<% 
    Usuario uVendas = (Usuario) session.getAttribute("usuario"); 
    if(uVendas == null) { response.sendRedirect("login.jsp"); return; } 
    if(!("ADMIN".equals(uVendas.getPerfil()) || "VENDEDOR".equals(uVendas.getPerfil()))) { response.sendError(403); return; } 
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registar Vendas - Carrinho</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/dashboard.css" rel="stylesheet">
</head>
<body class="app-body">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

    <main class="main-content">
    <div class="container-fluid page-container">
        <div class="page-heading">
            <div><h1>Gestão de Vendas</h1><p>Monte carrinhos, finalize operações e consulte o histórico.</p></div>
        </div>

        <c:if test="${not empty sessionScope.erroVenda}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <strong>Atenção:</strong> ${sessionScope.erroVenda}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% session.removeAttribute("erroVenda"); %>
        </c:if>

        <div class="row">
            <!-- Coluna Esquerda -->
            <div class="col-md-4 mb-4">
                <!-- 1. Cliente -->
                <div class="card shadow-sm mb-3">
                    <div class="card-header bg-dark text-white"><h5 class="mb-0">1. Cliente da Venda</h5></div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty sessionScope.clienteSelecionado}">
                                <form action="vendas?action=selecionarCliente" method="POST">
                                    <div class="mb-3">
                                        <select class="form-select" name="clienteId" onchange="this.form.submit()" required>
                                            <option value="" selected disabled>Selecione o cliente...</option>
                                            <c:forEach var="c" items="${listaClientes}">
                                                <option value="${c.id}">${c.nome}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <!-- Botão "Trocar" removido conforme solicitado -->
                                <div class="alert alert-success mb-0">
                                    <strong>Cliente:</strong> ${sessionScope.clienteSelecionado.nome}
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- 2. Vendedor -->
                <div class="card shadow-sm mb-3">
                    <div class="card-header bg-secondary text-white"><h5 class="mb-0">2. Vendedor Responsável</h5></div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${not empty sessionScope.clienteSelecionado && empty sessionScope.vendedorSelecionado}">
                                <form action="vendas?action=selecionarVendedor" method="POST">
                                    <div class="mb-3">
                                        <select class="form-select" name="vendedorId" onchange="this.form.submit()" required>
                                            <option value="" selected disabled>Selecione o vendedor...</option>
                                            <c:forEach var="v" items="${listaUsuarios}">
                                                <option value="${v.id}">${v.nome} (${v.perfil})</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </form>
                            </c:when>
                            <c:when test="${not empty sessionScope.vendedorSelecionado}">
                                <!-- Botão "Trocar" removido conforme solicitado -->
                                <div class="alert alert-info mb-0">
                                    <strong>Vendedor:</strong> ${sessionScope.vendedorSelecionado.nome}
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center text-muted py-2"><small>Selecione o cliente primeiro.</small></div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- 3. Produtos -->
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white"><h5 class="mb-0">3. Adicionar ao Carrinho</h5></div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${not empty sessionScope.clienteSelecionado && not empty sessionScope.vendedorSelecionado}">
                                <form action="vendas?action=adicionar" method="POST">
                                    <div class="mb-3">
                                        <label class="form-label">Produto:</label>
                                        <select class="form-select" name="produtoId" required>
                                            <option value="" selected disabled>Selecione o produto...</option>
                                            <c:forEach var="p" items="${listaProdutos}">
                                                <c:if test="${p.quantidadeEstoque >= 1}">
                                                    <option value="${p.id}">${p.nome} (R$ ${p.preco} | Est: ${p.quantidadeEstoque})</option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Quantidade:</label>
                                        <input type="number" class="form-control" name="quantidade" value="1" min="1" required>
                                    </div>
                                    <button type="submit" class="w-100 btn btn-primary fw-bold">Adicionar Item</button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center text-muted py-3">
                                    <p class="mb-0"><strong>Selecione cliente e vendedor</strong> para liberar produtos.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Coluna Direita -->
            <div class="col-md-8">
                <div class="card shadow-sm mb-4">
                    <div class="card-header bg-warning text-dark d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            Carrinho de Compras Atual
                            <c:if test="${not empty sessionScope.clienteSelecionado}"><span class="badge bg-dark ms-2">Cliente: ${sessionScope.clienteSelecionado.nome}</span></c:if>
                            <c:if test="${not empty sessionScope.vendedorSelecionado}"><span class="badge bg-secondary ms-1">Vd: ${sessionScope.vendedorSelecionado.nome}</span></c:if>
                        </h5>
                        <c:if test="${not empty sessionScope.clienteSelecionado || not empty sessionScope.carrinho}">
                            <a href="vendas?action=cancelar" class="btn btn-sm btn-danger fw-bold">Cancelar Venda</a>
                        </c:if>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive mb-3">
                            <table class="table table-striped table-hover align-middle">
                                <thead class="table-dark">
                                    <tr><th>Produto</th><th>Preço Unit.</th><th>Qtd</th><th>Subtotal</th><th>Ações</th></tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${sessionScope.carrinho}">
                                        <tr>
                                            <td>${item.produto.nome}</td>
                                            <td>R$ ${item.precoUnitario}</td>
                                            <td>
                                                <form action="vendas?action=alterar" method="POST" class="d-inline-flex">
                                                    <input type="hidden" name="produtoId" value="${item.produto.id}">
                                                    <input type="number" name="quantidade" value="${item.quantidade}" min="1" class="form-control form-control-sm me-1" style="width: 70px;">
                                                    <button type="submit" class="btn btn-sm btn-outline-secondary" title="Atualizar">🔄</button>
                                                </form>
                                            </td>
                                            <td>R$ ${item.subtotal}</td>
                                            <td><a href="vendas?action=remover&produtoId=${item.produto.id}" class="btn btn-sm btn-danger">Excluir</a></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty sessionScope.carrinho}">
                                        <tr><td colspan="5" class="text-center text-muted">Carrinho vazio.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>

                        <!-- Botão Forma de Pagamento -->
                        <div class="card bg-light border-success">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-md-4">
                                        <span class="text-muted d-block small">TOTAL DA VENDA</span>
                                        <h4 class="text-success mb-0">R$ ${totalCarrinho}</h4>
                                    </div>
                                    <div class="col-md-8">
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.carrinho && not empty sessionScope.clienteSelecionado && not empty sessionScope.vendedorSelecionado}">
                                                <a href="vendas?action=abrirModalPagamento" class="w-100 btn btn-success fw-bold py-2 text-decoration-none">Forma de Pagamento</a>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="w-100 btn btn-secondary fw-bold py-2" disabled>Forma de Pagamento</button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Histórico -->
                <div class="card shadow-sm">
                    <div class="card-header bg-secondary text-white"><h5 class="mb-0">Vendas Realizadas (Histórico)</h5></div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover align-middle">
                                <thead class="table-dark"><tr><th>ID</th><th>Data</th><th>Cliente / Nota</th><th>Valor Total</th></tr></thead>
                                <tbody>
                                    <c:forEach var="v" items="${listaVendas}">
                                        <tr>
                                            <td>${v.id}</td>
                                            <td>${v.data}</td>
                                            <td>
                                                ${v.cliente.nome}
                                                <a href="vendas?action=emitirNotaHistorico&id=${v.id}" class="text-info ms-2 text-decoration-none" title="Emitir/Ver Nota Fiscal da Venda">
                                                    <i class="bi bi-file-earmark-text-fill fs-5"></i>
                                                </a>
                                            </td>
                                            <td>R$ ${v.valorTotal}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaVendas}"><tr><td colspan="4" class="text-center text-muted">Nenhuma venda registrada.</td></tr></c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL 1: SELECIONAR MÉTODO DE PAGAMENTO -->
    <c:if test="${param.modal == 'pagamento'}">
    <div class="modal fade show" tabindex="-1" style="display: block; background: rgba(0,0,0,0.7);" aria-modal="true" role="dialog">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content bg-dark text-light border-secondary">
                <div class="modal-header border-secondary">
                    <h5 class="modal-title"><i class="bi bi-wallet2 me-2 text-warning"></i>Selecione a Forma de Pagamento</h5>
                    <a href="vendas?action=listar" class="btn-close btn-close-white"></a>
                </div>
                <div class="modal-body text-center py-4">
                    <div class="d-grid gap-3 col-8 mx-auto">
                        <a href="vendas?action=selecionarMetodo&metodo=PIX" class="btn btn-outline-light btn-lg">PIX</a>
                        <a href="vendas?action=selecionarMetodo&metodo=Debito" class="btn btn-outline-light btn-lg">Débito</a>
                        <a href="vendas?action=selecionarMetodo&metodo=Credito" class="btn btn-outline-light btn-lg">Crédito</a>
                        <a href="vendas?action=selecionarMetodo&metodo=Dinheiro" class="btn btn-outline-light btn-lg">Dinheiro</a>
                    </div>
                </div>
                <div class="modal-footer border-secondary justify-content-center">
                    <a href="vendas?action=cancelar" class="btn btn-danger btn-sm">Cancelar venda</a>
                </div>
            </div>
        </div>
    </div>
    </c:if>

    <!-- MODAL 2: CONFIRMAÇÃO DA VENDA -->
    <c:if test="${param.modal == 'confirmacao'}">
    <div class="modal fade show" tabindex="-1" style="display: block; background: rgba(0,0,0,0.7);" aria-modal="true" role="dialog">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content bg-dark text-light border-secondary">
                <div class="modal-header border-secondary">
                    <h5 class="modal-title"><i class="bi bi-check-circle me-2 text-success"></i>Confirmar Pagamento</h5>
                    <a href="vendas?action=listar" class="btn-close btn-close-white"></a>
                </div>
                <div class="modal-body text-center py-4">
                    <p class="text-secondary mb-1">Método Escolhido:</p>
                    <h3 class="text-warning mb-3">${sessionScope.metodoPagamento}</h3>
                    <p class="text-secondary mb-1">Total a Pagar:</p>
                    <h4 class="text-success fw-bold">R$ ${totalCarrinho}</h4>
                </div>
                <div class="modal-footer border-secondary justify-content-between">
                    <a href="vendas?action=abrirModalPagamento" class="btn btn-outline-warning btn-sm">Mudar forma de pagamento</a>
                    <div>
                        <a href="vendas?action=cancelar" class="btn btn-danger btn-sm me-2">Cancelar venda</a>
                        <a href="vendas?action=processarFinalizacao" class="btn btn-success btn-sm fw-bold">Finalizar Venda</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </c:if>

    <!-- MODAL 3: EMITIR NOTA (SIM / NÃO) -->
    <c:if test="${param.modal == 'emitirNota'}">
    <div class="modal fade show" tabindex="-1" style="display: block; background: rgba(0,0,0,0.7);" aria-modal="true" role="dialog">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content bg-dark text-light border-secondary">
                <div class="modal-header border-secondary">
                    <h5 class="modal-title"><i class="bi bi-receipt me-2 text-info"></i>Emissão de Comprovante</h5>
                </div>
                <div class="modal-body text-center py-4">
                    <h5 class="mb-3">Deseja emitir nota fiscal/recibo da venda?</h5>
                    <p class="text-muted small">Venda finalizada com sucesso e estoque atualizado!</p>
                </div>
                <div class="modal-footer border-secondary justify-content-center">
                    <a href="vendas?action=gerarNotaTxt" class="btn btn-success px-4 me-3">Sim</a>
                    <a href="vendas?action=listar" class="btn btn-secondary px-4">Não</a>
                </div>
            </div>
        </div>
    </div>
    </c:if>

    <!-- MODAL 4: VISUALIZAÇÃO DO TXT DA NOTA -->
    <c:if test="${param.modal == 'visualizarNota'}">
    <div class="modal fade show" tabindex="-1" style="display: block; background: rgba(0,0,0,0.7);" aria-modal="true" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content bg-dark text-light border-secondary">
                <div class="modal-header border-secondary">
                    <h5 class="modal-title"><i class="bi bi-file-earmark-text me-2 text-success"></i>Cupom Fiscal / Nota</h5>
                    <a href="vendas?action=listar" class="btn-close btn-close-white"></a>
                </div>
                <div class="modal-body">
                    <pre id="textoCupom" class="form-control bg-black text-success p-3" style="height: 350px; overflow-y: auto; font-family: monospace; font-size: 0.85rem;"><%=session.getAttribute("conteudoCupomTxt")%></pre>
                </div>
                <div class="modal-footer border-secondary justify-content-between">
                    <button type="button" class="btn btn-outline-light btn-sm" onclick="baixarTxt()"><i class="bi bi-download"></i> Baixar .TXT</button>
                    <div>
                        <button type="button" class="btn btn-info btn-sm me-2" onclick="imprimirCupom()"><i class="bi bi-printer"></i> Imprimir</button>
                        <a href="vendas?action=listar" class="btn btn-success btn-sm fw-bold">Concluir</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        function baixarTxt() {
            const blob = new Blob([document.getElementById("textoCupom").innerText], { type: "text/plain;charset=utf-8" });
            const link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = "cupom_fiscal.txt";
            link.click();
        }
        function imprimirCupom() {
            const conteudo = document.getElementById("textoCupom").innerText;
            const janela = window.open('', '', 'height=500,width=400');
            janela.document.write('<html><head><title>Imprimir Cupom</title></head><body><pre style="font-family:monospace;">' + conteudo + '</pre></body></html>');
            janela.document.close();
            janela.print();
        }
    </script>
    </c:if>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </main>
</body>
</html>