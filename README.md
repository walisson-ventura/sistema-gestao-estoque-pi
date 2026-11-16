# 📦 Sistema de Gestão de Estoque e Vendas

![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![JSP](https://img.shields.io/badge/JSP_%2F_Servlets-007396?style=for-the-badge&logo=java&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap_5-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white)
![Oracle Database](https://img.shields.io/badge/Oracle_Database-F80000?style=for-the-badge&logo=oracle&logoColor=white)

Sistema web completo para controle de estoque, gerenciamento de clientes, fornecedores e operações de frente de caixa (PDV/Vendas), desenvolvido como **Projeto Interdisciplinar de Análise e Desenvolvimento de Sistemas (ADS)**.

---

## 🎯 Sobre o Projeto

O **Gestão de Estoque** foi projetado para centralizar o fluxo comercial de pequenas e médias empresas, oferecendo uma interface moderna (Dark Mode), responsiva e com **Controle de Acesso Baseado em Perfis (RBAC)**, separando rigorosamente as visões e permissões entre **Administradores** e **Vendedores**.

---

## 🔐 Perfis de Acesso e Permissões (RBAC)

O sistema realiza a autenticação de usuários e adapta dinamicamente os menus, ações e relatórios exibidos:

### 👑 Administrador (`ADMIN`)
* **Visão Consolidada:** Acesso total ao faturamento anual, mensal e acumulado de toda a empresa.
* **Gestão de Cadastros:** Controle completo de Produtos, Clientes, Fornecedores e Usuários.
* **Monitoramento de Estoque:** Alertas visuais de produtos com estoque crítico ($\le 5$ unidades).
* **Relatórios Gerenciais (.TXT):** Geração, visualização em modal, cópia e download de relatórios de:
  * Faturamento Anual e Diário;
  * Produtos e Fornecedores Cadastrados;
  * Clientes Cadastrados;
  * Itens com Estoque Baixo;
  * Comprovante Anual de Rendimentos;
  * Desempenho individual detalhado de cada vendedor.

### 💼 Vendedor (`VENDEDOR`)
* **Frente de Caixa / Vendas:** Montagem de carrinho de compras, seleção de clientes, cálculo automático de subtotais e finalização com baixa automática no estoque.
* **Desempenho Individual:** Visualização exclusiva de suas próprias métricas de faturamento mensal/anual e histórico de vendas.
* **Ranking Competitivo:** Acesso ao **Top 3 Vendedores** do ano corrente.

---

## ✨ Funcionalidades Principais

* **🛒 Carrinho de Compras Dinâmico:** Adição de produtos com validação de disponibilidade em estoque, atualização de quantidades e remoção de itens.
* **💳 Múltiplas Formas de Pagamento:** Suporte para fechamento de vendas via **PIX, Cartão de Crédito, Cartão de Débito e Dinheiro**.
* **🧾 Emissão de Cupom / Recibo (.TXT):** Geração instantânea de comprovante da venda com opções para impressão térmica/comum ou download em arquivo `.txt`, além de reemissão pelo histórico.
* **📊 Gráficos Interativos:** Visualização da evolução do faturamento mensal utilizando **Chart.js**, com clique direto nas barras para detalhamento diário do mês selecionado.

---

## 🛠️ Tecnologias Utilizadas

* **Back-end:** Java (Jakarta EE / JSP / Servlets / JDBC)
* **Front-end:** HTML5, CSS3, JavaScript, Bootstrap 5, Bootstrap Icons e Chart.js
* **Banco de Dados:** Oracle Database (PL/SQL, Functions de data e agregação)
* **Servidor de Aplicação:** Apache Tomcat

---

## 📁 Estrutura Básica do Projeto

```text
ProjetoInterdisciplinarADS/
├── src/
│   └── main/
│       ├── java/
│       │   ├── controller/      # Servlets de controle (Vendas, Login, Cadastros)
│       │   ├── dao/             # ConnectionFactory e classes de acesso a dados
│       │   └── model/           # Entidades (Usuario, Produto, Cliente, Venda)
│       └── webapp/
│           ├── assets/          # CSS customizado, JS e ícones (favicon)
│           ├── WEB-INF/
│           │   └── jspf/        # Fragmentos reutilizáveis (sidebar.jspf)
│           ├── login.jsp        # Tela de autenticação
│           ├── vendas.jsp       # Módulo de carrinho e histórico de vendas
│           └── relatorios.jsp   # Dashboard analítico e gerador de relatórios TXT
└── README.md
```

---

## 🚀 Como Executar o Projeto

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/ProjetoInterdisciplinarADS.git
   ```
2. **Configure o Banco de Dados:**
   * Execute os scripts DDL/DML no seu ambiente **Oracle Database** para criar as tabelas (`tb_usuario`, `tb_cliente`, `tb_fornecedor`, `tb_produto`, `tb_venda`, `tb_item_venda`).
   * Ajuste as credenciais de acesso na classe `dao.ConnectionFactory`.
3. **Deploy no Servidor:**
   * Importe o projeto em sua IDE (Eclipse / IntelliJ IDEA / NetBeans).
   * Configure o servidor **Apache Tomcat** (versão 10+ compatível com `jakarta.*`).
   * Inicie o servidor e acesse: `http://localhost:8080/ProjetoInterdisciplinarADS/login.jsp`

---

## 👤 Acesso Padrão (Ambiente de Testes)

* **Usuário Administrador:** `admin` | **Senha:** `123`
* **Vendedor:** Login via CPF cadastrado no sistema.

> ⚠️ *Recomenda-se alterar as credenciais padrão antes de publicar o sistema em ambiente de produção.*