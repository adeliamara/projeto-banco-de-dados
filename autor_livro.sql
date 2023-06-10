-- Trigger para proibir DELETE e UPDATE em autor_livro
CREATE OR REPLACE FUNCTION proibir_delete_update_autor_livro()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'DELETE e UPDATE não são permitidos em autor_livro';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_proibir_delete_update_autor_livro
BEFORE DELETE OR UPDATE ON autor_livro
FOR EACH ROW
EXECUTE FUNCTION proibir_delete_update_autor_livro();