-- FUNÇÃO: Verificar se avaliação existe
CREATE OR REPLACE FUNCTION verificar_se_avaliacao_existe(var_id_avaliacao int)
RETURNS VOID AS $$
DECLARE
avaliacao_existe bool;
BEGIN
SELECT NOT EXISTS (SELECT * FROM AVALIACAO WHERE AVALIACAO.ID_AVALIACAO = var_id_avaliacao) INTO avaliacao_existe;
IF (avaliacao_existe) THEN
RAISE EXCEPTION 'Avaliação não existe.';
END IF;
END;
$$ LANGUAGE plpgsql;
		
	


-- FUNÇÃO: Verificar se usuário existe
CREATE OR REPLACE FUNCTION verificar_se_usuario_existe(var_id_usuario int)
RETURNS VOID AS $$
DECLARE
usuario_existe bool;
BEGIN
SELECT NOT EXISTS (SELECT * FROM usuario WHERE USUARIO.ID_USUARIO = var_id_usuario) INTO usuario_existe;
IF (usuario_existe) THEN
RAISE EXCEPTION 'Usuário não existe.';
END IF;
END;
$$ LANGUAGE plpgsql;




-- FUNÇÃO: curtir uma avaliação
CREATE OR REPLACE FUNCTION curtir_avaliacao(id_usuario INT, id_avaliacao INT)
RETURNS VOID AS $$

BEGIN
	PERFORM verificar_se_avaliacao_existe(id_avaliacao);
	PERFORM verificar_se_usuario_existe(id_usuario);

    INSERT INTO curtida
    VALUES(default, id_usuario, id_avaliacao);
	
	RAISE NOTICE 'Curtida adicionada.';
END;

$$ LANGUAGE plpgsql;




-- FUNÇÃO: descurtir uma avaliação
CREATE FUNCTION descurtir_avaliacao(id_usuario INT, id_avaliacao INT)
RETURNS VOID AS $$

BEGIN
	PERFORM verificar_se_avaliacao_existe(id_avaliacao);
	PERFORM verificar_se_usuario_existe(id_usuario);

    DELETE FROM curtida
    WHERE curtida.id_usuario = id_usuario and curtida.id_avaliacao = id_avaliacao;
END;

$$ LANGUAGE plpgsql;




-- TRIGGER UPDATE: não é possível atualizar a tabela curtida
CREATE FUNCTION bloquear_update_tabela_curtida()
RETURNS trigger as $$
BEGIN
    RAISE EXCEPTION 'Não é possível dar update na tabela curtida';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_bloquear_update_tabela_curtida
BEFORE UPDATE ON curtida
FOR EACH ROW
EXECUTE PROCEDURE bloquear_update_tabela_curtida();




-- TRIGGER INSERT OR DELETE: sempre que inserir uma curtida, deverá atualizar a quantidade de curtidas da avaliacao

CREATE FUNCTION update_likes_da_avaliacao()
    RETURNS trigger as $$
    BEGIN
        IF TG_OP = 'INSERT' THEN
            UPDATE avaliacao
            SET quantidade_curtidas = quantidade_curtidas + 1
            WHERE id_avaliacao = NEW.id_avaliacao;
                RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE avaliacao
            SET quantidade_curtidas = quantidade_curtidas - 1
            WHERE id_avaliacao = OLD.id_avaliacao;
                RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_curtidas
AFTER INSERT OR DELETE ON curtida
FOR EACH ROW
EXECUTE PROCEDURE update_likes_da_avaliacao();



-- TRIGGER INSERT: verificar se o usuário já curtiu uma avaliação
CREATE OR REPLACE FUNCTION verificar_se_usuario_ja_curtiu()
RETURNS TRIGGER AS $$
DECLARE
    usuario_ja_curtiu_avaliacao boolean;
BEGIN
    -- Verifica se o usuário já curtiu a avaliação
    SELECT EXISTS (
        SELECT 1
        FROM curtida
        WHERE id_avaliacao = NEW.id_avaliacao
        AND id_usuario = NEW.id_usuario
    ) INTO usuario_ja_curtiu_avaliacao;


    IF usuario_ja_curtiu_avaliacao THEN
        RAISE EXCEPTION 'O usuário já curtiu esta avaliação.';
    END IF;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_se_usuario_ja_curtiu
    BEFORE INSERT ON curtida
    FOR EACH ROW
    EXECUTE PROCEDURE verificar_se_usuario_ja_curtiu();
	
	