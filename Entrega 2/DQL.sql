
-- Consultar todos os pilotos e seus setores
SELECT p.id, p.email, s.nome AS setor
FROM Piloto p
JOIN Setor s ON p.setor = s.id;

-- Consultar todas as naves do hangar de um piloto específico
SELECT ng.nome, n.id_nave
FROM Nave ng, naves_hangar n
JOIN nave_piloto np ON n.id_nave = np.id_nave
WHERE np.id_piloto = 1;

-- Consultar naves disponíveis no mercado do setor que o piloto está	
SELECT me.nome_nave, me.descricao_nave, me.preco
FROM mercado_nave me, Piloto p, MERCADO
WHERE p.setor=Mercado.id_setor;

-- Consultar equipamentos disponíveis no mercado do setor que o piloto está
SELECT me.nome_equipamento, me.descricao_equipamento, me.preco
FROM mercado_equipamento me, Piloto p, MERCADO
WHERE p.setor=Mercado.id_setor;

-- Consultar motores disponíveis no mercado do setor que o piloto está
SELECT me.nome_motor, me.descricao_motor, me.preco
FROM mercado_motor me, Piloto p, MERCADO
WHERE p.setor=Mercado.id_setor;

-- Consultar minérios coletados por um piloto especifico no setor em que está
SELECT m.nome, m.peso, m.valor
FROM Minerio m
JOIN minerio_setor ms ON m.id = ms.id_minerio
JOIN Setor s ON ms.id_setor = s.id
WHERE s.id IN (SELECT setor FROM Piloto WHERE id = 1);

-- Consultar equipamentos que um piloto possui em sua nave
SELECT e.nome, e.descricao
FROM Equipamento e
JOIN nave_equipamento ne ON e.nome = ne.nome_equipamento
JOIN nave_piloto np ON ne.id_nave = np.id_nave
WHERE np.id_piloto = 1;

-- Consultar setores e suas descrições
SELECT nome, descricao
FROM Setor;

-- Consultar o mercado de uma nave específica
SELECT m.nome, m.capacidade, m.descricao
FROM Mercado m
JOIN Piloto p ON p.setor = 1
WHERE p.setor = m.id_setor;

-- Consultar todos os minérios e seus valores
SELECT nome, valor
FROM Minerio;
