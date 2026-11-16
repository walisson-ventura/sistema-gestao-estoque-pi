package controller;

import dao.FornecedorDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Fornecedor;
import model.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(value = {"/fornecedores", "/FornecedorController"})
public class FornecedorController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private FornecedorDAO fornecedorDAO;

    public void init() { fornecedorDAO = new FornecedorDAO(); }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) { response.sendError(401); return; }

        String action = request.getParameter("action");
        if (action == null) action = "listar";

        try {
            switch (action) {
                case "inserir": inserir(request, response); break;
                case "editar": editar(request, response); break;
                case "atualizar": atualizar(request, response); break;
                case "pesquisar": pesquisar(request, response); break;
                default: listar(request, response); break;
            }
        } catch (SQLException ex) {
            request.getSession().setAttribute("erroFornecedor", "Erro no banco de dados: " + ex.getMessage());
            response.sendRedirect("fornecedores?action=listar");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    private void listar(HttpServletRequest req, HttpServletResponse resp) throws SQLException, ServletException, IOException {
        req.setAttribute("listaFornecedores", fornecedorDAO.listar());
        req.getRequestDispatcher("fornecedores.jsp").forward(req, resp);
    }

    private void pesquisar(HttpServletRequest req, HttpServletResponse resp) throws SQLException, ServletException, IOException {
        String termo = req.getParameter("termo");
        List<Fornecedor> lista = (termo != null && !termo.trim().isEmpty()) ? fornecedorDAO.pesquisarPorNome(termo) : fornecedorDAO.listar();
        req.setAttribute("listaFornecedores", lista);
        req.getRequestDispatcher("fornecedores.jsp").forward(req, resp);
    }

    private void inserir(HttpServletRequest req, HttpServletResponse resp) throws SQLException, IOException {
        Fornecedor f = new Fornecedor();
        f.setNome(req.getParameter("nome"));
        f.setCnpj(req.getParameter("cnpj"));
        f.setTelefone(req.getParameter("telefone"));
        fornecedorDAO.inserir(f);
        req.getSession().setAttribute("sucessoCliente", "Fornecedor cadastrado com sucesso.");
        resp.sendRedirect("clientes?action=listar&tipo=FORNECEDOR");
    }

    private void editar(HttpServletRequest req, HttpServletResponse resp) throws SQLException, ServletException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        req.setAttribute("fornecedorEdit", fornecedorDAO.buscarPorId(id));
        req.setAttribute("listaClientes", new dao.ClienteDAO().listar());
        req.setAttribute("listaFornecedores", fornecedorDAO.listar());
        req.setAttribute("listaVendedores", new dao.UsuarioDAO().listarVendedores());
        req.getRequestDispatcher("clientes.jsp?tipo=FORNECEDOR").forward(req, resp);
    }

    private void atualizar(HttpServletRequest req, HttpServletResponse resp) throws SQLException, IOException {
        Fornecedor f = new Fornecedor();
        f.setId(Integer.parseInt(req.getParameter("id")));
        f.setNome(req.getParameter("nome"));
        f.setCnpj(req.getParameter("cnpj"));
        f.setTelefone(req.getParameter("telefone"));
        fornecedorDAO.atualizar(f);
        req.getSession().setAttribute("sucessoCliente", "Fornecedor atualizado com sucesso.");
        resp.sendRedirect("clientes?action=listar&tipo=FORNECEDOR");
    }
}