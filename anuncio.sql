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
END;
$$ LANGUAGE plpgsql;

-- nao teste esse trigger
CREATE TRIGGER trigger_cadastrar_anuncio_com_localizacoes
BEFORE INSERT ON anuncio
FOR EACH ROW
EXECUTE FUNCTION cadastrar_anuncio_com_localizacoes(
    NEW.id_livro,
    NEW.id_usuario,
    NEW.id_conservacao,
    NEW.valor,
    NEW.descricao,
    NEW.id_tipo_transacao,
    NEW.id_localizacoes
);

   


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


CREATE OR REPLACE FUNCTION deletar_anuncio(p_id_anuncio INT)
RETURNS VOID AS $$
BEGIN
    UPDATE anuncio
    SET removido = TRUE
    WHERE id_anuncio = p_id_anuncio;
END;
$$ LANGUAGE plpgsql;

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
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 AND aceita_trocas = FALSE OR
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 OR
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio)
			and     (SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE
        ) INTO v_wishlist_exists;

        IF v_wishlist_exists THEN
            -- Obter o ID da wishlist correspondente
            SELECT id_wishlist INTO v_wishlist_id
            FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 AND aceita_trocas = FALSE OR
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 OR
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio) and
				(SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE;

            -- Inserir registros correspondentes na tabela anuncios_desejados
            INSERT INTO anuncios_desejados (id_wishlist, id_anuncio, anuncio_fechado)
            VALUES (v_wishlist_id, NEW.id_anuncio, false);
        ELSE
            -- Excluir registros na tabela anuncios_desejados se não correspondem a nenhuma wishlist
            DELETE FROM anuncios_desejados WHERE id_anuncio = NEW.id_anuncio;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


--'

CREATE TRIGGER trigger_verificar_wishlists_correspondentes_aos_anuncios
AFTER INSERT OR UPDATE OR DELETE ON anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_wishlists_correspondentes_aos_anuncios();




-- testes






DELETE from anuncio
where id_anuncio = 1




delete from anuncio
where id_anuncio =10

delete from local_anuncio
where id_anuncio = 10


select atualizar_local_anuncio(11,2,3)
select adicionar_local_para_anuncio(10,3);


-- Chamada da função para cadastrar anúncio com várias localizações
SELECT cadastrar_anuncio_com_localizacoes(
    1, -- id_livro
    1, -- id_usuario
    1, -- id_conservacao
    10.99, -- valor
    'Anúncio de livro', -- descricao
    1, -- id_tipo_transacao
    ARRAY[
        1,8
    ]
);


