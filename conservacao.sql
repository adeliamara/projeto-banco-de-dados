CREATE OR REPLACE FUNCTION atualizar_conservacao(
  p_id_conservacao INT,
  p_estado_conservacao VARCHAR(32) = NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE conservacao
  SET
    estado_conservacao = COALESCE(p_estado_conservacao, estado_conservacao)
  WHERE id_conservacao = p_id_conservacao;
END;
$$ LANGUAGE plpgsql;


