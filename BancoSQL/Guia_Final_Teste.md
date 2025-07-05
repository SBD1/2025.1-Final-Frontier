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
CALL status_boas_vindas(1);
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

#### Ver mapa completo:
```sql
CALL mostrar_mapa();
```

#### Ver posição atual do piloto (simples):
```sql
SELECT p.id, p.email, s.nome as setor_atual, s.tipo 
FROM Piloto p 
LEFT JOIN Setor s ON p.setor = s.id;
```

### 4. Comandos para Acompanhar sua Movimentação

#### Ver status completo do piloto (posição, tipo, descrição e conexões):
```sql
CALL status_piloto(1);
```


### 5. Exemplo de Sessão Completa

```sql
-- 1. Boas-vindas automático (primeira vez ou retorno)
CALL boas_vindas_automatico(1);

-- 2. Ver mapa
CALL mostrar_mapa();

-- 3. Ver status completo
CALL status_piloto(1);

-- 4. Navegar para NORTE
CALL navegar_manual(1, '1');

-- 5. Ver status novamente
CALL status_piloto(1);

-- 6. Navegar para LESTE
CALL navegar_manual(1, '3');


## 🎮 O que o Sistema Faz

1. **Boas-vindas automático** - Mensagem especial para primeira vez
2. **Mostra sua posição atual** - Nome do setor, tipo e descrição
3. **Pergunta "Para onde vamos agora?"** - Lista as direções disponíveis
4. **Você escolhe (1-4)** - NORTE, SUL, LESTE, OESTE
5. **Move o piloto** - Valida e executa a movimentação
6. **Mostra nova posição** - Confirma onde você chegou
8. **Mostra status detalhado** - Tudo sobre o piloto e setor


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

##  Para Sair
```sql
\q
```

