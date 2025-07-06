--Tabela: Piloto
CREATE TABLE Piloto (
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL,
    senha TEXT NOT NULL,
    setor INTEGER,
    dinheiro NUMERIC DEFAULT 1000  -- saldo inicial 1000 créditos
);


-- Tabela: Setor
CREATE TABLE Setor (
    id SERIAL PRIMARY KEY,
    nome TEXT,
    tipo TEXT,
    descricao TEXT,
    id_norte INTEGER,
    id_sul INTEGER,
    id_leste INTEGER,
    id_oeste INTEGER,
    id_portal INTEGER
);

-- Tabela: Mercado
CREATE TABLE Mercado (
    nome TEXT PRIMARY KEY,
    capacidade INTEGER,
    descricao TEXT,
    id_setor INTEGER REFERENCES Setor(id)
);

-- Tabela: Hangar
CREATE TABLE Hangar (
    nome TEXT PRIMARY KEY,
    capacidade INTEGER,
    id_setor INTEGER REFERENCES Setor(id)
);

-- Tabela: Minerio
CREATE TABLE Minerio (
    id SERIAL PRIMARY KEY,
    nome TEXT,
    peso NUMERIC,
    valor NUMERIC,
    descricao TEXT
);

-- Tabela: minerio_setor
CREATE TABLE minerio_setor (
    UniqueId SERIAL PRIMARY KEY,
    id_minerio INTEGER REFERENCES Minerio(id),
    id_setor INTEGER REFERENCES Setor(id),
    quantidade INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT uq_minerio_setor UNIQUE (id_minerio, id_setor) 
);

-- Tabela: minerio_nave
CREATE TABLE minerio_nave (
    id SERIAL PRIMARY KEY,
    id_minerio INTEGER REFERENCES Minerio(id),
    id_nave INTEGER REFERENCES Nave(id)
);

-- Tabela: Nave
CREATE TABLE Nave (
    id SERIAL PRIMARY KEY,
    nome TEXT,
    descricao TEXT,
    tipo TEXT,
    limite NUMERIC, -- limite máximo de carga
    carga NUMERIC -- carga atual
);

-- Tabela: nave_piloto
CREATE TABLE nave_piloto (
    id SERIAL PRIMARY KEY,
    id_piloto INTEGER REFERENCES Piloto(id),
    id_nave INTEGER REFERENCES Nave(id)
);

-- Tabela: naves_hangar
CREATE TABLE naves_hangar (
    id SERIAL PRIMARY KEY,
    nome_hangar TEXT REFERENCES Hangar(nome),
    id_nave INTEGER REFERENCES Nave(id)
);

-- Tabela: Equipamento
CREATE TABLE Equipamento (
    nome TEXT PRIMARY KEY,
    consumo NUMERIC,
    ataque NUMERIC,
    defesa NUMERIC,
    extracao NUMERIC,
    reparo NUMERIC,
    habilidades TEXT,
    descricao TEXT
);

-- Tabela: Motor
CREATE TABLE Motor (
    nome TEXT PRIMARY KEY,
    potencia NUMERIC,
    energia NUMERIC,
    velocidade NUMERIC,
    descricao TEXT
);

-- Tabela: nave_equipamento
CREATE TABLE nave_equipamento (
    UniqueId SERIAL PRIMARY KEY,
    nome_equipamento TEXT REFERENCES Equipamento(nome),
    id_nave INTEGER REFERENCES Nave(id),
    nave_atual BOOLEAN
);

-- Tabela: nave_motor
CREATE TABLE nave_motor (
    UniqueId SERIAL PRIMARY KEY,
    nome_motor TEXT REFERENCES Motor(nome),
    id_nave INTEGER REFERENCES Nave(id),
    nave_atual BOOLEAN
);

-- Tabela: mercado_nave
CREATE TABLE mercado_nave (
    id SERIAL PRIMARY KEY,
    id_nave INTEGER REFERENCES Nave(id),
    nome_mercado TEXT REFERENCES Mercado(nome),
    nome_nave TEXT,
    descricao_nave TEXT,
    preco NUMERIC
);

-- Tabela: mercado_equipamento
CREATE TABLE mercado_equipamento (
    id SERIAL PRIMARY KEY,
    nome_equipamento TEXT REFERENCES Equipamento(nome),
    nome_mercado TEXT REFERENCES Mercado(nome),
    descricao_equipamento TEXT,
    preco NUMERIC
);

-- Tabela: mercado_motor
CREATE TABLE mercado_motor (
    id SERIAL PRIMARY KEY,
    nome_motor TEXT REFERENCES Motor(nome),
    nome_mercado TEXT REFERENCES Mercado(nome),
    descricao_motor TEXT,
    preco NUMERIC
);

-- Tabela: Mundo
CREATE TABLE Mundo (
    id SERIAL PRIMARY KEY,
    id_piloto INTEGER REFERENCES Piloto(id),
    nome_mercado TEXT REFERENCES Mercado(nome),
    id_nave INTEGER REFERENCES Nave(id),
    nome_equipamento TEXT REFERENCES Equipamento(nome),
    nome_motor TEXT REFERENCES Motor(nome),
    descricao TEXT
);
