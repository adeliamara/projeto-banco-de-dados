CREATE OR REPLACE FUNCTION cadastrar_anuncio_com_localizacoes(
    p_id_livro INT,
    p_id_usuario INT,
    p_id_conservacao INT,
    p_valor REAL,
    p_descricao VARCHAR(255),
    p_id_tipo_transacao INT,
    p_id_localizacoes INT[]
)
RETURNS VOID AS $$
DECLARE
    v_anuncio_id INT;
    v_id_localizacao INT;
    v_localizacao_exists BOOLEAN;
BEGIN
    INSERT INTO anuncio (
        id_livro,
        id_usuario,
        id_conservacao,
        valor,
        descricao,
        id_tipo_transacao
    )
    VALUES (
        p_id_livro,
        p_id_usuario,
        p_id_conservacao,
        p_valor,
        p_descricao,
        p_id_tipo_transacao
    )
    RETURNING id_anuncio INTO v_anuncio_id;

    FOREACH v_id_localizacao IN ARRAY p_id_localizacoes
    LOOP
        SELECT EXISTS (
            SELECT 1 FROM localizacao
            WHERE id_localizacao = v_id_localizacao
        ) INTO v_localizacao_exists;

        IF NOT v_localizacao_exists THEN
            RAISE EXCEPTION 'A localização com o ID % não existe.', v_id_localizacao;
        END IF;

        INSERT INTO local_anuncio (id_localizacao, id_anuncio)
        VALUES (v_id_localizacao, v_anuncio_id);
    END LOOP;

    RAISE NOTICE 'Anúncio publicado.';
END;
$$ LANGUAGE plpgsql;
   


CREATE OR REPLACE FUNCTION marcar_como_removido()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE anuncio
    SET removido = TRUE
    WHERE id_anuncio = old.id_anuncio;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_deletar_anuncio
BEFORE DELETE ON anuncio
FOR EACH ROW
EXECUTE PROCEDURE marcar_como_removido();


/*CREATE OR REPLACE FUNCTION deletar_anuncio(p_id_anuncio INT)
RETURNS VOID AS $$
BEGIN
    UPDATE anuncio
    SET removido = TRUE
    WHERE id_anuncio = p_id_anuncio;
END;
$$ LANGUAGE plpgsql;*/

CREATE OR REPLACE FUNCTION verificar_wishlists_correspondentes_aos_anuncios()
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
                id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) AND
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
                id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) AND
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


CREATE TRIGGER trigger_verificar_wishlists_correspondentes_aos_anuncios
AFTER INSERT OR UPDATE OR DELETE ON anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_wishlists_correspondentes_aos_anuncios();



-- '


CREATE OR REPLACE FUNCTION restaurar_anuncio_removido(var_id_anuncio INT)
RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE anuncio SET removido = false
    WHERE id_anuncio = var_id_anuncio; 

        RAISE NOTICE 'O anúncio  de id % foi restaurado', var_id_anuncio;

END;
$$ LANGUAGE plpgsql;






CREATE OR REPLACE FUNCTION encerrar_anuncio()
  RETURNS TRIGGER AS $$
BEGIN
  IF NEW.data_finalizacao IS NOT NULL THEN
    UPDATE anuncios_desejados SET anuncio_fechado = TRUE WHERE id_anuncio = NEW.id_anuncio;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER atualizacao_encerrar_anuncio_na_anuncio_desejado_trigger
AFTER UPDATE ON anuncio
FOR EACH ROW
EXECUTE FUNCTION encerrar_anuncio();


CREATE OR REPLACE FUNCTION marcar_anuncio_como_fechado(p_id_anuncio INT)
  RETURNS VOID AS $$
BEGIN
  UPDATE anuncio
  SET data_finalizacao = CURRENT_TIMESTAMP
  WHERE id_anuncio = p_id_anuncio;
  raise info 'Anúncio fechado %',p_id_anuncio ;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION verificar_se_anuncio_foi_removido()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.removido = true) THEN
            RAISE EXCEPTION 'Não é permitido fazer update em um anúncio removido.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_anuncio_removido
BEFORE UPDATE ON anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_se_anuncio_foi_removido();
