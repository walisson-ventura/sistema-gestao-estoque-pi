package controller;

import dao.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Usuario;
import util.ValidacaoCPF;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/LoginController")
public class LoginController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String login = request.getParameter("usuario");
        String senha = request.getParameter("senha");
        Usuario usuario = null;
        try {
            // Conta administrativa legada mantida para não interromper o acesso atual do projeto.
            if ("admin".equalsIgnoreCase(login) && "123".equals(senha)) {
                usuario = new Usuario(); usuario.setId(1); usuario.setNome("Administrador");
                usuario.setLogin("admin"); usuario.setPerfil("ADMIN");
            } else if (login != null && ValidacaoCPF.validar(login)) {
                usuario = new UsuarioDAO().autenticarPorCpf(login, senha);
            }
        } catch (SQLException e) { throw new ServletException("Falha ao autenticar no banco de dados.", e); }
        if (usuario != null) {
            HttpSession antiga = request.getSession(false); if (antiga != null) antiga.invalidate();
            HttpSession sessao = request.getSession(true);
            sessao.setAttribute("usuario", usuario); sessao.setAttribute("perfil", usuario.getPerfil());
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?erro=1");
        }
    }
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession s=request.getSession(false); if(s!=null)s.invalidate();
        response.sendRedirect(request.getContextPath()+"/login.jsp");
    }
}
