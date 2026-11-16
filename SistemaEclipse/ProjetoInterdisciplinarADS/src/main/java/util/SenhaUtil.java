package util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public final class SenhaUtil {
    private static final int ITERACOES = 210000;
    private static final int TAMANHO_CHAVE = 256;
    private SenhaUtil() {}

    public static String gerarHash(String senha) {
        try {
            byte[] salt = new byte[16];
            new SecureRandom().nextBytes(salt);
            byte[] hash = derivar(senha.toCharArray(), salt, ITERACOES);
            return "PBKDF2$" + ITERACOES + "$" + Base64.getEncoder().encodeToString(salt) + "$" + Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) { throw new IllegalStateException("Não foi possível proteger a senha.", e); }
    }

    public static boolean verificar(String senha, String armazenada) {
        try {
            if (senha == null || armazenada == null) return false;
            String[] p = armazenada.split("\\$");
            if (p.length != 4 || !"PBKDF2".equals(p[0])) return false;
            int iter = Integer.parseInt(p[1]);
            byte[] salt = Base64.getDecoder().decode(p[2]);
            byte[] esperado = Base64.getDecoder().decode(p[3]);
            byte[] atual = derivar(senha.toCharArray(), salt, iter);
            return MessageDigest.isEqual(esperado, atual);
        } catch (Exception e) { return false; }
    }

    private static byte[] derivar(char[] senha, byte[] salt, int iter) throws Exception {
        KeySpec spec = new PBEKeySpec(senha, salt, iter, TAMANHO_CHAVE);
        return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
    }
}
