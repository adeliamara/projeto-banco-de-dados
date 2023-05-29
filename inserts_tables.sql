INSERT INTO conservacao VALUES 
	(DEFAULT, 'Novo'),
	(DEFAULT, 'Seminovo'),
	(DEFAULT, 'Com muitas marcas de uso');
	
	
INSERT INTO tipo_transacao VALUES 
	(DEFAULT, 'Apenas venda'),
	(DEFAULT, 'Apenas troca'),
	(DEFAULT, 'Troca e venda');
	
	
INSERT INTO localizacao (id_localizacao, municipio, estado)VALUES 
	(DEFAULT, 'São Paulo', 'São Paulo'),
	(DEFAULT, 'Rio de Janeiro', 'Rio de Janeiro'),
	(DEFAULT, 'Belo Horizonte', 'Minas Gerais'),
	(DEFAULT, 'Qualquer município', 'Qualquer estado');
	
INSERT INTO usuario (id_usuario, login, senha, nome, contato, telefone, email, comportamento_perigoso)
VALUES
	(DEFAULT, 'usuario1', 'senha123', 'Usuário 1', 'Contato 1', '1234567890', 'usuario1@example.com', false),
	(DEFAULT, 'usuario2', 'senha456', 'Usuário 2', 'Contato 2', '0987654321', 'usuario2@example.com', true),
	(DEFAULT, 'usuario3', 'senha789', 'Usuário 3', 'Contato 3', '9876543210', 'usuario3@example.com', false);
  
INSERT INTO livro (id_livro, autor, sinopse, titulo) VALUES
	(DEFAULT, 'Autor 1', 'Sinopse do livro 1', 'Livro 1'),
	(DEFAULT, 'Autor 2', 'Sinopse do livro 2', 'Livro 2'),
	(DEFAULT, 'Autor 3', 'Sinopse do livro 3', 'Livro 3');



