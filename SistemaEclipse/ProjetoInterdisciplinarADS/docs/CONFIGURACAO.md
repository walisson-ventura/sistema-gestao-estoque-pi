# Configuração após importar no Eclipse

## 1. Banco Oracle

1. Faça backup do schema.
2. Abra o SQL Developer / SQL Worksheet conectado ao schema usado pelo sistema.
3. Execute `database/atualizacao_usuarios_vendedores.sql` uma única vez.
4. Confirme a criação de `TB_USUARIO` e da coluna `TB_VENDA.VENDEDOR_ID`.

O script pressupõe que as tabelas `TB_VENDA` e `TB_CLIENTE` já existem, como no projeto original.

## 2. Variáveis de ambiente do Tomcat no Eclipse

A conexão não mantém mais senha Oracle no fonte. Em **Run Configurations > Apache Tomcat > Environment**, adicione:

- `DB_URL` = URL JDBC completa do seu serviço Oracle, por exemplo `jdbc:oracle:thin:@//HOST:1521/SERVICE_NAME`
- `DB_USER` = usuário do schema
- `DB_PASSWORD` = senha atual do schema

Use os valores atuais do painel do seu provedor. Não publique esses dados no Git ou em ZIP compartilhado.

## 3. Acessos

- Administrador legado: usuário `admin`, senha `123` (troque antes de colocar em produção).
- Vendedor: CPF com 11 dígitos + senha criada pelo administrador na aba Clientes.
- Senha de vendedor: mínimo de 8 caracteres; armazenada com PBKDF2-HMAC-SHA256.

## 4. Permissões implementadas

- ADMIN: clientes (CRUD), cadastro de vendedores, produtos/estoque, vendas e relatórios gerais.
- VENDEDOR: consulta e cadastro de clientes, vendas e relatório individual. Não acessa produtos/estoque nem edição/exclusão de clientes.
- Toda venda feita por vendedor grava o `vendedor_id` da sessão autenticada. O filtro do relatório individual usa esse ID, não um parâmetro enviado pelo navegador.

## 5. Importação e execução

Importe a pasta do projeto como **Existing Projects into Workspace**, confira o Target Runtime Tomcat 10.1 e o JDK configurado, execute Project > Clean e reinicie o Tomcat.
