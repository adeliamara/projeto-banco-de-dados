CREATE ROLE publico;
-- só tem acesso a algumas views



CREATE ROLE autenticado;
GRANT SELECT, INSERT, UPDATE, DELETE ON anuncio TO autenticado;
GRANT SELECT, INSERT, UPDATE, DELETE ON wishlist TO autenticado;
GRANT SELECT, INSERT, UPDATE, DELETE ON avaliacao TO autenticado;
GRANT SELECT, INSERT, UPDATE, DELETE ON curtida TO autenticado;
GRANT SELECT, INSERT, UPDATE, DELETE ON anuncios_desejados TO autenticado;
GRANT SELECT, INSERT, UPDATE, DELETE ON local_anuncio TO autenticado;
GRANT SELECT, INSERT, UPDATE, DELETE ON usuario TO autenticado;



CREATE ROLE administrador;
ALTER ROLE administrador WITH SUPERUSER;



set role postgres
set role administrador
set role publico
set role autenticado

select current_user

-- ==================================== TABELA AUTOR
SELECT * FROM AUTOR

-- Insert
SELECT cadastrar('autor', 'default', '''Altaci Maria''');

-- Inserir um autor de mesmo nome
SELECT cadastrar('autor', 'default', '''Altaci Maria''');


-- Update
SELECT atualizar_registro('autor', ARRAY['nome = ''Monteiro Lobato'''], 'id_autor = 3');


-- Delete
SELECT remover_registro('autor', 'id_autor = 5')










-- ==================================== TABELA LIVRO
SELECT * FROM LIVRO
SELECT * FROM AUTOR
SELECT * FROM AUTOR_LIVRO

-- Insert

-- Inserindo um novo livro com um novo autor
SELECT inserir_livro('sinopse 1', 'titulo 1', Array['Vitor Araujo'])
SELECT inserir_livro('sinopse 2', 'titulo 2', Array['Vitor Araujo'])
SELECT inserir_livro('sinopse 3', 'titulo 32', Array['Vitor Araujo'])

-- Tentando deletar um autor que está relacionado a um livro
SELECT remover_registro('autor', 'id_autor = 6')

-- Tentando inserir um livro repetido que possui mesmo título
SELECT inserir_livro('sinopse 1', 'titulo 1', Array['Vitor Araujo'])
SELECT inserir_livro('sinopse 3', 'titulo 3', Array['Vitor Araujo', 'Adelia Mara'])


-- Update
SELECT atualizar_registro('livro', ARRAY['titulo = ''titulo 16'''], 'id_livro = 3');
SELECT atualizar_registro('livro', ARRAY['sinopse = ''Sinopse atualizada 1'''], 'id_livro = 5');
SELECT atualizar_registro('livro', ARRAY['titulo = ''Titulo do livro atualizado 2''', 'sinopse = ''Sinopse atualizada 2'''], 'id_livro = 5');


-- Deletar livro (se tiver, remove linhas da tabela autor_livro)
SELECT remover_registro('livro', 'id_livro = 5')

set role postgres
set role administrador
set role publico
select current_user


drop trigger trigger_verificar_permissao_livro on livro





-- ==================================== TABELA autor_livro
select * from autor_livro
select * from autor

-- Updates na tabela autor_livro só são permitidas para o administrador
SELECT atualizar_registro('autor_livro', ARRAY['id_autor = 8'], 'id_autor = 6  and id_livro = 3');





-- ==================================== TABELA USUARIO
SELECT * FROM USUARIO

-- INSERT
SELECT cadastrar('usuario', 'default', '''kvitorr''', '''123456789''', '''Vitor Araujo''', 'default', '''86999626417''', '''kvitorsantos@hotmail.com''', 'default');


-- UPDATE
SELECT atualizar_registro('usuario', ARRAY['nome = ''Vitor Araujo''', 'senha = ''vitorvitor''', 'login = ''vitorvitor''', 'email = ''kvi@hotmail.com'''], 'id_usuario = 3');
SELECT atualizar_registro('usuario', ARRAY['nome = ''Altaci Maria'''], 'id_usuario = 1');


-- DELETE (não é possível deletar usuário para manter histórico)
SELECT remover_registro('usuario', 'id_usuario = 1')





select * from alerta



-- ==================================== TABELA AVALIAÇÃO
SELECT * FROM LIVRO
SELECT * FROM USUARIO
SELECT * FROM AVALIACAO


-- INSERT
SELECT cadastrar('avaliacao', 'default', '5', '1', '''asdasdasdasd''');

-- UPDATE
SELECT atualizar_registro('avaliacao', ARRAY['conteudo = ''Parabéns ao autor.'''], 'id_avaliacao = 4');

-- DELETE (alterar atributo removido ao invés de apagar a avaliação)

SELECT remover_registro('avaliacao', 'id_avaliacao = 1');
SELECT remover_registro('avaliacao', 'id_avaliacao = 2');
SELECT remover_registro('avaliacao', 'id_avaliacao = 4');









-- ==================================== TABELA CURTIDAS
SELECT * FROM USUARIO
SELECT * FROM AVALIACAO
SELECT * FROM CURTIDA


-- INSERT (id_curtida, id_usuario, id_avaliacao)
-- Quando uma curtida é adicionada, o total de curitdas de avaliação aumentado
SELECT cadastrar('curtida', 'default', '1', '4');


-- não é possivel um usuário curtir duas vezes a mesma avaliação
SELECT cadastrar('curtida', 'default', '1', '1');


-- UPDATE
SELECT atualizar_registro('curtida', ARRAY['id_avaliacao = 3'], 'id_curtidas = 6');


-- DELETE
-- Quando uma curtida é removida, o total de curitdas de avaliação diminuido
SELECT remover_registro('curtida', 'id_curtidas = 6');



























-- ==================================== Funções

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



CREATE OR REPLACE FUNCTION remover_registro(tabela_name TEXT, condicoes TEXT)
RETURNS VOID AS $$
BEGIN
  EXECUTE format('DELETE FROM %I WHERE %s', tabela_name, condicoes);
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION atualizar_registro(tabela_name TEXT, colunas_valores TEXT[], condicoes TEXT)
RETURNS VOID AS $$
BEGIN
  EXECUTE format('UPDATE %I SET %s WHERE %s', tabela_name, array_to_string(colunas_valores, ', '), condicoes);
END;
$$ LANGUAGE plpgsql;



-- FUNCTION: AUTOR EXISTE?

CREATE OR REPLACE FUNCTION autor_ja_cadastrado(var_nome TEXT)
RETURNS BOOLEAN AS $$
DECLARE
BEGIN

	RETURN (SELECT EXISTS (SELECT 1 
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




-- Trigger: não permite deletar autor que está relacionado a um livro

CREATE OR REPLACE FUNCTION bloquear_exclusao_autor()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM autor_livro WHERE id_autor = OLD.id_autor
  ) THEN
    RAISE EXCEPTION 'Não é permitido excluir o autor enquanto ele estiver associado a um livro.';
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_bloquear_exclusao_autor_que_possui_livro
BEFORE DELETE ON autor
FOR EACH ROW
EXECUTE FUNCTION bloquear_exclusao_autor();



CREATE OR REPLACE FUNCTION autor_ja_cadastrado(var_nome TEXT)
RETURNS BOOLEAN AS $$
DECLARE
BEGIN

	RETURN (SELECT EXISTS (SELECT * 
				   FROM autor
				  WHERE autor.nome ILIKE var_nome));

END;
$$ LANGUAGE plpgsql;






-- TRIGGER: verificar se o título do livro já existe
CREATE OR REPLACE FUNCTION verificar_titulo_existente()
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM livro WHERE titulo ILIKE NEW.titulo) THEN
		RAISE EXCEPTION 'O título que você está inserindo já existe.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da trigger para verificar o título existente
CREATE TRIGGER trigger_verificar_titulo_existente
BEFORE INSERT OR UPDATE ON livro
FOR EACH ROW
EXECUTE FUNCTION verificar_titulo_existente();



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





-- Função cadastrar autor pelo nome

CREATE OR REPLACE FUNCTION cadastrar_autor(var_nome TEXT)
RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO autor
    VALUES(DEFAULT, var_nome);
	RAISE NOTICE 'Autor Cadastrado';

END;
$$ LANGUAGE plpgsql;



-- FUNCTION: inserir livro no banco de dados

CREATE OR REPLACE FUNCTION inserir_livro(var_sinopse TEXT, var_titulo TEXT, var_autores TEXT[])
RETURNS VOID AS $$
DECLARE
BEGIN

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








-- Criação do trigger
CREATE OR REPLACE FUNCTION bloquear_delete_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' AND TG_TABLE_NAME = 'usuario' THEN
        RAISE EXCEPTION 'Não é permitido excluir usuários.';
    END IF;

    -- Retorna o resultado do gatilho
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Atribuição do gatilho à tabela usuario
CREATE TRIGGER trigger_bloquear_delete_usuario
BEFORE DELETE ON usuario
FOR EACH ROW
EXECUTE FUNCTION bloquear_delete_usuario();


CREATE OR REPLACE FUNCTION bloquear_operacoes_perigosas()
RETURNS TRIGGER AS $$
DECLARE
    comportamento_perigoso BOOLEAN;
BEGIN
    SELECT u.comportamento_perigoso INTO comportamento_perigoso
    FROM usuario u
    WHERE u.id_usuario = NEW.id_usuario;

    IF comportamento_perigoso = TRUE THEN
        RAISE EXCEPTION 'Não é permitido inserir, atualizar ou excluir informações que contenha usuário com comportamento perigoso.';
    END IF;

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_bloquear_operacoes_perigosas_avaliacao
BEFORE INSERT OR UPDATE OR DELETE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();



CREATE TRIGGER trigger_bloquear_operacoes_perigosas_curtida
BEFORE INSERT OR UPDATE OR DELETE ON curtida
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();



CREATE TRIGGER trigger_bloquear_operacoes_perigosas_anuncio
BEFORE INSERT OR UPDATE OR DELETE ON anuncio
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();



CREATE TRIGGER trigger_bloquear_operacoes_perigosas_wishlist
BEFORE INSERT OR UPDATE OR DELETE ON wishlist
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();



CREATE OR REPLACE FUNCTION verificar_alteracao_comportamento_perigoso()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE' AND NEW.comportamento_perigoso <> OLD.comportamento_perigoso AND current_user <> 'administrador') THEN
        RAISE EXCEPTION 'Apenas a role "administrador" pode alterar a coluna "comportamento_perigoso".';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_alteracao_comportamento_perigoso
BEFORE UPDATE OF comportamento_perigoso ON usuario
FOR EACH ROW
EXECUTE FUNCTION verificar_alteracao_comportamento_perigoso();




















-- Function: Inserir alerta

CREATE OR REPLACE FUNCTION inserir_alerta(var_id_usuario INT, var_descricao TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO alerta (id_usuario, descricao)
  VALUES (var_id_usuario, var_descricao);

  RAISE NOTICE 'Alerta inserido para o usuário %', var_id_usuario;
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

-- Trigger: verifica comportamento perigoso de usuário e repassa para uma tabela

CREATE OR REPLACE FUNCTION verificar_comportamento_perigoso()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
  IF NEW.comportamento_perigoso = true THEN
    PERFORM inserir_alerta(NEW.id_usuario, 'Comportamento perigoso detectado para o usuário ' || NEW.login);

    PERFORM remover_anuncios_avaliacoes_usuario_perigoso(NEW.id_usuario);
    
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_comportamento_perigoso
AFTER INSERT OR UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION verificar_comportamento_perigoso();











-- TRIGGER: alterar removido ao invés de deletar
CREATE OR REPLACE FUNCTION alterar_removido_avaliacao()
RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN
		UPDATE avaliacao SET removido = true WHERE id_avaliacao = OLD.id_avaliacao;
		RETURN NULL;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da trigger para alterar removido
CREATE TRIGGER trigger_alterar_removido_avaliacao
BEFORE DELETE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION alterar_removido_avaliacao();


-- TRIGGER: não permitir usuário publicar avaliação duplicada
CREATE OR REPLACE FUNCTION verificar_avaliacao_duplicada()
RETURNS TRIGGER AS $$
DECLARE
    qtd_avaliacoes INTEGER;
BEGIN
    -- Verifica se já existe uma avaliação com o mesmo conteúdo para o mesmo livro e usuário
    SELECT COUNT(*) INTO qtd_avaliacoes
    FROM avaliacao
    WHERE id_livro = NEW.id_livro
        AND id_usuario = NEW.id_usuario
        AND conteudo = NEW.conteudo;

    -- Se houver avaliação duplicada, lança exceção
    IF qtd_avaliacoes > 0 THEN
        RAISE EXCEPTION 'Não é permitido publicar uma avaliação duplicada para o mesmo livro.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da trigger para verificar avaliação duplicada
CREATE TRIGGER trigger_verificar_avaliacao_duplicada
BEFORE INSERT ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION verificar_avaliacao_duplicada();




-- Criação da trigger para verificar avaliação removida

CREATE OR REPLACE FUNCTION verificar_avaliacao_removida()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.removido = TRUE THEN
        RAISE EXCEPTION 'Avaliação marcada como removida não pode ser editada.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_avaliacao_removida
BEFORE UPDATE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION verificar_avaliacao_removida();







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





CREATE OR REPLACE FUNCTION bloquear_update_tabela_curtida()
RETURNS trigger as $$
BEGIN
    RAISE EXCEPTION 'Não é possível dar update na tabela curtida';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_bloquear_update_tabela_curtida
BEFORE UPDATE ON curtida
FOR EACH ROW
EXECUTE PROCEDURE bloquear_update_tabela_curtida();

