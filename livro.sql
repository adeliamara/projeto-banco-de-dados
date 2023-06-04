
-- FUNCTION: inserir livro no banco de dados

CREATE FUNCTION inserir_livro(var_sinopse TEXT, var_titulo TEXT, var_autores TEXT[])
RETURNS VOID AS $$
DECLARE
BEGIN

	INSERT INTO livro
	VALUES(DEFAULT, var_titulo, var_sinopse);

    FOR i IN 1..array_length(var_autores, 1) LOOP

        IF NOT (autor_ja_cadastrado(var_autores[i])) THEN
            cadastrar_autor(var_autores[i]);
        END IF

        --cria uma função que insere os dados na tabela autor_livro, em que recebe os parâmetros: titulo do livro e o nome do autor
        
    END LOOP;


END;
$$ LANGUAGE plpgsql


-- TRIGGER INSERT AND UPDATE: verificar se o título do livro já existe

CREATE FUNCTION verificar_se_titulo_ja_existe()
RETURNS TRIGGER AS $$
DECLARE
	titulo_existente boolean;
BEGIN
	
	SELECT EXISTS (SELECT * FROM LIVRO WHERE LIVRO.TITULO ILIKE NEW.TITULO) INTO titulo_existente
	
	IF titulo_existente THEN
		RAISE EXCEPTION 'Título do livro já existe';
	END IF;
	
	RETURN NEW;

END;
$$ LANGUAGE plpgsql



CREATE TRIGGER trigger_verificar_se_titulo_ja_existe
AFTER INSERT OR UPDATE ON livro
FOR EACH ROW
EXECUTE PROCEDURE verificar_se_titulo_ja_existe();



-- TRIGGER INSERT: verifica se autor já existe no banco de dados


CREATE FUNCTION inserir_livro()
RETURNS VOID AS $$
DECLARE
BEGIN

	INSERT INTO livro
	VALUES(titulo, sinopse);


END;
$$ LANGUAGE plpgsql



CREATE TRIGGER verificar_se_autor_existe_na_tabela
AFTER INSERT OR UPDATE ON livro
FOR EACH ROW
EXECUTE PROCEDURE update_likes_da_avaliacao();







