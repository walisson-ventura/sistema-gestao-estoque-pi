package model;

public class Usuario {
    private int id;
    private String nome, login, senha, perfil, cpf, telefone;
    public Usuario() {}
    public Usuario(int id, String nome, String login, String senha, String perfil) {
        this.id=id; this.nome=nome; this.login=login; this.senha=senha; this.perfil=perfil;
    }
    public int getId(){return id;} public void setId(int v){id=v;}
    public String getNome(){return nome;} public void setNome(String v){nome=v;}
    public String getLogin(){return login;} public void setLogin(String v){login=v;}
    public String getSenha(){return senha;} public void setSenha(String v){senha=v;}
    public String getPerfil(){return perfil;} public void setPerfil(String v){perfil=v;}
    public String getCpf(){return cpf;} public void setCpf(String v){cpf=v;}
    public String getTelefone(){return telefone;} public void setTelefone(String v){telefone=v;}
}
