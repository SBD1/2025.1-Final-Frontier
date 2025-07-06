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

-- =====================================================
-- 3. FUNÇÕES PARA FRONTEND (RETORNAM DADOS)
-- =====================================================

-- Função de boas-vindas que retorna dados para o frontend
CREATE OR REPLACE FUNCTION boas_vindas_automatico_app(piloto_id INTEGER)
RETURNS TABLE(
    tipo_mensagem TEXT,
    titulo TEXT,
    mensagem TEXT,
    primeira_vez BOOLEAN
) AS $$
DECLARE
    eh_primeira_vez BOOLEAN;
BEGIN
    -- Verificar se é a primeira vez
    eh_primeira_vez := verificar_primeira_vez(piloto_id);
    
    IF eh_primeira_vez THEN
        -- Registrar que o piloto já viu as boas-vindas
        INSERT INTO boas_vindas_vistas (piloto_id) VALUES (piloto_id);
        
        -- Retornar dados para primeira vez
        RETURN QUERY SELECT 
            'PRIMEIRA_VEZ'::TEXT as tipo_mensagem,
            '🎉 BEM-VINDO À FINAL FRONTIER! 🎉'::TEXT as titulo,
            'O objetivo do jogo é explorar e navegar por setores cheios de riquezas, para que possamos minerar e nos transformarmos nos pilotos mais ricos do sistema!!! 🚀 Prepare-se para a maior aventura espacial de todos os tempos!'::TEXT as mensagem,
            TRUE as primeira_vez;
    ELSE
        -- Retornar dados para retorno
        RETURN QUERY SELECT 
            'RETORNO'::TEXT as tipo_mensagem,
            '👋 Bem-vindo de volta, piloto!'::TEXT as titulo,
            'Pronto para mais aventuras no universo Final Frontier?'::TEXT as mensagem,
            FALSE as primeira_vez;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Função para navegar que retorna dados para o frontend
CREATE OR REPLACE FUNCTION navegar_manual_app(
    piloto_id INTEGER,
    direcao_escolhida TEXT
)
RETURNS TABLE(
    sucesso BOOLEAN,
    mensagem TEXT,
    setor_origem TEXT,
    setor_destino TEXT,
    direcao TEXT,
    conexoes_disponiveis TEXT
) AS $$
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
        RETURN QUERY SELECT 
            FALSE as sucesso,
            'Piloto com ID ' || piloto_id || ' não encontrado' as mensagem,
            ''::TEXT as setor_origem,
            ''::TEXT as setor_destino,
            ''::TEXT as direcao,
            ''::TEXT as conexoes_disponiveis;
        RETURN;
    END IF;
    
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
    
    -- Validar escolha
    CASE direcao_escolhida
        WHEN '1' THEN 
            IF NOT tem_norte THEN
                RETURN QUERY SELECT 
                    FALSE as sucesso,
                    'Direção NORTE não está disponível' as mensagem,
                    nome_setor as setor_origem,
                    ''::TEXT as setor_destino,
                    'NORTE'::TEXT as direcao,
                    conexoes_disponiveis as conexoes_disponiveis;
                RETURN;
            END IF;
        WHEN '2' THEN 
            IF NOT tem_sul THEN
                RETURN QUERY SELECT 
                    FALSE as sucesso,
                    'Direção SUL não está disponível' as mensagem,
                    nome_setor as setor_origem,
                    ''::TEXT as setor_destino,
                    'SUL'::TEXT as direcao,
                    conexoes_disponiveis as conexoes_disponiveis;
                RETURN;
            END IF;
        WHEN '3' THEN 
            IF NOT tem_leste THEN
                RETURN QUERY SELECT 
                    FALSE as sucesso,
                    'Direção LESTE não está disponível' as mensagem,
                    nome_setor as setor_origem,
                    ''::TEXT as setor_destino,
                    'LESTE'::TEXT as direcao,
                    conexoes_disponiveis as conexoes_disponiveis;
                RETURN;
            END IF;
        WHEN '4' THEN 
            IF NOT tem_oeste THEN
                RETURN QUERY SELECT 
                    FALSE as sucesso,
                    'Direção OESTE não está disponível' as mensagem,
                    nome_setor as setor_origem,
                    ''::TEXT as setor_destino,
                    'OESTE'::TEXT as direcao,
                    conexoes_disponiveis as conexoes_disponiveis;
                RETURN;
            END IF;
        ELSE
            RETURN QUERY SELECT 
                FALSE as sucesso,
                'Escolha inválida. Use 1, 2, 3 ou 4.' as mensagem,
                nome_setor as setor_origem,
                ''::TEXT as setor_destino,
                ''::TEXT as direcao,
                conexoes_disponiveis as conexoes_disponiveis;
            RETURN;
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
    
    -- Retornar sucesso
    RETURN QUERY SELECT 
        TRUE as sucesso,
        'Movimentação realizada com sucesso!' as mensagem,
        nome_setor as setor_origem,
        nome_destino as setor_destino,
        direcao_escolhida as direcao,
        conexoes_disponiveis as conexoes_disponiveis;
END;
$$ LANGUAGE plpgsql;

-- Função para status do piloto que retorna dados para o frontend
CREATE OR REPLACE FUNCTION status_piloto_app(piloto_id INTEGER)
RETURNS TABLE(
    piloto_id INTEGER,
    email TEXT,
    setor_atual_id INTEGER,
    setor_atual_nome TEXT,
    setor_atual_tipo TEXT,
    setor_atual_descricao TEXT,
    conexoes_norte TEXT,
    conexoes_sul TEXT,
    conexoes_leste TEXT,
    conexoes_oeste TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as piloto_id,
        p.email,
        p.setor as setor_atual_id,
        s.nome as setor_atual_nome,
        s.tipo as setor_atual_tipo,
        s.descricao as setor_atual_descricao,
        norte.nome as conexoes_norte,
        sul.nome as conexoes_sul,
        leste.nome as conexoes_leste,
        oeste.nome as conexoes_oeste
    FROM Piloto p
    LEFT JOIN Setor s ON p.setor = s.id
    LEFT JOIN Setor norte ON s.id_norte = norte.id
    LEFT JOIN Setor sul ON s.id_sul = sul.id
    LEFT JOIN Setor leste ON s.id_leste = leste.id
    LEFT JOIN Setor oeste ON s.id_oeste = oeste.id
    WHERE p.id = $1;
END;
$$ LANGUAGE plpgsql;

-- Função para mapa que retorna dados para o frontend
CREATE OR REPLACE FUNCTION mostrar_mapa_app()
RETURNS TABLE(
    setor_id INTEGER,
    setor_nome TEXT,
    setor_tipo TEXT,
    setor_norte TEXT,
    setor_sul TEXT,
    setor_leste TEXT,
    setor_oeste TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id as setor_id,
        s.nome as setor_nome,
        s.tipo as setor_tipo,
        norte.nome as setor_norte,
        sul.nome as setor_sul,
        leste.nome as setor_leste,
        oeste.nome as setor_oeste
    FROM Setor s
    LEFT JOIN Setor norte ON s.id_norte = norte.id
    LEFT JOIN Setor sul ON s.id_sul = sul.id
    LEFT JOIN Setor leste ON s.id_leste = leste.id
    LEFT JOIN Setor oeste ON s.id_oeste = oeste.id
    ORDER BY s.id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. PROCEDIMENTOS PARA CONSOLE (RAISE NOTICE)
-- =====================================================

-- Procedimento de boas-vindas automático (para console)
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

-- Procedimento para navegar manualmente (para console)
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

-- Procedimento para mostrar mapa (para console)
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

-- Procedimento para status do piloto (para console)
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
-- 5. TRIGGERS
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
\echo '=== PARA CONSOLE (RAISE NOTICE): ==='
\echo '  CALL boas_vindas_automatico(1);'
\echo '  CALL navegar_manual(1, ''1''); -- NORTE'
\echo '  CALL status_piloto(1);'
\echo '  CALL mostrar_mapa();'
\echo '  CALL forcar_boas_vindas(1);'
\echo ''
\echo '=== PARA FRONTEND (RETORNA DADOS): ==='
\echo '  SELECT * FROM boas_vindas_automatico_app(1);'
\echo '  SELECT * FROM navegar_manual_app(1, ''1''); -- NORTE'
\echo '  SELECT * FROM status_piloto_app(1);'
\echo '  SELECT * FROM mostrar_mapa_app();'
\echo '  SELECT * FROM obter_setores_conectados(1);' 