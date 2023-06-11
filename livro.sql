

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
BEFORE INSERT ON livro
FOR EACH ROW
EXECUTE FUNCTION verificar_titulo_existente();

drop trigger trigger_verificar_titulo existente on livro


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

-- Função autor já cadastrado

CREATE OR REPLACE FUNCTION autor_ja_cadastrado(var_nome TEXT)
RETURNS BOOLEAN AS $$
DECLARE
BEGIN

	RETURN (SELECT EXISTS (SELECT * 
				   FROM autor
				  WHERE autor.nome ILIKE var_nome));

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
