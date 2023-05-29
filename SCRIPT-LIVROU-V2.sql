CREATE TABLE usuario (
  id_usuario INT PRIMARY KEY,
  login VARCHAR(50) UNIQUE NOT NULL,
  senha VARCHAR(50) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  contato VARCHAR(255) NOT NULL,
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  telefone VARCHAR(20) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  comportamento_perigoso BOOLEAN DEFAULT false NOT NULL
);

INSERT INTO usuario (id_usuario, login, senha, nome, contato, telefone, email, comportamento_perigoso)
VALUES
  (1, 'usuario1', 'senha123', 'Usuário 1', 'Contato 1', '1234567890', 'usuario1@example.com', false),
  (2, 'usuario2', 'senha456', 'Usuário 2', 'Contato 2', '0987654321', 'usuario2@example.com', true),
  (3, 'usuario3', 'senha789', 'Usuário 3', 'Contato 3', '9876543210', 'usuario3@example.com', false);


SELECT * FROM USUARIO

CREATE TABLE livro (
  	id_livro INT PRIMARY KEY,
  	autor VARCHAR(255) NOT NULL,
  	sinopse TEXT,
  	titulo VARCHAR(255) NOT NULL
);

INSERT INTO livro (id_livro, autor, sinopse, titulo) VALUES
(1, 'Autor 1', 'Sinopse do livro 1', 'Livro 1'),
(2, 'Autor 2', 'Sinopse do livro 2', 'Livro 2'),
(3, 'Autor 3', 'Sinopse do livro 3', 'Livro 3');


CREATE TABLE avaliacao (
 	id_avaliacao INT PRIMARY KEY,
 	id_livro INT NOT NULL,
 	id_usuario INT NOT NULL,
 	conteudo_avaliacao TEXT NOT NULL,
 	quantidade_curtidas INT DEFAULT 0,
 	FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
 	FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

INSERT INTO avaliacao (id_avaliacao, id_livro, id_usuario, conteudo_avaliacao, quantidade_curtidas)
VALUES
  (1, 1, 1, 'Ótimo livro!', 10),
  (2, 2, 2, 'Recomendo!', 5),
  (3, 3, 3, 'História emocionante.', 2);


CREATE TABLE curtida (
	id_curtidas INT PRIMARY KEY,
	id_usuario INT NOT NULL,
	id_avaliacao INT NOT NULL,
	FOREIGN KEy (id_avaliacao) REFERENCES avaliacao(id_avaliacao),
	FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);


CREATE TABLE conservacao(
	id_conservacao INT PRIMARY KEY,
	estado_conservacao VARCHAR(32)  			
);

INSERT INTO conservacao VALUES 
	(1, 'Novo'),
	(2, 'Seminovo'),
	(3, 'Com muitas marcas de uso');




CREATE TABLE tipo_transacao(
	id_tipo_transacao INT PRIMARY KEY,
	tipo_transacao VARCHAR(32)  			
);

INSERT INTO tipo_transacao VALUES 
	(1, 'Apenas venda'),
	(2, 'Apenas troca'),
	(3, 'Troca e venda');
	
	
	
CREATE TABLE anuncio (
  id_anuncio INT PRIMARY KEY,
  id_livro INT NOT NULL,
  id_usuario INT NOT NULL,
  id_conservacao INT NOT NULL,
  valor REAL NOT NULL,
  descricao VARCHAR(255) NOT NULL,
  data_postagem TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  data_finalizacao TIMESTAMP,
  id_tipo_transacao int not NULL,
  FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
  FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  FOREIGN KEY (id_tipo_transacao) REFERENCES tipo_transacao (id_tipo_transacao)
);


INSERT INTO anuncio (id_anuncio, id_livro, id_usuario, id_conservacao, valor, descricao, data_postagem, data_finalizacao, id_tipo_transacao)
VALUES (1, 1, 1, 1, 29.99, 'Ótimo livro para leitura', '2023-05-21 10:00:00', NULL, 1);

INSERT INTO anuncio (id_anuncio, id_livro, id_usuario, id_conservacao, valor, descricao, data_postagem, data_finalizacao, id_tipo_transacao)
VALUES (2, 2, 2, 2, 15.99, 'Livro em bom estado', '2023-05-22 14:30:00', NULL, 2);

INSERT INTO anuncio (id_anuncio, id_livro, id_usuario, id_conservacao, valor, descricao, data_postagem, data_finalizacao, id_tipo_transacao)
VALUES (3, 3, 3, 3, 9.99, 'Livro usado, preço baixo', '2023-05-23 17:45:00', NULL, 3);


CREATE TABLE localizacao (
  	id_localizacao INT PRIMARY KEY,
	municipio VARCHAR(255) NOT NULL,
  	estado VARCHAR(255) NOT NULL
);

INSERT INTO localizacao (id_localizacao, municipio, estado)
VALUES (1, 'São Paulo', 'São Paulo');

INSERT INTO localizacao (id_localizacao, municipio, estado)
VALUES (2, 'Rio de Janeiro', 'Rio de Janeiro');

INSERT INTO localizacao (id_localizacao, municipio, estado)
VALUES (3, 'Belo Horizonte', 'Minas Gerais');

CREATE TABLE local_anuncio (
  	id_local_anuncio INT PRIMARY KEY,
  	id_localizacao INT NOT NULL,
	id_anuncio INT NOT NULL,
	FOREIGN KEY (id_localizacao) REFERENCES localizacao (id_localizacao),
  	FOREIGN KEY (id_anuncio) REFERENCES anuncio (id_anuncio)
);


CREATE TABLE wishlist (
  	id_wishlist INT PRIMARY KEY,
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
  	id_anuncios_desejados INT PRIMARY KEY,
  	id_anuncio INT NOT NULL,
  	id_wishlist INT NOT NULL,
  	anuncio_fechado BOOLEAN,
  	FOREIGN KEY (id_anuncio) REFERENCES anuncio (id_anuncio),
  	FOREIGN KEY (id_wishlist) REFERENCES wishlist (id_wishlist)
);

















-- sempre que inserir uma curtida, deverá atualizar a quantidade de curtidas da avaliacao
CREATE FUNCTION update_likes()
RETURNS trigger as $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		UPDATE avaliacao
		SET quantidade_curtidas = quantidade_curtidas + 1
		WHERE id_avaliacao = NEW.id_avaliacao;
	ELSIF TG_OP = 'DELETE' THEN
		UPDATE avaliacao
		SET quantidade_curtidas = quantidade_curtidas - 1
		WHERE id_avaliacao = OLD.id_avaliacao;
	END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_curtidas
AFTER INSERT OR DELETE ON curtida
FOR EACH ROW
EXECUTE PROCEDURE update_likes();


-- SE O USUARIO JÁ TIVER CURTIDO NÃO DEVE inserir uma curtida
--   ESSA FUNCAO PODERIA SER JUNTO DO UPDATE LIKES
CREATE OR REPLACE FUNCTION verificar_curtida()
    RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o usuário já curtiu a avaliação
    IF EXISTS (
        SELECT 1
        FROM curtida
        WHERE id_avaliacao = NEW.id_avaliacao
        AND id_usuario = NEW.id_usuario
    ) THEN
        RAISE EXCEPTION 'O usuário já curtiu esta avaliação.';
    END IF;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do trigger
CREATE TRIGGER trigger_verificar_curtida
    BEFORE INSERT ON curtida
    FOR EACH ROW
    EXECUTE FUNCTION verificar_curtida()
;










insert into curtida values (4, 1, 1);
insert into curtida values (2, 2, 1);

DELETE FROM curtida
WHERE id_curtidas = 1;


select * from curtida;

DROP FUNCTION update_likes();
drop trigger update_curtidas on curtida;








----------------- QUANDO ADICIONAR NOVA WISHLIST DEVE ADICIONAR UM NOVO ITEM NO ANUNCIO DESEJADO
CREATE FUNCTION verificar_anuncios_para_wishlist() 
RETURNS TRIGGER AS $$
BEGIN
	-- DEVE AVALIAR O UPDATE TAMBÉM
	-- ESSE CASO ATENDE APENS QUANDO id_tipo_transacao != 1 (ACEITA TROCA)
	IF TG_OP = 'INSERT' THEN
		IF NEW.aceita_trocas IS TRUE THEN
			INSERT INTO anuncios_desejados (id_wishlist, id_anuncio, anuncio_fechado)
			SELECT NEW.id_wishlist, anuncio.id_anuncio, false
			FROM anuncio
			LEFT JOIN local_anuncio ON local_anuncio.id_anuncio = anuncio.id_anuncio
			WHERE 
			anuncio.id_livro = new.id_livro AND
			anuncio.data_finalizacao IS NULL AND
			(NEW.valor_maximo >= anuncio.valor OR (anuncio.id_tipo_transacao != 1 AND local_anuncio.id_localizacao = NEW.id_localizacao))
			group by  NEW.id_wishlist, anuncio.id_anuncio;
		END IF;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGgER trigger_verificar_anuncios_para_wishlist
after insert or delete on wishlist
for each row
execute procedure verificar_anuncios_para_wishlist(); 

------------------------------
drop trigger trigger_verificar_anuncios_para_wishlist on wishlist;
drop function verificar_anuncios_para_wishlist;

select * from anuncio

insert into local_anuncio values (1,1,1);
insert into local_anuncio values (2,2,1);

insert into wishlist values (6,1,1,1, 20, true);
insert into wishlist values (5,2,1,1, 10, true);
insert into wishlist values (4,1,1,1, 40, true);
insert into wishlist values (12,2,1,1, 60, true);
insert into wishlist values (13,2,1,2, 60, true);
insert into wishlist values (14,2,1,2, 20, true);
insert into wishlist values (16,2,1,2, 20, true);
insert into wishlist values (76,2,1,2, 20, true);

insert into wishlist values (8,1,1,1, 60, false);
insert into wishlist values (9,1,1,1, 10, false);



insert into wishlist values (1,1,1,1, 20, true);
SELECT NEW.id_wishlist, anuncio.id_anuncio, false
			FROM anuncio
			LEFT JOIN local_anuncio ON local_anuncio.id_anuncio = anuncio.id_anuncio
			WHERE 
			anuncio.id_livro = 2 AND
			anuncio.data_finalizacao IS NULL AND
			(NEW.valor_maximo >= anuncio.valor OR (anuncio.id_tipo_transacao != 1 AND local_anuncio.id_localizacao = NEW.id_localizacao))
			group by  NEW.id_wishlist, anuncio.id_anuncio;
			
select * from anuncios_desejados;
select * from wishlist;
			 
			 select * from anuncio;




