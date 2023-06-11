-- ACHO QUE TA TUDO CERTO


-- TRIGGER: alterar removido ao invés de deletar
CREATE OR REPLACE FUNCTION alterar_removido_avaliacao()
RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN
		UPDATE avaliacao SET removido = true WHERE id_avaliacao = OLD.id_avaliacao;
		RETURN NULL;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da trigger para alterar removido
CREATE TRIGGER trigger_alterar_removido_avaliacao
BEFORE DELETE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION alterar_removido();






-- apenas administradores podem utilizar essa função, utilizada quando usuário é avaliado como não perigoso
CREATE FUNCTION restaurar_avalicacao_removida(var_id_avaliacao INT)
RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE avaliacao SET removida = false
    WHERE id_avaliacao = var_id_avaliacao; 

        RAISE NOTICE 'A da avaliação de id % foi restaurada', var_id_avaliacao;

END;
$$ LANGUAGE plpgsql;






-- TRIGGER: não permitir usuário publicar avaliação duplicada
CREATE OR REPLACE FUNCTION verificar_avaliacao_duplicada()
RETURNS TRIGGER AS $$
DECLARE
    qtd_avaliacoes INTEGER;
BEGIN
    -- Verifica se já existe uma avaliação com o mesmo conteúdo para o mesmo livro e usuário
    SELECT COUNT(*) INTO qtd_avaliacoes
    FROM avaliacao
    WHERE id_livro = NEW.id_livro
        AND id_usuario = NEW.id_usuario
        AND conteudo = NEW.conteudo;

    -- Se houver avaliação duplicada, lança exceção
    IF qtd_avaliacoes > 0 THEN
        RAISE EXCEPTION 'Não é permitido publicar uma avaliação duplicada para o mesmo livro.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da trigger para verificar avaliação duplicada
CREATE TRIGGER trigger_verificar_avaliacao_duplicada
BEFORE INSERT OR UPDATE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION verificar_avaliacao_duplicada();


CREATE OR REPLACE FUNCTION verificar_avaliacao_removida()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.removido = TRUE THEN
        RAISE EXCEPTION 'Avaliação marcada como removida não pode ser editada.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_avaliacao_removida
BEFORE UPDATE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION verificar_avaliacao_removida();




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

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_bloquear_operacoes_perigosas_avaliacao
BEFORE INSERT OR UPDATE OR DELETE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION bloquear_operacoes_perigosas();