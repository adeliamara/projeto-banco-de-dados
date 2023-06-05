-- ============================= inserts básicos
INSERT INTO conservacao VALUES 
	(1, 'Novo'),
	(2, 'Seminovo'),
	(3, 'Com muitas marcas de uso');
	
	
INSERT INTO tipo_transacao VALUES 
	(1, 'Apenas venda'),
	(2, 'Apenas troca'),
	(3, 'Troca e venda');
	
SELECT * FROM CONSERVACAO
SELECT * FROM TIPO_TRANSACAO
	
	
-- ================================ Cadastrar Localização
select cadastrar_localizacao('São Paulo', 'São Paulo');
select cadastrar_localizacao('Rio de Janeiro', 'Rio de Janeiro');
select cadastrar_localizacao('Belo Horizonte', 'Minas Gerais');
select cadastrar_localizacao('Qualquer município', 'Qualquer estado');

SELECT * FROM LOCALIZACAO


	
-- ================================ Cadastrar Usuários

select cadastrar_usuario('kvitorr', '123', 'Altaci Maria', '123', '86999626417', 'kvitorsantos@hotmail.com');
select cadastrar_usuario('ricardo222', '456', 'Ricardo Araujo', '456', '86999222222', 'ricardoaraujoeng@hotmail.com');

select * from usuario


-- ================================ Cadastrar Autores

select cadastrar_autor('Adélia');
select cadastrar_autor('Vitor');
select cadastrar_autor('Thiago');

SELECT * FROM AUTOR




-- ================================ TESTES TABELA LIVRO 

	-- Verificar se o título inserido já existe no bd
	-- cenario que passa
	select inserir_livro('Livro de histórias!', 'Ponte para Terabíta', array['Adélia', 'Vitor']);
	select inserir_livro('Livro de romance', 'Um dia', array['Thiago']);
	-- cenario que nao apssa // autor se repete
	select inserir_livro('Livro de histórias!', 'Ponte para Terabíta', array['Adélia', 'Thiago']);
	
	
	-- Verificar se está adicionando o novo autor que não existe no bd
	select inserir_livro('Livro de históriasasdadsd!', 'Amor e Gelato', array['Romero', 'Karla']);
	select inserir_livro('Livasdsdasda', 'Vade Mecun', array['Juliana']);


	SELECT * FROM LIVRO
	SELECT * FROM ANUNCIO
	SELECT * FROM AUTOR
	SELECT * FROM AUTOR_LIVRO



-- ================================ TESTES TABELA AVALIAÇÃO


	SELECT avaliar_livro(1, 1, 'ameeei');
	SELECT deletar_avaliacao_livro(1);
	SELECT ATUALIZAR_aVALIACAO_LIVRO(1, 'NAO GOSTEI');
	
	select * from avaliacao


-- ================================ TESTES TABELA CURTIDA

	SELECT * FROM CURTIDA
	select * from avaliacao
	
	SELECT CURTIR_AVALIACAO(1, 1);
	SELECT DESCURTIR_AVALIACAO(1, 1);

	select * from usuario
	
 	UPDATE curtida
	SET id_usuario = 2
	WHERE id_curtidas = 6;
	



-- ================================ TESTES TABELA Localização

	DELETE FROM LOCALIZACAO
	WHERE ID_LOCALIZACAO = 1
		
	UPDATE LOCALIZACAO 
	SET estado = 'Belo horizonte'
	WHERE ID_LOCALIZACAO = 10;


-- ================================ TESTES TABELA ANÚNCIO

-- Chamada da função para cadastrar anúncio com várias localizações
SELECT cadastrar_anuncio_com_localizacoes(
    1, -- id_livro
    1, -- id_usuario
    1, -- id_conservacao
    10.99, -- valor
    'Anúncio de livro', -- descricao
    1, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);


-- Chamada da função para cadastrar anúncio com várias localizações
SELECT cadastrar_anuncio_com_localizacoes(
    1, -- id_livro
    1, -- id_usuario
    1, -- id_conservacao
    10.99, -- valor
    'Anúncio de livro', -- descricao
    1, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);

SELECT * FROM ANUNCIO
SELECT * FROM LOCAL_ANUNCIO
SELECT * FROM WISHLIST

SELECT DELETAR_ANUNCIO(2);



-- ================================ TESTES TABELA LOCAL ANUNCIO

SELECT adicionar_local_para_anuncio(2, 3);

select atualizar_local_anuncio(2, 3, 4);

select atualizar_local_anuncio(2, 5, 4);


SELECT remover_localizacao_de_anuncio(2, 1)
SELECT remover_localizacao_de_anuncio(2, 2)
SELECT remover_localizacao_de_anuncio(5, 2)
SELECT remover_localizacao_de_anuncio(2, 5)
SELECT remover_localizacao_de_anuncio(2, 4)



-- ================================ TESTES TABELA WISHLIST

SELECT * FROM WISHLIST
SELECT * FROM LIVRO
SELECT * FROM ANUNCIOS_DESEJADOS 
select * FROM local_anuncio
select * from anuncio

SELECT cadastrar_wishlist(1,1,2, 20, true); 
SELECT cadastrar_wishlist(1,2,1, 22, false); 
SELECT cadastrar_wishlist(1,1,1, 8, false); 
SELECT cadastrar_wishlist(1,1,1, 8, true);
SELECT cadastrar_wishlist(1,1,1, 11, true;
SELECT cadastrar_wishlist(1,1,1, 8, false);
						  
						  
SELECT cadastrar_wishlist(2,1,1, 8, false);
SELECT cadastrar_wishlist(2,2,2, 8, true); 
				  
SELECT cadastrar_wishlist(2,2,3, 1, true);
						  
						  SELECT * FROM WISHLIST
						  SELECT * FROM ANUNCIO
  						select * from local_anuncio
					  
SELECT cadastrar_anuncio_com_localizacoes(
    2, -- id_livro
    2, -- id_usuario
    1, -- id_conservacao
    0.5, -- valor
    'Anúncio de livro', -- descricao
    1, -- id_tipo_transacao
    ARRAY[
       2
    ]
);
						  
						  select adicionar_local_para_anuncio(15, 3)
						  
						  select * from local_anuncio

						  

CREATE OR REPLACE FUNCTION verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao()
RETURNS TRIGGER AS $$
DECLARE
    v_wishlist_exists BOOLEAN;
    v_wishlist_id INT;
BEGIN


 	IF TG_OP = 'DELETE'  OR TG_OP ='UPDATE' THEN
        -- Excluir registros na tabela anuncios_desejados ao excluir um anúncio
        DELETE FROM anuncios_desejados WHERE id_anuncio = OLD.id_anuncio;
	END IF;
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT EXISTS (
            SELECT 1 FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) OR id_localizacao = NEW.id_localizacao)  AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 AND aceita_trocas = TRUE) OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3 AND aceita_trocas = TRUE)
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio)
			and     (SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE
        ) INTO v_wishlist_exists;

        IF v_wishlist_exists THEN


            -- Obter o ID da wishlist correspondente
            INSERT INTO anuncios_desejados (id_anuncio, id_wishlist, anuncio_fechado)
            SELECT NEW.id_anuncio, id_wishlist, false
            FROM wishlist
            WHERE
                id_livro = (SELECT id_livro FROM anuncio WHERE id_anuncio = NEW.id_anuncio) AND
                (id_localizacao = ANY(SELECT id_localizacao FROM local_anuncio WHERE id_anuncio = NEW.id_anuncio) OR id_localizacao = NEW.id_localizacao) AND
                (
                    (SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 1 OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 2 AND aceita_trocas = TRUE) OR
                    ((SELECT id_tipo_transacao FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = 3 AND aceita_trocas = TRUE)
                ) AND
                valor_maximo >= (SELECT valor FROM anuncio WHERE id_anuncio = NEW.id_anuncio) and
				(SELECT removido FROM anuncio WHERE id_anuncio = NEW.id_anuncio) = FALSE;
         

        ELSE
            -- Excluir registros na tabela anuncios_desejados se não correspondem a nenhuma wishlist
            DELETE FROM anuncios_desejados WHERE id_anuncio = NEW.id_anuncio;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao
AFTER INSERT OR UPDATE OR DELETE ON local_anuncio
FOR EACH ROW
EXECUTE FUNCTION verificar_wishlists_correspondentes_aos_anuncios_com_nova_localizacao();		
						  