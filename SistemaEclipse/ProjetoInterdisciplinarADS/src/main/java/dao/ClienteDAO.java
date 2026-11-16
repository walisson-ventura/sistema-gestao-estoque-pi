package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Cliente;

public class ClienteDAO {

    public ClienteDAO() {
        // No Oracle, geralmente criamos a tabela manualmente no SQL Worksheet 
        // ou tratamos a exceção caso ela já exista.
    }


    public boolean cpfExiste(String cpf) throws SQLException {
        String sql = "SELECT 1 FROM tb_cliente WHERE REGEXP_REPLACE(cpf_cnpj, '[^0-9]', '') = ?";
        try (Connection conn = ConnectionFactory.conectar(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cpf == null ? "" : cpf.replaceAll("\\D", ""));
            try (ResultSet rs = stmt.executeQuery()) { return rs.next(); }
        }
    }

    public void inserir(Cliente cliente) throws SQLException {
        String sql = "INSERT INTO tb_cliente (nome, cpf_cnpj, telefone) VALUES (?, ?, ?)";
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, cliente.getNome());
            stmt.setString(2, cliente.getCpf());
            stmt.setString(3, cliente.getTelefone());
            stmt.executeUpdate();
        }
    }

    public List<Cliente> listar() throws SQLException {
        String sql = "SELECT * FROM tb_cliente";
        List<Cliente> clientes = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Cliente c = new Cliente();
                c.setId(rs.getInt("id"));
                c.setNome(rs.getString("nome"));
                c.setCpf(rs.getString("cpf_cnpj"));
                c.setTelefone(rs.getString("telefone"));
                clientes.add(c);
            }
        }
        return clientes;
    }

    public Cliente buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM tb_cliente WHERE id = ?";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Cliente c = new Cliente();
                    c.setId(rs.getInt("id"));
                    c.setNome(rs.getString("nome"));
                    c.setCpf(rs.getString("cpf_cnpj"));
                    c.setTelefone(rs.getString("telefone"));
                    return c;
                }
            }
        }
        return null;
    }

    public void atualizar(Cliente cliente) throws SQLException {
        String sql = "UPDATE tb_cliente SET nome = ?, cpf_cnpj = ?, telefone = ? WHERE id = ?";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cliente.getNome());
            stmt.setString(2, cliente.getCpf());
            stmt.setString(3, cliente.getTelefone());
            stmt.setInt(4, cliente.getId());
            stmt.executeUpdate();
        }
    }

    public void deletar(int id) throws SQLException {
        String sql = "DELETE FROM tb_cliente WHERE id = ?";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }
}