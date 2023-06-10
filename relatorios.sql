-- Função para um usuário ver seus próprios anúncios:

CREATE OR REPLACE FUNCTION visualizar_anuncios_usuario(id_usuario INT)
RETURNS TABLE (
    id_anuncio INT,
    id_livro INT,
    descricao VARCHAR(255),
    valor REAL
) AS $$
BEGIN
    RETURN QUERY SELECT id_anuncio, id_livro, descricao, valor
                 FROM anuncio
                 WHERE id_usuario = id_usuario;
END;
$$ LANGUAGE plpgsql;


-- Função para um usuário ver sua própria wishlist:

CREATE OR REPLACE FUNCTION visualizar_wishlist_usuario(id_usuario INT)
RETURNS TABLE (
    id_wishlist INT,
    id_livro INT,
    valor_maximo REAL,
    aceita_trocas BOOLEAN
) AS $$
BEGIN
    RETURN QUERY SELECT id_wishlist, id_livro, valor_maximo, aceita_trocas
                 FROM wishlist
                 WHERE id_usuario = id_usuario;
END;
$$ LANGUAGE plpgsql;

-- Função para um usuário ver seus anúncios desejados:

CREATE OR REPLACE FUNCTION visualizar_anuncios_desejados_usuario(id_usuario INT)
RETURNS TABLE (
    id_anuncios_desejados INT,
    id_anuncio INT
) AS $$
BEGIN
    RETURN QUERY SELECT id_anuncios_desejados, id_anuncio
                 FROM anuncios_desejados
                 WHERE id_usuario = id_usuario;
END;
$$ LANGUAGE plpgsql;

--Função para um usuário ver suas próprias avaliações:

CREATE OR REPLACE FUNCTION visualizar_avaliacoes_usuario(id_usuario INT)
RETURNS TABLE (
    id_avaliacao INT,
    id_livro INT,
    conteudo TEXT,
    quantidade_curtidas INT
) AS $$
BEGIN
    RETURN QUERY SELECT id_avaliacao, id_livro, conteudo, quantidade_curtidas
                 FROM avaliacao
                 WHERE id_usuario = id_usuario;
END;
$$ LANGUAGE plpgsql;

