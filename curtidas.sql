

-- ANALISAR SE A AVALIAÇÃO EXISTE
-- ANALISAR SE O USUÁRIO EXISTE
    -- CONTAR QUANTIDADE DE CURTIDAS DE UMA DETERMINADA AVALIAÇÃO
    -- CURTIR REVIEW




-- FUNÇÃO: curtir uma avaliação
CREATE FUNCTION curtir_review(id_usuario INT, id_avaliacao INT)
RETURNS VOID AS $$

BEGIN
    INSERT INTO curtida
    VALUES(default, id_usuario, id_avaliacao)
END;

$$ LANGUAGE plpgsql;

-- FUNÇÃO: descurtir uma avaliação
CREATE FUNCTION descurtir_review(id_usuario INT, id_avaliacao INT)
RETURNS VOID AS $$

BEGIN
    DELETE FROM curtida
    WHERE curtida.id_usuario = id_usuario and curtida.id_avaliacao = id_avaliacao;
END;

$$ LANGUAGE plpgsql;



-- TRIGGER UPDATE: não é possível atualizar a tabela curtida
CREATE FUNCTION bloquear_update()
RETURNS trigger as $$
BEGIN
    RAISE EXCEPTION 'Não é possível dar update na tabela curtida';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_bloquear_update
BEFORE UPDATE ON curtida
FOR EACH ROW
EXECUTE PROCEDURE bloquear_update();



-- TRIGGER INSERT OR DELETE: sempre que inserir uma curtida, deverá atualizar a quantidade de curtidas da avaliacao

CREATE FUNCTION update_likes()
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
EXECUTE PROCEDURE update_likes();


-- SE O USUARIO JÁ TIVER CURTIDO NÃO DEVE inserir uma curtida
--   ESSA FUNCAO PODERIA SER JUNTO DO UPDATE LIKES
CREATE OR REPLACE FUNCTION verificar_curtida()
    RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o usuário já curtiu a avaliação
    IF EXISTS (
        SELECT 1
        FROM curtida
        WHERE id_avaliacao = NEW.id_avaliacao
        AND id_usuario = NEW.id_usuario
    ) THEN
        RAISE EXCEPTION 'O usuário já curtiu esta avaliação.';
    END IF;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do trigger
CREATE TRIGGER trigger_verificar_curtida
    BEFORE INSERT ON curtida
    FOR EACH ROW
    EXECUTE FUNCTION verificar_curtida()
;