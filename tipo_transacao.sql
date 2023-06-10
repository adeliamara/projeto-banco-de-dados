CREATE OR REPLACE FUNCTION atualizar_tipo_transacao(
  p_id_tipo_transacao INT,
  p_tipo_transacao VARCHAR(32) = NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE tipo_transacao
  SET
    tipo_transacao = COALESCE(p_tipo_transacao, tipo_transacao)
  WHERE id_tipo_transacao = p_id_tipo_transacao;
END;
$$ LANGUAGE plpgsql;
