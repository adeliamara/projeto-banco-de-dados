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





