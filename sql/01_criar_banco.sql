-- sql/01_criar_banco.sql
-- Criação das 4 Dimensões
CREATE TABLE dim_orgao (
    sk_orgao INT PRIMARY KEY,
    cnpj_orgao VARCHAR(50),
    nome_orgao TEXT,
    poder VARCHAR(50)
);

CREATE TABLE dim_fornecedor (
    sk_fornecedor INT PRIMARY KEY,
    ni_fornecedor VARCHAR(50),
    nome_fornecedor TEXT,
    tipo_pessoa VARCHAR(10),
    porte VARCHAR(50)
);

CREATE TABLE dim_modalidade (
    sk_modalidade INT PRIMARY KEY,
    modalidade_id INT,
    nome_modalidade VARCHAR(100)
);

CREATE TABLE dim_localidade (
    sk_localidade INT PRIMARY KEY,
    uf_sigla VARCHAR(5),
    uf_nome VARCHAR(50),
    regiao VARCHAR(50)
);

-- Criação da Tabela Fato
CREATE TABLE fato_item_contratado (
    numero_controle_pncp VARCHAR(50),
    numero_item INT,
    sk_orgao INT REFERENCES dim_orgao(sk_orgao),
    sk_fornecedor INT REFERENCES dim_fornecedor(sk_fornecedor),
    sk_modalidade INT REFERENCES dim_modalidade(sk_modalidade),
    sk_localidade INT REFERENCES dim_localidade(sk_localidade),
    data_publicacao DATE,
    data_homologacao DATE,
    descricao_item TEXT,
    perfil_gasto VARCHAR(50),
    quantidade NUMERIC,
    valor_unitario_estimado NUMERIC,
    valor_total_estimado NUMERIC,
    valor_unitario_homologado NUMERIC,
    valor_total_homologado NUMERIC,
    comparavel INT,
    economia_valor NUMERIC,
    dias_ciclo INT,
    PRIMARY KEY (numero_controle_pncp, numero_item)
);