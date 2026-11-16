<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.text.NumberFormat,java.util.*,java.time.*,model.Usuario,dao.ConnectionFactory" %>
<%!
private String moedaBR(double v){return NumberFormat.getCurrencyInstance(new Locale("pt","BR")).format(v);}

// Classe auxiliar para encapsular os dados do ranking e evitar qualquer falha de generics no JSP
public static class VendedorRanking {
    private int id;
    private String nome;
    private double total;

    public VendedorRanking(int id, String nome, double total) {
        this.id = id;
        this.nome = nome;
        this.total = total;
    }

    public int getId() { return id; }
    public String getNome() { return nome; }
    public double getTotal() { return total; }
}
%>
<%
Usuario u=(Usuario)session.getAttribute("usuario");if(u==null){response.sendRedirect("login.jsp");return;}
boolean admin="ADMIN".equals(u.getPerfil());
int anoAtual = Year.now().getValue();

String relatorioAtivo = request.getParameter("relatorio");
String mesParam = request.getParameter("mes");
String vendedorIdParam = request.getParameter("vendedor_id");
String conteudoRelatorio = "";
String tituloRelatorio = "";

// Geração de conteúdo TXT para exibição em Modal
if(relatorioAtivo != null) {
    StringBuilder sb = new StringBuilder();
    try(Connection c = ConnectionFactory.conectar()) {
        if("ano".equals(relatorioAtivo)) {
            tituloRelatorio = "Relatório de Faturamento Anual (" + anoAtual + ")";
            sb.append("==================================================\n");
            sb.append("   RELATÓRIO DE VENDAS NO ANO - ").append(anoAtual).append("\n");
            sb.append("==================================================\n\n");
            
            String filtroExp = admin ? "" : " AND vendedor_id = ? ";
            String sql = "SELECT EXTRACT(MONTH FROM data_venda) mes, COUNT(*) qtd, SUM(valor_total) total FROM tb_venda WHERE data_venda >= TRUNC(SYSDATE,'YYYY')" + filtroExp + " GROUP BY EXTRACT(MONTH FROM data_venda) ORDER BY mes";
            double totalAnoVal = 0; int totalQtdVal = 0;
            String[] nomesMeses = {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"};
            
            try(PreparedStatement p = c.prepareStatement(sql)) {
                if(!admin) p.setInt(1, u.getId());
                try(ResultSet r = p.executeQuery()) {
                    while(r.next()) {
                        int m = r.getInt("mes"), q = r.getInt("qtd"); double t = r.getDouble("total");
                        totalAnoVal += t; totalQtdVal += q;
                        sb.append("Mês: ").append(nomesMeses[m-1]).append(" | Vendas: ").append(q).append(" | Total: ").append(moedaBR(t)).append("\n");
                    }
                }
            }
            sb.append("\n--------------------------------------------------\n");
            sb.append("TOTAL DE VENDAS NO ANO: ").append(totalQtdVal).append("\n");
            sb.append("FATURAMENTO TOTAL: ").append(moedaBR(totalAnoVal)).append("\n");
            sb.append("==================================================");

        } else if("mes".equals(relatorioAtivo)) {
            if(mesParam != null && !mesParam.isEmpty()) {
                int mNum = Integer.parseInt(mesParam);
                String[] nomesMeses = {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"};
                tituloRelatorio = "Relatório Diário - " + nomesMeses[mNum-1] + "/" + anoAtual;
                sb.append("==================================================\n");
                sb.append("   RELATÓRIO DE VENDAS POR DIA - ").append(nomesMeses[mNum-1].toUpperCase()).append("/").append(anoAtual).append("\n");
                sb.append("==================================================\n\n");
                
                String filtroExp = admin ? "" : " AND vendedor_id = ? ";
                String sql = "SELECT TO_CHAR(data_venda,'DD/MM/YYYY') dia, COUNT(*) qtd, SUM(valor_total) total FROM tb_venda WHERE EXTRACT(MONTH FROM data_venda) = ? AND EXTRACT(YEAR FROM data_venda) = ?" + filtroExp + " GROUP BY TO_CHAR(data_venda,'DD/MM/YYYY') ORDER BY TO_DATE(TO_CHAR(data_venda,'DD/MM/YYYY'),'DD/MM/YYYY')";
                double totalMesVal = 0; int totalQtdMes = 0;
                
                try(PreparedStatement p = c.prepareStatement(sql)) {
                    p.setInt(1, mNum);
                    p.setInt(2, anoAtual);
                    if(!admin) p.setInt(3, u.getId());
                    try(ResultSet r = p.executeQuery()) {
                        while(r.next()) {
                            String d = r.getString("dia"); int q = r.getInt("qtd"); double t = r.getDouble("total");
                            totalMesVal += t; totalQtdMes += q;
                            sb.append("Dia: ").append(d).append(" | Vendas: ").append(q).append(" | Faturamento: ").append(moedaBR(t)).append("\n");
                        }
                    }
                }
                sb.append("\n--------------------------------------------------\n");
                sb.append("TOTAL DE VENDAS NO MÊS: ").append(totalQtdMes).append("\n");
                sb.append("FATURAMENTO NO MÊS: ").append(moedaBR(totalMesVal)).append("\n");
                sb.append("==================================================");
            } else {
                tituloRelatorio = "Relatório Diário do Mês Atual";
                sb.append("==================================================\n");
                sb.append("   RELATÓRIO DE VENDAS POR DIA (MÊS ATUAL)\n");
                sb.append("==================================================\n\n");
                
                String filtroExp = admin ? "" : " AND vendedor_id = ? ";
                String sql = "SELECT TO_CHAR(data_venda,'DD/MM/YYYY') dia, COUNT(*) qtd, SUM(valor_total) total FROM tb_venda WHERE data_venda >= TRUNC(SYSDATE,'MM')" + filtroExp + " GROUP BY TO_CHAR(data_venda,'DD/MM/YYYY') ORDER BY TO_DATE(TO_CHAR(data_venda,'DD/MM/YYYY'),'DD/MM/YYYY')";
                double totalMesVal = 0; int totalQtdMes = 0;
                
                try(PreparedStatement p = c.prepareStatement(sql)) {
                    if(!admin) p.setInt(1, u.getId());
                    try(ResultSet r = p.executeQuery()) {
                        while(r.next()) {
                            String d = r.getString("dia"); int q = r.getInt("qtd"); double t = r.getDouble("total");
                            totalMesVal += t; totalQtdMes += q;
                            sb.append("Dia: ").append(d).append(" | Vendas: ").append(q).append(" | Faturamento: ").append(moedaBR(t)).append("\n");
                        }
                    }
                }
                sb.append("\n--------------------------------------------------\n");
                sb.append("TOTAL DE VENDAS NO MÊS: ").append(totalQtdMes).append("\n");
                sb.append("FATURAMENTO NO MÊS: ").append(moedaBR(totalMesVal)).append("\n");
                sb.append("==================================================");
            }

        } else if("produtos_cadastrados".equals(relatorioAtivo) && admin) {
            tituloRelatorio = "Relatório de Produtos Cadastrados";
            sb.append("==================================================\n");
            sb.append("   RELATÓRIO DE PRODUTOS E FORNECEDORES\n");
            sb.append("==================================================\n\n");
            
            String sql = "SELECT p.nome, NVL(f.nome, 'Não vinculado') AS fornecedor FROM tb_produto p LEFT JOIN tb_fornecedor f ON p.fornecedor_id = f.id ORDER BY p.nome";
            int totalPrd = 0;
            try(PreparedStatement p = c.prepareStatement(sql); ResultSet r = p.executeQuery()) {
                while(r.next()) {
                    totalPrd++;
                    sb.append("Produto: ").append(r.getString("nome"))
                      .append(" | Fornecedor: ").append(r.getString("fornecedor")).append("\n");
                }
            }
            sb.append("\n--------------------------------------------------\n");
            sb.append("TOTAL DE PRODUTOS: ").append(totalPrd).append("\n");
            sb.append("==================================================");

        } else if("clientes_cadastrados".equals(relatorioAtivo) && admin) {
            tituloRelatorio = "Relatório de Clientes Cadastrados";
            sb.append("==================================================\n");
            sb.append("   RELATÓRIO DE CLIENTES\n");
            sb.append("==================================================\n\n");
            
            String sql = "SELECT nome, cpf_cnpj, telefone FROM tb_cliente ORDER BY nome";
            int totalCl = 0;
            try(PreparedStatement p = c.prepareStatement(sql); ResultSet r = p.executeQuery()) {
                while(r.next()) {
                    totalCl++;
                    sb.append("Nome: ").append(r.getString("nome"))
                      .append(" | CPF/CNPJ: ").append(r.getString("cpf_cnpj") != null ? r.getString("cpf_cnpj") : "N/D")
                      .append(" | Telefone: ").append(r.getString("telefone") != null ? r.getString("telefone") : "N/D").append("\n");
                }
            }
            sb.append("\n--------------------------------------------------\n");
            sb.append("TOTAL DE CLIENTES: ").append(totalCl).append("\n");
            sb.append("==================================================");

        } else if("estoque_baixo".equals(relatorioAtivo) && admin) {
            tituloRelatorio = "Relatório de Produtos com Estoque Baixo";
            sb.append("==================================================\n");
            sb.append("   RELATÓRIO DE PRODUTOS COM ESTOQUE BAIXO (<= 5)\n");
            sb.append("==================================================\n\n");
            
            String sql = "SELECT p.nome, NVL(f.nome, 'Não vinculado') AS fornecedor, p.quantidade_estoque FROM tb_produto p LEFT JOIN tb_fornecedor f ON p.fornecedor_id = f.id WHERE p.quantidade_estoque <= 5 ORDER BY p.quantidade_estoque ASC, p.nome ASC";
            int totalBaixo = 0;
            try(PreparedStatement p = c.prepareStatement(sql); ResultSet r = p.executeQuery()) {
                while(r.next()) {
                    totalBaixo++;
                    sb.append("Produto: ").append(r.getString("nome"))
                      .append(" | Fornecedor: ").append(r.getString("fornecedor"))
                      .append(" | Qtd Estoque: ").append(r.getInt("quantidade_estoque")).append("\n");
                }
            }
            if(totalBaixo == 0) {
                sb.append("Nenhum produto com estoque baixo no momento.\n");
            }
            sb.append("\n--------------------------------------------------\n");
            sb.append("TOTAL DE ITENS COM ESTOQUE BAIXO: ").append(totalBaixo).append("\n");
            sb.append("==================================================");

        } else if("vendedor_detalhe".equals(relatorioAtivo) && vendedorIdParam != null) {
            // Vendedor só pode ver o detalhe se for admin ou se for o próprio ID dele
            if(admin || String.valueOf(u.getId()).equals(vendedorIdParam)) {
                String nomeVend = "Vendedor";
                String sqlVend = "SELECT nome FROM tb_usuario WHERE id = ?";
                try(PreparedStatement p = c.prepareStatement(sqlVend)) {
                    p.setInt(1, Integer.parseInt(vendedorIdParam));
                    try(ResultSet r = p.executeQuery()) { if(r.next()) nomeVend = r.getString("nome"); }
                }
                tituloRelatorio = "Desempenho no Mês - " + nomeVend;
                sb.append("==================================================\n");
                sb.append("   RELATÓRIO PESSOAL DO VENDEDOR: ").append(nomeVend.toUpperCase()).append("\n");
                sb.append("==================================================\n\n");
                
                String sqlVendas = "SELECT TO_CHAR(data_venda,'DD/MM/YYYY') dia, COUNT(*) qtd, SUM(valor_total) total FROM tb_venda WHERE vendedor_id = ? AND data_venda >= TRUNC(SYSDATE,'MM') GROUP BY TO_CHAR(data_venda,'DD/MM/YYYY') ORDER BY TO_DATE(TO_CHAR(data_venda,'DD/MM/YYYY'),'DD/MM/YYYY')";
                double totalV = 0; int qtdV = 0;
                try(PreparedStatement p = c.prepareStatement(sqlVendas)) {
                    p.setInt(1, Integer.parseInt(vendedorIdParam));
                    try(ResultSet r = p.executeQuery()) {
                        while(r.next()) {
                            String d = r.getString("dia"); int q = r.getInt("qtd"); double t = r.getDouble("total");
                            totalV += t; qtdV += q;
                            sb.append("Dia: ").append(d).append(" | Vendas: ").append(q).append(" | Total: ").append(moedaBR(t)).append("\n");
                        }
                    }
                }
                sb.append("\n--------------------------------------------------\n");
                sb.append("TOTAL DE VENDAS NO MÊS: ").append(qtdV).append("\n");
                sb.append("FATURAMENTO TOTAL: ").append(moedaBR(totalV)).append("\n");
                sb.append("==================================================");
            }
        } else if("informe_rendimentos".equals(relatorioAtivo) && admin) {
            tituloRelatorio = "Comprovante Anual de Rendimentos - " + anoAtual;
            sb.append("MINISTÉRIO DA FAZENDA\n");
            sb.append("SECRETARIA DA RECEITA FEDERAL\n");
            sb.append("COMPROVANTE ANUAL DE RENDIMENTOS PAGOS OU CREDITADOS E DE RETENÇÃO DE IMPOSTO DE RENDA NA FONTE\n");
            sb.append("Ano-Calendário ").append(anoAtual).append("\n");
            sb.append("==================================================================\n\n");
            sb.append("1. FONTE PAGADORA\n");
            sb.append("NOME EMPRESARIAL: GESTÃO DE ESTOQUE LTDA.\n");
            sb.append("CNPJ: 00.000.000/0001-00\n\n");
            sb.append("2. PESSOA JURÍDICA BENEFICIÁRIA DOS RENDIMENTOS / VENDEDORES\n");
            sb.append("------------------------------------------------------------------\n");
            sb.append(String.format("%-5s | %-18s | %-22s | %-15s | %-15s\n", "MÊS", "CÓD. RETENÇÃO", "DESCRIÇÃO DO RENDIMENTO", "RENDIMENTO (R$)", "IMPOSTO RETIDO"));
            sb.append("------------------------------------------------------------------\n");
            
            String[] nomesMeses = {"JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"};
            double[] valoresMeses = new double[12];
            
            String sqlRend = "SELECT EXTRACT(MONTH FROM data_venda) mes, SUM(valor_total) total FROM tb_venda WHERE EXTRACT(YEAR FROM data_venda) = ? GROUP BY EXTRACT(MONTH FROM data_venda)";
            try(PreparedStatement p = c.prepareStatement(sqlRend)) {
                p.setInt(1, anoAtual);
                try(ResultSet r = p.executeQuery()) {
                    while(r.next()) {
                        int m = r.getInt("mes");
                        if(m >= 1 && m <= 12) valoresMeses[m-1] = r.getDouble("total");
                    }
                }
            }
            
            double totalRendGeral = 0;
            for(int i=0; i<12; i++) {
                double val = valoresMeses[i];
                double imposto = val * 0.015;
                totalRendGeral += val;
                sb.append(String.format("%-5s | %-18s | %-22s | %-15s | %-15s\n", nomesMeses[i], "8045", "Comissões", moedaBR(val), moedaBR(imposto)));
            }
            sb.append("------------------------------------------------------------------\n");
            sb.append("TOTAL DE RENDIMENTOS NO ANO: ").append(moedaBR(totalRendGeral)).append("\n");
            sb.append("==================================================================");
        }
    } catch(Exception e) {
        sb.append("Erro ao gerar relatório: ").append(e.getMessage());
    }
    conteudoRelatorio = sb.toString();
}

double totalAno = 0, totalMes = 0, totalGeral = 0;
int qtdMes = 0, qtdAno = 0, totalProdutos = 0, totalClientes = 0, produtosEstoqueBaixo = 0;
String erro = null;
double[] serie = new double[12];
List<String> ultimasDatas = new ArrayList<>();
List<String> ultimosClientes = new ArrayList<>();
List<Double> ultimosValores = new ArrayList<>();

List<VendedorRanking> topVendedoresLista = new ArrayList<>();

try(Connection c = ConnectionFactory.conectar()){
    String sql = "SELECT NVL(SUM(valor_total),0) total, COUNT(*) qtd FROM tb_venda WHERE data_venda >= TRUNC(SYSDATE,'YYYY')" + (admin ? "" : " AND vendedor_id = ? ");
    try(PreparedStatement p = c.prepareStatement(sql)){if(!admin)p.setInt(1,u.getId());try(ResultSet r = p.executeQuery()){if(r.next()){totalAno=r.getDouble("total");qtdAno=r.getInt("qtd");}}}
    
    sql = "SELECT NVL(SUM(valor_total),0) total, COUNT(*) qtd FROM tb_venda WHERE data_venda >= TRUNC(SYSDATE,'MM')" + (admin ? "" : " AND vendedor_id = ? ");
    try(PreparedStatement p = c.prepareStatement(sql)){if(!admin)p.setInt(1,u.getId());try(ResultSet r = p.executeQuery()){if(r.next()){totalMes=r.getDouble("total");qtdMes=r.getInt("qtd");}}}
    
    sql = "SELECT NVL(SUM(valor_total),0) FROM tb_venda WHERE 1=1" + (admin ? "" : " AND vendedor_id = ? ");
    try(PreparedStatement p = c.prepareStatement(sql)){if(!admin)p.setInt(1,u.getId());try(ResultSet r = p.executeQuery()){if(r.next())totalGeral=r.getDouble(1);}}
    
    if(admin) {
        try(PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM tb_produto"); ResultSet r = p.executeQuery()){ if(r.next()) totalProdutos = r.getInt(1); }
        try(PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM tb_cliente"); ResultSet r = p.executeQuery()){ if(r.next()) totalClientes = r.getInt(1); }
        try(PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM tb_produto WHERE quantidade_estoque <= 5"); ResultSet r = p.executeQuery()){ if(r.next()) produtosEstoqueBaixo = r.getInt(1); }
    }

    sql = "SELECT EXTRACT(MONTH FROM data_venda) mes, NVL(SUM(valor_total),0) total FROM tb_venda WHERE data_venda >= TRUNC(SYSDATE,'YYYY')" + (admin ? "" : " AND vendedor_id = ? ") + " GROUP BY EXTRACT(MONTH FROM data_venda) ORDER BY mes";
    try(PreparedStatement p = c.prepareStatement(sql)){if(!admin)p.setInt(1,u.getId());try(ResultSet r = p.executeQuery()){while(r.next())serie[r.getInt("mes")-1]=r.getDouble("total");}}
    
    sql = "SELECT TO_CHAR(v.data_venda,'DD/MM/YYYY') data, c.nome cliente, v.valor_total FROM tb_venda v JOIN tb_cliente c ON c.id=v.cliente_id WHERE 1=1"+(admin?"":" AND v.vendedor_id = ? ")+" ORDER BY v.data_venda DESC FETCH FIRST 10 ROWS ONLY";
    try(PreparedStatement p = c.prepareStatement(sql)){if(!admin)p.setInt(1,u.getId());try(ResultSet r = p.executeQuery()){while(r.next()){ultimasDatas.add(r.getString("data"));ultimosClientes.add(r.getString("cliente"));ultimosValores.add(r.getDouble("valor_total"));}}}

    String sqlVendedores = "SELECT u.id, u.nome, SUM(v.valor_total) total FROM tb_venda v JOIN tb_usuario u ON u.id = v.vendedor_id GROUP BY u.id, u.nome ORDER BY total DESC FETCH FIRST 3 ROWS ONLY";
    try(PreparedStatement p = c.prepareStatement(sqlVendedores); ResultSet r = p.executeQuery()){
        while(r.next()){
            topVendedoresLista.add(new VendedorRanking(r.getInt("id"), r.getString("nome"), r.getDouble("total")));
        }
    } catch(SQLException ignore) {}

}catch(SQLException ex){
    erro="Não foi possível carregar os relatórios. Verifique se executou o script SQL de atualização.";
}
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Relatórios - Gestão de Estoque</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/dashboard.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .metric {
            padding: 22px;
            border-radius: 13px;
            background: #222a35;
            border: 1px solid #354151;
            text-decoration: none;
            display: block;
            transition: transform 0.2s, border-color 0.2s;
            height: 100%;
        }
        .metric:hover {
            transform: translateY(-3px);
            border-color: #8b5cf6;
        }
        .metric small { color: #9ca3af; }
        .metric strong { display: block; color: #f8fafc; font-size: clamp(21px,2vw,29px); margin-top: 8px; }
        .chart-box { height: 310px; }
        .vendedor-link { color: inherit; text-decoration: none; transition: color 0.2s; }
        .vendedor-link:hover { color: #8b5cf6; text-decoration: underline; }
    </style>
</head>
<body class="app-body">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-content">
        <div class="container-fluid page-container">
            <div class="page-heading d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1><%=admin?"Relatórios Gerais":"Meu Desempenho"%></h1>
                    <p class="text-secondary mb-0"><%=admin?"Indicadores consolidados de todas as vendas do sistema.":"Acompanhe exclusivamente seu desempenho individual e o ranking de vendas."%></p>
                </div>
                <span class="badge text-bg-success px-3 py-2"><%=admin?"Painel administrativo":"Relatório individual"%></span>
            </div>

            <%if(erro!=null){%>
                <div class="alert alert-warning"><%=erro%></div>
            <%}else{%>

            <!-- LINHA DE MÉTRICAS / CARTÕES COM ÍCONES -->
            <% if(admin) { %>
                <!-- Visão Completa para Administradores -->
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <a href="relatorios.jsp?relatorio=ano" class="metric">
                            <div class="text-info fs-4 mb-2"><i class="bi bi-currency-dollar"></i></div>
                            <small>Faturamento no ano (<%=anoAtual%>)</small>
                            <strong><%=moedaBR(totalAno)%></strong>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="relatorios.jsp?relatorio=mes" class="metric">
                            <div class="text-success fs-4 mb-2"><i class="bi bi-graph-up-arrow"></i></div>
                            <small>Faturamento no mês</small>
                            <strong><%=moedaBR(totalMes)%></strong>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="relatorios.jsp?relatorio=produtos_cadastrados" class="metric">
                            <div class="text-primary fs-4 mb-2"><i class="bi bi-box-seam"></i></div>
                            <small>Produtos Cadastrados</small>
                            <strong><%=totalProdutos%></strong>
                        </a>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <a href="relatorios.jsp?relatorio=clientes_cadastrados" class="metric">
                            <div class="text-warning fs-4 mb-2"><i class="bi bi-people"></i></div>
                            <small>Clientes Cadastrados</small>
                            <strong><%=totalClientes%></strong>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="relatorios.jsp?relatorio=estoque_baixo" class="metric">
                            <div class="text-danger fs-4 mb-2"><i class="bi bi-exclamation-triangle"></i></div>
                            <small>Produtos com Estoque Baixo</small>
                            <strong class="<%=produtosEstoqueBaixo > 0 ? "text-danger" : "text-light"%>"><%=produtosEstoqueBaixo%></strong>
                            <small class="d-block mt-1 text-warning" style="font-size: 0.75rem;">Atenção ao estoque</small>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="relatorios.jsp?relatorio=informe_rendimentos" class="metric">
                            <div class="text-info fs-4 mb-2"><i class="bi bi-file-earmark-spreadsheet"></i></div>
                            <small>Informe de Rendimentos</small>
                            <strong style="font-size: 1.1rem; padding-top: 8px;"><i class="bi bi-download"></i> Comprovante Anual</strong>
                        </a>
                    </div>
                </div>
            <% } else { %>
                <!-- Visão Limitada apenas para Vendedores (Desempenho Individual) -->
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <a href="relatorios.jsp?relatorio=ano" class="metric">
                            <div class="text-info fs-4 mb-2"><i class="bi bi-currency-dollar"></i></div>
                            <small>Meu Faturamento no Ano (<%=anoAtual%>)</small>
                            <strong><%=moedaBR(totalAno)%></strong>
                        </a>
                    </div>
                    <div class="col-md-6">
                        <a href="relatorios.jsp?relatorio=mes" class="metric">
                            <div class="text-success fs-4 mb-2"><i class="bi bi-graph-up-arrow"></i></div>
                            <small>Meu Faturamento no Mês</small>
                            <strong><%=moedaBR(totalMes)%></strong>
                        </a>
                    </div>
                </div>
            <% } %>

            <!-- GRÁFICO E RESUMO -->
            <div class="row g-3 mb-4">
                <div class="col-lg-8">
                    <div class="card h-100">
                        <div class="card-header"><h5><i class="bi bi-bar-chart-line me-2 text-info"></i><%=admin ? "Faturamento mensal - " + Year.now().getValue() : "Meu faturamento mensal - " + Year.now().getValue()%> (Clique na barra para ver o mês)</h5></div>
                        <div class="card-body"><div class="chart-box"><canvas id="graficoVendas"></canvas></div></div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="card h-100">
                        <div class="card-header"><h5><i class="bi bi-speedometer2 me-2 text-warning"></i>Resumo do período</h5></div>
                        <div class="card-body d-flex flex-column justify-content-around">
                            <div><small class="text-secondary"><%=admin ? "Vendas realizadas no ano" : "Minhas vendas no ano"%></small><h2 class="text-light"><%=qtdAno%></h2></div>
                            <div><small class="text-secondary"><%=admin ? "Faturamento acumulado" : "Meu faturamento acumulado"%></small><h3 class="text-light"><%=moedaBR(totalGeral)%></h3></div>
                            <div><small class="text-secondary">Usuário</small><h5 class="text-light"><%=u.getNome()%></h5></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TABELA DE RANKING DE VENDEDORES (Visível para ambos) -->
            <div class="row g-3 mb-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="bi bi-trophy text-warning me-2"></i>Ranking: Top 3 Vendedores - <%=anoAtual%> <%=admin ? "(Clique no nome para relatório pessoal)" : ""%></h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-dark table-striped align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th style="width: 120px;">Posição</th>
                                            <th>Vendedor</th>
                                            <th class="text-end">Total Vendido</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        if(topVendedoresLista.isEmpty()) { 
                                        %>
                                            <tr><td colspan="3" class="text-center text-secondary">Nenhum registro de vendas encontrado.</td></tr>
                                        <% 
                                        } else {
                                            int pos = 1;
                                            for(VendedorRanking v : topVendedoresLista) {
                                                String badgeColor = pos == 1 ? "bg-warning text-dark" : (pos == 2 ? "bg-secondary text-white" : "bg-dark border border-secondary text-white");
                                        %>
                                            <tr>
                                                <td><span class="badge <%=badgeColor%> fw-bold px-3 py-2"><%=pos%>º</span></td>
                                                <td class="fw-semibold">
                                                    <% if(admin) { %>
                                                        <a href="relatorios.jsp?relatorio=vendedor_detalhe&vendedor_id=<%=v.getId()%>" class="vendedor-link" title="Clique para ver o relatório pessoal deste vendedor">
                                                            <i class="bi bi-person-badge me-1 text-info"></i> <%=v.getNome()%>
                                                        </a>
                                                    <% } else { %>
                                                        <i class="bi bi-person-badge me-1 text-info"></i> <%=v.getNome()%>
                                                    <% } %>
                                                </td>
                                                <td class="text-end fw-bold text-success"><%=moedaBR(v.getTotal())%></td>
                                            </tr>
                                        <% 
                                                pos++;
                                            }
                                        } 
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TABELA DE ÚLTIMAS VENDAS -->
            <div class="row g-3">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header"><h5><i class="bi bi-clock-history me-2 text-primary"></i><%=admin?"Últimas vendas do sistema":"Minhas últimas vendas"%></h5></div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle">
                                    <thead><tr><th>Data</th><th>Cliente</th><th>Valor</th></tr></thead>
                                    <tbody>
                                        <%for(int i=0;i<ultimasDatas.size();i++){%>
                                            <tr>
                                                <td><%=ultimasDatas.get(i)%></td>
                                                <td><%=ultimosClientes.get(i)==null?"":ultimosClientes.get(i).replace("<","&lt;")%></td>
                                                <td><%=moedaBR(ultimosValores.get(i))%></td>
                                            </tr>
                                        <%}%>
                                        <%if(ultimasDatas.isEmpty()){%>
                                            <tr><td colspan="3" class="text-center text-secondary">Nenhuma venda registrada neste período.</td></tr>
                                        <%}%>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <%}%>
        </div>
    </main>

    <!-- MODAL DE EXIBIÇÃO DO RELATÓRIO TXT -->
    <% if(relatorioAtivo != null && (!conteudoRelatorio.isEmpty())) { %>
    <div class="modal fade show" tabindex="-1" style="display: block; background: rgba(0,0,0,0.7);" aria-modal="true" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content bg-dark text-light border-secondary">
                <div class="modal-header border-secondary">
                    <h5 class="modal-title"><i class="bi bi-file-earmark-text me-2 text-info"></i><%=tituloRelatorio%></h5>
                    <a href="relatorios.jsp" class="btn-close btn-close-white"></a>
                </div>
                <div class="modal-body">
                    <pre id="textoRelatorio" class="form-control bg-black text-success p-3" style="height: 310px; overflow-y: auto; font-family: monospace; font-size: 0.9rem;"><%=conteudoRelatorio%></pre>
                </div>
                <div class="modal-footer border-secondary justify-content-between">
                    <button type="button" class="btn btn-outline-light btn-sm" onclick="copiarTexto()">
                        <i class="bi bi-clipboard"></i> Copiar Texto
                    </button>
                    <div>
                        <button type="button" class="btn btn-success btn-sm me-2" onclick="baixarTxt()">
                            <i class="bi bi-download"></i> Baixar .TXT
                        </button>
                        <a href="relatorios.jsp" class="btn btn-secondary btn-sm">Fechar</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        function copiarTexto() {
            navigator.clipboard.writeText(document.getElementById("textoRelatorio").innerText).then(() => {
                alert("Relatório copiado para a área de transferência!");
            });
        }
        function baixarTxt() {
            const blob = new Blob([document.getElementById("textoRelatorio").innerText], { type: "text/plain;charset=utf-8" });
            const link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = "relatorio_<%=relatorioAtivo%>.txt";
            link.click();
        }
    </script>
    <% } %>

    <script>
        const labels=["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];
        const valores=<%=java.util.Arrays.toString(serie)%>;
        const canvas=document.getElementById('graficoVendas');
        if(canvas){
            const chart = new Chart(canvas,{
                type:'bar',
                data:{
                    labels:labels,
                    datasets:[{label:'Faturamento (R$)',data:valores,backgroundColor:'#8b5cf6',borderRadius:6}]
                },
                options:{
                    responsive:true,
                    maintainAspectRatio:false,
                    onClick: (event, elements) => {
                        if(elements && elements.length > 0) {
                            const mesIndex = elements[0].index + 1;
                            window.location.href = "relatorios.jsp?relatorio=mes&mes=" + mesIndex;
                        }
                    },
                    plugins:{legend:{labels:{color:'#cbd5e1'}}},
                    scales:{
                        x:{ticks:{color:'#9ca3af'},grid:{color:'#303b49'}},
                        y:{ticks:{color:'#9ca3af'},grid:{color:'#303b49'}}
                    }
                }
            });
        }
    </script>
</body>
</html>