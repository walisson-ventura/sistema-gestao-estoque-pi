package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Produto;

public class ProdutoDAO {

    public void inserir(Produto produto) throws SQLException {
        String sql = "INSERT INTO tb_produto (nome, descricao, preco, custo, quantidade_estoque, fornecedor_id) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, produto.getNome());
            stmt.setString(2, produto.getDescricao());
            stmt.setDouble(3, produto.getPreco());
            stmt.setDouble(4, produto.getCusto());
            stmt.setInt(5, produto.getQuantidadeEstoque());
            stmt.setInt(6, produto.getFornecedorId());
            stmt.executeUpdate();
        }
    }

    public List<Produto> listar() throws SQLException {
        String sql = "SELECT p.*, f.nome AS nome_fornecedor FROM tb_produto p LEFT JOIN tb_fornecedor f ON p.fornecedor_id = f.id ORDER BY p.id DESC";
        List<Produto> produtos = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Produto p = new Produto();
                p.setId(rs.getInt("id"));
                p.setNome(rs.getString("nome"));
                p.setDescricao(rs.getString("descricao"));
                p.setPreco(rs.getDouble("preco"));
                p.setCusto(rs.getDouble("custo"));
                p.setQuantidadeEstoque(rs.getInt("quantidade_estoque"));
                p.setFornecedorId(rs.getInt("fornecedor_id"));
                p.setNomeFornecedor(rs.getString("nome_fornecedor"));
                produtos.add(p);
            }
        }
        return produtos;
    }

    public List<Produto> pesquisarPorNome(String termo) throws SQLException {
        String sql = "SELECT p.*, f.nome AS nome_fornecedor FROM tb_produto p LEFT JOIN tb_fornecedor f ON p.fornecedor_id = f.id WHERE LOWER(p.nome) LIKE LOWER(?) ORDER BY p.id DESC";
        List<Produto> produtos = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + termo + "%");
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Produto p = new Produto();
                    p.setId(rs.getInt("id"));
                    p.setNome(rs.getString("nome"));
                    p.setDescricao(rs.getString("descricao"));
                    p.setPreco(rs.getDouble("preco"));
                    p.setCusto(rs.getDouble("custo"));
                    p.setQuantidadeEstoque(rs.getInt("quantidade_estoque"));
                    p.setFornecedorId(rs.getInt("fornecedor_id"));
                    p.setNomeFornecedor(rs.getString("nome_fornecedor"));
                    produtos.add(p);
                }
            }
        }
        return produtos;
    }

    public Produto buscarPorId(int id) throws SQLException {
        String sql = "SELECT p.*, f.nome AS nome_fornecedor FROM tb_produto p LEFT JOIN tb_fornecedor f ON p.fornecedor_id = f.id WHERE p.id = ?";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Produto p = new Produto();
                    p.setId(rs.getInt("id"));
                    p.setNome(rs.getString("nome"));
                    p.setDescricao(rs.getString("descricao"));
                    p.setPreco(rs.getDouble("preco"));
                    p.setCusto(rs.getDouble("custo"));
                    p.setQuantidadeEstoque(rs.getInt("quantidade_estoque"));
                    p.setFornecedorId(rs.getInt("fornecedor_id"));
                    p.setNomeFornecedor(rs.getString("nome_fornecedor"));
                    return p;
                }
            }
        }
        return null;
    }

    public Produto buscarPorNomeExato(String nome) throws SQLException {
        String sql = "SELECT p.*, f.nome AS nome_fornecedor FROM tb_produto p LEFT JOIN tb_fornecedor f ON p.fornecedor_id = f.id WHERE LOWER(TRIM(p.nome)) = LOWER(TRIM(?))";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, nome);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Produto p = new Produto();
                    p.setId(rs.getInt("id"));
                    p.setNome(rs.getString("nome"));
                    p.setDescricao(rs.getString("descricao"));
                    p.setPreco(rs.getDouble("preco"));
                    p.setCusto(rs.getDouble("custo"));
                    p.setQuantidadeEstoque(rs.getInt("quantidade_estoque"));
                    p.setFornecedorId(rs.getInt("fornecedor_id"));
                    p.setNomeFornecedor(rs.getString("nome_fornecedor"));
                    return p;
                }
            }
        }
        return null;
    }

    public void atualizar(Produto produto) throws SQLException {
        String sql = "UPDATE tb_produto SET nome = ?, descricao = ?, preco = ?, custo = ?, quantidade_estoque = ?, fornecedor_id = ? WHERE id = ?";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, produto.getNome());
            stmt.setString(2, produto.getDescricao());
            stmt.setDouble(3, produto.getPreco());
            stmt.setDouble(4, produto.getCusto());
            stmt.setInt(5, produto.getQuantidadeEstoque());
            stmt.setInt(6, produto.getFornecedorId());
            stmt.setInt(7, produto.getId());
            stmt.executeUpdate();
        }
    }

    public void zerarEstoque(int id) throws SQLException {
        String sql = "UPDATE tb_produto SET quantidade_estoque = 0 WHERE id = ?";
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    public void atualizarEstoque(Connection conn, int idProduto, int quantidadeVendida) throws SQLException {
        String sql = "UPDATE tb_produto SET quantidade_estoque = quantidade_estoque - ? WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantidadeVendida);
            stmt.setInt(2, idProduto);
            stmt.executeUpdate();
        }
    }
}