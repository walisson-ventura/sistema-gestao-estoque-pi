package controller;

import dao.ProdutoDAO;
import dao.FornecedorDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Produto;
import model.Usuario;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(value = {"/produtos", "/ProdutoController"})
public class ProdutoController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProdutoDAO produtoDAO;
    private FornecedorDAO fornecedorDAO;

    public void init() {
        produtoDAO = new ProdutoDAO();
        fornecedorDAO = new FornecedorDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
            response.sendError(usuario == null ? 401 : 403); return;
        }
        String action = request.getParameter("action");
        if (action == null) action = "listar";

        try {
            switch (action) {
                case "inserir": inserirProduto(request, response); break;
                case "editar": carregarParaEditar(request, response); break;
                case "atualizar": atualizarProduto(request, response); break;
                case "zerar": zerarEstoqueProduto(request, response); break;
                case "pesquisar": pesquisarProdutos(request, response); break;
                case "gerarTxtProdutos": gerarTxtProdutos(request, response); break;
                default: listarProdutos(request, response); break;
            }
        } catch (SQLException | RuntimeException ex) {
            ex.printStackTrace(); 
            HttpSession session = request.getSession();
            session.setAttribute("erroProduto", "Erro interno: " + ex.getMessage());
            
            if ("listar".equals(action) || action == null) {
                try {
                    request.setAttribute("listaProdutos", new java.util.ArrayList<>());
                    request.setAttribute("listaFornecedores", new java.util.ArrayList<>());
                    request.getRequestDispatcher("produtos.jsp").forward(request, response);
                } catch (Exception e) {
                    throw new ServletException(ex);
                }
            } else {
                response.sendRedirect("produtos?action=listar");
            }
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    private void listarProdutos(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        request.setAttribute("listaProdutos", produtoDAO.listar());
        request.setAttribute("listaFornecedores", fornecedorDAO.listar());
        request.getRequestDispatcher("produtos.jsp").forward(request, response);
    }

    private void pesquisarProdutos(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        String termo = request.getParameter("termo");
        List<Produto> lista = (termo != null && !termo.trim().isEmpty()) ? produtoDAO.pesquisarPorNome(termo) : produtoDAO.listar();
        request.setAttribute("listaProdutos", lista);
        request.setAttribute("listaFornecedores", fornecedorDAO.listar());
        request.getRequestDispatcher("produtos.jsp").forward(request, response);
    }

    private void inserirProduto(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        String nome = request.getParameter("nome");
        Produto existente = produtoDAO.buscarPorNomeExato(nome);
        if (existente != null) {
            HttpSession session = request.getSession();
            session.setAttribute("erroProduto", "Item já cadastrado, gostaria de alterar a quantidade do mesmo no estoque?");
            session.setAttribute("produtoDuplicadoId", existente.getId());
            response.sendRedirect("produtos?action=listar");
            return;
        }

        Produto p = new Produto();
        p.setNome(nome);
        p.setDescricao(request.getParameter("descricao"));
        p.setPreco(Double.parseDouble(request.getParameter("preco")));
        p.setCusto(Double.parseDouble(request.getParameter("custo")));
        p.setQuantidadeEstoque(Integer.parseInt(request.getParameter("quantidade")));
        p.setFornecedorId(Integer.parseInt(request.getParameter("fornecedorId")));

        produtoDAO.inserir(p);
        response.sendRedirect("produtos?action=listar");
    }

    private void carregarParaEditar(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Produto p = produtoDAO.buscarPorId(id);
        request.setAttribute("produtoEdit", p);
        request.setAttribute("listaProdutos", produtoDAO.listar());
        request.setAttribute("listaFornecedores", fornecedorDAO.listar());
        request.getRequestDispatcher("produtos.jsp").forward(request, response);
    }

    private void atualizarProduto(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        Produto p = new Produto();
        p.setId(Integer.parseInt(request.getParameter("id")));
        p.setNome(request.getParameter("nome"));
        p.setDescricao(request.getParameter("descricao"));
        p.setPreco(Double.parseDouble(request.getParameter("preco")));
        p.setCusto(Double.parseDouble(request.getParameter("custo")));
        p.setQuantidadeEstoque(Integer.parseInt(request.getParameter("quantidade")));
        p.setFornecedorId(Integer.parseInt(request.getParameter("fornecedorId")));

        produtoDAO.atualizar(p);
        response.sendRedirect("produtos?action=listar");
    }

    private void zerarEstoqueProduto(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        produtoDAO.zerarEstoque(id);
        response.sendRedirect("produtos?action=listar");
    }

    private void gerarTxtProdutos(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        List<Produto> produtos = produtoDAO.listar();
        
        StringBuilder sb = new StringBuilder();
        sb.append("========================================================================\n");
        sb.append("           RELATÓRIO: PRODUTOS, CUSTO, PREÇO E ESTOQUE                   \n");
        sb.append("========================================================================\n");
        sb.append(String.format("%-24s | %-15s | %-8s | %-8s\n", "PRODUTO", "FORNECEDOR", "CUSTO", "ESTQ"));
        sb.append("------------------------------------------------------------------------\n");
        
        for (Produto p : produtos) {
            String nomeProd = p.getNome() != null ? p.getNome() : "";
            String nomeForn = p.getNomeFornecedor() != null ? p.getNomeFornecedor() : "Não Informado";
            double custo = p.getCusto();
            int qtdEstoque = p.getQuantidadeEstoque();
            
            if (nomeProd.length() > 24) nomeProd = nomeProd.substring(0, 21) + "...";
            if (nomeForn.length() > 15) nomeForn = nomeForn.substring(0, 12) + "...";
            
            sb.append(String.format("%-24s | %-15s | R$ %6.2f | %-8d\n", nomeProd, nomeForn, custo, qtdEstoque));
        }
        sb.append("========================================================================\n");
        sb.append("Total de registros: ").append(produtos.size()).append("\n");
        sb.append("========================================================================\n");
        
        request.getSession().setAttribute("conteudoTxtProdutos", sb.toString());
        response.sendRedirect("produtos?action=listar&modal=visualizarTxtProdutos");
    }
}