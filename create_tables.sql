CREATE TABLE usuario (
  	id_usuario INT PRIMARY KEY,
  	login VARCHAR(50) UNIQUE,	
  	senha VARCHAR(255),
  	nome VARCHAR(255),
  	contato VARCHAR(255),
  	data_cadastro DATE,
  	telefone VARCHAR(20),
  	email VARCHAR(255),
  	comportamento BOOLEAN
);

CREATE TABLE livro (
  	id_livro INT PRIMARY KEY,
  	autor VARCHAR(255),
  	sinopse TEXT,
  	titulo VARCHAR(255)
);

CREATE TABLE avaliacao (
 	id_avaliacao INT PRIMARY KEY,
 	id_livro INT,
 	id_usuario INT,
 	conteudo_avaliacao TEXT,
 	quantidade_curtidas INT,
 	FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
 	FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

CREATE TABLE conservacao(
	id_conservacao INT PRIMARY KEY,
	estado_conservacao VARCHAR(255)  			
);

CREATE TABLE anuncio (
  	id_anuncio INT PRIMARY KEY,
  	id_livro INT,
  	id_usuario INT,
  	id_conservacao INT,
  	valor DECIMAL(10, 2),
  	descricao TEXT,
  	data_postagem DATE,
  	data_finalizacao DATE,
  	tipo_transacao VARCHAR(255),
  	FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
  	FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  	FOREIGN KEY (id_conservacao) REFERENCES conservacao (id_conservacao)
);

CREATE TABLE localizacao (
  	id_localizacao INT PRIMARY KEY,
  	localizacao VARCHAR(255)
);

CREATE TABLE local_anuncio (
  	id_local_anuncio INT PRIMARY KEY,
  	id_localizacao INT,
	id_anuncio INT,
	FOREIGN KEY (id_localizaco) REFERENCES localizacao (id_localizacao),
  	FOREIGN KEY (id_anuncio) REFERENCES anuncio (id_anuncio)
);

CREATE TABLE wishlist (
  	id_wishlist INT PRIMARY KEY,
  	id_livro INT,
  	id_usuario INT,
  	id_localizacao INT,
  	valor_maximo DECIMAL(10, 2),
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
    FOREIGN KEY (id_wishlist) REFERENCES wishlist (id_wishlist) ON DELETE CASCADE
);



CREATE TABLE curtidas (
  	id_curtidas INT PRIMARY KEY,
  	id_usuario INT,
  	id_avaliacao INT,
 	FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  	FOREIGN KEY (id_avaliacao) REFERENCES avaliacao (id_avaliacao)	
);