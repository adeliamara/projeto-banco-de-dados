-- View que mostra as informações sobre as avaliações dos livros

CREATE VIEW view_avaliacoes AS
SELECT l.id_livro, l.titulo AS nome_livro, u.nome AS nome_usuario, a.conteudo, a.quantidade_curtidas, a.created_at
FROM avaliacao a
JOIN livro l ON l.id_livro = a.id_livro
JOIN usuario u ON u.id_usuario = a.id_usuario;

SELECT * FROM view_avaliacoes;



-- Função que retorna as avaliações de um livro específico

CREATE OR REPLACE FUNCTION obter_avaliacoes_por_id_livro(p_id_livro INT)
RETURNS TABLE (
    livro_id INT,
    nome_livro VARCHAR(255),
    nome_usuario VARCHAR(255),
    conteudo TEXT,
    quantidade_curtidas INT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM view_avaliacoes
    WHERE id_livro = p_id_livro;
END;
$$ LANGUAGE plpgsql;

select * from obter_avaliacoes_por_id_livro(2)


-- Função que retorna as avaliações mais curtidas de um livro específico

CREATE OR REPLACE FUNCTION obter_avaliacoes_mais_curtidas_por_id_livro(p_id_livro INT)
RETURNS TABLE (
    livro_id INT,
    nome_livro VARCHAR(255),
    nome_usuario VARCHAR(255),
    conteudo TEXT,
    quantidade_curtidas INT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM view_avaliacoes
    WHERE id_livro = p_id_livro
    ORDER BY quantidade_curtidas DESC
    LIMIT 5; -- Especifica o número máximo de avaliações mais curtidas a retornar
END;
$$ LANGUAGE plpgsql;




-- View que mostra os livros existentes, a sinopse e os autores

CREATE VIEW view_livro_autor AS
SELECT l.titulo, l.sinopse, string_agg(a.nome, ', ') AS autores
FROM livro l
LEFT JOIN autor_livro al ON al.id_livro = l.id_livro
LEFT JOIN autor a ON a.id_autor = al.id_autor
GROUP BY l.id_livro;

SELECT * FROM view_livro_autor;


-- View que mostra informações sobre anúncios ativos, excluindo aqueles que foram removidos:

CREATE OR REPLACE VIEW view_anuncios_ativos AS
SELECT l.id_livro, l.titulo AS nome_livro, u.nome AS nome_usuario, c.estado_conservacao,
       a.valor, a.descricao, a.data_postagem, t.tipo_transacao
FROM anuncio a
JOIN livro l ON a.id_livro = l.id_livro
JOIN usuario u ON a.id_usuario = u.id_usuario
JOIN conservacao c ON a.id_conservacao = c.id_conservacao
JOIN tipo_transacao t ON a.id_tipo_transacao = t.id_tipo_transacao
WHERE a.removido = FALSE;
						  
						  DROP VIEW view_anuncios_ativos;


						  
						  select * from view_anuncios_ativos


-- função buscar anuncios por id de livro

CREATE OR REPLACE FUNCTION get_anuncios_por_id_livro(p_id_livro INT)
RETURNS TABLE (
  id_livro INT,
  nome_livro VARCHAR(255),
  nome_usuario VARCHAR(255),
  estado_conservacao VARCHAR(32),
  valor REAL,
  descricao VARCHAR(255),
  data_postagem TIMESTAMP,
  tipo_transacao VARCHAR(32)
)
AS $$
BEGIN
  RETURN QUERY
  SELECT l.id_livro, l.titulo AS nome_livro, u.nome AS nome_usuario, c.estado_conservacao,
         a.valor, a.descricao, a.data_postagem, t.tipo_transacao
  FROM anuncio a
  JOIN livro l ON a.id_livro = l.id_livro
  JOIN usuario u ON a.id_usuario = u.id_usuario
  JOIN conservacao c ON a.id_conservacao = c.id_conservacao
  JOIN tipo_transacao t ON a.id_tipo_transacao = t.id_tipo_transacao
  WHERE a.removido = FALSE
    AND l.id_livro = p_id_livro;
END;
$$ LANGUAGE plpgsql;




SET ROLE postgres;
						  
-- Criação da role "publico"
CREATE ROLE publico;

-- Concessão de acesso ao SELECT na view view_avaliacoes
GRANT SELECT ON view_avaliacoes TO publico;

-- Concessão de acesso ao SELECT na view view_livro_autor
GRANT SELECT ON view_livro_autor TO publico;

-- Concessão de acesso ao SELECT na view view_anuncios_ativos
GRANT SELECT ON view_anuncios_ativos TO publico;

-- Concessão de acesso ao SELECT na função obter_avaliacoes_por_id_livro
GRANT EXECUTE ON FUNCTION obter_avaliacoes_por_id_livro(INT) TO publico;

-- Concessão de acesso ao SELECT na função obter_avaliacoes_mais_curtidas_por_id_livro
GRANT EXECUTE ON FUNCTION obter_avaliacoes_mais_curtidas_por_id_livro(INT) TO publico;

-- Concessão de acesso ao SELECT na função get_anuncios_por_id_livro
GRANT EXECUTE ON FUNCTION get_anuncios_por_id_livro(INT) TO publico;

-- Concessão de acesso ao INSERT no usuário
GRANT INSERT ON usuario TO publico;





-- =====================================================================

-- Criação da role "autenticado"
CREATE ROLE autenticado;

GRANT SELECT, UPDATE ON usuario TO autenticado;
GRANT SELECT ON livro TO autenticado;
GRANT SELECT ON view_avaliacoes TO autenticado;
GRANT SELECT ON view_livro_autor TO autenticado;
GRANT SELECT ON view_anuncios_ativos TO autenticado;
GRANT SELECT ON obter_avaliacoes_por_id_livro(int) TO autenticado;
GRANT SELECT ON obter_avaliacoes_mais_curtidas_por_id_livro(int) TO autenticado;
GRANT SELECT ON get_anuncios_por_id_livro(int) TO autenticado;

-- Garantir INSERT e DELETE na tabela avaliacao
GRANT INSERT, DELETE, UPDATE ON avaliacao TO autenticado;

-- Garantir INSERT e DELETE na tabela anuncio
GRANT INSERT, DELETE, UPDATE ON anuncio TO autenticado;
GRANT INSERT, DELETE, UPDATE ON local_anuncio TO autenticado;
GRANT INSERT, DELETE, UPDATE ON autor TO autenticado;
GRANT INSERT, DELETE, UPDATE ON anuncios_desejados TO autenticado;

-- Garantir INSERT e DELETE na tabela wishlist
GRANT INSERT, DELETE, UPDATE ON wishlist TO autenticado;

-- Garantir INSERT e DELETE na tabela curtida
GRANT INSERT, DELETE, UPDATE ON curtida TO autenticado;






-- =====================================================================
-- Criar a role "administrador"
CREATE ROLE administrador;

-- Conceder acesso a todas as tabelas para a role "administrador"
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrador;
















