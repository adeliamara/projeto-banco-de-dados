CREATE OR REPLACE FUNCTION proibir_alteracao_localizacao()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Não é permitido deletar ou atualizar registros na tabela localizacao.';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_proibir_alteracao_localizacao
BEFORE DELETE OR UPDATE ON localizacao
FOR EACH ROW
EXECUTE FUNCTION proibir_alteracao_localizacao();

CREATE OR REPLACE FUNCTION verificar_localizacao_existente()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM localizacao
        WHERE municipio = NEW.municipio
        AND estado = NEW.estado
    ) THEN
        RAISE EXCEPTION 'Localização já existe.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_localizacao_existente
BEFORE INSERT ON localizacao
FOR EACH ROW
EXECUTE FUNCTION verificar_localizacao_existente();







