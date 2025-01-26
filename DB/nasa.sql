CREATE TABLE USUARIO (
  USU_COD INT AUTO_INCREMENT PRIMARY KEY,
  USU_USUARIO VARCHAR(50) NOT NULL,
  USU_SENHA_HASH VARCHAR(255) NOT NULL,
  USU_STATU ENUM('Ativo', 'Desativado', 'Pendente') NOT NULL DEFAULT 'Pendente',
  USU_NIVEL INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE FORNECEDOR (
  FOR_COD INT AUTO_INCREMENT PRIMARY KEY,
  FOR_CNPJ VARCHAR(14) NOT NULL UNIQUE,
  FOR_RAZAO_SOCIAL VARCHAR(140) NOT NULL,
  FOR_ENDERECO VARCHAR(150) NOT NULL,
  FOR_TELEFONE VARCHAR(11) NOT NULL,
  FOR_RESPONSAVEL VARCHAR(40) NOT NULL  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci; 

CREATE TABLE CLIENTE (
  CLI_COD INT AUTO_INCREMENT PRIMARY KEY,                  -- Código único do cliente
  CLI_CPF_CNPJ VARCHAR(14) NOT NULL UNIQUE,                -- CPF ou CNPJ (com 14 caracteres)
  CLI_NOME VARCHAR(100) NOT NULL,                          -- Nome completo
  CLI_NOME_FANTASIA VARCHAR(100),                          -- Nome fantasia (para pessoa jurídica)
  CLI_DATA_NASCIMENTO DATE,                                -- Data de nascimento (pessoa física)
  CLI_RG VARCHAR(20),                                      -- RG (pessoa física)
  CLI_EMAIL VARCHAR(150),                                  -- Email
  CLI_TELEFONE VARCHAR(15),                                -- Telefone
  CLI_ESTADO_CIVIL VARCHAR(20),                            -- Estado civil (para pessoa física)
  CLI_NACIONALIDADE VARCHAR(50),                           -- Nacionalidade (opcional)
  -- Dados de endereço
  CLI_ENDERECO VARCHAR(255),                               -- Endereço
  CLI_BAIRRO VARCHAR(100),                                 -- Bairro
  CLI_CIDADE VARCHAR(100),                                 -- Cidade
  CLI_ESTADO VARCHAR(50),                                  -- Estado
  CLI_CEP VARCHAR(10),                                     -- CEP
  -- Dados fiscais
  CLI_INSCRICAO_ESTADUAL VARCHAR(20),                      -- Inscrição estadual (para pessoa jurídica)
  CLI_INSCRICAO_MUNICIPAL VARCHAR(20),                     -- Inscrição municipal (para pessoa jurídica)
  -- Dados bancários
  CLI_BANCO VARCHAR(50),                                   -- Banco
  CLI_AGENCIA VARCHAR(20),                                 -- Agência bancária
  CLI_CONTA_BANCARIA VARCHAR(30),                          -- Número da conta bancária
  -- Dados adicionais
  CLI_CNAE VARCHAR(50),                                    -- Atividade econômica (CNAE, para pessoa jurídica)
  CLI_RESPONSAVEL_LEGAL VARCHAR(100),                       -- Responsável legal pela empresa (se aplicável)
  CLI_TERMO_ACEITO BOOLEAN DEFAULT FALSE,                   -- Termo de consentimento aceito (booleano)
  CLI_DATA_CRIACAO TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- Data de criação do cadastro
  CLI_ATIVO BOOLEAN DEFAULT TRUE                           -- Flag para status ativo/inativo
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE PEDIDO (
  PED_COD INT AUTO_INCREMENT PRIMARY KEY,
  PED_CLI_COD INT NOT NULL,
  PED_FOR_COD INT NOT NULL,
  PED_NUMERO_CHAMADO VARCHAR(7) UNIQUE,
  PED_PRODUTO VARCHAR(100),
  PED_QUANTIDADE INT,
  PED_PEDIDO_DATA DATE,
  PED_VALOR DECIMAL(15, 2),
  PED_STATUS_PEDIDO ENUM('Resolvido', 'Pendente', 'Pendente') NOT NULL DEFAULT 'Pendente',
  FOREIGN KEY (PED_CLI_COD) REFERENCES CLIENTE(CLI_COD),
  FOREIGN KEY (PED_FOR_COD) REFERENCES FORNECEDOR(FOR_COD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE ORCAMENTO (
  ORC_COD INT AUTO_INCREMENT PRIMARY KEY,
  ORC_PED_COD INT NOT NULL,
  ORC_FOR_COD INT NOT NULL,
  ORC_CLI_COD INT NOT NULL,
  ORC_NOME_ARQUIVO VARCHAR(255),
  ORC_HORCAMENTO_PDF VARCHAR(255),
  ORC_STATUS_GESTAO ENUM('Aprovado', 'Reprovado', 'Pendente') NOT NULL DEFAULT 'Pendente',
  FOREIGN KEY (ORC_PED_COD) REFERENCES PEDIDO(PED_COD),
  FOREIGN KEY (ORC_FOR_COD) REFERENCES FORNECEDOR(FOR_COD),
  FOREIGN KEY (ORC_CLI_COD) REFERENCES CLIENTE(CLI_COD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE VENDA (
  VEN_COD INT AUTO_INCREMENT PRIMARY KEY,
  VEN_DATA DATE NOT NULL,
  VEN_USU_COD INT NOT NULL, -- Referência ao usuário que fez a venda
  VEN_CLI_COD INT NOT NULL, -- Referência ao cliente
  VEN_TOTAL DECIMAL(15, 2) NOT NULL, -- Total da venda
  VEN_STATUS ENUM('Pendente', 'Concluída', 'Cancelada') NOT NULL DEFAULT 'Pendente',
  FOREIGN KEY (VEN_USU_COD) REFERENCES USUARIO(USU_COD),
  FOREIGN KEY (VEN_CLI_COD) REFERENCES CLIENTE(CLI_COD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE ITENS_VENDA (
  ITV_COD INT AUTO_INCREMENT PRIMARY KEY,
  ITV_VEN_COD INT NOT NULL, -- Referência à venda
  ITV_PRODUTO VARCHAR(100) NOT NULL, -- Nome do produto
  ITV_QUANTIDADE INT NOT NULL, -- Quantidade vendida
  ITV_VALOR_UNITARIO DECIMAL(15, 2) NOT NULL, -- Valor unitário do produto
  ITV_VALOR_TOTAL DECIMAL(15, 2) NOT NULL, -- Valor total do item (quantidade * valor_unitario)
  FOREIGN KEY (ITV_VEN_COD) REFERENCES VENDA(VEN_COD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE ESTOQUE (
  ESTOQUE_COD INT AUTO_INCREMENT PRIMARY KEY,
  ESTOQUE_PRODUTO VARCHAR(100) NOT NULL,
  ESTOQUE_QUANTIDADE INT NOT NULL, -- Quantidade disponível
  ESTOQUE_VALOR_UNITARIO DECIMAL(15, 2) NOT NULL, -- Valor unitário do produto
  ESTOQUE_VALOR_TOTAL DECIMAL(15, 2) NOT NULL, -- Valor total do estoque (quantidade * valor_unitario)
  ESTOQUE_DATA_ULTIMA_ATUALIZACAO TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE LOG (
  LOG_COD INT AUTO_INCREMENT PRIMARY KEY,
  LOG_USU_COD INT NOT NULL, -- Referência ao usuário que fez a ação
  LOG_DATA TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Data da ação
  LOG_ACAO VARCHAR(100) NOT NULL, -- Ação realizada
  FOREIGN KEY (LOG_USU_COD) REFERENCES USUARIO(USU_COD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Despejando dados para a tabela = USUARIO

INSERT INTO USUARIO (USU_USUARIO, USU_SENHA_HASH, USU_STATU) VALUES
('kassio', '310ea5e7934323b2cf1ef31fca2aa2b1', 1);

INSERT INTO FORNECEDOR (FOR_CNPJ, FOR_RAZAO_SOCIAL, FOR_ENDERECO, FOR_TELEFONE, FOR_RESPONSAVEL) VALUES
('24111769000145', 'IMAX TECNOLOGIA LTDA', 'RUA 250, QD 34 LT 07 SETOR COIMBRA', '62993093392', 'RICARDO'); 

INSERT INTO CLIENTE (CLI_CPF_CNPJ, CLI_NOME, CLI_TELEFONE) VALUES
('33636838000397', 'GRUPO NASA GOIANIA', '6232408085');