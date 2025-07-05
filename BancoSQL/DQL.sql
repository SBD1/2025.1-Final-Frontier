
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

-- Ver setores vizinhos do piloto (setores adjacentes ao atual)
SELECT s.id, s.nome, s.descricao
FROM Setor s
JOIN Piloto p ON p.setor = s.id
WHERE p.id = 1;

-- Ver motor atual da nave do piloto
SELECT m.nome, m.descricao, m.velocidade
FROM Motor m
JOIN nave_motor nm ON m.nome = nm.nome_motor
JOIN nave_piloto np ON nm.id_nave = np.id_nave
WHERE np.id_piloto = 1 AND nm.nave_atual = true;

-- Ver equipamentos atuais da nave do piloto
SELECT e.nome, e.descricao, e.ataque, e.defesa, e.extracao, e.reparo
FROM Equipamento e
JOIN nave_equipamento ne ON e.nome = ne.nome_equipamento
JOIN nave_piloto np ON ne.id_nave = np.id_nave
WHERE np.id_piloto = 1 AND ne.nave_atual = true;

-- Ver todas as naves, motores e equipamentos de um mercado específico
SELECT 'Nave' FROM mercado_nave WHERE nome_mercado = 'Mercado Central'
UNION ALL
SELECT 'Motor' FROM mercado_motor WHERE nome_mercado = 'Mercado Central'
UNION ALL
SELECT 'Equipamento' FROM mercado_equipamento WHERE nome_mercado = 'Mercado Central';

-- Listar poder de ataque total da nave do piloto
SELECT SUM(e.ataque) AS ataque_total
FROM Equipamento e
JOIN nave_equipamento ne ON e.nome = ne.nome_equipamento
JOIN nave_piloto np ON ne.id_nave = np.id_nave
WHERE np.id_piloto = 1 AND ne.nave_atual = true;

-- Listar defesa total da nave
SELECT SUM(e.defesa) AS defesa_total
FROM Equipamento e
JOIN nave_equipamento ne ON e.nome = ne.nome_equipamento
JOIN nave_piloto np ON ne.id_nave = np.id_nave
WHERE np.id_piloto = 1 AND ne.nave_atual = true;

-- Ver os minérios disponíveis no setor atual para mineração
SELECT m.nome, m.descricao, m.peso, m.valor
FROM Minerio m
JOIN minerio_setor ms ON m.id = ms.id_minerio
WHERE ms.id_setor = (SELECT setor FROM Piloto WHERE id = 1);

-- Status geral do piloto (setor atual, nave, motor, equipamentos)
SELECT 
    p.email AS piloto,
    s.nome AS setor_atual,
    n.nome AS nave,
    m.nome AS motor
FROM Piloto p
JOIN Setor s ON p.setor = s.id
JOIN nave_piloto np ON p.id = np.id_piloto
JOIN Nave n ON np.id_nave = n.id
LEFT JOIN nave_motor nm ON n.id = nm.id_nave AND nm.nave_atual = true
LEFT JOIN Motor m ON nm.nome_motor = m.nome
WHERE p.id = 1;
