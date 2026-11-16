package controller;

import dao.ClienteDAO;
import dao.FornecedorDAO;
import dao.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Cliente;
import model.Usuario;
import util.ValidacaoCPF;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(value = {"/clientes", "/ClienteController"})
public class ClienteController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ClienteDAO clienteDAO;
    private FornecedorDAO fornecedorDAO;
    private UsuarioDAO usuarioDAO;

    public void init() {
        clienteDAO = new ClienteDAO();
        fornecedorDAO = new FornecedorDAO();
        usuarioDAO = new UsuarioDAO();
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario u = (Usuario) req.getSession().getAttribute("usuario");
        if (u == null) { resp.sendRedirect(req.getContextPath() + "/login.jsp"); return; }
        
        String action = req.getParameter("action");
        if (action == null) action = "listar";
        
        boolean admin = "ADMIN".equals(u.getPerfil());
        if (!admin && !"listar".equals(action) && !"novo".equals(action) && !"inserir".equals(action)) {
            resp.sendError(403);
            return;
        }

        try {
            switch (action) {
                case "novo":
                    carregarListasCompletas(req);
                    req.getRequestDispatcher("clientes.jsp").forward(req, resp);
                    break;
                case "inserir":
                    inserir(req, resp);
                    break;
                case "editar":
                    editar(req, resp);
                    break;
                case "atualizar":
                    atualizar(req, resp);
                    break;
                default:
                    listar(req, resp);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Erro ao processar clientes e cadastros.", e);
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

    private void listar(HttpServletRequest req, HttpServletResponse resp) throws SQLException, ServletException, IOException {
        carregarListasCompletas(req);
        req.getRequestDispatcher("clientes.jsp").forward(req, resp);
    }

    private void carregarListasCompletas(HttpServletRequest req) throws SQLException {
        req.setAttribute("listaClientes", clienteDAO.listar());
        req.setAttribute("listaFornecedores", fornecedorDAO.listar());
        req.setAttribute("listaVendedores", usuarioDAO.listarVendedores());
    }

    private void inserir(HttpServletRequest req, HttpServletResponse resp) throws SQLException, IOException {
        String nome = limpar(req.getParameter("nome"));
        String cpf = req.getParameter("cpf");
        String tel = limpar(req.getParameter("telefone"));

        if (nome.isEmpty() || tel.isEmpty() || !ValidacaoCPF.validar(cpf)) {
            req.getSession().setAttribute("erroCliente", "Informe nome, contato e um CPF/CNPJ válido.");
            resp.sendRedirect("clientes?action=listar");
            return;
        }

        Cliente c = new Cliente();
        c.setNome(nome);
        c.setCpf(ValidacaoCPF.somenteDigitos(cpf));
        c.setTelefone(tel);

        try {
            if (clienteDAO.cpfExiste(cpf) || usuarioDAO.cpfExiste(cpf)) {
                req.getSession().setAttribute("erroCliente", "Este documento já está cadastrado no sistema.");
                resp.sendRedirect("clientes?action=listar");
                return;
            }
            clienteDAO.inserir(c);
            req.getSession().setAttribute("sucessoCliente", "Cliente cadastrado com sucesso.");
        } catch (SQLException e) {
            req.getSession().setAttribute("erroCliente", e.getErrorCode() == 1 ? "Este documento já está cadastrado." : "Não foi possível cadastrar o cliente.");
        }
        resp.sendRedirect("clientes?action=listar");
    }

    private void editar(HttpServletRequest req, HttpServletResponse resp) throws SQLException, ServletException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        Cliente c = clienteDAO.buscarPorId(id);
        req.setAttribute("cliente", c);
        carregarListasCompletas(req);
        req.getRequestDispatcher("clientes.jsp").forward(req, resp);
    }

    private void atualizar(HttpServletRequest req, HttpServletResponse resp) throws SQLException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        String cpf = req.getParameter("cpf");
        
        if (!ValidacaoCPF.validar(cpf) || limpar(req.getParameter("nome")).isEmpty() || limpar(req.getParameter("telefone")).isEmpty()) {
            req.getSession().setAttribute("erroCliente", "Dados inválidos. Confira nome, CPF/CNPJ e contato.");
            resp.sendRedirect("clientes?action=listar");
            return;
        }

        Cliente c = new Cliente();
        c.setId(id);
        c.setNome(limpar(req.getParameter("nome")));
        c.setCpf(ValidacaoCPF.somenteDigitos(cpf));
        c.setTelefone(limpar(req.getParameter("telefone")));
        
        clienteDAO.atualizar(c);
        req.getSession().setAttribute("sucessoCliente", "Cliente atualizado com sucesso.");
        resp.sendRedirect("clientes?action=listar");
    }

    private String limpar(String s) {
        return s == null ? "" : s.trim();
    }
}