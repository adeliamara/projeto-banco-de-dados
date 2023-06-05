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










