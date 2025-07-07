-- =====================================================
-- SISTEMA COMPLETO DE NAVEGAÇÃO - TRIGGERS E PROCEDIMENTOS
-- =====================================================

-- =====================================================
-- 1. FUNÇÕES DE VALIDAÇÃO
-- =====================================================

-- Função para validar se um setor existe
CREATE OR REPLACE FUNCTION validar_setor(setor_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(SELECT 1 FROM Setor WHERE id = setor_id);
END;
$$ LANGUAGE plpgsql;

-- Função para verificar se a movimentação é válida
CREATE OR REPLACE FUNCTION verificar_movimentacao_valida(
    setor_atual INTEGER,
    direcao TEXT
)
RETURNS INTEGER AS $$
DECLARE
    setor_destino INTEGER;
BEGIN
    -- Verificar se o setor atual existe
    IF NOT validar_setor(setor_atual) THEN
        RAISE EXCEPTION 'Setor atual não existe';
    END IF;
    
    -- Obter o setor de destino baseado na direção
    SELECT 
        CASE direcao
            WHEN 'NORTE' THEN id_norte
            WHEN 'SUL' THEN id_sul
            WHEN 'LESTE' THEN id_leste
            WHEN 'OESTE' THEN id_oeste
            WHEN 'PORTAL' THEN id_portal
            ELSE NULL
        END INTO setor_destino
    FROM Setor
    WHERE id = setor_atual;
    
    -- Verificar se existe conexão na direção especificada
    IF setor_destino IS NULL THEN
        RAISE EXCEPTION 'Não há conexão na direção %', direcao;
    END IF;
    
    -- Verificar se o setor de destino existe
    IF NOT validar_setor(setor_destino) THEN
        RAISE EXCEPTION 'Setor de destino não existe';
    END IF;
    
    RETURN setor_destino;
END;
$$ LANGUAGE plpgsql;

-- Função para obter setores conectados
CREATE OR REPLACE FUNCTION obter_setores_conectados(setor_id INTEGER)
RETURNS TABLE(
    direcao TEXT,
    setor_destino INTEGER,
    nome_setor TEXT,
    tipo_setor TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'NORTE' as direcao,
        s.id_norte as setor_destino,
        dest.nome as nome_setor,
        dest.tipo as tipo_setor
    FROM Setor s
    JOIN Setor dest ON s.id_norte = dest.id
    WHERE s.id = setor_id AND s.id_norte IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'SUL' as direcao,
        s.id_sul as setor_destino,
        dest.nome as nome_setor,
        dest.tipo as tipo_setor
    FROM Setor s
    JOIN Setor dest ON s.id_sul = dest.id
    WHERE s.id = setor_id AND s.id_sul IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'LESTE' as direcao,
        s.id_leste as setor_destino,
        dest.nome as nome_setor,
        dest.tipo as tipo_setor
    FROM Setor s
    JOIN Setor dest ON s.id_leste = dest.id
    WHERE s.id = setor_id AND s.id_leste IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'OESTE' as direcao,
        s.id_oeste as setor_destino,
        dest.nome as nome_setor,
        dest.tipo as tipo_setor
    FROM Setor s
    JOIN Setor dest ON s.id_oeste = dest.id
    WHERE s.id = setor_id AND s.id_oeste IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'PORTAL' as direcao,
        s.id_portal as setor_destino,
        dest.nome as nome_setor,
        dest.tipo as tipo_setor
    FROM Setor s
    JOIN Setor dest ON s.id_portal = dest.id
    WHERE s.id = setor_id AND s.id_portal IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. SISTEMA DE BOAS-VINDAS
-- =====================================================

-- Tabela para rastrear boas-vindas
CREATE TABLE IF NOT EXISTS boas_vindas_vistas (
    piloto_id INTEGER PRIMARY KEY REFERENCES Piloto(id),
    data_primeira_vez TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função para verificar primeira vez
CREATE OR REPLACE FUNCTION verificar_primeira_vez(piloto_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS(SELECT 1 FROM boas_vindas_vistas WHERE piloto_id = $1);
END;
$$ LANGUAGE plpgsql;

-- Procedimento de boas-vindas automático
CREATE OR REPLACE PROCEDURE boas_vindas_automatico(piloto_id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar se é a primeira vez
    IF verificar_primeira_vez(piloto_id) THEN
        -- Mostrar mensagem de boas-vindas
        RAISE NOTICE '';
        RAISE NOTICE '🎉 BEM-VINDO À FINAL FRONTIER! 🎉';
        RAISE NOTICE '';
        RAISE NOTICE 'O objetivo do jogo é explorar e navegar por setores cheios de riquezas,';
        RAISE NOTICE 'para que possamos minerar e nos transformarmos nos pilotos mais ricos do sistema!!!';
        RAISE NOTICE '';
        RAISE NOTICE '🚀 Prepare-se para a maior aventura espacial de todos os tempos!';
        RAISE NOTICE '';
        
        -- Registrar que o piloto já viu as boas-vindas
        INSERT INTO boas_vindas_vistas (piloto_id) VALUES (piloto_id);
        
        RAISE NOTICE '✅ Boas-vindas registradas! Divirta-se explorando o universo!';
        RAISE NOTICE '';
    ELSE
        -- Se não é a primeira vez, mostrar mensagem de retorno
        RAISE NOTICE '';
        RAISE NOTICE '👋 Bem-vindo de volta, piloto!';
        RAISE NOTICE 'Pronto para mais aventuras no universo Final Frontier?';
        RAISE NOTICE '';
    END IF;
END;
$$;

-- Procedimento para forçar boas-vindas
CREATE OR REPLACE PROCEDURE forcar_boas_vindas(piloto_id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Remover registro de boas-vindas vistas (se existir)
    DELETE FROM boas_vindas_vistas WHERE piloto_id = $1;
    
    -- Executar boas-vindas novamente
    CALL boas_vindas_automatico($1);
END;
$$;

-- =====================================================
-- 3. SISTEMA DE NAVEGAÇÃO
-- =====================================================

-- Procedimento para navegar manualmente
CREATE OR REPLACE PROCEDURE navegar_manual(
    piloto_id INTEGER,
    direcao_escolhida TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    setor_atual INTEGER;
    nome_setor TEXT;
    tipo_setor TEXT;
    descricao_setor TEXT;
    setor_destino INTEGER;
    nome_destino TEXT;
    conexoes_disponiveis TEXT := '';
    tem_norte BOOLEAN := FALSE;
    tem_sul BOOLEAN := FALSE;
    tem_leste BOOLEAN := FALSE;
    tem_oeste BOOLEAN := FALSE;
BEGIN
    -- Obter informações do setor atual
    SELECT p.setor, s.nome, s.tipo, s.descricao 
    INTO setor_atual, nome_setor, tipo_setor, descricao_setor
    FROM Piloto p
    LEFT JOIN Setor s ON p.setor = s.id
    WHERE p.id = piloto_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Piloto com ID % não encontrado', piloto_id;
    END IF;
    
    -- Mostrar posição atual
    RAISE NOTICE '';
    RAISE NOTICE '=== POSIÇÃO ATUAL ===';
    RAISE NOTICE 'Você está no: %', nome_setor;
    RAISE NOTICE 'Tipo: %', tipo_setor;
    RAISE NOTICE 'Descrição: %', descricao_setor;
    RAISE NOTICE '';
    
    -- Verificar conexões disponíveis
    SELECT 
        CASE WHEN s.id_norte IS NOT NULL THEN TRUE ELSE FALSE END,
        CASE WHEN s.id_sul IS NOT NULL THEN TRUE ELSE FALSE END,
        CASE WHEN s.id_leste IS NOT NULL THEN TRUE ELSE FALSE END,
        CASE WHEN s.id_oeste IS NOT NULL THEN TRUE ELSE FALSE END
    INTO tem_norte, tem_sul, tem_leste, tem_oeste
    FROM Setor s
    WHERE s.id = setor_atual;
    
    -- Construir lista de direções disponíveis
    IF tem_norte THEN
        conexoes_disponiveis := conexoes_disponiveis || '1 - NORTE ';
    END IF;
    IF tem_sul THEN
        conexoes_disponiveis := conexoes_disponiveis || '2 - SUL ';
    END IF;
    IF tem_leste THEN
        conexoes_disponiveis := conexoes_disponiveis || '3 - LESTE ';
    END IF;
    IF tem_oeste THEN
        conexoes_disponiveis := conexoes_disponiveis || '4 - OESTE ';
    END IF;
    
    -- Perguntar direção
    RAISE NOTICE 'Para onde vamos agora?';
    RAISE NOTICE 'Direções disponíveis: %', conexoes_disponiveis;
    RAISE NOTICE '';
    RAISE NOTICE 'Escolha uma direção (1-4): %', direcao_escolhida;
    
    -- Validar escolha
    CASE direcao_escolhida
        WHEN '1' THEN 
            IF NOT tem_norte THEN
                RAISE EXCEPTION 'Direção NORTE não está disponível';
            END IF;
        WHEN '2' THEN 
            IF NOT tem_sul THEN
                RAISE EXCEPTION 'Direção SUL não está disponível';
            END IF;
        WHEN '3' THEN 
            IF NOT tem_leste THEN
                RAISE EXCEPTION 'Direção LESTE não está disponível';
            END IF;
        WHEN '4' THEN 
            IF NOT tem_oeste THEN
                RAISE EXCEPTION 'Direção OESTE não está disponível';
            END IF;
        ELSE
            RAISE EXCEPTION 'Escolha inválida. Use 1, 2, 3 ou 4.';
    END CASE;
    
    -- Converter escolha em direção
    CASE direcao_escolhida
        WHEN '1' THEN direcao_escolhida := 'NORTE';
        WHEN '2' THEN direcao_escolhida := 'SUL';
        WHEN '3' THEN direcao_escolhida := 'LESTE';
        WHEN '4' THEN direcao_escolhida := 'OESTE';
    END CASE;
    
    -- Mover o piloto
    setor_destino := verificar_movimentacao_valida(setor_atual, direcao_escolhida);
    
    UPDATE Piloto
    SET setor = setor_destino
    WHERE id = piloto_id;
    
    -- Obter nome do setor de destino
    SELECT nome INTO nome_destino
    FROM Setor
    WHERE id = setor_destino;
    
    -- Mostrar resultado
    RAISE NOTICE '';
    RAISE NOTICE '=== MOVIMENTAÇÃO REALIZADA ===';
    RAISE NOTICE 'Você se moveu para: %', direcao_escolhida;
    RAISE NOTICE 'Nova posição: %', nome_destino;
    RAISE NOTICE '';
    
    COMMIT;
END;
$$;

-- =====================================================
-- 4. SISTEMA DE STATUS E ACOMPANHAMENTO
-- =====================================================

-- Procedimento para mostrar mapa
CREATE OR REPLACE PROCEDURE mostrar_mapa()
LANGUAGE plpgsql
AS $$
DECLARE
    setor RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== MAPA DOS SETORES ===';
    
    FOR setor IN 
        SELECT 
            s.id,
            s.nome,
            s.tipo,
            norte.nome as setor_norte,
            sul.nome as setor_sul,
            leste.nome as setor_leste,
            oeste.nome as setor_oeste
        FROM Setor s
        LEFT JOIN Setor norte ON s.id_norte = norte.id
        LEFT JOIN Setor sul ON s.id_sul = sul.id
        LEFT JOIN Setor leste ON s.id_leste = leste.id
        LEFT JOIN Setor oeste ON s.id_oeste = oeste.id
        ORDER BY s.id
    LOOP
        RAISE NOTICE 'Setor %: % (%s)', setor.id, setor.nome, setor.tipo;
        IF setor.setor_norte IS NOT NULL THEN
            RAISE NOTICE '  NORTE -> %', setor.setor_norte;
        END IF;
        IF setor.setor_sul IS NOT NULL THEN
            RAISE NOTICE '  SUL -> %', setor.setor_sul;
        END IF;
        IF setor.setor_leste IS NOT NULL THEN
            RAISE NOTICE '  LESTE -> %', setor.setor_leste;
        END IF;
        IF setor.setor_oeste IS NOT NULL THEN
            RAISE NOTICE '  OESTE -> %', setor.setor_oeste;
        END IF;
        RAISE NOTICE '';
    END LOOP;
END;
$$;

-- Procedimento para status do piloto
CREATE OR REPLACE PROCEDURE status_piloto(piloto_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    piloto_info RECORD;
    setor_info RECORD;
BEGIN
    -- Obter informações do piloto e setor atual
    SELECT 
        p.id,
        p.email,
        p.setor,
        s.nome as nome_setor,
        s.tipo as tipo_setor,
        s.descricao as descricao_setor
    INTO piloto_info
    FROM Piloto p
    LEFT JOIN Setor s ON p.setor = s.id
    WHERE p.id = piloto_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Piloto com ID % não encontrado', piloto_id;
    END IF;
    
    -- Mostrar status
    RAISE NOTICE '';
    RAISE NOTICE '=== STATUS DO PILOTO ===';
    RAISE NOTICE 'ID: %', piloto_info.id;
    RAISE NOTICE 'Email: %', piloto_info.email;
    RAISE NOTICE '';
    RAISE NOTICE '=== POSIÇÃO ATUAL ===';
    RAISE NOTICE 'Setor: %', piloto_info.nome_setor;
    RAISE NOTICE 'Tipo: %', piloto_info.tipo_setor;
    RAISE NOTICE 'Descrição: %', piloto_info.descricao_setor;
    RAISE NOTICE '';
    
    -- Mostrar conexões disponíveis
    IF piloto_info.setor IS NOT NULL THEN
        RAISE NOTICE '=== CONEXÕES DISPONÍVEIS ===';
        
        -- Verificar cada direção
        IF EXISTS(SELECT 1 FROM Setor WHERE id = piloto_info.setor AND id_norte IS NOT NULL) THEN
            SELECT nome INTO setor_info FROM Setor WHERE id = (SELECT id_norte FROM Setor WHERE id = piloto_info.setor);
            RAISE NOTICE 'NORTE -> %', setor_info.nome;
        END IF;
        
        IF EXISTS(SELECT 1 FROM Setor WHERE id = piloto_info.setor AND id_sul IS NOT NULL) THEN
            SELECT nome INTO setor_info FROM Setor WHERE id = (SELECT id_sul FROM Setor WHERE id = piloto_info.setor);
            RAISE NOTICE 'SUL -> %', setor_info.nome;
        END IF;
        
        IF EXISTS(SELECT 1 FROM Setor WHERE id = piloto_info.setor AND id_leste IS NOT NULL) THEN
            SELECT nome INTO setor_info FROM Setor WHERE id = (SELECT id_leste FROM Setor WHERE id = piloto_info.setor);
            RAISE NOTICE 'LESTE -> %', setor_info.nome;
        END IF;
        
        IF EXISTS(SELECT 1 FROM Setor WHERE id = piloto_info.setor AND id_oeste IS NOT NULL) THEN
            SELECT nome INTO setor_info FROM Setor WHERE id = (SELECT id_oeste FROM Setor WHERE id = piloto_info.setor);
            RAISE NOTICE 'OESTE -> %', setor_info.nome;
        END IF;
    END IF;
    
    RAISE NOTICE '';
END;
$$;

-- =====================================================
-- 5. SISTEMA DE COLETAS
-- =====================================================

-- 1. Procedure para coletar minério
CREATE OR REPLACE PROCEDURE coletar_minerio(piloto_id INTEGER, minerio_id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    setor_piloto INTEGER;
    id_nave_var INTEGER;
    peso_minerio NUMERIC;
    carga_atual NUMERIC;
    limite_carga NUMERIC;
    extracao_total NUMERIC;
    quantidade_para_extrair INTEGER;
    quantidade_atual INTEGER;
    nome_minerio TEXT;
BEGIN
    -- Verificar se o piloto existe
    IF NOT EXISTS(SELECT 1 FROM Piloto WHERE id = piloto_id) THEN
        RAISE EXCEPTION 'Piloto com ID % não encontrado', piloto_id;
    END IF;

    -- Setor do piloto
    SELECT setor INTO setor_piloto FROM Piloto WHERE id = piloto_id;
    IF setor_piloto IS NULL THEN
        RAISE EXCEPTION 'Piloto não possui setor definido';
    END IF;

    -- Nave do piloto
    SELECT np.id_nave INTO id_nave_var FROM nave_piloto np WHERE np.id_piloto = piloto_id LIMIT 1;
    IF id_nave_var IS NULL THEN
        RAISE EXCEPTION 'Piloto não possui nave vinculada';
    END IF;

    -- Verificar se o minério existe
    IF NOT EXISTS(SELECT 1 FROM Minerio WHERE id = minerio_id) THEN
        RAISE EXCEPTION 'Minério com ID % não encontrado', minerio_id;
    END IF;

    -- Peso e quantidade do minério no setor
    SELECT m.peso, ms.quantidade, m.nome INTO peso_minerio, quantidade_atual, nome_minerio
    FROM Minerio m
    JOIN minerio_setor ms ON ms.id_minerio = m.id
    WHERE m.id = minerio_id AND ms.id_setor = setor_piloto;

    IF NOT FOUND OR quantidade_atual <= 0 THEN
        RAISE EXCEPTION 'Minério % não disponível no setor atual do piloto!', minerio_id;
    END IF;

    -- Carga atual e limite da nave
    SELECT carga, limite INTO carga_atual, limite_carga FROM Nave WHERE id = id_nave_var;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nave não encontrada';
    END IF;

    -- Soma extração dos equipamentos (ou 5 se for menor)
    SELECT COALESCE(SUM(e.extracao), 0) INTO extracao_total
    FROM nave_equipamento ne
    JOIN Equipamento e ON e.nome = ne.nome_equipamento
    WHERE ne.id_nave = id_nave_var AND ne.nave_atual = TRUE;

    quantidade_para_extrair := GREATEST(extracao_total, 5)::INTEGER;

    -- Verifica disponibilidade no setor e espaço na nave
    IF quantidade_atual < quantidade_para_extrair THEN
        RAISE EXCEPTION 'Quantidade insuficiente no setor para extração (requer %, disponível %)', quantidade_para_extrair, quantidade_atual;
    END IF;

    IF carga_atual + (peso_minerio * quantidade_para_extrair) > limite_carga THEN
        RAISE EXCEPTION 'Nave sem espaço para essa carga de minério (limite: %, atual: %, necessário: %)', limite_carga, carga_atual, peso_minerio * quantidade_para_extrair;
    END IF;

    -- Atualiza carga da nave e quantidade no setor
    UPDATE Nave SET carga = carga + (peso_minerio * quantidade_para_extrair) WHERE id = id_nave_var;
    UPDATE minerio_setor SET quantidade = quantidade - quantidade_para_extrair WHERE id_minerio = minerio_id AND id_setor = setor_piloto;

    -- Insere minérios na nave
    FOR i IN 1..quantidade_para_extrair LOOP
        INSERT INTO minerio_nave (id_minerio, id_nave) VALUES (minerio_id, id_nave_var);
    END LOOP;

    RAISE NOTICE '✅ Coletado % unidades de % (ID: %)', quantidade_para_extrair, nome_minerio, minerio_id;
    RAISE NOTICE '📦 Carga atual da nave: % / %', carga_atual + (peso_minerio * quantidade_para_extrair), limite_carga;
END;
$$;

-- 2. Procedure para vender minérios quando estiver em estação
CREATE OR REPLACE PROCEDURE vender_minerios(piloto_id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    setor_piloto INTEGER;
    id_nave_var INTEGER;
    tipo_setor TEXT;
    dinheiro_ganho NUMERIC := 0;
    rec RECORD;
    peso_total NUMERIC := 0;
    dinheiro_atual NUMERIC;
    nome_setor TEXT;
BEGIN
    -- Verificar se o piloto existe
    IF NOT EXISTS(SELECT 1 FROM Piloto WHERE id = piloto_id) THEN
        RAISE EXCEPTION 'Piloto com ID % não encontrado', piloto_id;
    END IF;

    -- Setor e tipo
    SELECT setor INTO setor_piloto FROM Piloto WHERE id = piloto_id;
    IF setor_piloto IS NULL THEN
        RAISE EXCEPTION 'Piloto não possui setor definido';
    END IF;

    SELECT tipo, nome INTO tipo_setor, nome_setor FROM Setor WHERE id = setor_piloto;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Setor não encontrado';
    END IF;

    IF tipo_setor IS DISTINCT FROM 'Estação' THEN
        RAISE EXCEPTION 'Só é possível vender minérios em uma estação! (Setor atual: % - Tipo: %)', nome_setor, tipo_setor;
    END IF;

    -- Nave do piloto
    SELECT np.id_nave INTO id_nave_var FROM nave_piloto np WHERE np.id_piloto = piloto_id LIMIT 1;
    IF id_nave_var IS NULL THEN
        RAISE EXCEPTION 'Piloto não possui nave vinculada';
    END IF;

    -- Verificar se há minérios na nave
    IF NOT EXISTS(SELECT 1 FROM minerio_nave WHERE id_nave = id_nave_var) THEN
        RAISE NOTICE 'Nenhum minério para vender na nave.';
        RETURN;
    END IF;

    -- Para cada tipo de minério na nave, calcula valor e soma
    FOR rec IN
        SELECT m.id, m.nome, m.valor, COUNT(mn.id) AS qtd
        FROM minerio_nave mn
        JOIN Minerio m ON m.id = mn.id_minerio
        WHERE mn.id_nave = id_nave_var
        GROUP BY m.id, m.nome, m.valor
    LOOP
        dinheiro_ganho := dinheiro_ganho + (rec.valor * rec.qtd);
        peso_total := peso_total + (rec.qtd * (SELECT peso FROM Minerio WHERE id = rec.id));
        RAISE NOTICE '💎 Vendendo % unidades de % por % créditos cada', rec.qtd, rec.nome, rec.valor;
    END LOOP;

    -- Obter dinheiro atual do piloto
    SELECT dinheiro INTO dinheiro_atual FROM Piloto WHERE id = piloto_id;

    -- Atualiza dinheiro do piloto
    UPDATE Piloto SET dinheiro = dinheiro + dinheiro_ganho WHERE id = piloto_id;

    -- Remove minérios da nave e reseta carga
    DELETE FROM minerio_nave WHERE id_nave = id_nave_var;
    UPDATE Nave SET carga = 0 WHERE id = id_nave_var;

    RAISE NOTICE '💰 Total vendido: % créditos', dinheiro_ganho;
    RAISE NOTICE '💳 Saldo anterior: % créditos', dinheiro_atual;
    RAISE NOTICE '💳 Saldo atual: % créditos', dinheiro_atual + dinheiro_ganho;
    RAISE NOTICE '📦 Carga da nave resetada para 0';
END;
$$;


CREATE OR REPLACE FUNCTION ver_dinheiro_piloto(piloto_id INTEGER)
RETURNS VOID AS $$
DECLARE
    saldo NUMERIC;
    nome_piloto TEXT;
BEGIN
    -- Verificar se o piloto existe
    IF NOT EXISTS(SELECT 1 FROM Piloto WHERE id = piloto_id) THEN
        RAISE EXCEPTION 'Piloto com ID % não encontrado', piloto_id;
    END IF;

    SELECT dinheiro, email INTO saldo, nome_piloto FROM Piloto WHERE id = piloto_id;

    IF saldo IS NULL THEN
        RAISE NOTICE '💳 Piloto % (ID: %) possui 0 créditos.', nome_piloto, piloto_id;
    ELSE
        RAISE NOTICE '💳 Piloto % (ID: %) possui % créditos.', nome_piloto, piloto_id, saldo;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION comprar_mais_carga_nave(piloto_id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    id_nave_var INTEGER;
    dinheiro_atual NUMERIC;
    custo_upgrade NUMERIC := 300; -- Custo fixo do upgrade
    incremento_carga INTEGER := 30; -- Quanto será aumentado o limite de carga
    nova_carga_maxima INTEGER;
    tipo_setor TEXT;
    nome_setor TEXT;
BEGIN
    -- Verificar se o piloto existe
    IF NOT EXISTS(SELECT 1 FROM Piloto WHERE id = piloto_id) THEN
        RAISE EXCEPTION 'Piloto com ID % não encontrado', piloto_id;
    END IF;

    -- Obter nave vinculada ao piloto
    SELECT np.id_nave INTO id_nave_var FROM nave_piloto np WHERE np.id_piloto = piloto_id LIMIT 1;
    IF id_nave_var IS NULL THEN
        RAISE EXCEPTION 'Piloto não possui nave vinculada';
    END IF;

    -- Setor e tipo
    SELECT setor INTO setor_piloto FROM Piloto WHERE id = piloto_id;
    IF setor_piloto IS NULL THEN
        RAISE EXCEPTION 'Piloto não possui setor definido';
    END IF;

    SELECT tipo, nome INTO tipo_setor, nome_setor FROM Setor WHERE id = setor_piloto;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Setor não encontrado';
    END IF;

    IF tipo_setor IS DISTINCT FROM 'Estação' THEN
        RAISE EXCEPTION 'Só é possível comprar upgrades em uma estação! (Setor atual: % - Tipo: %)', nome_setor, tipo_setor;
    END IF;

    -- Obter dinheiro atual do piloto
    SELECT dinheiro INTO dinheiro_atual FROM Piloto WHERE id = piloto_id;

    -- Verificar se há dinheiro suficiente
    IF dinheiro_atual < custo_upgrade THEN
        RAISE EXCEPTION 'Créditos insuficientes: necessário %, disponível %', custo_upgrade, dinheiro_atual;
    END IF;

    -- Subtrai o valor do upgrade do dinheiro do piloto
    UPDATE Piloto SET dinheiro = dinheiro - custo_upgrade WHERE id = piloto_id;

    -- Aumenta o limite de carga da nave
    UPDATE Nave SET limite = limite + incremento_carga WHERE id = id_nave_var;

    -- Exibe novo limite para confirmação
    SELECT limite INTO nova_carga_maxima FROM Nave WHERE id = id_nave_var;

    RAISE NOTICE '🚀 Upgrade concluído com sucesso!';
    RAISE NOTICE '💸 Créditos gastos: %', custo_upgrade;
    RAISE NOTICE '📦 Novo limite de carga da nave: %', nova_carga_maxima;
END;
$$;




-- =====================================================
-- 5.1. PROCEDIMENTOS AUXILIARES PARA DEBUG
-- =====================================================

-- Procedimento para verificar status da nave e minérios
CREATE OR REPLACE PROCEDURE status_nave_minerios(piloto_id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    id_nave INTEGER;
    nome_nave TEXT;
    carga_atual NUMERIC;
    limite_carga NUMERIC;
    rec RECORD;
BEGIN
    -- Verificar se o piloto existe
    IF NOT EXISTS(SELECT 1 FROM Piloto WHERE id = piloto_id) THEN
        RAISE EXCEPTION 'Piloto com ID % não encontrado', piloto_id;
    END IF;

    -- Nave do piloto
    SELECT np.id_nave, n.nome, n.carga, n.limite 
    INTO id_nave, nome_nave, carga_atual, limite_carga 
    FROM nave_piloto np
    JOIN Nave n ON n.id = np.id_nave
    WHERE np.id_piloto = piloto_id LIMIT 1;
    
    IF id_nave IS NULL THEN
        RAISE NOTICE '❌ Piloto não possui nave vinculada';
        RETURN;
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE '🚀 === STATUS DA NAVE ===';
    RAISE NOTICE 'Nave: % (ID: %)', nome_nave, id_nave;
    RAISE NOTICE 'Carga atual: % / %', carga_atual, limite_carga;
    RAISE NOTICE '';

    -- Verificar minérios na nave
    IF EXISTS(SELECT 1 FROM minerio_nave WHERE id_nave = id_nave) THEN
        RAISE NOTICE '💎 === MINÉRIOS NA NAVE ===';
        FOR rec IN
            SELECT m.nome, COUNT(mn.id) AS quantidade, m.valor
            FROM minerio_nave mn
            JOIN Minerio m ON m.id = mn.id_minerio
            WHERE mn.id_nave = id_nave
            GROUP BY m.nome, m.valor
            ORDER BY m.nome
        LOOP
            RAISE NOTICE '%: % unidades (valor: % créditos cada)', rec.nome, rec.quantidade, rec.valor;
        END LOOP;
    ELSE
        RAISE NOTICE '📦 Nave vazia - nenhum minério carregado';
    END IF;
    RAISE NOTICE '';
END;
$$;

-- Procedimento para verificar minérios disponíveis no setor atual
CREATE OR REPLACE PROCEDURE minerios_disponiveis_setor(piloto_id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    setor_piloto INTEGER;
    nome_setor TEXT;
    rec RECORD;
BEGIN
    -- Verificar se o piloto existe
    IF NOT EXISTS(SELECT 1 FROM Piloto WHERE id = piloto_id) THEN
        RAISE EXCEPTION 'Piloto com ID % não encontrado', piloto_id;
    END IF;

    -- Setor do piloto
    SELECT setor INTO setor_piloto FROM Piloto WHERE id = piloto_id;
    IF setor_piloto IS NULL THEN
        RAISE EXCEPTION 'Piloto não possui setor definido';
    END IF;

    SELECT nome INTO nome_setor FROM Setor WHERE id = setor_piloto;

    RAISE NOTICE '';
    RAISE NOTICE '🏔️ === MINÉRIOS DISPONÍVEIS EM % ===', nome_setor;

    -- Verificar minérios no setor
    IF EXISTS(SELECT 1 FROM minerio_setor WHERE id_setor = setor_piloto AND quantidade > 0) THEN
        FOR rec IN
            SELECT m.id, m.nome, ms.quantidade, m.peso, m.valor
            FROM minerio_setor ms
            JOIN Minerio m ON m.id = ms.id_minerio
            WHERE ms.id_setor = setor_piloto AND ms.quantidade > 0
            ORDER BY m.nome
        LOOP
            RAISE NOTICE 'ID %: % - % unidades (peso: %, valor: % créditos)', 
                        rec.id, rec.nome, rec.quantidade, rec.peso, rec.valor;
        END LOOP;
    ELSE
        RAISE NOTICE '❌ Nenhum minério disponível neste setor';
    END IF;
    RAISE NOTICE '';
END;
$$;

-- =====================================================
-- 6. TRIGGERS
-- =====================================================

-- Trigger para validar movimentação
CREATE OR REPLACE FUNCTION trigger_validar_movimentacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o setor está sendo alterado
    IF OLD.setor IS DISTINCT FROM NEW.setor THEN
        -- Verificar se o novo setor existe
        IF NEW.setor IS NOT NULL AND NOT validar_setor(NEW.setor) THEN
            RAISE EXCEPTION 'Setor % não existe', NEW.setor;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger na tabela Piloto
DROP TRIGGER IF EXISTS trigger_validar_movimentacao_piloto ON Piloto;
CREATE TRIGGER trigger_validar_movimentacao_piloto
    BEFORE UPDATE ON Piloto
    FOR EACH ROW
    EXECUTE FUNCTION trigger_validar_movimentacao();

-- Trigger para log de movimentação
CREATE OR REPLACE FUNCTION trigger_log_movimentacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o setor foi alterado
    IF OLD.setor IS DISTINCT FROM NEW.setor THEN
        RAISE NOTICE 'Piloto % movido do setor % para o setor %', 
                     NEW.id, OLD.setor, NEW.setor;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger de log na tabela Piloto
DROP TRIGGER IF EXISTS trigger_log_movimentacao_piloto ON Piloto;
CREATE TRIGGER trigger_log_movimentacao_piloto
    AFTER UPDATE ON Piloto
    FOR EACH ROW
    EXECUTE FUNCTION trigger_log_movimentacao();

-- =====================================================
-- SISTEMA COMPLETO INSTALADO!
-- =====================================================

\echo '✅ SISTEMA COMPLETO DE NAVEGAÇÃO INSTALADO!'
\echo ''
\echo 'Comandos disponíveis:'
\echo '  CALL boas_vindas_automatico(1);' -- IGNORAR
\echo '  CALL navegar_manual(1, ''1''); -- NORTE' -- FEITO
\echo '  CALL navegar_manual(1, ''2''); -- SUL' -- FEITO
\echo '  CALL navegar_manual(1, ''3''); -- LESTE' -- FEITO
\echo '  CALL navegar_manual(1, ''4''); -- OESTE' -- FEITO
\echo '  CALL status_piloto(1);' -- FEITO
\echo '  CALL mostrar_mapa();' -- FEITO
\echo '  CALL forcar_boas_vindas(1);' -- IGNORAR
\echo ''
\echo 'Comandos de Mineração:'
\echo '  CALL coletar_minerio(1, 1); -- Coleta minério ID 1'
\echo '  CALL vender_minerios(1); -- Vende minérios em estação'
\echo '  SELECT ver_dinheiro_piloto(1); -- Ver saldo'
\echo '  CALL comprar_mais_carga_nave(1) -- Aumenta a carga total da sua nave'
\echo ''
\echo 'Comandos de Debug:'
\echo '  CALL status_nave_minerios(1); -- Status da nave e minérios'
\echo '  CALL minerios_disponiveis_setor(1); -- Minérios no setor atual' 