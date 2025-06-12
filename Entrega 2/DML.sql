INSERT INTO Setor (nome, tipo, descricao, id_norte, id_sul, id_leste, id_oeste, id_portal) VALUES
('Alfa', 'Estação', 'Local do centro de treinamento de novos recrutas', NULL, NULL, NULL, NULL, NULL),
('Beta', 'Livre', 'Local de mineração de Prismatina', NULL, NULL, NULL, NULL, NULL),
('Gama', 'Livre', 'Local de mineração de Zetânio', NULL, NULL, NULL, NULL, NULL),
('Teta', 'Livre', 'Local de mineração de Cronóbio', NULL, NULL, NULL, NULL, NULL),
('Gortran', 'Livre', 'Local de ataques pirata', NULL, NULL, NULL, NULL, NULL),
('Fronteira Sinistra', 'Livre', 'Zona perigosa', NULL, NULL, NULL, NULL, NULL);

--------beta
---gama alfa gortran x----x fronteira sinistra
--------teta

UPDATE Setor SET id_norte = 2, id_sul = 4, id_leste = 3, id_oeste = 5, id_portal = NULL WHERE id = 1; -- alfa
UPDATE Setor SET id_norte = NULL, id_sul = 1, id_leste = NULL, id_oeste = NULL, id_portal = NULL WHERE id = 2; -- beta
UPDATE Setor SET id_norte = NULL, id_sul = NULL, id_leste = NULL, id_oeste = 1, id_portal = NULL WHERE id = 3; -- gama
UPDATE Setor SET id_norte = 1, id_sul = NULL, id_leste = NULL, id_oeste = NULL, id_portal = NULL WHERE id = 4; -- teta
UPDATE Setor SET id_norte = NULL, id_sul = NULL, id_leste = 1, id_oeste = NULL, id_portal = 6 WHERE id = 5; -- gortran
UPDATE Setor SET id_norte = NULL, id_sul = NULL, id_leste = NULL, id_oeste = NULL, id_portal = 5 WHERE id = 6; -- fronteira sinistra


INSERT INTO Mercado (nome, capacidade, descricao, id_setor) VALUES
('Mercado Central', 1000, 'Principal mercado da federação galática', 1),
('Mercado Pirata de Gortran', 200, 'Mercado dos piratas de Gortran', 5);

INSERT INTO Hangar (nome, capacidade, id_setor) VALUES
('Hangar de Alfa', 5, 1),
('Hangar de Gortran', 3, 5);


INSERT INTO Piloto (email, senha, setor) VALUES
('piloto1@exemplo.com', 'senha123', 1),
('piloto2@exemplo.com', 'senha456', 1);


INSERT INTO Minerio (nome, peso, valor, descricao) VALUES
('Prismatina', 2, 10, 'Conhecido como luz cristalizada, ótimo para energizar armamentos.'),
('Zetânio', 3, 50, 'A fonte de combustível mais eficiente da galáxia.'),
('Cronóbio', 7, 300, 'Extramemente raro e poderoso, seu potencial total ainda é um mistério.');


INSERT INTO minerio_setor (id_minerio, id_setor) VALUES
(1, 1),
(2, 1),
(3, 3);


INSERT INTO Nave (nome, descricao, tipo, limite, carga) VALUES
('G4rim-PO', 'Nave de colet leve', 'Coleta', 200, 250),
('DSTRYR', 'Nave de combate pesado', 'Combate', 500, 50);


INSERT INTO nave_piloto (id_piloto, id_nave) VALUES
(1, 1),
(2, 2);


INSERT INTO naves_hangar (nome_hangar, id_nave) VALUES
('Hangar de Alfa', 1),
('Hangar de Gortran', 2);


INSERT INTO Equipamento (nome, consumo, ataque, defesa, extracao, reparo, habilidades, descricao) VALUES
('Laser V2', 10, 1, 0, 0, 0, 'Disparo rápido', 'Laser de ataque básico'),
('Escudo Prismatina', 2, 0, 50, 0, 0, 'Proteção', 'Escudo de defesa básico');


INSERT INTO Motor (nome, potencia, energia, velocidade, descricao) VALUES
('Propulsor X', 200, 5, 100, 'Motor de base'),
('Impulsivo-99', 700, 3, 500, 'Motor de velocidade média');


INSERT INTO nave_equipamento (nome_equipamento, id_nave, nave_atual) VALUES
('Laser V2', 1, true),
('Laser V2', 2, true),
('Escudo Prismatina', 1, true);


INSERT INTO nave_motor (nome_motor, id_nave, nave_atual) VALUES
('Propulsor X', 1, true),
('Impulsivo-99', 2, true);


INSERT INTO mercado_nave (id_nave, nome_mercado, nome_nave, descricao_nave, preco) VALUES
(1, 'Mercado Central', 'Falcon X', 'Nave de transporte leve', 100000),


INSERT INTO mercado_equipamento (nome_equipamento, nome_mercado, descricao_equipamento, preco) VALUES
('Laser V2', 'Mercado Central', 'Laser de ataque básico', 5000),
('Escudo Prismatina', 'Mercado Beta', 'Escudo de defesa básico', 7000);


INSERT INTO mercado_motor (nome_motor, nome_mercado, descricao_motor, preco) VALUES
('Propulsor X', 'Mercado Central', 'Motor de de base', 30000),
('Impulsivo-99', 'Mercado Beta', 'Motor de velocidade média', 15000);


INSERT INTO Mundo (id_piloto, nome_mercado, id_nave, nome_equipamento, nome_motor, descricao) VALUES
(1, 'Mercado Central', 1, 'Laser V2', 'Propulsor X', 'Mundo inicial do piloto 1'),
(2, 'Mercado Beta', 2, 'Escudo Prismatina', 'Impulsivo-99', 'Mundo inicial do piloto 2');
