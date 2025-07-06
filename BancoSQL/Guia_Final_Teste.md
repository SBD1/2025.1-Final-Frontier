# 🚀 SISTEMA DE NAVEGAÇÃO FINAL FRONTIER - FUNCIONANDO!

## Como Testar Manualmente
senha:novasenhaforte

### 1. Conectar ao PostgreSQL
```bash
wsl sudo -u postgres psql -d final_frontier
```

### 2. Sistema de Boas-Vindas Automático

#### Para pilotos que entram pela primeira vez:
```sql
CALL boas_vindas_automatico(1);
```
**Resultado:** Mostra mensagem especial de boas-vindas e registra que o piloto já viu

#### Para pilotos que já entraram antes:
```sql
CALL boas_vindas_automatico(1);
```
**Resultado:** Mostra mensagem de "Bem-vindo de volta!"

#### Verificar status das boas-vindas:
```sql
SELECT verificar_primeira_vez(1);
```

#### Forçar boas-vindas novamente:
```sql
CALL forcar_boas_vindas(1);
```

### 3. Comandos de Navegação

#### Navegação manual:
```sql
CALL navegar_manual(1, '1');  -- NORTE
CALL navegar_manual(1, '2');  -- SUL  
CALL navegar_manual(1, '3');  -- LESTE
CALL navegar_manual(1, '4');  -- OESTE
```

#### Verificar movimentação válida:
```sql
SELECT verificar_movimentacao_valida(1, 'NORTE');
```

#### Obter setores conectados:
```sql
SELECT * FROM obter_setores_conectados(1);
```

#### Ver mapa completo:
```sql
CALL mostrar_mapa();
```

### 4. Comandos para Acompanhar sua Movimentação

#### Ver status completo do piloto (posição, tipo, descrição e conexões):
```sql
CALL status_piloto(1);
```

#### Ver dinheiro do piloto:
```sql
SELECT ver_dinheiro_piloto(1);
```

#### Ver status da nave e minérios:
```sql
CALL status_nave_minerios(1);
```

#### Ver minérios disponíveis no setor atual:
```sql
CALL minerios_disponiveis_setor(1);
```

### 5. Sistema de Coleta e Venda de Minérios

#### Coletar minérios (requer estar em setor com minérios):
```sql
CALL coletar_minerio(1, 1); -- Coleta minério ID 1
CALL coletar_minerio(1, 2); -- Coleta minério ID 2
CALL coletar_minerio(1, 3); -- Coleta minério ID 3
```

#### Vender minérios (requer estar em estação):
```sql
CALL vender_minerios(1);
```

### 6. Funções de Validação

#### Validar se setor existe:
```sql
SELECT validar_setor(1);
```

#### Verificar primeira vez do piloto:
```sql
SELECT verificar_primeira_vez(1);
```

### 7. Exemplo de Sessão Completa

```sql
-- 1. Boas-vindas automático (primeira vez ou retorno)
CALL boas_vindas_automatico(1);

-- 2. Ver mapa
CALL mostrar_mapa();

-- 3. Ver status completo
CALL status_piloto(1);

-- 4. Verificar dinheiro atual
SELECT ver_dinheiro_piloto(1);

-- 5. Ver status da nave
CALL status_nave_minerios(1);

-- 6. Ver minérios disponíveis no setor atual
CALL minerios_disponiveis_setor(1);

-- 7. Coletar minérios (se disponível no setor)
CALL coletar_minerio(1, 1);

-- 8. Ver status da nave após coleta
CALL status_nave_minerios(1);

-- 9. Navegar para LESTE
CALL navegar_manual(1, '3');

-- 10. Vender minérios (se estiver em estação)
CALL vender_minerios(1);

-- 11. Verificar dinheiro após venda
SELECT ver_dinheiro_piloto(1);

-- 12. Ver status final da nave
CALL status_nave_minerios(1);
```

## 🎮 O que o Sistema Faz

1. **Boas-vindas automático** - Mensagem especial para primeira vez
2. **Mostra sua posição atual** - Nome do setor, tipo e descrição
3. **Pergunta "Para onde vamos agora?"** - Lista as direções disponíveis
4. **Você escolhe (1-4)** - NORTE, SUL, LESTE, OESTE
5. **Move o piloto** - Valida e executa a movimentação
6. **Mostra nova posição** - Confirma onde você chegou
7. **Sistema de coleta** - Coleta minérios dos setores
8. **Sistema de venda** - Vende minérios em estações
9. **Controle de dinheiro** - Gerencia créditos do piloto
10. **Mostra status detalhado** - Tudo sobre o piloto e setor

## 🗺️ Mapa dos Setores

```
Setor 1: Base Espacial Alpha (BASE)
  NORTE -> Setor de Mineração
  LESTE -> Setor Comercial

Setor 2: Setor de Mineração (MINERACAO)  
  SUL -> Base Espacial Alpha
  LESTE -> Setor Industrial

Setor 3: Setor Comercial (COMERCIAL)
  OESTE -> Base Espacial Alpha

Setor 4: Setor Industrial (INDUSTRIAL)
  OESTE -> Setor de Mineração
```

## 🔧 Funções Técnicas Disponíveis

### Funções de Validação:
- `validar_setor(setor_id)` - Verifica se setor existe
- `verificar_movimentacao_valida(setor_atual, direcao)` - Valida movimento
- `obter_setores_conectados(setor_id)` - Lista conexões do setor

### Funções de Status:
- `verificar_primeira_vez(piloto_id)` - Verifica se é primeira vez
- `ver_dinheiro_piloto(piloto_id)` - Mostra saldo do piloto

### Triggers Automáticos:
- **trigger_validar_movimentacao_piloto** - Valida movimentação antes de atualizar
- **trigger_log_movimentacao_piloto** - Registra movimentações no log

## 💰 Sistema Econômico

1. **Coleta de Minérios**: Use `coletar_minerio(piloto_id, minerio_id)` em setores com minérios
2. **Venda**: Use `vender_minerios(piloto_id)` em estações para converter minérios em créditos
3. **Controle de Carga**: Sistema verifica automaticamente se a nave tem espaço
4. **Valorização**: Diferentes minérios têm valores diferentes

##  Para Sair
```sql
\q
```

