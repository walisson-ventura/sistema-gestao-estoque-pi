package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Cliente;
import model.ItemVenda;
import model.Produto;
import model.Venda;

public class VendaDAO {

    public void inserir(Venda venda) throws SQLException {
        String sqlVenda = "INSERT INTO tb_venda (cliente_id, valor_total, vendedor_id) VALUES (?, ?, ?)";
        String sqlItem = "INSERT INTO tb_item_venda (venda_id, produto_id, quantidade, preco_unitario) VALUES (?, ?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = ConnectionFactory.conectar();
            conn.setAutoCommit(false); // Inicia transação

            int vendaId = 0;

            // 1. Inserção especificando explicitamente o ID gerado
            try (PreparedStatement stmtVenda = conn.prepareStatement(sqlVenda, new String[]{"ID"})) {
                stmtVenda.setInt(1, venda.getCliente().getId());
                stmtVenda.setDouble(2, venda.getValorTotal());
                if (venda.getVendedorId() == null) {
                    stmtVenda.setNull(3, java.sql.Types.INTEGER);
                } else {
                    stmtVenda.setInt(3, venda.getVendedorId());
                }
                stmtVenda.executeUpdate();

                try (ResultSet rs = stmtVenda.getGeneratedKeys()) {
                    if (rs.next()) {
                        vendaId = rs.getInt(1);
                    }
                }
            }

            // Fallback de segurança caso getGeneratedKeys não retorne o ID diretamente
            if (vendaId == 0) {
                try (Statement stmtMax = conn.createStatement();
                     ResultSet rsMax = stmtMax.executeQuery("SELECT MAX(id) FROM tb_venda")) {
                    if (rsMax.next()) {
                        vendaId = rsMax.getInt(1);
                    }
                }
            }

            ProdutoDAO produtoDAO = new ProdutoDAO();

            // 2. Inserir itens e dar baixa no estoque em lote
            try (PreparedStatement stmtItem = conn.prepareStatement(sqlItem)) {
                for (ItemVenda item : venda.getItens()) {
                    stmtItem.setInt(1, vendaId);
                    stmtItem.setInt(2, item.getProduto().getId());
                    stmtItem.setInt(3, item.getQuantidade());
                    stmtItem.setDouble(4, item.getPrecoUnitario());
                    stmtItem.executeUpdate();

                    // Atualiza o estoque no produto usando a mesma conexão transacional
                    produtoDAO.atualizarEstoque(conn, item.getProduto().getId(), item.getQuantidade());
                }
            }

            conn.commit(); // Confirma transação
        } catch (SQLException e) {
            if (conn != null) {
                try { 
                    conn.rollback(); 
                } catch (SQLException ex) { 
                    ex.printStackTrace(); 
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { 
                    conn.close(); 
                } catch (SQLException e) { 
                    e.printStackTrace(); 
                }
            }
        }
    }

    public List<Venda> listar() throws SQLException {
        return listar(null);
    }

    public List<Venda> listar(Integer vendedorId) throws SQLException {
        String sql = "SELECT v.id AS venda_id, v.data_venda, v.valor_total, " +
                     "c.id AS cliente_id, c.nome AS cliente_nome " +
                     "FROM tb_venda v " +
                     "JOIN tb_cliente c ON v.cliente_id = c.id " +
                     "WHERE (? IS NULL OR v.vendedor_id = ?) " +
                     "ORDER BY v.id DESC";
                     
        List<Venda> vendas = new ArrayList<>();
        
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (vendedorId == null) { 
                stmt.setNull(1, java.sql.Types.INTEGER); 
                stmt.setNull(2, java.sql.Types.INTEGER); 
            } else { 
                stmt.setInt(1, vendedorId); 
                stmt.setInt(2, vendedorId); 
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Venda v = new Venda();
                    v.setId(rs.getInt("venda_id"));
                    v.setData(rs.getString("data_venda"));
                    v.setValorTotal(rs.getDouble("valor_total"));
                    
                    Cliente c = new Cliente();
                    c.setId(rs.getInt("cliente_id"));
                    c.setNome(rs.getString("cliente_nome"));
                    v.setCliente(c);
                    
                    vendas.add(v);
                }
            }
        }
        return vendas;
    }

    // Método necessário para buscar os detalhes e itens da venda ao emitir a nota pelo histórico
    public Venda buscarPorId(int vendaId) throws SQLException {
        String sqlVenda = "SELECT v.id AS venda_id, v.data_venda, v.valor_total, " +
                          "c.id AS cliente_id, c.nome AS cliente_nome " +
                          "FROM tb_venda v JOIN tb_cliente c ON v.cliente_id = c.id WHERE v.id = ?";
                          
        String sqlItens = "SELECT iv.quantidade, iv.preco_unitario, " +
                          "p.id AS produto_id, p.nome AS produto_nome " +
                          "FROM tb_item_venda iv JOIN tb_produto p ON iv.produto_id = p.id WHERE iv.venda_id = ?";
        
        Venda v = null;
        try (Connection conn = ConnectionFactory.conectar();
             PreparedStatement stmtV = conn.prepareStatement(sqlVenda)) {
            stmtV.setInt(1, vendaId);
            try (ResultSet rsV = stmtV.executeQuery()) {
                if (rsV.next()) {
                    v = new Venda();
                    v.setId(rsV.getInt("venda_id"));
                    v.setData(rsV.getString("data_venda"));
                    v.setValorTotal(rsV.getDouble("valor_total"));
                    
                    Cliente c = new Cliente();
                    c.setId(rsV.getInt("cliente_id"));
                    c.setNome(rsV.getString("cliente_nome"));
                    v.setCliente(c);
                }
            }
            
            if (v != null) {
                List<ItemVenda> itens = new ArrayList<>();
                try (PreparedStatement stmtI = conn.prepareStatement(sqlItens)) {
                    stmtI.setInt(1, vendaId);
                    try (ResultSet rsI = stmtI.executeQuery()) {
                        while (rsI.next()) {
                            Produto p = new Produto();
                            p.setId(rsI.getInt("produto_id"));
                            p.setNome(rsI.getString("produto_nome"));
                            
                            ItemVenda iv = new ItemVenda();
                            iv.setProduto(p);
                            iv.setQuantidade(rsI.getInt("quantidade"));
                            iv.setPrecoUnitario(rsI.getDouble("preco_unitario"));
                            itens.add(iv);
                        }
                    }
                }
                v.setItens(itens);
            }
        }
        return v;
    }
}