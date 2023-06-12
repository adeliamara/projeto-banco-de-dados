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




-------------------------------


