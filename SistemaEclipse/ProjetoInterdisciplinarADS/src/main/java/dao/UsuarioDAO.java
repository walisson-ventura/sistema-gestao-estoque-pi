package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Usuario;
import util.SenhaUtil;
import util.ValidacaoCPF;

public class UsuarioDAO {

    public Usuario autenticarPorCpf(String cpf, String senha) throws SQLException {
        String sql = "SELECT id, nome, cpf, telefone, senha_hash, perfil FROM tb_usuario WHERE cpf = ? AND ativo = 'S'";
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, ValidacaoCPF.somenteDigitos(cpf));
            try (ResultSet r = p.executeQuery()) {
                if (!r.next() || !SenhaUtil.verificar(senha, r.getString("senha_hash"))) return null;
                Usuario u = new Usuario();
                u.setId(r.getInt("id")); u.setNome(r.getString("nome"));
                u.setCpf(r.getString("cpf")); u.setTelefone(r.getString("telefone"));
                u.setLogin(r.getString("cpf")); u.setPerfil(r.getString("perfil"));
                return u;
            }
        }
    }

    public void inserirVendedor(Usuario u) throws SQLException {
        String sql = "INSERT INTO tb_usuario (nome, cpf, telefone, senha_hash, perfil, ativo) VALUES (?, ?, ?, ?, 'VENDEDOR', 'S')";
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, u.getNome()); p.setString(2, ValidacaoCPF.somenteDigitos(u.getCpf()));
            p.setString(3, u.getTelefone()); p.setString(4, SenhaUtil.gerarHash(u.getSenha()));
            p.executeUpdate();
        }
    }

    // Método geral para listar todos os usuários ativos (usado na tela de vendas para escolher o responsável)
    public List<Usuario> listar() throws SQLException {
        String sql = "SELECT id, nome, cpf, telefone, perfil FROM tb_usuario WHERE ativo = 'S' ORDER BY nome ASC";
        List<Usuario> lista = new ArrayList<>();
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sql); ResultSet r = p.executeQuery()) {
            while (r.next()) {
                Usuario u = new Usuario();
                u.setId(r.getInt("id"));
                u.setNome(r.getString("nome"));
                u.setCpf(r.getString("cpf"));
                u.setTelefone(r.getString("telefone"));
                u.setPerfil(r.getString("perfil"));
                lista.add(u);
            }
        }
        return lista;
    }

    public List<Usuario> listarVendedores() throws SQLException {
        String sql = "SELECT id, nome, cpf, telefone, perfil FROM tb_usuario WHERE perfil = 'VENDEDOR' AND ativo = 'S' ORDER BY id DESC";
        List<Usuario> lista = new ArrayList<>();
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sql); ResultSet r = p.executeQuery()) {
            while (r.next()) {
                Usuario u = new Usuario();
                u.setId(r.getInt("id"));
                u.setNome(r.getString("nome"));
                u.setCpf(r.getString("cpf"));
                u.setTelefone(r.getString("telefone"));
                u.setPerfil(r.getString("perfil"));
                lista.add(u);
            }
        }
        return lista;
    }

    public Usuario buscarPorId(int id) throws SQLException {
        String sql = "SELECT id, nome, cpf, telefone, perfil FROM tb_usuario WHERE id = ?";
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) {
                    Usuario u = new Usuario();
                    u.setId(r.getInt("id"));
                    u.setNome(r.getString("nome"));
                    u.setCpf(r.getString("cpf"));
                    u.setTelefone(r.getString("telefone"));
                    u.setPerfil(r.getString("perfil"));
                    return u;
                }
            }
        }
        return null;
    }

    public void atualizarVendedor(Usuario u) throws SQLException {
        String sql = "UPDATE tb_usuario SET nome = ?, telefone = ? WHERE id = ?";
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, u.getNome());
            p.setString(2, u.getTelefone());
            p.setInt(3, u.getId());
            p.executeUpdate();
        }
    }

    public boolean cpfExiste(String cpf) throws SQLException {
        try (Connection c = ConnectionFactory.conectar(); PreparedStatement p = c.prepareStatement("SELECT 1 FROM tb_usuario WHERE cpf = ?")) {
            p.setString(1, ValidacaoCPF.somenteDigitos(cpf));
            try (ResultSet r = p.executeQuery()) { return r.next(); }
        }
    }
}