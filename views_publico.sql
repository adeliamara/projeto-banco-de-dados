-- View das avaliações dos usuarios

CREATE OR REPLACE VIEW vw_avaliacoes AS
SELECT a.id_avaliacao, l.id_livro, u.id_usuario, l.titulo AS nome_livro, u.nome AS nome_usuario, a.conteudo, a.quantidade_curtidas
FROM avaliacao a
JOIN livro l ON l.id_livro = a.id_livro
JOIN usuario u ON u.id_usuario = a.id_usuario
WHERE a.removido = false;



-- Função que mostra as avaliações de um livro em order decrescente de curtidas

CREATE OR REPLACE FUNCTION obter_avaliacoes_de_um_livro(p_id_livro INT)
RETURNS TABLE (
  id_avaliacao INT,
  id_livro INT,
  id_usuario INT,
  nome_livro VARCHAR(255),
  nome_usuario VARCHAR(255),
  conteudo TEXT,
  quantidade_curtidas INT
)
AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_avaliacao, l.id_livro, u.id_usuario, l.titulo AS nome_livro, u.nome AS nome_usuario, a.conteudo, a.quantidade_curtidas
  FROM avaliacao a
  JOIN livro l ON l.id_livro = a.id_livro
  JOIN usuario u ON u.id_usuario = a.id_usuario
  WHERE l.id_livro = p_id_livro
  ORDER BY a.quantidade_curtidas DESC;

  RETURN;
END;
$$ LANGUAGE plpgsql;


SELECT * from obter_avaliacoes_de_um_livro(5)



-- Mostra informações sobre os livros


CREATE OR REPLACE VIEW view_livros_autores AS
SELECT l.id_livro, l.titulo, l.sinopse, string_agg(a.nome, ', ') AS autores
FROM livro l
JOIN autor_livro al ON al.id_livro = l.id_livro
JOIN autor a ON a.id_autor = al.id_autor
GROUP BY l.id_livro, l.titulo, l.sinopse;


select * from view_livros_autores



-- view dos livros mais populares

CREATE VIEW vw_livros_populares AS
SELECT l.id_livro, l.titulo, l.sinopse, al.autores, a.quantidade_avaliacoes, a.quantidade_curtidas
FROM livro l
JOIN (
    SELECT a.id_livro, COUNT(a.id_avaliacao) AS quantidade_avaliacoes, SUM(a.quantidade_curtidas) AS quantidade_curtidas
    FROM avaliacao a
    WHERE a.removido = false
    GROUP BY a.id_livro
) a ON l.id_livro = a.id_livro
JOIN (
    SELECT al.id_livro, STRING_AGG(au.nome, ', ') AS autores
    FROM autor_livro al
    JOIN autor au ON al.id_autor = au.id_autor
    GROUP BY al.id_livro
) al ON l.id_livro = al.id_livro
ORDER BY a.quantidade_curtidas DESC;




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