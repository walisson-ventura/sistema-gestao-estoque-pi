package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Fornecedor;

public class FornecedorDAO {

    public void inserir(Fornecedor fornecedor) throws SQLException {
        String sql = "INSERT INTO tb_fornecedor (nome, cnpj, telefone) VALUES (?, ?, ?)";
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, fornecedor.getNome());
            stmt.setString(2, fornecedor.getCnpj());
            stmt.setString(3, fornecedor.getTelefone());
            stmt.executeUpdate();
        }
    }
    public Fornecedor buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM tb_fornecedor WHERE id = ?";
        try (Connection conn = ConnectionFactory.conectar(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Fornecedor f = new Fornecedor();
                    f.setId(rs.getInt("id"));
                    f.setNome(rs.getString("nome"));
                    f.setCnpj(rs.getString("cnpj"));
                    f.setTelefone(rs.getString("telefone"));
                    return f;
                }
            }
        }
        return null;
    }

    public void atualizar(Fornecedor fornecedor) throws SQLException {
        String sql = "UPDATE tb_fornecedor SET nome = ?, cnpj = ?, telefone = ? WHERE id = ?";
        try (Connection conn = ConnectionFactory.conectar(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, fornecedor.getNome());
            stmt.setString(2, fornecedor.getCnpj());
            stmt.setString(3, fornecedor.getTelefone());
            stmt.setInt(4, fornecedor.getId());
            stmt.executeUpdate();
        }
    }

    public List<Fornecedor> listar() throws SQLException {
        String sql = "SELECT * FROM tb_fornecedor ORDER BY id DESC";
        List<Fornecedor> fornecedores = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Fornecedor f = new Fornecedor();
                f.setId(rs.getInt("id"));
                f.setNome(rs.getString("nome"));
                f.setCnpj(rs.getString("cnpj"));
                f.setTelefone(rs.getString("telefone"));
                fornecedores.add(f);
            }
        }
        return fornecedores;
    }

    public List<Fornecedor> pesquisarPorNome(String termo) throws SQLException {
        String sql = "SELECT * FROM tb_fornecedor WHERE LOWER(nome) LIKE LOWER(?) ORDER BY id DESC";
        List<Fornecedor> fornecedores = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + termo + "%");
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Fornecedor f = new Fornecedor();
                    f.setId(rs.getInt("id"));
                    f.setNome(rs.getString("nome"));
                    f.setCnpj(rs.getString("cnpj"));
                    f.setTelefone(rs.getString("telefone"));
                    fornecedores.add(f);
                }
            }
        }
        return fornecedores;
    }

    public boolean cnpjExiste(String cnpj) throws SQLException {
        String sql = "SELECT 1 FROM tb_fornecedor WHERE REGEXP_REPLACE(cnpj, '[^0-9]', '') = ?";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cnpj == null ? "" : cnpj.replaceAll("\\D", ""));
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void deletar(int id) throws SQLException {
        String sql = "DELETE FROM tb_fornecedor WHERE id = ?";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }
}