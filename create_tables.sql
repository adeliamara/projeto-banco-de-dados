CREATE TABLE usuario (
  id_usuario SERIAL PRIMARY KEY,
  login VARCHAR(50) UNIQUE NOT NULL,
  senha VARCHAR(50) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  contato VARCHAR(255) NOT NULL,
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  telefone VARCHAR(20) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  comportamento_perigoso BOOLEAN DEFAULT false NOT NULL
);


CREATE TABLE livro (
  	id_livro SERIAL PRIMARY KEY,
  	sinopse TEXT,
  	titulo VARCHAR(255) NOT NULL
);


CREATE TABLE avaliacao (
 	id_avaliacao SERIAL PRIMARY KEY,
 	id_livro INT NOT NULL,
 	id_usuario INT NOT NULL,


 	conteudo_avaliacao TEXT NOT NULL,
 	quantidade_curtidas INT DEFAULT 0,
  	removido BOOLEAN NOT NULL DEFAULT FALSE,


 	FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
 	FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);


CREATE TABLE curtida (
	id_curtidas SERIAL PRIMARY KEY,
	id_usuario INT NOT NULL,
	id_avaliacao INT NOT NULL,


	FOREIGN KEY (id_avaliacao) REFERENCES avaliacao(id_avaliacao),
	FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);


CREATE TABLE conservacao(
	id_conservacao SERIAL PRIMARY KEY,
	estado_conservacao VARCHAR(32) NOT NULL  			
);


CREATE TABLE tipo_transacao(
	id_tipo_transacao SERIAL PRIMARY KEY,
	tipo_transacao VARCHAR(32) NOT NULL			
);
		
	
CREATE TABLE anuncio (
  id_anuncio SERIAL PRIMARY KEY,
  id_livro INT NOT NULL,
  id_usuario INT NOT NULL,
  id_conservacao INT NOT NULL,


  valor REAL NOT NULL,
  descricao VARCHAR(255) NOT NULL,
  data_postagem TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  data_finalizacao TIMESTAMP,
  id_tipo_transacao INT NOT NULL,
  removido BOOLEAN NOT NULL DEFAULT FALSE,


  FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
  FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  FOREIGN KEY (id_tipo_transacao) REFERENCES tipo_transacao (id_tipo_transacao)
);


CREATE TABLE localizacao (
  	id_localizacao SERIAL PRIMARY KEY,
	municipio VARCHAR(255) NOT NULL,
  	estado VARCHAR(255) NOT NULL
);


CREATE TABLE local_anuncio (
  	id_local_anuncio SERIAL PRIMARY KEY,
  	id_localizacao INT NOT NULL,
	id_anuncio INT NOT NULL,

	FOREIGN KEY (id_localizacao) REFERENCES localizacao (id_localizacao),
  	FOREIGN KEY (id_anuncio) REFERENCES anuncio (id_anuncio)
);


CREATE TABLE wishlist (
  	id_wishlist SERIAL PRIMARY KEY,
  	id_livro INT NOT NULL,
  	id_usuario INT NOT NULL,
  	id_localizacao INT NOT NULL,


  	valor_maximo REAL NOT NULL,
  	aceita_trocas BOOLEAN,


  	FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
  	FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  	FOREIGN KEY (id_localizacao) REFERENCES localizacao (id_localizacao)
);

CREATE TABLE anuncios_desejados (
  	id_anuncios_desejados SERIAL PRIMARY KEY,
  	id_anuncio INT NOT NULL,
  	id_wishlist INT NOT NULL,


  	anuncio_fechado BOOLEAN,


  	FOREIGN KEY (id_anuncio) REFERENCES anuncio (id_anuncio),
  	FOREIGN KEY (id_wishlist) REFERENCES wishlist (id_wishlist)
);


CREATE TABLE AUTOR (
	id_autor SERIAL PRIMARY KEY,
  	nome TEXT NOT NULL
);

CREATE TABLE AUTOR_LIVRO (
	id_autor_livro SERIAL PRIMARY KEY,
	id_autor INT NOT NULL,
	id_livro INT NOT NULL,

	FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
	FOREIGN KEY (id_autor) REFERENCES autor (id_autor)
);