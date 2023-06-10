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
