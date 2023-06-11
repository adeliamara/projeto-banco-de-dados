CREATE OR REPLACE FUNCTION verificar_permissao_update_autor_livro()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE' AND current_user <> 'administrador') THEN
        RAISE EXCEPTION 'Apenas a role "administrador" pode fazer updates na tabela "AUTOR_LIVRO".';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_permissao_update_autor_livro
BEFORE UPDATE ON AUTOR_LIVRO
FOR EACH ROW
EXECUTE FUNCTION verificar_permissao_update_autor_livro();
