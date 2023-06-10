
----------------- QUANDO ADICIONAR NOVA WISHLIST DEVE ADICIONAR UM NOVO ITEM NO ANUNCIO DESEJADO
CREATE OR REPLACE FUNCTION verificar_anuncios_para_wishlist() 
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'UPDATE' THEN
			DELETE FROM anuncios_desejados
			WHERE id_wishlist = new.id_wishlist;
	END IF;
	IF NEW.aceita_trocas IS TRUE THEN
			INSERT INTO anuncios_desejados (id_wishlist, id_anuncio, anuncio_fechado)
			SELECT NEW.id_wishlist, anuncio.id_anuncio, false
			FROM anuncio
			LEFT JOIN local_anuncio ON local_anuncio.id_anuncio = anuncio.id_anuncio
			WHERE 
			anuncio.id_livro = new.id_livro AND
			anuncio.data_finalizacao IS NULL AND local_anuncio.id_localizacao = NEW.id_localizacao and
			((new.valor_maximo >= anuncio.valor and anuncio.id_tipo_transacao != 2) or  anuncio.id_tipo_transacao != 1)	 and removido = false		
			group by  NEW.id_wishlist, anuncio.id_anuncio;
	ELSE
			INSERT INTO anuncios_desejados (id_wishlist, id_anuncio, anuncio_fechado)
			SELECT NEW.id_wishlist, anuncio.id_anuncio, false
			FROM anuncio
			LEFT JOIN local_anuncio ON local_anuncio.id_anuncio = anuncio.id_anuncio
			WHERE 
			anuncio.id_livro = new.id_livro AND
			anuncio.data_finalizacao IS NULL AND
			NEW.valor_maximo >= anuncio.valor AND anuncio.id_tipo_transacao != 2 and local_anuncio.id_localizacao = NEW.id_localizacao
			and removido = false
			group by  NEW.id_wishlist, anuncio.id_anuncio;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGgER trigger_verificar_anuncios_para_wishlist
after insert or UPDATE on wishlist
for each row
execute procedure verificar_anuncios_para_wishlist(); 

------------------------------

CREATE OR REPLACE FUNCTION cadastrar_wishlist(id_livro INT, id_usuario INT, id_localizacao INT,  valor_maximo REAL, aceita_trocas BOOLEAN)
RETURNS VOID AS $$
BEGIN
    INSERT INTO wishlist
    VALUES(DEFAULT, id_livro, id_usuario, id_localizacao, valor_maximo, aceita_trocas);
	RAISE NOTICE 'Wishlist cadastrada!';
END;
$$ LANGUAGE plpgsql;





-------------------------------
drop trigger trigger_verificar_anuncios_para_wishlist on wishlist;
drop function verificar_anuncios_para_wishlist;


SELECT cadastrar_wishlist(1,1,1, 20, true);
SELECT cadastrar_wishlist(1,2,1, 22, false);
SELECT cadastrar_wishlist(1,1,1, 8, false);
SELECT cadastrar_wishlist(1,1,1, 8, true);

select * from anuncios_desejados

--

CREATE OR REPLACE FUNCTION atualizar_wishlist(
  p_id_wishlist INT,
  p_id_livro INT = NULL,
  p_id_usuario INT = NULL,
  p_id_localizacao INT = NULL,
  p_valor_maximo REAL = NULL,
  p_aceita_trocas BOOLEAN = NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE wishlist
  SET
    id_livro = COALESCE(p_id_livro, id_livro),
    id_usuario = COALESCE(p_id_usuario, id_usuario),
    id_localizacao = COALESCE(p_id_localizacao, id_localizacao),
    valor_maximo = COALESCE(p_valor_maximo, valor_maximo),
    aceita_trocas = COALESCE(p_aceita_trocas, aceita_trocas)
  WHERE id_wishlist = p_id_wishlist;
END;
$$ LANGUAGE plpgsql;
