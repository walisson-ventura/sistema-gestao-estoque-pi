package controller;

import dao.ConnectionFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Usuario;
import util.SenhaUtil;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(value = {"/PerfilController", "/SenhaController"})
public class PerfilController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario usuario = (Usuario) req.getSession().getAttribute("usuario");
        if (usuario == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.setCharacterEncoding("UTF-8");
        String uri = req.getRequestURI();

        try {
            if (uri.contains("SenhaController")) {
                alterarSenha(req, resp, usuario);
            } else {
                atualizarPerfil(req, resp, usuario);
            }
        } catch (SQLException e) {
            throw new ServletException("Erro ao processar as alterações de perfil.", e);
        }
    }

    private void atualizarPerfil(HttpServletRequest req, HttpServletResponse resp, Usuario usuario) throws SQLException, IOException {
        String nome = req.getParameter("nome");
        String telefone = req.getParameter("telefone");

        if (nome == null || nome.trim().isEmpty()) {
            req.getSession().setAttribute("erroPerfil", "O nome não pode estar vazio.");
            resp.sendRedirect("perfil.jsp");
            return;
        }

        String sql = "UPDATE tb_usuario SET nome = ?, telefone = ? WHERE id = ?";
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, nome.trim());
            p.setString(2, telefone != null ? telefone.trim() : "");
            p.setInt(3, usuario.getId());
            p.executeUpdate();
        }

        // Atualiza a sessão
        usuario.setNome(nome.trim());
        usuario.setTelefone(telefone != null ? telefone.trim() : "");
        req.getSession().setAttribute("usuario", usuario);
        req.getSession().setAttribute("sucessoPerfil", "Informações pessoais atualizadas com sucesso!");
        resp.sendRedirect("perfil.jsp");
    }

    private void alterarSenha(HttpServletRequest req, HttpServletResponse resp, Usuario usuario) throws SQLException, IOException {
        String senhaAtual = req.getParameter("senhaAtual");
        String novaSenha = req.getParameter("novaSenha");
        String confirmarSenha = req.getParameter("confirmarSenha");

        if (senhaAtual == null || novaSenha == null || confirmarSenha == null) {
            req.getSession().setAttribute("erroSenha", "Preencha todos os campos de senha.");
            resp.sendRedirect("perfil.jsp");
            return;
        }

        if (!novaSenha.equals(confirmarSenha)) {
            req.getSession().setAttribute("erroSenha", "A nova senha e a confirmação não coincidem.");
            resp.sendRedirect("perfil.jsp");
            return;
        }

        if (novaSenha.length() < 8) {
            req.getSession().setAttribute("erroSenha", "A nova senha deve ter no mínimo 8 caracteres.");
            resp.sendRedirect("perfil.jsp");
            return;
        }

        // Valida se a senha atual está correta no banco
        String sqlVerifica = "SELECT senha_hash FROM tb_usuario WHERE id = ?";
        String senhaHashAtual = "";
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sqlVerifica)) {
            p.setInt(1, usuario.getId());
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) {
                    senhaHashAtual = r.getString("senha_hash");
                }
            }
        }

        if (!SenhaUtil.verificar(senhaAtual, senhaHashAtual)) {
            req.getSession().setAttribute("erroSenha", "A senha atual informada está incorreta.");
            resp.sendRedirect("perfil.jsp");
            return;
        }

        // Atualiza para a nova senha gerando o hash
        String novoHash = SenhaUtil.gerarHash(novaSenha);
        String sqlUpdate = "UPDATE tb_usuario SET senha_hash = ? WHERE id = ?";
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sqlUpdate)) {
            p.setString(1, novoHash);
            p.setInt(2, usuario.getId());
            p.executeUpdate();
        }

        req.getSession().setAttribute("sucessoSenha", "Senha alterada com sucesso!");
        resp.sendRedirect("perfil.jsp");
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect("perfil.jsp");
    }
}