## **Tabela: `Nave`**
Armazena as informações referentes a nave do usuário.

| Nome         | Descrição                                    | Tipo de dado | Tamanho | Restrições de domínio                                  |
|--------------|----------------------------------------------|--------------|---------|--------------------------------------------------------|
| `idNave`     | Identificador único da nave                  | `SERIAL`     | -       | PK, Not Null                                           |
| `nome`       | Nome da nave                                 | `VARCHAR`    | 50      |  Not Null                                              |
| `vidaMax`    | O limite de vida da nave                     | `INTEGER`    | -       | Not Null,                                              |
| `vidaAtual`  | A vida atual da nave                         | `INTEGER`    | -       | Not Null,                                              |
| `tipo`       | Tipo de nave o piloto está pilotando         | `INTEGER`    | -       | Not Null, Default = 1                                  |
| `limite`     | Quantas modificações o piloto pode fazer     | `INTEGER`    | -       | Not Null                                               |
| `carga`      | Quanto de peso a nave consegue levar         | `INTEGER`    | -       | Not Null                                               |


---

## **Tabela: `Equipamento`**
Armazena as informações referentes aos equipamentos que podem ser equipados na nave.

| Nome               | Descrição                                | Tipo de dado | Tamanho | Restrições de domínio |
|--------------------|------------------------------------------|--------------|---------|------------------------|
| `nome`             | Nome único do equipamento                | `VARCHAR`    | 50      | PK, Not Null           |
| `consumo`          | O limite de vida do equipamento          | `INTEGER`    | -       | Not Null               |
| `defesa`           | O limite de defesa do equipamento        | `INTEGER`    | -       | Not Null               |
| `ataque`           | Dano causado ao inimigo                  | `INTEGER`    | -       | Not Null               |
| `estração`         | Velocidade do inimigo                    | `INTEGER`    | -       | Not Null               |
| `reparo`           | Quantidade para reparar o equipamento    | `INTEGER`    | -       | Not Null               |
| `habilidade`       | Habilidade do equipamento                | `VARCHAR`    | 250     | Not Null               |

---

## **Tabela: `Motor`**
Armazena informações referentes ao motor.

| Nome       | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio |
|------------|-------------------------------------------|--------------|---------|------------------------|
| `nome`     | Nome único do motor                       | `VARCHAR`    | 50      | PK, Not Null           |
| `potencia` | Quantidade de potência do motor           | `INTEGER`    | -       | Not Null               |
| `energia`  | Energia utilizada pelo motor              | `INTEGER`    | -       | -                      |
| `velocidade`| Velocidade do motor                      | `INTEGER`    | -       | FK, Not Null           |

---

## **Tabela: `Piloto`**
Armazena informações referentes ao piloto.

| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `idPiloto`     | Identificador único do usuário            | `SERIAL`     | -       | PK, Not Null           |
| `email`        | Email de login                            | `VARCHAR`    | 50      | PK, Not Null           |
| `senha`        | Senha de login                            | `VARCHAR`    | 50      | PK, Not Null           |


---

## **Tabela: `Minério`**
Armazena informações sobre os minérios que podem ser coletados no jogo.

| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `idMinério`    | Identificador único do minério            | `SERIAL`     | -       | PK, Not Null           |
| `nome`         | Nome do minério                           | `VARCHAR`    | 30      | Not Null               |
| `peso`         | Peso do minério                           | `INTEGER`    | -       | Not Null               |
| `valor`        | Valor do minério                          | `INTEGER`    | -       | Not Null               |

---

## **Tabela: `Hangar`**
Armazena informações de quais naves estão sendo guardadas.

| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `nome`         | Nome único do hangar                      | `VARCHAR`    | 30       | PK, Not Null          |
| `capacidade`   | Capacidade de guardar                     | `INTEGER`    | -       | Not Null               |

---

## **Tabela: `Mercado`**
Armazena informações sobre quanto cada item está sendo vendido.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `nome`         | Nome único do mercado                     | `VARCHAR`    | 30      | PK, Not Null           |
| `capacidade`   | Capacidade de guardar                     | `INTEGER`    | -       | Not Null               |

## **Tabela: `Mercado e Nave`**
Armazena informações de quais naves o mercado vende.
| Nome             | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------  |-------------------------------------------|--------------|---------|------------------------|
| `idMercado_Nave` | Identificador único da instância          | `SERIAL`     |-        | PK, Not Null           |
| `id_nave`        | Identificador único da nave               | `SERIAL`     |-        | FK, Not Null           |
| `nome_mercado`   | Nome do mercado                           | `VARCHAR`    | 30      | FK, Not Null           |
| `preco`          | Valor da nave                             | `INTEGER`    | -       | Not Null               |

## **Tabela: `Mercado e Equipamento`**
Armazena informações de quais equipamentos o mercado vende.
| Nome              | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|-------------------|-------------------------------------------|--------------|---------|------------------------|
| `idSetor`         | Identificador único da instância          | `SERIAL`     | -       | PK, Not Null           |
| `nome_equipamento`| Nome do equipamento                       | `VARCHAR`    | 30      | FK, Not Null           |
| `nome_mercado`    | Nome do mercado                           | `VARCHAR`    | 30      | FK, Not Null           |
| `preco`           | Valor do equipamento                      | `INTEGER`    | -       | Not Null               |

## **Tabela: `Mercado e Motor`**
Armazena informações de quais motores o mercado vende.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `idSetor`      | Identificador único da instância          | `SERIAL`     | -       | PK, Not Null           |
| `nome_motor`   | Nome do motor                             | `VARCHAR`    | 30      | Not Null               |
| `nome_mercado` | Nome do mercado                           | `VARCHAR`    | 30      | Not Null               |
| `preco`        | Valor do equipamento                      | `INTEGER`    | -       | Not Null               |

## **Tabela: `Anuncia`**
Armazena informações de quais motores, equipamentos e naves o mercado vende para o piloto.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `naves`      | Identificador único da instância            | `VARCHAR`     | 30     | Not Null               |
| `motores`   | Nome do motor                                | `VARCHAR`    | 30      | Not Null               |
| `equipamentos` | Nome do mercado                           | `VARCHAR`    | 30      | Not Null               |

## **Tabela: `Vende`**
Armazena informações do preço do motor que está sendo vendido.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `preco_motor`  | Preço do motor                            | `VARCHAR`     | 30     | Not Null               |

## **Tabela: `Vende`**
Armazena informações do preço do equipamento que está sendo vendido.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `preco_equipamento`  | Preço do equipamento                | `VARCHAR`     | 30     | Not Null               |

## **Tabela: `Vende`**
Armazena informações do preço da nave que está sendo vendido.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `preco_nave`   | Preço da nave                             | `VARCHAR`     | 30     | Not Null               |

---

## **Tabela: `Setor`**
Armazena a informação do setor.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `idSetor`      | Identificador único da instância          | `SERIAL`     | -       | PK, Not Null           |
| `nome`         | Nome do setor                             | `VARCHAR`    | 30      | Not Null               |
| `tipo`         | Tipo de setor                             | `VARCHAR`    | 30      | Not Null               |

## **Tabela: `Conecta`**
Armazena informações de quais setores existem.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `Norte`        | Cardinalidade que o piloto pode ir        | `VARCHAR`     | 30     | Not Null               |
| `Sul`          | Cardinalidade que o piloto pode ir        | `VARCHAR`    | 30      | Not Null               |
| `Leste`        | Cardinalidade que o piloto pode ir        | `VARCHAR`    | 30      | Not Null               |
| `Oeste`        | Cardinalidade que o piloto pode ir        | `VARCHAR`    | 30      | Not Null               |
| `Portal`       | Portal que se abre, permitindo o piloto ir para outro lugar     | `VARCHAR`    | 30      | Not Null               |

## **Tabela: `Abriga`**
Armazena informação de qual setor o minério está.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `setor_atual`  | Setor que o minério se encontra           | `VARCHAR`     | 30     | Not Null               |

## **Tabela: `Abriga`**
Armazena informação de qual setor o piloto está.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `setor_atual`  | Setor que o minério se encontra           | `VARCHAR`     | 30     | Not Null               |

---

## **Tabela: `Usa`**
Armazena informação de qual nave o piloto está usando.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `nave_atual`   | Nave atual que o piloto está usando       | `VARCHAR`     | 30     | Not Null               |

## **Tabela: `Coleta`**
Armazena informação da coleta de minério na nave que o piloto está.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `nave_atual`   | Armazena o minério na nave atual          | `VARCHAR`    | 30     | Not Null               |

## **Tabela: `Possui`**
Armazena informação de qual motor o piloto está usando.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `nave_atual`   | Armazena o minério na nave atual          | `VARCHAR`    | 30     | Not Null               |

## **Tabela: `Possui`**
Armazena informação de qual equipamento o piloto está usando.
| Nome           | Descrição                                 | Tipo de dado | Tamanho | Restrições de domínio  |
|----------------|-------------------------------------------|--------------|---------|------------------------|
| `nave_atual`   | Armazena o minério na nave atual          | `VARCHAR`    | 30     | Not Null               |


