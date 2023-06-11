CREATE OR REPLACE VIEW vw_alerta_info AS
SELECT a.id_alerta, a.id_usuario, u.nome, a.data_alerta, a.descricao
FROM alerta a
JOIN usuario u ON u.id_usuario = a.id_usuario;
