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