
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
        RAISE EXCEPTION 'O registro antigo não existe na tabela local_anuncio.';
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



CREATE OR REPLACE FUNCTION remover_localizacao_de_anuncio(p_id_anuncio INT, p_id_localizacao INT)
RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM local_anuncio
        WHERE id_anuncio = p_id_anuncio
        AND id_localizacao = p_id_localizacao
    ) THEN
        RAISE EXCEPTION 'A localização do anúncio não existe.';
    ELSE
        DELETE FROM local_anuncio
        WHERE id_anuncio = p_id_anuncio
        AND id_localizacao = p_id_localizacao;
    END IF;
            RAISE NOTICE 'A localização de id % foi apagada', p_id_localizacao;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao()
RETURNS TRIGGER AS $$
DECLARE
    v_wishlist_exists BOOLEAN;
    v_wishlist_id INT;
BEGIN


 	IF TG_OP = 'DELETE'  OR TG_OP ='UPDATE' THEN
        -- Excluir registros na tabela anuncios_desejados ao excluir um anúncio
        DELETE FROM anuncios_desejados WHERE id_anuncio = OLD.id_anuncio;
	END IF;
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT EXISTS (
            SELECT 1 FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) OR id_localizacao = NEW.id_localizacao)  AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 AND aceita_trocas = TRUE) OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3 AND aceita_trocas = TRUE)
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio)
			and     (SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE
        ) INTO v_wishlist_exists;

        IF v_wishlist_exists THEN


            -- Obter o ID da wishlist correspondente
            INSERT INTO anuncios_desejados (id_anuncio, id_wishlist, anuncio_fechado)
            SELECT NEW.id_anuncio, id_wishlist, false
            FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) OR id_localizacao = NEW.id_localizacao) AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 AND aceita_trocas = TRUE) OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3 AND aceita_trocas = TRUE)
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio) and
				(SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE;
         

        ELSE
            -- Excluir registros na tabela anuncios_desejados se não correspondem a nenhuma wishlist
            DELETE FROM anuncios_desejados WHERE id_anuncio = NEW.id_anuncio;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao
AFTER INSERT OR UPDATE OR DELETE ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao();


CREATE OR REPLACE FUNCTION check_duplicate_local_anuncio() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM local_anuncio
        WHERE id_local_anuncio <> NEW.id_local_anuncio
        AND id_anuncio = NEW.id_anuncio
        AND id_localizacao = NEW.id_localizacao
    ) THEN
        RAISE EXCEPTION 'Já existe um par com o mesmo id_anuncio e id_localizacao';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_duplicate_local_anuncio_trigger
BEFORE INSERT OR UPDATE ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_local_anuncio();
