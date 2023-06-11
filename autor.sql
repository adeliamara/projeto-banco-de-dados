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


