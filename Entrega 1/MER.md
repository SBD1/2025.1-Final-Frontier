
**Hangar abriga Nave**  
- Um Hangar abriga uma ou mais Naves (1,n)  
- Uma Nave é abrigada por um único Hangar (1,1)

**Nave possui Motor**  
- Uma Nave possui exatamente um Motor (1,1)  
- Um Motor pode ser usado por uma ou mais Naves (1,n)

**Nave possui Equipamento**  
- Uma Nave possui um ou mais Equipamentos (1,n)  
- Um Equipamento pode estar em várias Naves (1,n)

**Nave coleta Minério**  
- Uma Nave coleta um ou mais Minérios (1,n)  
- Um Minério é coletado por uma única Nave (1,1)

**Piloto usa Nave**  
- Um Piloto usa uma única Nave (1,1)  
- Uma Nave é usada por no máximo um Piloto (0,1)

**Setor abriga Piloto**  
- Um Setor abriga um ou mais Pilotos (1,n)  
- Um Piloto está em apenas um Setor (1,1)

**Setor abriga Minério**  
- Um Setor abriga um ou mais Minérios (1,n)  
- Um Minério está em apenas um Setor (1,1)

**Setor conecta com outros Setores**  
- Um Setor se conecta com outro Setor em direções: norte, sul, leste, oeste, portal


## Versionamento

| Data       | Versão | Autor       | Alterações                        |
|------------|--------|-------------|-----------------------------------|
| 01/05/2025 | 1.0    | [Matheus Barros](https://github.com/Ninja-Haiyai) | Criação do documento MER e adição da primeira versão|
