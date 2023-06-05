-- FUNCTION: cadastrar usuário

CREATE FUNCTION cadastrar_usuario(var_login VARCHAR(50), var_senha VARCHAR(50), var_nome VARCHAR(255), var_contato VARCHAR(255), var_telefone VARCHAR(20), var_email VARCHAR(255))
RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO USUARIO
    VALUES(DEFAULT, var_login, var_senha, var_nome, var_contato, DEFAULT, var_telefone, var_email, DEFAULT);

    RAISE NOTICE '% foi cadastrado com sucesso', var_nome;
END;
$$ LANGUAGE plpgsql;


-- Function: Inserir alerta

CREATE OR REPLACE FUNCTION inserir_alerta(var_id_usuario INT, var_descricao TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO alerta (id_usuario, descricao)
  VALUES (var_id_usuario, var_descricao);

  RAISE NOTICE 'Alerta inserido para o usuário %', var_id_usuario;
END;
$$ LANGUAGE plpgsql;






-- Listar alertas de comportamentos perigosos

CREATE OR REPLACE FUNCTION listar_alertas()
RETURNS TABLE (
    alerta_id INT,
    alerta_descricao TEXT,
    data_criacao TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY 
    SELECT id_alerta, descricao AS alerta_descricao, data_alerta
    FROM ALERTA
    ORDER BY data_alerta DESC;
END;
$$ LANGUAGE plpgsql;

-- FUNCTION: Remover anúncios e avaliações de usuário com comportamento perigoso

CREATE OR REPLACE FUNCTION remover_anuncios_avaliacoes_usuario_perigoso(var_id_usuario int)
RETURNS VOID AS $$

DECLARE
   id_avaliacao_temp INT;
   id_anuncio_temp INT;
BEGIN


    IF EXISTS (SELECT 1 FROM USUARIO WHERE comportamento_perigoso = true AND id_usuario = var_id_usuario) THEN
        
        CREATE TEMPORARY TABLE anuncios_encontrados (
            id_anuncios_encontrados INT
        );

        INSERT INTO anuncios_encontrados (id_anuncios_encontrados)
        SELECT id_anuncio FROM anuncio
        WHERE id_usuario = var_id_usuario;

        CREATE TEMPORARY TABLE avaliacoes_encontradas (
            id_avaliacoes_encontradas INT
        );

        INSERT INTO avaliacoes_encontradas (id_avaliacoes_encontradas)
        SELECT id_avaliacao FROM avaliacao
        WHERE id_usuario = var_id_usuario;


        FOR id_avaliacao_temp IN (SELECT id_avaliacoes_encontradas FROM avaliacoes_encontradas) LOOP
            
            PERFORM deletar_avaliacao_livro(id_avaliacao_temp);

        END LOOP;


        FOR id_anuncio_temp IN (SELECT id_anuncios_encontrados FROM anuncios_encontrados) LOOP
            
            UPDATE ANUNCIO
            SET REMOVIDO = TRUE
            WHERE ID_ANUNCIO = ID_ANUNCIO_TEMP;

        END LOOP;

        RAISE NOTICE 'Todas as publicações do usuário % foram removidas por comportamento perigoso.', var_id_usuario;

        DROP TABLE anuncios_encontrados;
        DROP TABLE avaliacoes_encontradas;
    ELSE
        RAISE NOTICE 'O usuário % selecionado não é perigoso', var_id_usuario;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- Trigger: verifica comportamento perigoso de usuário e faz algo repassa para uma tabela

CREATE OR REPLACE FUNCTION verificar_comportamento_perigoso()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
  IF NEW.comportamento_perigoso = true THEN
    PERFORM inserir_alerta(NEW.id_usuario, 'Comportamento perigoso detectado para o usuário ' || NEW.login);

    PERFORM remover_anuncios_avaliacoes_usuario_perigoso(NEW.id_usuario);
    
    -- BLOQUEAR ACESSO DO USUÁRIO
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_comportamento_perigoso
AFTER INSERT OR UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION verificar_comportamento_perigoso();


-- Function: alterar comportamento de usuário para perigoso

CREATE FUNCTION alterar_comportamento_do_usuario_para_perigoso(var_id_user int)
RETURNS VOID AS $$
BEGIN

    PERFORM verificar_se_usuario_existe(var_id_user);

    UPDATE USUARIO
    SET COMPORTAMENTO_PERIGOSO = TRUE
    WHERE id_usuario = var_id_user;
    RAISE NOTICE 'Usuário de id % tornou-se perigoso', var_id_user;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION atualizar_usuario(
  p_id_usuario INT,
  p_login VARCHAR(50) DEFAULT NULL,
  p_senha VARCHAR(50) DEFAULT NULL,
  p_nome VARCHAR(255) DEFAULT NULL,
  p_contato VARCHAR(255) DEFAULT NULL,
  p_telefone VARCHAR(20) DEFAULT NULL,
  p_email VARCHAR(255) DEFAULT NULL,
  p_comportamento_perigoso BOOLEAN DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE usuario SET
    login = COALESCE(p_login, login),
    senha = COALESCE(p_senha, senha),
    nome = COALESCE(p_nome, nome),
    contato = COALESCE(p_contato, contato),
    telefone = COALESCE(p_telefone, telefone),
    email = COALESCE(p_email, email),
    comportamento_perigoso = COALESCE(p_comportamento_perigoso, comportamento_perigoso)
  WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;