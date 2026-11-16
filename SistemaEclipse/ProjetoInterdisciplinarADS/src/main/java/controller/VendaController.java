package controller;

import dao.ClienteDAO;
import dao.ProdutoDAO;
import dao.UsuarioDAO;
import dao.VendaDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cliente;
import model.ItemVenda;
import model.Produto;
import model.Venda;
import model.Usuario;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@WebServlet(value = {"/vendas", "/VendaController"})
public class VendaController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VendaDAO vendaDAO;
    private ClienteDAO clienteDAO;
    private ProdutoDAO produtoDAO;
    private UsuarioDAO usuarioDAO;

    public void init() {
        vendaDAO = new VendaDAO();
        clienteDAO = new ClienteDAO();
        produtoDAO = new ProdutoDAO();
        usuarioDAO = new UsuarioDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        if (usuario == null || !("ADMIN".equals(usuario.getPerfil()) || "VENDEDOR".equals(usuario.getPerfil()))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
        }
        String action = request.getParameter("action");
        if (action == null) action = "listar";

        try {
            switch (action) {
                case "selecionarCliente": selecionarCliente(request, response); break;
                case "selecionarVendedor": selecionarVendedor(request, response); break;
                case "trocarVendedor": trocarVendedor(request, response); break;
                case "adicionar": adicionarAoCarrinho(request, response); break;
                case "alterar": alterarQuantidadeCarrinho(request, response); break;
                case "remover": removerDoCarrinho(request, response); break;
                case "cancelar": cancelarVenda(request, response); break;
                case "abrirModalPagamento": response.sendRedirect("vendas?action=listar&modal=pagamento"); break;
                case "selecionarMetodo": selecionarMetodoPagamento(request, response); break;
                case "processarFinalizacao": processarFinalizacaoVenda(request, response); break;
                case "gerarNotaTxt": response.sendRedirect("vendas?action=listar&modal=visualizarNota"); break;
                case "emitirNotaHistorico": emitirNotaHistorico(request, response); break;
                default: carregarTela(request, response); break;
            }
        } catch (SQLException | RuntimeException ex) {
            HttpSession session = request.getSession();
            session.setAttribute("erroVenda", ex.getMessage());
            response.sendRedirect("vendas?action=listar");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    @SuppressWarnings("unchecked")
    private List<ItemVenda> getCarrinho(HttpSession session) {
        List<ItemVenda> carrinho = (List<ItemVenda>) session.getAttribute("carrinho");
        if (carrinho == null) {
            carrinho = new ArrayList<>();
            session.setAttribute("carrinho", carrinho);
        }
        return carrinho;
    }

    private void carregarTela(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        HttpSession session = request.getSession();
        List<ItemVenda> carrinho = getCarrinho(session);

        double totalCarrinho = carrinho.stream().mapToDouble(ItemVenda::getSubtotal).sum();
        request.setAttribute("totalCarrinho", totalCarrinho);

        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        boolean admin = "ADMIN".equals(usuario.getPerfil());
        request.setAttribute("listaVendas", admin ? vendaDAO.listar() : vendaDAO.listar(usuario.getId()));
        request.setAttribute("listaClientes", clienteDAO.listar());
        request.setAttribute("listaProdutos", produtoDAO.listar());
        request.setAttribute("listaUsuarios", usuarioDAO.listar());

        request.getRequestDispatcher("vendas.jsp").forward(request, response);
    }

    private void selecionarCliente(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        String clienteIdStr = request.getParameter("clienteId");
        HttpSession session = request.getSession();
        if (clienteIdStr != null && !clienteIdStr.isEmpty()) {
            Cliente cliente = clienteDAO.buscarPorId(Integer.parseInt(clienteIdStr));
            if (cliente != null) session.setAttribute("clienteSelecionado", cliente);
        }
        response.sendRedirect("vendas?action=listar");
    }

    private void selecionarVendedor(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        String vendedorIdStr = request.getParameter("vendedorId");
        HttpSession session = request.getSession();
        if (vendedorIdStr != null && !vendedorIdStr.isEmpty()) {
            Usuario vendedor = usuarioDAO.buscarPorId(Integer.parseInt(vendedorIdStr));
            if (vendedor != null) session.setAttribute("vendedorSelecionado", vendedor);
        }
        response.sendRedirect("vendas?action=listar");
    }

    private void trocarVendedor(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession().removeAttribute("vendedorSelecionado");
        response.sendRedirect("vendas?action=listar");
    }

    private void adicionarAoCarrinho(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        HttpSession session = request.getSession();
        Cliente cliente = (Cliente) session.getAttribute("clienteSelecionado");
        Usuario vendedor = (Usuario) session.getAttribute("vendedorSelecionado");

        if (cliente == null || vendedor == null) throw new RuntimeException("Selecione cliente e vendedor.");

        int produtoId = Integer.parseInt(request.getParameter("produtoId"));
        int qtdDesejada = Integer.parseInt(request.getParameter("quantidade"));
        Produto produto = produtoDAO.buscarPorId(produtoId);

        if (produto == null) throw new RuntimeException("Produto não encontrado.");

        List<ItemVenda> carrinho = getCarrinho(session);
        int qtdNoCarrinho = carrinho.stream().filter(i -> i.getProduto().getId() == produtoId).mapToInt(ItemVenda::getQuantidade).sum();

        if (produto.getQuantidadeEstoque() < (qtdNoCarrinho + qtdDesejada)) {
            throw new RuntimeException("Estoque insuficiente. Disponível: " + produto.getQuantidadeEstoque());
        }

        boolean encontrado = false;
        for (ItemVenda item : carrinho) {
            if (item.getProduto().getId() == produtoId) {
                item.setQuantidade(item.getQuantidade() + qtdDesejada);
                encontrado = true;
                break;
            }
        }
        if (!encontrado) carrinho.add(new ItemVenda(produto, qtdDesejada, produto.getPreco()));

        response.sendRedirect("vendas?action=listar");
    }

    private void alterarQuantidadeCarrinho(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int produtoId = Integer.parseInt(request.getParameter("produtoId"));
        int novaQtd = Integer.parseInt(request.getParameter("quantidade"));
        HttpSession session = request.getSession();
        List<ItemVenda> carrinho = getCarrinho(session);

        for (ItemVenda item : carrinho) {
            if (item.getProduto().getId() == produtoId) {
                if (novaQtd <= 0) {
                    carrinho.remove(item);
                } else if (item.getProduto().getQuantidadeEstoque() < novaQtd) {
                    session.setAttribute("erroVenda", "Estoque insuficiente.");
                } else {
                    item.setQuantidade(novaQtd);
                }
                break;
            }
        }
        response.sendRedirect("vendas?action=listar");
    }

    private void removerDoCarrinho(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int produtoId = Integer.parseInt(request.getParameter("produtoId"));
        getCarrinho(request.getSession()).removeIf(i -> i.getProduto().getId() == produtoId);
        response.sendRedirect("vendas?action=listar");
    }

    private void cancelarVenda(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        session.removeAttribute("carrinho");
        session.removeAttribute("clienteSelecionado");
        session.removeAttribute("vendedorSelecionado");
        session.removeAttribute("metodoPagamento");
        response.sendRedirect("vendas?action=listar");
    }

    private void selecionarMetodoPagamento(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String metodo = request.getParameter("metodo");
        HttpSession session = request.getSession();
        session.setAttribute("metodoPagamento", metodo);
        response.sendRedirect("vendas?action=listar&modal=confirmacao");
    }

    private void processarFinalizacaoVenda(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        HttpSession session = request.getSession();
        List<ItemVenda> carrinho = getCarrinho(session);
        Cliente cliente = (Cliente) session.getAttribute("clienteSelecionado");
        Usuario vendedor = (Usuario) session.getAttribute("vendedorSelecionado");
        String metodoPagamento = (String) session.getAttribute("metodoPagamento");

        if (cliente == null || vendedor == null || carrinho.isEmpty() || metodoPagamento == null) {
            throw new RuntimeException("Dados incompletos para finalizar a venda.");
        }

        double valorTotal = carrinho.stream().mapToDouble(ItemVenda::getSubtotal).sum();

        Venda novaVenda = new Venda();
        novaVenda.setCliente(cliente);
        novaVenda.setItens(carrinho);
        novaVenda.setValorTotal(valorTotal);
        novaVenda.setVendedorId(vendedor.getId());

        vendaDAO.inserir(novaVenda);

        // Gera o cupom para a nova venda recém finalizada
        gerarTextoCupom(session, novaVenda, metodoPagamento);

        session.removeAttribute("carrinho");
        session.removeAttribute("clienteSelecionado");
        session.removeAttribute("vendedorSelecionado");
        session.removeAttribute("metodoPagamento");

        response.sendRedirect("vendas?action=listar&modal=emitirNota");
    }

    private void emitirNotaHistorico(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        int vendaId = Integer.parseInt(request.getParameter("id"));
        Venda venda = vendaDAO.buscarPorId(vendaId); // Garanta que VendaDAO possua este método
        
        if (venda != null) {
            gerarTextoCupom(request.getSession(), venda, "DINHEIRO/OUTROS");
            response.sendRedirect("vendas?action=listar&modal=visualizarNota");
        } else {
            throw new RuntimeException("Venda não encontrada no histórico.");
        }
    }

    private void gerarTextoCupom(HttpSession session, Venda venda, String metodoPagamento) {
        StringBuilder cupom = new StringBuilder();
        cupom.append("                        LOGO\n");
        cupom.append("           RUA ENDEREÇO X, 000, BAIRRO, ESTADO/ UF\n");
        cupom.append("        CNPJ: 00.000.000/0001-00 IE: 1234567890\n");
        cupom.append("----------------------------------------------------\n");
        cupom.append("         DANFE NFC-e - Documento Auxiliar\n");
        cupom.append("      da Nota Fiscal do Consumidor Eletrônica\n");
        cupom.append("    Não permite aproveitamento de crédito de ICMS\n");
        cupom.append("ITEM  CÓDIGO     DESCRIÇÃO DO PRODUTO\n");
        cupom.append("      QTDE UNID.   V. UNIT. (R$)   V. ITEM (R$)\n");
        cupom.append("----------------------------------------------------\n");
        
        int itemIndex = 1;
        int totalItensQtd = 0;
        if (venda.getItens() != null) {
            for(ItemVenda iv : venda.getItens()) {
                String idxStr = String.format("%03d", itemIndex++);
                String codStr = String.format("%-8d", iv.getProduto().getId());
                String nomeProd = iv.getProduto().getNome();
                cupom.append(idxStr).append("   ").append(codStr).append(" ").append(nomeProd).append("\n");
                cupom.append("      ").append(String.format("%.2f", (double)iv.getQuantidade())).append(" UNID.     ")
                     .append(String.format("%.2f", iv.getPrecoUnitario())).append("          ")
                     .append(String.format("%.2f", iv.getSubtotal())).append("\n");
                totalItensQtd += iv.getQuantidade();
            }
        }
        
        cupom.append("----------------------------------------------------\n");
        cupom.append("QTD. TOTAL DE ITENS                           ").append(totalItensQtd).append("\n");
        cupom.append("VALOR TOTAL                               R$ ").append(String.format("%.2f", venda.getValorTotal())).append("\n");
        cupom.append("FORMA DE PAGAMENTO                         VALOR PAGO\n");
        cupom.append(String.format("%-42s R$ %6.2f\n", metodoPagamento, venda.getValorTotal()));
        cupom.append("----------------------------------------------------\n");
        cupom.append("Val Aprox. dos Tributos: 0,69 (4,18%) (Fonte: IBPT)\n");
        cupom.append("----------------------------------------------------\n");
        cupom.append("         Emitido pelo software GESTÃO versão 1.0\n");
        cupom.append("            HOMOLOGAÇÃO - SEM VALOR FISCAL\n");
        cupom.append("             Número: 000.000.000 - Série: 000\n");
        cupom.append("   Emissão: ").append(venda.getData() != null ? venda.getData() : LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"))).append(" - Via do consumidor\n");
        cupom.append("    Consulte pela chave de acesso em:\n");
        cupom.append("    enderecondaweb.doseuestado.gov.br\n");
        cupom.append("                  CHAVE DE ACESSO\n");
        cupom.append("     3526 1100 0000 0000 0001 6500 0000 0001\n");
        cupom.append("----------------------------------------------------\n");
        cupom.append("                       CONSUMIDOR\n");
        cupom.append("               ").append(venda.getCliente() != null ? venda.getCliente().getNome() : "N/I").append("\n");
        cupom.append("----------------------------------------------------\n");
        cupom.append("               Consulta via leitor de QR Code\n");
        cupom.append("               [ ||||| | |||| |||||| |||| ]\n");
        cupom.append("                 Protocolo de Autorização\n");
        cupom.append("                   135260000000001\n");

        session.setAttribute("conteudoCupomTxt", cupom.toString());
    }
}