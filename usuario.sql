-- Function: Inserir alerta

CREATE OR REPLACE FUNCTION inserir_alerta(var_id_usuario INT, var_descricao TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO alerta (id_usuario, descricao)
  VALUES (var_id_usuario, var_descricao);

  RAISE NOTICE 'Alerta inserido para o usuário %', var_id_usuario;
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

-- Trigger: verifica comportamento perigoso de usuário e repassa para uma tabela

CREATE OR REPLACE FUNCTION verificar_comportamento_perigoso()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
  IF NEW.comportamento_perigoso = true THEN
    PERFORM inserir_alerta(NEW.id_usuario, 'Comportamento perigoso detectado para o usuário ' || NEW.login);

    PERFORM remover_anuncios_avaliacoes_usuario_perigoso(NEW.id_usuario);
    
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_comportamento_perigoso
AFTER INSERT OR UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION verificar_comportamento_perigoso();



-- Criação do trigger
CREATE OR REPLACE FUNCTION bloquear_delete_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' AND TG_TABLE_NAME = 'usuario' THEN
        RAISE EXCEPTION 'Não é permitido excluir usuários.';
    END IF;

    -- Retorna o resultado do gatilho
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Atribuição do gatilho à tabela usuario
CREATE TRIGGER trigger_bloquear_delete_usuario
BEFORE DELETE ON usuario
FOR EACH ROW
EXECUTE FUNCTION bloquear_delete_usuario();


-- Criação do trigger para a tabela avaliacao
CREATE OR REPLACE FUNCTION bloquear_operacoes_perigosas()
RETURNS TRIGGER AS $$
DECLARE
    comportamento_perigoso BOOLEAN;
BEGIN
    SELECT u.comportamento_perigoso INTO comportamento_perigoso
    FROM usuario u
    WHERE u.id_usuario = NEW.id_usuario;

    IF comportamento_perigoso = TRUE THEN
        RAISE EXCEPTION 'Não é permitido inserir, atualizar ou excluir avaliações de usuários com comportamento perigoso.';
    END IF;

    IF TG_OP = 'DELETE' THEN
      RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_bloquear_operacoes_perigosas_avaliacao
BEFORE INSERT OR UPDATE OR DELETE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();



CREATE TRIGGER trigger_bloquear_operacoes_perigosas_curtida
BEFORE INSERT OR UPDATE OR DELETE ON curtida
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();



CREATE TRIGGER trigger_bloquear_operacoes_perigosas_anuncio
BEFORE INSERT OR UPDATE OR DELETE ON anuncio
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();



CREATE TRIGGER trigger_bloquear_operacoes_perigosas_wishlist
BEFORE INSERT OR UPDATE OR DELETE ON wishlist
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();


CREATE OR REPLACE FUNCTION verificar_alteracao_comportamento_perigoso()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE' AND NEW.comportamento_perigoso <> OLD.comportamento_perigoso AND current_user <> 'administrador') THEN
        RAISE EXCEPTION 'Apenas a role "administrador" pode alterar a coluna "comportamento_perigoso".';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_alteracao_comportamento_perigoso
BEFORE UPDATE OF comportamento_perigoso ON usuario
FOR EACH ROW
EXECUTE FUNCTION verificar_alteracao_comportamento_perigoso();
