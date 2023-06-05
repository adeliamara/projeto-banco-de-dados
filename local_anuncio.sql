
CREATE OR REPLACE FUNCTION verificar_existencia_local_anuncio()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM local_anuncio
        WHERE id_anuncio = NEW.id_anuncio
        AND id_localizacao = NEW.id_localizacao
    ) THEN
        RAISE EXCEPTION 'Já existe um registro na tabela local_anuncio para o anúncio e ID de localização especificados.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_existencia_local_anuncio
BEFORE UPDATE OR INSERT ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_existencia_local_anuncio();




CREATE OR REPLACE FUNCTION adicionar_local_para_anuncio(p_id_anuncio INT, p_id_localizacao INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO local_anuncio (id_localizacao, id_anuncio)
    VALUES (p_id_localizacao, p_id_anuncio);
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION atualizar_local_anuncio(
    p_id_anuncio INT,
    p_local_antigo INT,
    p_local_novo INT
)
RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM local_anuncio
        WHERE id_anuncio = p_id_anuncio
        AND id_localizacao = p_local_antigo
    ) THEN
        RAISE NOTICE 'O registro antigo não existe na tabela local_anuncio.';
    ELSE
        UPDATE local_anuncio
        SET id_localizacao = p_local_novo
        WHERE id_anuncio = p_id_anuncio
        AND id_localizacao = p_local_antigo;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION impedir_exclusao_todos_locais_anuncio()
RETURNS TRIGGER AS $$
DECLARE
    v_total_locais INT;
BEGIN
    SELECT COUNT(*) INTO v_total_locais
    FROM local_anuncio
    WHERE id_anuncio = OLD.id_anuncio;

    IF v_total_locais <= 1 THEN
        RAISE EXCEPTION 'Não é permitido excluir todos os registros da tabela local_anuncio para um anúncio.';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_impedir_exclusao_todos_locais_anuncio
BEFORE DELETE ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION impedir_exclusao_todos_locais_anuncio();



CREATE TRIGGER trigger_verificar_wishlists_correspondentes_aos_anuncios
AFTER INSERT OR UPDATE OR DELETE ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_wishlists_correspondentes_aos_anuncios();

