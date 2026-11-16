package controller;

import dao.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Usuario;
import util.ValidacaoCPF;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/usuarios")
public class UsuarioController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario logado = (Usuario) req.getSession().getAttribute("usuario");
        if (logado == null || !"ADMIN".equals(logado.getPerfil())) { resp.sendError(403); return; }

        String action = req.getParameter("action");
        if ("editar".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Usuario vendedorEdit = new UsuarioDAO().buscarPorId(id);
                req.setAttribute("vendedorEdit", vendedorEdit);
                req.setAttribute("listaClientes", new dao.ClienteDAO().listar());
                req.setAttribute("listaFornecedores", new dao.FornecedorDAO().listar());
                req.setAttribute("listaVendedores", new UsuarioDAO().listarVendedores());
                req.getRequestDispatcher("/clientes.jsp?tipo=VENDEDOR").forward(req, resp);
            } catch (SQLException e) {
                throw new ServletException("Erro ao carregar vendedor para edição.", e);
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/clientes?action=listar&tipo=VENDEDOR");
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario logado = (Usuario) req.getSession().getAttribute("usuario");
        if (logado == null || !"ADMIN".equals(logado.getPerfil())) { resp.sendError(403); return; }
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        UsuarioDAO dao = new UsuarioDAO();

        if ("atualizar".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                String nome = limpar(req.getParameter("nome"));
                String telefone = limpar(req.getParameter("telefone"));

                if (nome.isEmpty() || telefone.isEmpty()) {
                    req.getSession().setAttribute("erroCliente", "Informe nome e telefone válidos.");
                } else {
                    Usuario u = new Usuario();
                    u.setId(id);
                    u.setNome(nome);
                    u.setTelefone(telefone);
                    dao.atualizarVendedor(u);
                    req.getSession().setAttribute("sucessoCliente", "Dados do vendedor atualizados com sucesso.");
                }
            } catch (SQLException e) {
                req.getSession().setAttribute("erroCliente", "Erro ao atualizar vendedor.");
            }
            resp.sendRedirect(req.getContextPath() + "/clientes?action=listar&tipo=VENDEDOR");
            return;
        }

        // Fluxo de inserção de novo vendedor
        String nome = limpar(req.getParameter("nome")), cpf = req.getParameter("cpf"), telefone = limpar(req.getParameter("telefone"));
        String senha = req.getParameter("senha"), confirmar = req.getParameter("confirmarSenha");
        String erro = null;

        if (nome.isEmpty() || cpf == null || telefone.isEmpty() || senha == null || senha.length() < 8)
            erro = "Preencha todos os campos. A senha deve ter pelo menos 8 caracteres.";
        else if (!ValidacaoCPF.validar(cpf))
            erro = "O CPF informado não é válido.";
        else if (!senha.equals(confirmar))
            erro = "A senha e a confirmação não são iguais.";

        try {
            if (erro == null && (dao.cpfExiste(cpf) || new dao.ClienteDAO().cpfExiste(cpf)))
                erro = "Este CPF já está cadastrado no sistema.";
            if (erro == null) {
                Usuario u = new Usuario();
                u.setNome(nome); u.setCpf(cpf); u.setTelefone(telefone); u.setSenha(senha);
                dao.inserirVendedor(u);
                req.getSession().setAttribute("sucessoCliente", "Vendedor cadastrado com sucesso.");
            } else {
                req.getSession().setAttribute("erroCliente", erro);
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("erroCliente", "Não foi possível cadastrar o vendedor.");
        }
        resp.sendRedirect(req.getContextPath() + "/clientes?action=listar&tipo=VENDEDOR");
    }

    private String limpar(String s) { return s == null ? "" : s.trim(); }
}