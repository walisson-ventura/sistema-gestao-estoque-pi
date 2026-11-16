GESTAO DE ESTOQUE - ATUALIZACAO DE PERFIS E VENDEDORES

ANTES DE EXECUTAR:
1. Leia docs/CONFIGURACAO.md.
2. Execute database/atualizacao_usuarios_vendedores.sql no schema Oracle uma unica vez.
3. Configure DB_URL, DB_USER e DB_PASSWORD nas variaveis de ambiente do Tomcat no Eclipse.
4. Troque a senha do usuario Oracle que estava gravada no fonte do ZIP original, pois credenciais embutidas em codigo devem ser consideradas expostas.
5. Execute Project > Clean e reinicie o Tomcat.

ADMIN: login legado admin / 123. Cadastre vendedores na pagina Clientes escolhendo Vendedor.
VENDEDOR: CPF (11 digitos) + senha criada pelo administrador.

O script SQL pressupoe que TB_CLIENTE, TB_VENDA, TB_ITEM_VENDA e TB_PRODUTO ja existem.
