CREATE ROLE publico;
-- só tem acesso a algumas views



CREATE ROLE autenticado;
-- Tabela: anuncio
GRANT SELECT, UPDATE, DELETE ON anuncio TO autenticado;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE anuncio_id_anuncio_seq TO autenticado;

-- Tabela: wishlist
GRANT SELECT, UPDATE, DELETE ON wishlist TO autenticado;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE wishlist_id_wishlist_seq TO autenticado;

-- Tabela: avaliacao
GRANT SELECT, UPDATE, DELETE ON avaliacao TO autenticado;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE avaliacao_id_avaliacao_seq TO autenticado;

-- Tabela: curtida
GRANT SELECT, UPDATE, DELETE ON curtida TO autenticado;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE curtida_id_curtidas_seq TO autenticado;

-- Tabela: anuncios_desejados
GRANT SELECT, UPDATE, DELETE ON anuncios_desejados TO autenticado;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE anuncios_desejados_id_anuncios_desejados_seq TO autenticado;

-- Tabela: local_anuncio
GRANT SELECT, UPDATE, DELETE ON local_anuncio TO autenticado;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE local_anuncio_id_local_anuncio_seq TO autenticado;

-- Tabela: usuario
GRANT SELECT, UPDATE, DELETE ON usuario TO autenticado;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE usuario_id_usuario_seq TO autenticado;

-- Tabela: localizacao
GRANT SELECT, UPDATE, DELETE ON localizacao TO autenticado;


CREATE ROLE administrador;
ALTER ROLE administrador WITH SUPERUSER;

set role publico
set role autenticado

set role administrador

select  current_user

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
select cadastrar('localizacao','default', '''São Paulo''', '''São Paulo''');
select cadastrar('localizacao', 'default', '''Belo Horizonte''', '''Belo Horizonte''');
select cadastrar('localizacao', 'default', '''Rio de Janeiro''', '''Rio de Janeiro''');

-- tentar repetir localizacao
select cadastrar('localizacao', 'default', '''Rio de Janeiro''', '''Rio de Janeiro''');


-- ==================================== TABELA AUTOR
SELECT * FROM AUTOR

-- Insert
SELECT cadastrar('autor', 'default', '''Monteiro Lobato''');
SELECT cadastrar('autor', 'default', '''Clarice Lispector''');
SELECT cadastrar('autor', 'default', '''Katherine Paterson''');


-- Update
SELECT atualizar_registro('autor', ARRAY['nome = ''Walter Isaacson'''], 'id_autor = 2');


-- Delete
SELECT remover_registro('autor', 'id_autor = 2')


/*Teste 01: Insert/Update autor repetido */
SELECT cadastrar('autor', 'default', '''Monteiro Lobato''');
SELECT atualizar_registro('autor', ARRAY['nome = ''Monteiro Lobato'''], 'id_autor = 3');





-- ==================================== TABELA LIVRO
SELECT * FROM LIVRO;
SELECT * FROM AUTOR;
SELECT * FROM AUTOR_LIVRO;


-- Inserindo um novo livro com um novo autor
SELECT inserir_livro('Jess sente-se um estranho na escola e até mesmo em sua família. Durante todo o verão ele treinou para ser o garoto mais rápido da escola, mas seus planos são ameaçados por Leslie, que vence uma corrida que deveria ser apenas para garotos.', 'Ponte para Terabítia', Array['Katherine Paterson']);
SELECT inserir_livro('Um verão na Itália, uma antiga história de amor e um segredo de famíliaDepois da morte da mãe, Lina fica com a missão de realizar um último pedido: ir até a Itália para conhecer o pa.', 'Amor e Gelato', Array['Jenna Evans Welch']);
SELECT inserir_livro('Harry Potter é um garoto órfão que vive infeliz com seus tios, os Dursleys. Ele recebe uma carta contendo um convite para ingressar em Hogwarts, uma famosa escola especializada em formar jovens bruxos. ', 'Harry Potter e a Pedra Filosofal', Array['J. K. Rowling']);
SELECT inserir_livro('Green nasceu e foi criada no Brooklyn, em Nova York, mas cada vez que ela pisca os olhos seu amado bairro parece mudar', 'Quando ninguém está olhando', Array['Alyssa Cole']);
SELECT inserir_livro('Um livro com mais de dois autores', 'O livro dos autores', Array['Alyssa Cole', 'Vitor Araujo']);


/* TESTE 02: Tentando deletar um autor que está relacionado a um livro */
SELECT remover_registro('autor', 'id_autor = 6')

/* TESTE 03: Tentando inserir um título que já existe*/
SELECT inserir_livro('Jess sente-se um estranho na escola e até mesmo em sua família. Durante todo o verão ele treinou para ser o garoto mais rápido da escola, mas seus planos são ameaçados por Leslie, que vence uma corrida que deveria ser apenas para garotos.', 'Ponte para Terabítia', Array['Katherine Paterson']);


-- Update
SELECT atualizar_registro('livro', ARRAY['titulo = ''A Ponte para Terabítia'''], 'id_livro = 1');
SELECT atualizar_registro('livro', ARRAY['sinopse = ''Harry Potter'''], 'id_livro = 3');
SELECT atualizar_registro('livro', ARRAY['titulo = ''Ponte para Terabítia''', 'sinopse = ''Jess sente-se um estranho...'''], 'id_livro = 1');


/* TESTE 04: Apagar um livro remove as linhas da tabela autor_livro (ON DELETE CASCADE)*/
-- Deletar livro (se tiver, remove linhas da tabela autor_livro)
SELECT remover_registro('livro', 'id_livro = 4')





-- ==================================== TABELA autor_livro
select * from autor_livro
select * from autor
select * from livro


-- Insert: permitido
SELECT cadastrar('autor_livro', '3', '7');



-- Updates na tabela autor_livro só são permitidas para o administrador
/* TESTE 05: Somente a role administrador pode atualizar o autor_livro */
SELECT atualizar_registro('autor_livro', ARRAY['id_autor = 3'], 'id_autor = 1  and id_livro = 7');



-- Delete
/* TESTE 06: Um livro não pode ficar sem autor */
SELECT remover_registro('autor_livro', 'id_livro = 7 AND id_autor = 8');
SELECT remover_registro('autor_livro', 'id_livro = 7 AND id_autor = 9');
SELECT remover_registro('autor_livro', 'id_livro = 7 AND id_autor = 1');





-- ==================================== TABELA USUARIO
SELECT * FROM USUARIO

-- INSERT
SELECT cadastrar('usuario', 'default', '''kvitorr''', '''123456789''', '''Vitor Araujo''', 'default', '''86999626417''', '''kvitorsantos@hotmail.com''', 'default');
SELECT cadastrar('usuario', 'default', '''adeliamara''', '''senha123''', '''Adélia Mara''', 'default', '''86999381705''', '''adeliamara13@gmail.com''', 'default');


-- UPDATE
SELECT atualizar_registro('usuario', ARRAY['nome = ''Vitor Araujo''', 'senha = ''vitorvitor''', 'login = ''vitorvitor''', 'email = ''kvi@hotmail.com'''], 'id_usuario = 1');
SELECT atualizar_registro('usuario', ARRAY['nome = ''Altaci Maria'''], 'id_usuario = 1');

/* TESTE 07: apenas administradores podem modificar comportamento perigoso */
SELECT atualizar_registro('usuario', ARRAY['comportamento_perigoso = true'], 'id_usuario = 1');


-- DELETE
/* TESTE 08: não é possível deletar usuário para manter histórico */
SELECT remover_registro('usuario', 'id_usuario = 1')







-- ==================================== TABELA AVALIAÇÃO
SELECT * FROM LIVRO
SELECT * FROM USUARIO
SELECT * FROM AVALIACAO


-- INSERT
SELECT cadastrar('avaliacao', 'default', '1', '1', '''Eu adorei o livro''');
SELECT cadastrar('avaliacao', 'default', '3', '1', '''Eu adorei o livro''');


/Teste 09: não permitir usuário publicar avaliação duplicada (verificação do conteúdo)/
SELECT cadastrar('avaliacao', 'default', '1', '1', '''Eu adorei o livro''');

-- UPDATE
SELECT atualizar_registro('avaliacao', ARRAY['conteudo = ''Parabéns ao autor.'''], 'id_avaliacao = 3');


-- DELETE 
/* Teste 10: o delete altera o atributo removido para true ao invés de deletar o registro*/
SELECT remover_registro('avaliacao', 'id_avaliacao = 1');

/* Teste 11: Avaliação marcada como removida não pode ser editada*/
SELECT atualizar_registro('avaliacao', ARRAY['conteudo = ''Paraddasdsa.'''], 'id_avaliacao = 1');



-- ==================================== TABELA CURTIDAS
SELECT * FROM USUARIO
SELECT * FROM AVALIACAO
SELECT * FROM CURTIDA


-- INSERT (id_curtida, id_usuario, id_avaliacao)
/* TESTE 12: Quando uma curtida é adicionada, o total de curtidas de avaliação aumentado */
SELECT cadastrar('curtida', 'default', '1', '7');


/* TESTE 13: não é possivel um usuário curtir duas vezes a mesma avaliação */
SELECT cadastrar('curtida', 'default', '1', '7');


-- UPDATE
/* TESTE 14: não é possível dar update na tabela curtida */
SELECT atualizar_registro('curtida', ARRAY['id_avaliacao = 7'], 'id_curtidas = 7');


-- DELETE

/* TESTE 15: quando uma curtida é removida, o total de curtida de avaliação diminui */
SELECT remover_registro('curtida', 'id_curtidas = 7');


-- Teste 16: Não permitir usuario perigoso inserir avaliacao
SELECT cadastrar('usuario', 'default', '''karlamaria''', '''senha245''', '''Karla Maria''', 'default', '''86999000000''', '''karliinhahmar@gmail.com''', 'true');

SELECT cadastrar('avaliacao', 'default', '1', '3', '''Eu adorei o livro''');

-- Teste 17: Não permitir usuario perigoso inserir curtida 

SELECT cadastrar('curtida', 'default', '3', '1');

-- Teste 18: Não permitir usuario perigoso inserir anuncio 

SELECT cadastrar_anuncio_com_localizacoes(
    1, -- id_livro
    3, -- id_usuario
    1, -- id_conservacao
    10.99, -- valor
    'Livro com as orelhas danificadas.', -- descricao
    3, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);

-- Teste 19: alterar atributo removido do anuncio e da avaliacao quando o usuario for adicionado como periogo e verificar se criou alerta
select * from anuncio
select * from avaliacao

SELECT cadastrar_anuncio_com_localizacoes(
    4, -- id_livro
    2, -- id_usuario
    1, -- id_conservacao
    10.99, -- valor
    'Livro com as orelhas danificadas.', -- descricao
    3, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);

select atualizar_registro('usuario', array['comportamento_perigoso = true'], 'id_usuario = 2');
select * from alerta

-- ========================= Movimentações

-- Teste 20: cadastra wishlist com aceita trocas = true e valor menor do que o anuncio e mesma cidade do anuncio
SELECT cadastrar_anuncio_com_localizacoes(
    1, -- id_livro
    1, -- id_usuario
    1, -- id_conservacao
    10.99, -- valor
    'Livro com as orelhas danificadas.', -- descricao
    3, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);

select cadastrar('wishlist', 'default','1','1','1','10','true')

-- deve exibir
select * from anuncios_desejados




-- Teste 21:  cadastra wishlist com aceita trocas = false e valor menor do que o anuncio e mesma cidade do anuncio
select cadastrar('wishlist', 'default','1','1','1','8','false');
-- nao deve exibir
select * from anuncios_desejados


-- Teste 22:  cadastra wishlist com aceita trocas = false e valor maior do que o anuncio e mesma cidade do anuncio
select cadastrar('wishlist', 'default','1','1','1','15','false');
-- deve exibir
select * from anuncios_desejados


-- Teste 23: Remover local anuncio dos anuncio
select remover_localizacao_de_anuncio(4,1)
-- nao deve exibir
select * from anuncios_desejados


-- Teste 24: Criar anuncio e depois adicionar local anuncio 
SELECT cadastrar(
	'anuncio',
	'default',
    '1', -- id_livro
    '1', -- id_usuario
    '1', -- id_conservacao
    '10.99', -- valor
    '''Livro sem nenhuma marca de uso.''', -- descricao
    'default',
	'default',
	'3' -- id_tipo_transacao
);

select * from anuncio

select cadastrar('local_anuncio','default','1','5' )
-- deve exibir
select * from anuncios_desejados


-- Teste 25: remover anuncio

select remover_registro('anuncio', 'id_anuncio = 5');
-- nao deve exibir
select * from anuncios_desejados


-- Teste 26: REMOVER LOCAL DE ANUNCIO DE ANUNCIO 


SELECT cadastrar_anuncio_com_localizacoes(
    1, -- id_livro
    1, -- id_usuario
    1, -- id_conservacao
    10.99, -- valor
    'Livro com as orelhas danificadas.', -- descricao
    3, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);

-- deve exibir na anuncio_desejados
select * from anuncios_desejados


select remover_registro('local_anuncio', 'id_anuncio = 6 and id_localizacao = 1');

-- nao deve exibir na anuncio_desejados
select * from anuncios_desejados



-- Teste 27: insere wishlist sem nenhum anuncio correspondente e aceita trocas false e insere novo anuncio com valor menor do que o maximo e cidade igual
select cadastrar('wishlist', 'default','5','1','1','17','false')

select * from wishlist

SELECT cadastrar_anuncio_com_localizacoes(
    5, -- id_livro
    1, -- id_usuario
    1, -- id_conservacao
    10.99, -- valor
    'Livro com as orelhas danificadas.', -- descricao
    3, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);

-- deve exibir nova wishlist
select * from anuncios_desejados

-- Teste 28: insere wishlist sem nenhum anuncio correspondente e aceita trocas false e insere novo anuncio com valor maior do que o maximo e cidade igual
select cadastrar('wishlist', 'default','2','1','1','17','false')

select * from wishlist

SELECT cadastrar_anuncio_com_localizacoes(
    2, -- id_livro
    1, -- id_usuario
    1, -- id_conservacao
    20, -- valor
    'Livro com as orelhas danificadas.', -- descricao
    3, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);


-- nao deve exibir na anuncio_desejados
select * from anuncios_desejados



-- Teste 30: insere wishlist sem nenhum anuncio correspondente e aceita trocas true e insere novo anuncio com valor maior do que o maximo e cidade igual
select cadastrar('wishlist', 'default','3','1','1','17','true')

select * from wishlist

SELECT cadastrar_anuncio_com_localizacoes(
    3, -- id_livro
    1, -- id_usuario
    1, -- id_conservacao
    20, -- valor
    'Livro com as orelhas danificadas.', -- descricao
    3, -- id_tipo_transacao
    ARRAY[
        1,2
    ]
);


-- nao deve exibir na anuncio_desejados
select * from anuncios_desejados


