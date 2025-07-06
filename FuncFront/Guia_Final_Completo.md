# 🚀 Guia Final Completo - Final Frontier

## 📋 Índice
1. [Visão Geral](#visão-geral)
2. [Instalação](#instalação)
3. [Sistema Duplo](#sistema-duplo)
4. [Funções para Frontend](#funções-para-frontend)
5. [Procedimentos para Console](#procedimentos-para-console)
6. [Exemplos de Uso](#exemplos-de-uso)
7. [Integração com Aplicação](#integração-com-aplicação)
8. [Troubleshooting](#troubleshooting)

## 🎯 Visão Geral

O sistema Final Frontier possui **duas abordagens** para resolver o problema dos `RAISE NOTICE`:

- **Para Console**: Procedimentos com `RAISE NOTICE` para testes manuais
- **Para Frontend**: Funções que retornam dados estruturados para aplicações

## ⚙️ Instalação

### 1. Preparar o Ambiente
```bash
# Iniciar PostgreSQL no WSL
sudo service postgresql start

# Conectar ao PostgreSQL
sudo -u postgres psql

# Criar banco (se não existir)
CREATE DATABASE final_frontier;

# Conectar ao banco
\c final_frontier
```

### 2. Executar o Sistema
```sql
-- Executar o arquivo completo
\i 'Entrega 2/Procedimentos_Completos.sql'
```

## 🔄 Sistema Duplo

### Para Console (RAISE NOTICE)
```sql
-- Use quando estiver testando no PostgreSQL diretamente
CALL boas_vindas_automatico(1);
CALL navegar_manual(1, '1');
CALL status_piloto(1);
CALL mostrar_mapa();
```

### Para Frontend (RETURNS TABLE)
```sql
-- Use quando estiver integrando com aplicação
SELECT * FROM boas_vindas_automatico_app(1);
SELECT * FROM navegar_manual_app(1, '1');
SELECT * FROM status_piloto_app(1);
SELECT * FROM mostrar_mapa_app();
```

## 🎮 Funções para Frontend

### 1. Boas-Vindas Automático
```sql
SELECT * FROM boas_vindas_automatico_app(piloto_id);
```

**Retorna:**
- `tipo_mensagem`: 'PRIMEIRA_VEZ' ou 'RETORNO'
- `titulo`: Título da mensagem
- `mensagem`: Texto da mensagem
- `primeira_vez`: true/false

**Exemplo de Retorno:**
```json
{
  "tipo_mensagem": "PRIMEIRA_VEZ",
  "titulo": "🎉 BEM-VINDO À FINAL FRONTIER! 🎉",
  "mensagem": "O objetivo do jogo é explorar...",
  "primeira_vez": true
}
```

### 2. Navegação Manual
```sql
SELECT * FROM navegar_manual_app(piloto_id, direcao);
```

**Parâmetros:**
- `direcao`: '1' (NORTE), '2' (SUL), '3' (LESTE), '4' (OESTE)

**Retorna:**
- `sucesso`: true/false
- `mensagem`: Mensagem de sucesso ou erro
- `setor_origem`: Nome do setor de origem
- `setor_destino`: Nome do setor de destino
- `direcao`: Direção escolhida
- `conexoes_disponiveis`: Lista de direções disponíveis

**Exemplo de Retorno (Sucesso):**
```json
{
  "sucesso": true,
  "mensagem": "Movimentação realizada com sucesso!",
  "setor_origem": "Setor Alpha",
  "setor_destino": "Setor Beta",
  "direcao": "NORTE",
  "conexoes_disponiveis": "1 - NORTE 2 - SUL 3 - LESTE"
}
```

### 3. Status do Piloto
```sql
SELECT * FROM status_piloto_app(piloto_id);
```

**Retorna:**
- `piloto_id`: ID do piloto
- `email`: Email do piloto
- `setor_atual_id`: ID do setor atual
- `setor_atual_nome`: Nome do setor atual
- `setor_atual_tipo`: Tipo do setor atual
- `setor_atual_descricao`: Descrição do setor atual
- `conexoes_norte`: Nome do setor ao norte
- `conexoes_sul`: Nome do setor ao sul
- `conexoes_leste`: Nome do setor ao leste
- `conexoes_oeste`: Nome do setor ao oeste

### 4. Mapa Completo
```sql
SELECT * FROM mostrar_mapa_app();
```

**Retorna:**
- `setor_id`: ID do setor
- `setor_nome`: Nome do setor
- `setor_tipo`: Tipo do setor
- `setor_norte`: Nome do setor ao norte
- `setor_sul`: Nome do setor ao sul
- `setor_leste`: Nome do setor ao leste
- `setor_oeste`: Nome do setor ao oeste

### 5. Setores Conectados
```sql
SELECT * FROM obter_setores_conectados(setor_id);
```

**Retorna:**
- `direcao`: Direção da conexão
- `setor_destino`: ID do setor de destino
- `nome_setor`: Nome do setor de destino
- `tipo_setor`: Tipo do setor de destino

## 💻 Procedimentos para Console

### 1. Boas-Vindas Automático
```sql
CALL boas_vindas_automatico(1);
```
**Saída no console:**
```
🎉 BEM-VINDO À FINAL FRONTIER! 🎉

O objetivo do jogo é explorar e navegar por setores cheios de riquezas,
para que possamos minerar e nos transformarmos nos pilotos mais ricos do sistema!!!

🚀 Prepare-se para a maior aventura espacial de todos os tempos!

✅ Boas-vindas registradas! Divirta-se explorando o universo!
```

### 2. Navegação Manual
```sql
CALL navegar_manual(1, '1');
```
**Saída no console:**
```
=== POSIÇÃO ATUAL ===
Você está no: Setor Alpha
Tipo: Civilizado
Descrição: Setor principal do sistema

Para onde vamos agora?
Direções disponíveis: 1 - NORTE 2 - SUL 3 - LESTE 4 - OESTE

Escolha uma direção (1-4): 1

=== MOVIMENTAÇÃO REALIZADA ===
Você se moveu para: NORTE
Nova posição: Setor Beta
```

### 3. Status do Piloto
```sql
CALL status_piloto(1);
```
**Saída no console:**
```
=== STATUS DO PILOTO ===
ID: 1
Email: piloto@test.com

=== POSIÇÃO ATUAL ===
Setor: Setor Alpha
Tipo: Civilizado
Descrição: Setor principal do sistema

=== CONEXÕES DISPONÍVEIS ===
NORTE -> Setor Beta
SUL -> Setor Gamma
LESTE -> Setor Delta
OESTE -> Setor Epsilon
```

### 4. Mostrar Mapa
```sql
CALL mostrar_mapa();
```
**Saída no console:**
```
=== MAPA DOS SETORES ===
Setor 1: Setor Alpha (Civilizado)
  NORTE -> Setor Beta
  SUL -> Setor Gamma
  LESTE -> Setor Delta
  OESTE -> Setor Epsilon

Setor 2: Setor Beta (Selvagem)
  SUL -> Setor Alpha
  LESTE -> Setor Epsilon
  OESTE -> Setor Delta
```

## 🧪 Exemplos de Uso

### Teste Rápido no PostgreSQL
```sql
-- 1. Verificar boas-vindas
SELECT * FROM boas_vindas_automatico_app(1);

-- 2. Ver status atual
SELECT * FROM status_piloto_app(1);

-- 3. Ver conexões disponíveis
SELECT * FROM obter_setores_conectados(1);

-- 4. Navegar para uma direção
SELECT * FROM navegar_manual_app(1, '1');

-- 5. Verificar novo status
SELECT * FROM status_piloto_app(1);

-- 6. Ver mapa completo
SELECT * FROM mostrar_mapa_app();
```

### Teste no Console
```sql
-- 1. Boas-vindas
CALL boas_vindas_automatico(1);

-- 2. Status
CALL status_piloto(1);

-- 3. Navegar
CALL navegar_manual(1, '1');

-- 4. Mapa
CALL mostrar_mapa();
```

## 🔗 Integração com Aplicação

### JavaScript/Node.js
```javascript
// Verificar boas-vindas
async function verificarBoasVindas(pilotoId) {
    const response = await fetch(`/api/boas-vindas/${pilotoId}`);
    const data = await response.json();
    
    if (data.primeira_vez) {
        mostrarMensagem(data.titulo, data.mensagem);
    } else {
        mostrarMensagem(data.titulo, data.mensagem);
    }
}

// Navegar
async function navegar(pilotoId, direcao) {
    const response = await fetch(`/api/navegar`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pilotoId, direcao })
    });
    const data = await response.json();
    
    if (data.sucesso) {
        atualizarPosicao(data.setor_destino);
        mostrarMensagem('Sucesso!', data.mensagem);
    } else {
        mostrarErro(data.mensagem);
    }
}

// Obter status
async function obterStatus(pilotoId) {
    const response = await fetch(`/api/status/${pilotoId}`);
    const data = await response.json();
    atualizarInterfacePiloto(data);
}
```

### React
```jsx
import React, { useState, useEffect } from 'react';

function GameComponent({ pilotoId }) {
    const [status, setStatus] = useState(null);
    const [mensagem, setMensagem] = useState('');

    useEffect(() => {
        verificarBoasVindas();
        carregarStatus();
    }, []);

    const verificarBoasVindas = async () => {
        const response = await fetch(`/api/boas-vindas/${pilotoId}`);
        const data = await response.json();
        setMensagem(`${data.titulo} ${data.mensagem}`);
    };

    const carregarStatus = async () => {
        const response = await fetch(`/api/status/${pilotoId}`);
        const data = await response.json();
        setStatus(data);
    };

    const navegar = async (direcao) => {
        const response = await fetch(`/api/navegar`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ pilotoId, direcao })
        });
        const data = await response.json();
        
        if (data.sucesso) {
            setMensagem(`Movido para ${data.setor_destino}!`);
            carregarStatus();
        } else {
            setMensagem(`Erro: ${data.mensagem}`);
        }
    };

    return (
        <div>
            {mensagem && <div className="mensagem">{mensagem}</div>}
            
            {status && (
                <div className="status">
                    <h3>Status do Piloto</h3>
                    <p>Posição: {status.setor_atual_nome}</p>
                    <p>Tipo: {status.setor_atual_tipo}</p>
                    <p>Descrição: {status.setor_atual_descricao}</p>
                </div>
            )}

            <div className="navegacao">
                <h3>Navegação</h3>
                <button onClick={() => navegar('1')}>NORTE</button>
                <button onClick={() => navegar('2')}>SUL</button>
                <button onClick={() => navegar('3')}>LESTE</button>
                <button onClick={() => navegar('4')}>OESTE</button>
            </div>
        </div>
    );
}
```

## 🔧 Troubleshooting

### Problema: RAISE NOTICE não aparece na aplicação
**Solução:** Use as funções `_app` ao invés dos procedimentos `CALL`

### Problema: Erro "Piloto não encontrado"
**Solução:** Verifique se o piloto existe na tabela `Piloto`

### Problema: Erro "Direção não disponível"
**Solução:** Verifique as conexões disponíveis com `obter_setores_conectados()`

### Problema: Erro de conexão com banco
**Solução:** Verifique se o PostgreSQL está rodando e se as credenciais estão corretas

## 📁 Arquivos do Sistema

- `Procedimentos_Completos.sql`: Sistema completo com funções e procedimentos
- `Guia_Final_Completo.md`: Esta documentação
- `DDL.sql`: Estrutura do banco de dados
- `DML.sql`: Dados iniciais
- `DQL.sql`: Consultas de exemplo

## ✅ Checklist de Instalação

- [ ] PostgreSQL instalado e rodando
- [ ] Banco `final_frontier` criado
- [ ] Arquivo `Procedimentos_Completos.sql` executado
- [ ] Dados iniciais inseridos (DDL.sql e DML.sql)
- [ ] Testes básicos realizados
- [ ] Aplicação configurada para usar funções `_app`

## 🎮 Próximos Passos

1. **Execute o sistema** no PostgreSQL
2. **Teste as funções** para frontend
3. **Integre com sua aplicação**
4. **Personalize conforme necessário**
5. **Divirta-se explorando o universo Final Frontier!**

---

**🎉 Sistema Final Frontier - Pronto para Uso! 🚀** 