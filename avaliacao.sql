-- ACHO QUE TA TUDO CERTO

--FUNCTION: Realizar avaliação

CREATE FUNCTION avaliar_livro(var_id_livro INT, var_id_usuario INT, var_conteudo TEXT)
RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO avaliacao
    VALUES(DEFAULT, var_id_livro, var_id_usuario, var_conteudo, DEFAULT, DEFAULT, DEFAULT);

    RAISE NOTICE 'A avaliação foi publicada';
END;
$$ LANGUAGE plpgsql;




--FUNCTION: Deletar avaliação

CREATE FUNCTION deletar_avaliacao_livro(var_id_avaliacao INT)
RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE avaliacao SET removido = true
    WHERE id_avaliacao = var_id_avaliacao; 
END;
$$ LANGUAGE plpgsql;


-- trigger: bloquear delete da avaliação




--FUNCTION: Atualizar avaliação

CREATE FUNCTION atualizar_avaliacao_livro(var_id_avaliacao INT, var_conteudo TEXT)
RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE avaliacao SET conteudo = var_conteudo
    WHERE id_avaliacao = var_id_avaliacao; 
END;
$$ LANGUAGE plpgsql;

