-- Criação das Tabelas

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


 	conteudo TEXT NOT NULL,
 	quantidade_curtidas INT DEFAULT 0,
  	removido BOOLEAN NOT NULL DEFAULT FALSE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,


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
	id_conservacao INT PRIMARY KEY,
	estado_conservacao VARCHAR(32) NOT NULL  			
);


CREATE TABLE tipo_transacao(
	id_tipo_transacao INT PRIMARY KEY,
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
  data_finalizacao TIMESTAMP DEFAULT NULL,
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
    FOREIGN KEY (id_wishlist) REFERENCES wishlist (id_wishlist) ON DELETE CASCADE
);


CREATE TABLE AUTOR (
	id_autor SERIAL PRIMARY KEY,
  	nome TEXT NOT NULL
);

CREATE TABLE AUTOR_LIVRO (
	id_autor INT NOT NULL,
	id_livro INT NOT NULL,

	PRIMARY KEY (id_autor, id_livro),
	FOREIGN KEY (id_livro) REFERENCES livro (id_livro),
	FOREIGN KEY (id_autor) REFERENCES autor (id_autor)
);

CREATE TABLE alerta (
  id_alerta SERIAL PRIMARY KEY,
  id_usuario INT NOT NULL,
  data_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  descricao TEXT
);





-- ========================================================= Tabela Autor

-- FUNCTION: AUTOR EXISTE?

CREATE OR REPLACE FUNCTION autor_ja_cadastrado(var_nome TEXT)
RETURNS BOOLEAN AS $$
DECLARE
BEGIN

	RETURN (SELECT EXISTS (SELECT * 
				   FROM autor
				  WHERE autor.nome ILIKE var_nome));

END;
$$ LANGUAGE plpgsql;



-- TRIGGER INSERT E UPDATE: verifica se nome de autor já existe na tabela

CREATE OR REPLACE FUNCTION verificar_nome_autor()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
	
    IF autor_ja_cadastrado(NEW.NOME) THEN
        RAISE EXCEPTION 'Autor já cadastrado';
    END IF;
	
	RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_nao_permitir_autores_repetidos
BEFORE UPDATE OR INSERT ON autor
FOR EACH ROW
EXECUTE PROCEDURE verificar_nome_autor();



-- FUNÇÃO: cadastrar autor

CREATE OR REPLACE FUNCTION cadastrar_autor(var_nome TEXT)
RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO autor
    VALUES(DEFAULT, var_nome);
	RAISE NOTICE 'Autor Cadastrado';

END;
$$ LANGUAGE plpgsql;


-- FUNÇÃO: atualizar autor

CREATE OR REPLACE FUNCTION atualizar_autor(var_id_autor INT, var_nome TEXT)
RETURNS VOID AS $$
DECLARE
BEGIN

    UPDATE autor
    SET NOME = var_nome
    WHERE id_autor = var_id_autor;

	RAISE NOTICE 'Autor de id % foi atualizado', var_id_autor;

END;
$$ LANGUAGE plpgsql;


-- TRIGGER DELETE: não é possível deletar na tabela autor
CREATE OR REPLACE FUNCTION bloquear_delete_na_tabela_autor()
RETURNS trigger as $$
BEGIN
    RAISE EXCEPTION 'Não é possível realizar operação de delete na tabela autor';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_bloquear_delete_tabela_autor
BEFORE DELETE ON autor
FOR EACH ROW
EXECUTE PROCEDURE bloquear_delete_na_tabela_autor();




-- ========================================================= Tabela Livro
-- FUNCTION: verificar se o título do livro já existe

CREATE FUNCTION verificar_se_titulo_ja_existe(var_titulo TEXT)
RETURNS BOOLEAN AS $$
DECLARE
BEGIN
	RETURN EXISTS (SELECT 1 FROM LIVRO WHERE LIVRO.TITULO ILIKE var_titulo);
END;
$$ LANGUAGE plpgsql;


-- FUNCTION: verificar se o título existente possui os mesmos autores do livro que está sendo inserido

CREATE FUNCTION verificar_se_titulo_existente_possui_autores_repetidos(var_titulo TEXT, var_autores TEXT[])
RETURNS VOID AS $$
DECLARE

BEGIN

	CREATE TEMPORARY TABLE autores_encontrados (
		nome_autor TEXT
	);
	
	INSERT INTO autores_encontrados (nome_autor)
	SELECT autor.nome FROM autor
	JOIN autor_livro ON autor.id_autor = autor_livro.id_autor
    JOIN livro ON autor_livro.id_livro = livro.id_livro
	WHERE livro.titulo = var_titulo;


	FOR i IN 1..array_length(var_autores, 1) LOOP

		IF EXISTS(SELECT 1 FROM autores_encontrados WHERE nome_autor ILIKE var_autores[i]) THEN
			RAISE EXCEPTION 'O título que você está inserindo já existe';
		END IF;
   
    END LOOP;

	DROP TABLE autores_encontrados;


END;
$$ LANGUAGE plpgsql;



-- FUNCTION: inserir dados na tabela autor_livro

CREATE OR REPLACE FUNCTION inserir_tabela_autor_livro(var_titulo TEXT, var_nome_autor TEXT)
RETURNS VOID AS $$
DECLARE
	var_id_autor int;
	var_id_livro int;
BEGIN

	SELECT id_autor INTO var_id_autor 
	FROM AUTOR 
	WHERE AUTOR.nome ILIKE var_nome_autor;

	
	SELECT id_livro INTO var_id_livro 
	FROM LIVRO 
	WHERE titulo ILIKE var_titulo;

	INSERT INTO AUTOR_LIVRO
	VALUES(var_id_autor, var_id_livro);

END;
$$ LANGUAGE plpgsql;



-- TRIGGER DELETE e update: Bloquear delete e update na tabela autor_livro

CREATE OR REPLACE FUNCTION bloquear_delete_update_na_tabela_autor_livro()
RETURNS trigger as $$
BEGIN
    RAISE EXCEPTION 'Não é possível realizar operação de delete ou update na tabela autor_livro';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_bloquear_delete_update_tabela_autor_livro
BEFORE DELETE OR UPDATE ON autor_livro
FOR EACH ROW
EXECUTE PROCEDURE bloquear_delete_update_na_tabela_autor_livro();


-- FUNCTION: inserir livro no banco de dados

CREATE OR REPLACE FUNCTION inserir_livro(var_sinopse TEXT, var_titulo TEXT, var_autores TEXT[])
RETURNS VOID AS $$
DECLARE
BEGIN


	IF verificar_se_titulo_ja_existe(var_titulo) THEN
		PERFORM verificar_se_titulo_existente_possui_autores_repetidos(var_titulo, var_autores);
	END IF;

	INSERT INTO livro
	VALUES (DEFAULT, var_sinopse, var_titulo);

    FOR i IN 1..array_length(var_autores, 1) LOOP

        IF NOT (autor_ja_cadastrado(var_autores[i])) THEN
            PERFORM cadastrar_autor(var_autores[i]);
        END IF;

		PERFORM inserir_tabela_autor_livro(var_titulo, var_autores[i]);

    END LOOP;
	RAISE NOTICE 'O livro % foi inserido', var_titulo;
END;
$$ LANGUAGE plpgsql;






-- ========================================================= Tabela AVALIAÇÃO

-- ACHO QUE TA TUDO CERTO

--FUNCTION: Realizar avaliação

CREATE FUNCTION avaliar_livro(var_id_livro INT, var_id_usuario INT, var_conteudo TEXT)
RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO avaliacao
    VALUES(DEFAULT, var_id_livro, var_id_usuario, var_conteudo, DEFAULT, DEFAULT, DEFAULT);

    RAISE NOTICE 'A avaliação foi publicada';
END;
$$ LANGUAGE plpgsql;




--FUNCTION: Deletar avaliação

CREATE FUNCTION deletar_avaliacao_livro(var_id_avaliacao INT)
RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE avaliacao SET removido = true
    WHERE id_avaliacao = var_id_avaliacao; 

    RAISE NOTICE 'A avaliação de id % foi removida', var_id_avaliacao;
END;
$$ LANGUAGE plpgsql;


-- TRIGGER DELETE e update: Bloquear delete  na tabela autor_livro

CREATE OR REPLACE FUNCTION bloquear_delete_na_tabela_avaliacao()
RETURNS trigger as $$
BEGIN
    RAISE EXCEPTION 'Não é possível realizar operação de delete na tabela avaliacao';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_bloquear_delete_tabela_avaliacao
BEFORE DELETE ON avaliacao
FOR EACH ROW
EXECUTE PROCEDURE bloquear_delete_na_tabela_avaliacao();



--FUNCTION: Atualizar avaliação

CREATE FUNCTION atualizar_avaliacao_livro(var_id_avaliacao INT, var_conteudo TEXT)
RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE avaliacao SET conteudo = var_conteudo
    WHERE id_avaliacao = var_id_avaliacao; 

        RAISE NOTICE 'O conteúdo da avaliação de id % foi atualizado', var_id_avaliacao;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION restaurar_avalicacao_removida(var_id_avaliacao INT)
RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE avaliacao SET removido = false
    WHERE id_avaliacao = var_id_avaliacao; 

        RAISE NOTICE 'A da avaliação de id % foi restaurada', var_id_avaliacao;

END;
$$ LANGUAGE plpgsql;




-- ========================================================= Tabela CURTIDAS


CREATE OR REPLACE FUNCTION verificar_se_avaliacao_existe(var_id_avaliacao int)
RETURNS VOID AS $$
DECLARE
avaliacao_existe bool;
BEGIN
SELECT NOT EXISTS (SELECT * FROM AVALIACAO WHERE AVALIACAO.ID_AVALIACAO = var_id_avaliacao) INTO avaliacao_existe;
IF (avaliacao_existe) THEN
RAISE EXCEPTION 'Avaliação de id % não existe.', var_id_avaliacao;
END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION verificar_se_usuario_existe(var_id_usuario int)
RETURNS VOID AS $$
DECLARE
usuario_existe bool;
BEGIN
SELECT NOT EXISTS (SELECT * FROM usuario WHERE USUARIO.ID_USUARIO = var_id_usuario) INTO usuario_existe;
IF (usuario_existe) THEN
RAISE EXCEPTION 'Usuário de id % não existe.', var_id_usuario;
END IF;
END;
$$ LANGUAGE plpgsql;

-- FUNÇÃO: curtir uma avaliação
CREATE OR REPLACE FUNCTION curtir_avaliacao(var_id_usuario INT, var_id_avaliacao INT)
RETURNS VOID AS $$

BEGIN
    PERFORM verificar_se_usuario_existe(var_id_usuario);
    PERFORM verificar_se_avaliacao_existe(var_id_avaliacao);

    INSERT INTO curtida
    VALUES(default, var_id_usuario, var_id_avaliacao);
	
	RAISE NOTICE 'Curtida adicionada.';
END;

$$ LANGUAGE plpgsql;




-- FUNÇÃO: descurtir uma avaliação
CREATE OR REPLACE FUNCTION descurtir_avaliacao(var_id_usuario INT, var_id_avaliacao INT)
RETURNS VOID AS $$

BEGIN

    PERFORM verificar_se_usuario_existe(var_id_usuario);
    PERFORM verificar_se_avaliacao_existe(var_id_avaliacao);

    DELETE FROM curtida
    WHERE curtida.id_usuario = var_id_usuario and curtida.id_avaliacao = var_id_avaliacao;

    	RAISE NOTICE 'Curtida removida.';

END;

$$ LANGUAGE plpgsql;




-- TRIGGER UPDATE: não é possível atualizar a tabela curtida
CREATE OR REPLACE FUNCTION bloquear_update_tabela_curtida()
RETURNS trigger as $$
BEGIN
    RAISE EXCEPTION 'Não é possível dar update na tabela curtida';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_bloquear_update_tabela_curtida
AFTER UPDATE ON curtida
FOR EACH ROW
EXECUTE PROCEDURE bloquear_update_tabela_curtida();




-- TRIGGER INSERT OR DELETE: sempre que inserir ou remover uma curtida, deverá atualizar a quantidade de curtidas da avaliacao

CREATE FUNCTION update_likes_da_avaliacao()
    RETURNS trigger as $$
    BEGIN
        IF TG_OP = 'INSERT' THEN
            UPDATE avaliacao
            SET quantidade_curtidas = quantidade_curtidas + 1
            WHERE id_avaliacao = NEW.id_avaliacao;
                RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE avaliacao
            SET quantidade_curtidas = quantidade_curtidas - 1
            WHERE id_avaliacao = OLD.id_avaliacao;
                RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_curtidas
AFTER INSERT OR DELETE ON curtida
FOR EACH ROW
EXECUTE PROCEDURE update_likes_da_avaliacao();



-- TRIGGER INSERT: verificar se o usuário já curtiu uma avaliação
CREATE OR REPLACE FUNCTION verificar_se_usuario_ja_curtiu()
RETURNS TRIGGER AS $$
DECLARE
    usuario_ja_curtiu_avaliacao boolean;
BEGIN
    -- Verifica se o usuário já curtiu a avaliação
    SELECT EXISTS (
        SELECT 1
        FROM curtida
        WHERE id_avaliacao = NEW.id_avaliacao
        AND id_usuario = NEW.id_usuario
    ) INTO usuario_ja_curtiu_avaliacao;


    IF usuario_ja_curtiu_avaliacao THEN
        RAISE EXCEPTION 'O usuário já curtiu esta avaliação.';
    END IF;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_se_usuario_ja_curtiu
BEFORE INSERT ON curtida
FOR EACH ROW
EXECUTE PROCEDURE verificar_se_usuario_ja_curtiu();
	
	




-- ========================================================= Tabela USUÁRIO

-- FUNCTION: cadastrar usuário

CREATE FUNCTION cadastrar_usuario(var_login VARCHAR(50), var_senha VARCHAR(50), var_nome VARCHAR(255), var_contato VARCHAR(255), var_telefone VARCHAR(20), var_email VARCHAR(255))
RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO USUARIO
    VALUES(DEFAULT, var_login, var_senha, var_nome, var_contato, DEFAULT, var_telefone, var_email, DEFAULT);

    RAISE NOTICE '% foi cadastrado com sucesso', var_nome;
END;
$$ LANGUAGE plpgsql;
--'

CREATE OR REPLACE FUNCTION atualizar_usuario(
  p_id_usuario INT,
  p_login VARCHAR(50) DEFAULT NULL,
  p_senha VARCHAR(50) DEFAULT NULL,
  p_nome VARCHAR(255) DEFAULT NULL,
  p_contato VARCHAR(255) DEFAULT NULL,
  p_telefone VARCHAR(20) DEFAULT NULL,
  p_email VARCHAR(255) DEFAULT NULL,
  p_comportamento_perigoso BOOLEAN DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE usuario SET
    login = COALESCE(p_login, login),
    senha = COALESCE(p_senha, senha),
    nome = COALESCE(p_nome, nome),
    contato = COALESCE(p_contato, contato),
    telefone = COALESCE(p_telefone, telefone),
    email = COALESCE(p_email, email),
    comportamento_perigoso = COALESCE(p_comportamento_perigoso, comportamento_perigoso)
  WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;


-- Function: Inserir alerta

CREATE OR REPLACE FUNCTION inserir_alerta(var_id_usuario INT, var_descricao TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO alerta (id_usuario, descricao)
  VALUES (var_id_usuario, var_descricao);

  RAISE NOTICE 'Alerta inserido para o usuário %', var_id_usuario;
END;
$$ LANGUAGE plpgsql;






-- Listar alertas de comportamentos perigosos

CREATE OR REPLACE FUNCTION listar_alertas()
RETURNS TABLE (
    alerta_id INT,
    alerta_descricao TEXT,
    data_criacao TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY 
    SELECT id_alerta, descricao AS alerta_descricao, data_alerta
    FROM ALERTA
    ORDER BY data_alerta DESC;
END;
$$ LANGUAGE plpgsql;


-- FUNCTION: Remover anúncios e avaliações de usuário com comportamento perigoso

CREATE OR REPLACE FUNCTION remover_anuncios_avaliacoes_usuario_perigoso(var_id_usuario int)
RETURNS VOID AS $$

DECLARE
   id_avaliacao_temp INT;
   id_anuncio_temp INT;
BEGIN


    IF EXISTS (SELECT 1 FROM USUARIO WHERE comportamento_perigoso = true AND id_usuario = var_id_usuario) THEN
        
        CREATE TEMPORARY TABLE anuncios_encontrados (
            id_anuncios_encontrados INT
        );

        INSERT INTO anuncios_encontrados (id_anuncios_encontrados)
        SELECT id_anuncio FROM anuncio
        WHERE id_usuario = var_id_usuario;

        CREATE TEMPORARY TABLE avaliacoes_encontradas (
            id_avaliacoes_encontradas INT
        );

        INSERT INTO avaliacoes_encontradas (id_avaliacoes_encontradas)
        SELECT id_avaliacao FROM avaliacao
        WHERE id_usuario = var_id_usuario;


        FOR id_avaliacao_temp IN (SELECT id_avaliacoes_encontradas FROM avaliacoes_encontradas) LOOP
            
            PERFORM deletar_avaliacao_livro(id_avaliacao_temp);

        END LOOP;


        FOR id_anuncio_temp IN (SELECT id_anuncios_encontrados FROM anuncios_encontrados) LOOP
            
            UPDATE ANUNCIO
            SET REMOVIDO = TRUE
            WHERE ID_ANUNCIO = ID_ANUNCIO_TEMP;

        END LOOP;

        RAISE NOTICE 'Todas as publicações do usuário % foram removidas por comportamento perigoso.', var_id_usuario;

        DROP TABLE anuncios_encontrados;
        DROP TABLE avaliacoes_encontradas;
    ELSE
        RAISE NOTICE 'O usuário % selecionado não é perigoso', var_id_usuario;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- Trigger: verifica comportamento perigoso de usuário e faz algo repassa para uma tabela

CREATE OR REPLACE FUNCTION verificar_comportamento_perigoso()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
  IF NEW.comportamento_perigoso = true THEN
    PERFORM inserir_alerta(NEW.id_usuario, 'Comportamento perigoso detectado para o usuário ' || NEW.login);

    PERFORM remover_anuncios_avaliacoes_usuario_perigoso(NEW.id_usuario);
    
    -- BLOQUEAR ACESSO DO USUÁRIO
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_comportamento_perigoso
AFTER INSERT OR UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION verificar_comportamento_perigoso();


-- Function: alterar comportamento de usuário para perigoso

CREATE FUNCTION alterar_comportamento_do_usuario_para_perigoso(var_id_user int)
RETURNS VOID AS $$
BEGIN

    PERFORM verificar_se_usuario_existe(var_id_user);

    UPDATE USUARIO
    SET COMPORTAMENTO_PERIGOSO = TRUE
    WHERE id_usuario = var_id_user;
    RAISE NOTICE 'Usuário de id % tornou-se perigoso', var_id_user;
END;
$$ LANGUAGE plpgsql;




-- ========================================================= Tabela LOCALIZAÇÃO

CREATE OR REPLACE FUNCTION proibir_alteracao_localizacao()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Não é permitido deletar ou atualizar registros na tabela localizacao.';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_proibir_alteracao_localizacao
BEFORE DELETE OR UPDATE ON localizacao
FOR EACH ROW
EXECUTE FUNCTION proibir_alteracao_localizacao();

CREATE OR REPLACE FUNCTION verificar_localizacao_existente()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM localizacao
        WHERE municipio = NEW.municipio
        AND estado = NEW.estado
    ) THEN
        RAISE EXCEPTION 'Localização já existe.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_localizacao_existente
BEFORE INSERT ON localizacao
FOR EACH ROW
EXECUTE FUNCTION verificar_localizacao_existente();


CREATE OR REPLACE FUNCTION cadastrar_localizacao(
    p_municipio VARCHAR(255),
    p_estado VARCHAR(255)
)
RETURNS INT AS $$
DECLARE
    v_localizacao_id INT;
BEGIN
    INSERT INTO localizacao (municipio, estado)
    VALUES (p_municipio, p_estado)
    RETURNING id_localizacao INTO v_localizacao_id;

    RETURN v_localizacao_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_duplicate_local_anuncio() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM local_anuncio
        WHERE id_local_anuncio <> NEW.id_local_anuncio
        AND id_anuncio = NEW.id_anuncio
        AND id_localizacao = NEW.id_localizacao
    ) THEN
        RAISE EXCEPTION 'Já existe um par com o mesmo id_anuncio e id_localizacao';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_duplicate_local_anuncio_trigger
BEFORE INSERT OR UPDATE ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_local_anuncio();



-- ========================================================= Tabela wishlist


----------------- QUANDO ADICIONAR NOVA WISHLIST DEVE ADICIONAR UM NOVO ITEM NO ANUNCIO DESEJADO
CREATE OR REPLACE FUNCTION verificar_anuncios_para_wishlist() 
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'UPDATE' THEN
			DELETE FROM anuncios_desejados
			WHERE id_wishlist = new.id_wishlist;
	END IF;
	IF NEW.aceita_trocas IS TRUE THEN
			INSERT INTO anuncios_desejados (id_wishlist, id_anuncio, anuncio_fechado)
			SELECT NEW.id_wishlist, anuncio.id_anuncio, false
			FROM anuncio
			LEFT JOIN local_anuncio ON local_anuncio.id_anuncio = anuncio.id_anuncio
			WHERE 
			anuncio.id_livro = new.id_livro AND
			anuncio.data_finalizacao IS NULL AND local_anuncio.id_localizacao = NEW.id_localizacao and
			((new.valor_maximo >= anuncio.valor and anuncio.id_tipo_transacao != 2) or  anuncio.id_tipo_transacao != 1)	 and removido = false		
			group by  NEW.id_wishlist, anuncio.id_anuncio;
	ELSE
			INSERT INTO anuncios_desejados (id_wishlist, id_anuncio, anuncio_fechado)
			SELECT NEW.id_wishlist, anuncio.id_anuncio, false
			FROM anuncio
			LEFT JOIN local_anuncio ON local_anuncio.id_anuncio = anuncio.id_anuncio
			WHERE 
			anuncio.id_livro = new.id_livro AND
			anuncio.data_finalizacao IS NULL AND
			NEW.valor_maximo >= anuncio.valor AND anuncio.id_tipo_transacao != 2 and local_anuncio.id_localizacao = NEW.id_localizacao
			and removido = false
			group by  NEW.id_wishlist, anuncio.id_anuncio;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGgER trigger_verificar_anuncios_para_wishlist
after insert or UPDATE on wishlist
for each row
execute procedure verificar_anuncios_para_wishlist(); 

------------------------------

CREATE OR REPLACE FUNCTION cadastrar_wishlist(id_livro INT, id_usuario INT, id_localizacao INT,  valor_maximo REAL, aceita_trocas BOOLEAN)
RETURNS VOID AS $$
BEGIN
    INSERT INTO wishlist
    VALUES(DEFAULT, id_livro, id_usuario, id_localizacao, valor_maximo, aceita_trocas);
	RAISE NOTICE 'Wishlist cadastrada!';
END;
$$ LANGUAGE plpgsql;




-- ========================================================= Tabela ANÚNCIO

CREATE OR REPLACE FUNCTION cadastrar_anuncio_com_localizacoes(
    p_id_livro INT,
    p_id_usuario INT,
    p_id_conservacao INT,
    p_valor REAL,
    p_descricao VARCHAR(255),
    p_id_tipo_transacao INT,
    p_id_localizacoes INT[]
)
RETURNS VOID AS $$
DECLARE
    v_anuncio_id INT;
    v_id_localizacao INT;
    v_localizacao_exists BOOLEAN;
BEGIN
    INSERT INTO anuncio (
        id_livro,
        id_usuario,
        id_conservacao,
        valor,
        descricao,
        id_tipo_transacao
    )
    VALUES (
        p_id_livro,
        p_id_usuario,
        p_id_conservacao,
        p_valor,
        p_descricao,
        p_id_tipo_transacao
    )
    RETURNING id_anuncio INTO v_anuncio_id;

    FOREACH v_id_localizacao IN ARRAY p_id_localizacoes
    LOOP
        SELECT EXISTS (
            SELECT 1 FROM localizacao
            WHERE id_localizacao = v_id_localizacao
        ) INTO v_localizacao_exists;

        IF NOT v_localizacao_exists THEN
            RAISE EXCEPTION 'A localização com o ID % não existe.', v_id_localizacao;
        END IF;

        INSERT INTO local_anuncio (id_localizacao, id_anuncio)
        VALUES (v_id_localizacao, v_anuncio_id);
    END LOOP;
    
    RAISE NOTICE 'Anúncio publicado.';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION marcar_como_removido()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE anuncio
    SET removido = TRUE
    WHERE id_anuncio = old.id_anuncio;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_deletar_anuncio
BEFORE DELETE ON anuncio
FOR EACH ROW
EXECUTE PROCEDURE marcar_como_removido();


CREATE OR REPLACE FUNCTION deletar_anuncio(p_id_anuncio INT)
RETURNS VOID AS $$
BEGIN
    UPDATE anuncio
    SET removido = TRUE
    WHERE id_anuncio = p_id_anuncio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verificar_wishlists_correspondentes_aos_anuncios()
RETURNS TRIGGER AS $$
DECLARE
    v_wishlist_exists BOOLEAN;
    v_wishlist_id INT;
BEGIN
 	IF TG_OP = 'DELETE'  OR TG_OP ='UPDATE' THEN
        -- Excluir registros na tabela anuncios_desejados ao excluir um anúncio
        DELETE FROM anuncios_desejados WHERE id_anuncio = OLD.id_anuncio;
	END IF;
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT EXISTS (
            SELECT 1 FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 AND aceita_trocas = TRUE) OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3 AND aceita_trocas = TRUE)
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio)
			and     (SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE
        ) INTO v_wishlist_exists;

        IF v_wishlist_exists THEN
            -- Obter o ID da wishlist correspondente
            INSERT INTO anuncios_desejados (id_anuncio, id_wishlist, anuncio_fechado)
            SELECT NEW.id_anuncio, id_wishlist, false            
            FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 AND aceita_trocas = TRUE) OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3 AND aceita_trocas = TRUE)
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio) and
				(SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE;

        ELSE
            -- Excluir registros na tabela anuncios_desejados se não correspondem a nenhuma wishlist
            DELETE FROM anuncios_desejados WHERE id_anuncio = NEW.id_anuncio;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


--'

CREATE TRIGGER trigger_verificar_wishlists_correspondentes_aos_anuncios
AFTER INSERT OR UPDATE OR DELETE ON anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_wishlists_correspondentes_aos_anuncios();






CREATE OR REPLACE FUNCTION restaurar_anuncio_removido(var_id_anuncio INT)
RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE anuncio SET removido = false
    WHERE id_anuncio = var_id_anuncio; 

        RAISE NOTICE 'O anúncio  de id % foi restaurado', var_id_anuncio;

END;
$$ LANGUAGE plpgsql;






CREATE OR REPLACE FUNCTION atualizar_anuncio_fechado()
  RETURNS TRIGGER AS $$
BEGIN
  IF NEW.data_finalizacao IS NOT NULL THEN
    UPDATE anuncios_desejados SET anuncio_fechado = TRUE WHERE id_anuncio = NEW.id_anuncio;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER atualizacao_anuncio_fechado_trigger
AFTER UPDATE ON anuncio
FOR EACH ROW
EXECUTE FUNCTION atualizar_anuncio_fechado();



CREATE OR REPLACE FUNCTION marcar_anuncio_como_fechado(p_id_anuncio INT)
  RETURNS VOID AS $$
BEGIN
  UPDATE anuncio
  SET data_finalizacao = CURRENT_TIMESTAMP
  WHERE id_anuncio = p_id_anuncio;
  raise info 'Anúncio fechado %',p_id_anuncio ;
END;
$$ LANGUAGE plpgsql;








------------------------------------------------------------ Tabela LOCAL_ANÚNCIO
 

CREATE OR REPLACE FUNCTION verificar_existencia_local_anuncio()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM local_anuncio
        WHERE id_anuncio = NEW.id_anuncio
        AND id_localizacao = NEW.id_localizacao
    ) THEN
        RAISE EXCEPTION 'Já existe um registro na tabela local_anuncio para o anúncio e ID de localização especificados.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_existencia_local_anuncio
BEFORE UPDATE OR INSERT ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_existencia_local_anuncio();




CREATE OR REPLACE FUNCTION adicionar_local_para_anuncio(p_id_anuncio INT, p_id_localizacao INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO local_anuncio (id_localizacao, id_anuncio)
    VALUES (p_id_localizacao, p_id_anuncio);
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION atualizar_local_anuncio(
    p_id_anuncio INT,
    p_local_antigo INT,
    p_local_novo INT
)
RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM local_anuncio
        WHERE id_anuncio = p_id_anuncio
        AND id_localizacao = p_local_antigo
    ) THEN
        RAISE EXCEPTION 'O registro antigo não existe na tabela local_anuncio.';
    ELSE
        UPDATE local_anuncio
        SET id_localizacao = p_local_novo
        WHERE id_anuncio = p_id_anuncio
        AND id_localizacao = p_local_antigo;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION impedir_exclusao_todos_locais_anuncio()
RETURNS TRIGGER AS $$
DECLARE
    v_total_locais INT;
BEGIN
    SELECT COUNT(*) INTO v_total_locais
    FROM local_anuncio
    WHERE id_anuncio = OLD.id_anuncio;

    IF v_total_locais <= 1 THEN
        RAISE EXCEPTION 'Não é permitido excluir todos os registros da tabela local_anuncio para um anúncio.';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_impedir_exclusao_todos_locais_anuncio
BEFORE DELETE ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION impedir_exclusao_todos_locais_anuncio();



CREATE OR REPLACE FUNCTION remover_localizacao_de_anuncio(p_id_anuncio INT, p_id_localizacao INT)
RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM local_anuncio
        WHERE id_anuncio = p_id_anuncio
        AND id_localizacao = p_id_localizacao
    ) THEN
        RAISE EXCEPTION 'A localização do anúncio não existe.';
    ELSE
        DELETE FROM local_anuncio
        WHERE id_anuncio = p_id_anuncio
        AND id_localizacao = p_id_localizacao;
    END IF;
            RAISE NOTICE 'A localização de id % foi apagada', p_id_localizacao;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao()
RETURNS TRIGGER AS $$
DECLARE
    v_wishlist_exists BOOLEAN;
    v_wishlist_id INT;
BEGIN


 	IF TG_OP = 'DELETE'  OR TG_OP ='UPDATE' THEN
        -- Excluir registros na tabela anuncios_desejados ao excluir um anúncio
        DELETE FROM anuncios_desejados WHERE id_anuncio = OLD.id_anuncio;
	END IF;
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT EXISTS (
            SELECT 1 FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) OR id_localizacao = NEW.id_localizacao)  AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 AND aceita_trocas = TRUE) OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3 AND aceita_trocas = TRUE)
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio)
			and     (SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE
        ) INTO v_wishlist_exists;

        IF v_wishlist_exists THEN


            -- Obter o ID da wishlist correspondente
            INSERT INTO anuncios_desejados (id_anuncio, id_wishlist, anuncio_fechado)
            SELECT NEW.id_anuncio, id_wishlist, false
            FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) OR id_localizacao = NEW.id_localizacao) AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 AND aceita_trocas = TRUE) OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3 AND aceita_trocas = TRUE)
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio) and
				(SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE;
         

        ELSE
            -- Excluir registros na tabela anuncios_desejados se não correspondem a nenhuma wishlist
            DELETE FROM anuncios_desejados WHERE id_anuncio = NEW.id_anuncio;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao
AFTER INSERT OR UPDATE OR DELETE ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao();



--'


-- Função generica para inserir registros em todas as tabelas

CREATE OR REPLACE FUNCTION cadastrar(tabela_name TEXT, variadic valores TEXT[])
RETURNS VOID AS $$
DECLARE
  colunas TEXT;
BEGIN
  EXECUTE format('INSERT INTO %I VALUES (%s)',
    tabela_name,
    array_to_string(valores, ', ')
  );
END;
$$ LANGUAGE plpgsql;


-- Inserindo um registro na tabela "avaliacao"
SELECT cadastrar('avaliacao', 'default','1', '1', '''titulo2''','2', 'false', '''2022-01-01''');


-- Trigger para proibir DELETE e UPDATE em anuncios_desejados
CREATE OR REPLACE FUNCTION proibir_delete_update_anuncios_desejados()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'DELETE e UPDATE não são permitidos em anuncios_desejados';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_proibir_delete_update_anuncios_desejados
BEFORE DELETE OR UPDATE ON anuncios_desejados
FOR EACH ROW
EXECUTE FUNCTION proibir_delete_update_anuncios_desejados();
