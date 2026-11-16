package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class ConnectionFactory {
    
    // URL formatada com protocolo TCPS, host, porta e service name obtidos no painel do FreeSQL / Oracle
    private static final String URL = "jdbc:oracle:thin:@(description=(address=(protocol=tcps)(host=db.freesql.com)(port=2484))(connect_data=(service_name=26ai_un3c1)))";
    
    private static final String USUARIO = "WALISSON_VENTURA_SCHEMA_X1SIJ";
    private static final String SENHA = "497B49LCLqMQEV4F6#APHR41UT7IA0";

    public static Connection conectar() throws SQLException {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
            
            Properties props = new Properties();
            props.put("user", USUARIO);
            props.put("password", SENHA);
            // Configuração para aceitar a conexão segura TCPS fornecida pelo servidor
            props.put("oracle.net.ssl_server_dn_match", "false");
            
            return DriverManager.getConnection(URL, props);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver JDBC do Oracle não foi encontrado no projeto.", e);
        }
    }
}