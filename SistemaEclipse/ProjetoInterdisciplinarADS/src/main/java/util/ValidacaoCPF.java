package util;

public final class ValidacaoCPF {
    private ValidacaoCPF() {}
    public static String somenteDigitos(String cpf) {
        return cpf == null ? "" : cpf.replaceAll("\\D", "");
    }
    public static boolean validar(String cpf) {
        String s = somenteDigitos(cpf);
        if (s.length() != 11 || s.matches("(\\d)\\1{10}")) return false;
        int soma = 0;
        for (int i = 0; i < 9; i++) soma += (s.charAt(i) - '0') * (10 - i);
        int d1 = 11 - (soma % 11); if (d1 >= 10) d1 = 0;
        if (d1 != s.charAt(9) - '0') return false;
        soma = 0;
        for (int i = 0; i < 10; i++) soma += (s.charAt(i) - '0') * (11 - i);
        int d2 = 11 - (soma % 11); if (d2 >= 10) d2 = 0;
        return d2 == s.charAt(10) - '0';
    }
}
