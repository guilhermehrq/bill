CREATE DATABASE bill TEMPLATE template0 ENCODING utf8;

-- -----------------------------------------------------
-- Table users
-- -----------------------------------------------------
DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users (
  id            SERIAL       NOT NULL,
  email         VARCHAR(255) NOT NULL,
  password      VARCHAR(255) NOT NULL,
  name          VARCHAR(100) NOT NULL,
  register_date DATE         NOT NULL,
  block_date    DATE         NOT NULL,
  url_img       VARCHAR(255)     NULL,
  CONSTRAINT 
    pk_users_id PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table account_types
-- -----------------------------------------------------
DROP TABLE IF EXISTS account_types;

CREATE TABLE IF NOT EXISTS account_types (
  id     SERIAL       NOT NULL,
  title  VARCHAR(255) NOT NULL,
  icon   VARCHAR(45)  NOT NULL,
  active BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_account_types_id 
    PRIMARY KEY (id)
);

INSERT INTO account_types(title, icon) 
  VALUES ('Conta Corrente', 'account_balance'),
         ('Dinheiro', 'local_atm'),
         ('Poupança', 'account_balance_wallet'),
         ('Investimentos', 'trending_up')
         ('Outros', 'fiber_manual_record');

-- -----------------------------------------------------
-- Table accounts
-- -----------------------------------------------------
DROP TABLE IF EXISTS accounts;

CREATE TABLE IF NOT EXISTS accounts (
  id                SERIAL        NOT NULL,
  user_id           INT           NOT NULL,
  title             VARCHAR(45)   NOT NULL,
  initial_balance   DECIMAL(15,2) NOT NULL,
  actual_balance    DECIMAL(15,2) NOT NULL,
  type              INT           NOT NULL,
  color             VARCHAR(45)   NOT NULL,
  include_dashboard BOOLEAN       NOT NULL DEFAULT TRUE,
  main_account      BOOLEAN       NOT NULL DEFAULT FALSE,
  register_date     DATE          NOT NULL DEFAULT now(),
  active            BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_accounts_id 
    PRIMARY KEY (id, user_id),
  CONSTRAINT fk_accounts_user
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_accounts_account_types
    FOREIGN KEY (type) REFERENCES account_types (id)
);

-- -----------------------------------------------------
-- Table categories
-- -----------------------------------------------------
DROP TABLE IF EXISTS categories;

CREATE TABLE IF NOT EXISTS categories (
  id      SERIAL       NOT NULL,
  user_id INT          NOT NULL,
  title   VARCHAR(255) NOT NULL,
  type    CHAR         NOT NULL COMMENT 'E - Expenses / I - Income / T - Transfers',
  color   VARCHAR(45)  NOT NULL,
  icon    VARCHAR(45)  NOT NULL,
  active  BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_categories_id 
    PRIMARY KEY (id, user_id),
  CONSTRAINT fk_categories_user
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- ESSES SERÃO INSERIDOS PARA CADA USER CADASTRADO

-- Categorias padrão para entradas
INSERT INTO categories (user_id, title, type, color, icon)
  VALUES ('?', 'Salário', 'I', '#1E88E5', 'local_atm'),
         ('?', 'Investimentos', 'I', '#43A047', 'trending_up'),
         ('?', 'Presente', 'I', '#6D4C41', 'card_giftcard'),
         ('?', 'Prêmios', 'I', '#3949AB', 'emoji_events'),
         ('?', 'Outros', 'I', '#546E7A', 'more_horiz');

-- Categorias padrão para saídas
INSERT INTO categories (user_id, title, type, color, icon)
  VALUES ('?', 'Educação', 'E', '#546E7A', 'menu_book'),
         ('?', 'Contas', 'E', '#E53935', 'attach_money'),
         ('?', 'Comida e bebida', 'E', '#1E88E5', 'restaurant'),
         ('?', 'Casa', 'E', '#5E35B1', 'home'),
         ('?', 'Transporte', 'E', '#00897B', 'directions_car'),
         ('?', 'Compras', 'E', '#D81B60', 'local_mall');

-- Categorias padrão para transferências (user_id zero pois vai ser uma categoria default que nehum user vai utilizar)
INSERT INTO categories (user_id, title, type, color, icon)
  VALUES (0, 'Transferência Entrada', 'T', '#43A047', 'swap_vert'),
         (0, 'Transferência Saída', 'T', '#E53935', 'swap_vert');

-- -----------------------------------------------------
-- Table transactions
-- -----------------------------------------------------
DROP TABLE IF EXISTS transactions;

CREATE TABLE IF NOT EXISTS transactions (
  id              SERIAL        NOT NULL,
  account_id      INT           NOT NULL,
  category_id     INT           NOT NULL,
  value           DECIMAL(15,2) NOT NULL DEFAULT 0,
  date            DATE          NOT NULL DEFAULT now(),
  description     VARCHAR(255)  NOT NULL,
  active          BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_transactions_id 
    PRIMARY KEY (id, account_id, category_id),
  CONSTRAINT fk_transactions_accounts
    FOREIGN KEY (account_id) REFERENCES accounts (id),
  CONSTRAINT fk_transactions_categories
    FOREIGN KEY (category_id) REFERENCES categories (id)
);

-- -----------------------------------------------------
-- Table goals
-- -----------------------------------------------------
DROP TABLE IF EXISTS goals;

CREATE TABLE IF NOT EXISTS goals (
  id            SERIAL        NOT NULL,
  user_id       INT           NOT NULL,
  title         VARCHAR(255)  NOT NULL,
  goal_value    DECIMAL(15,2) NOT NULL,
  initial_value DECIMAL(15,2) NOT NULL DEFAULT 0,
  deadline      DATE          NOT NULL,
  color         VARCHAR(45)   NOT NULL,
  icon          VARCHAR(45)   NOT NULL,
  description   VARCHAR(255)      NULL,
  status        CHAR          NOT NULL DEFAULT 'A' COMMENT 'A - ACTIVE / D - DEACTIVE / F - FINISHED',
  CONSTRAINT pk_goals_id 
    PRIMARY KEY (id, user_id),
  CONSTRAINT fk_goals_users
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- -----------------------------------------------------
-- Table goals_transactions
-- -----------------------------------------------------
DROP TABLE IF EXISTS goals_transactions;

CREATE TABLE IF NOT EXISTS goals_transactions (
  id               SERIAL        NOT NULL,
  goal_id          INT           NOT NULL,
  value            DECIMAL(15,2) NOT NULL,
  transaction_date DATE          NOT NULL DEFAULT now(),
  CONSTRAINT pk_goals_transactions_id 
    PRIMARY KEY (id, goal_id),
  CONSTRAINT fk_goals_transactions_goal
    FOREIGN KEY (goal_id) REFERENCES goals (id)
);

-- -----------------------------------------------------
-- Table repetition_types
-- -----------------------------------------------------
DROP TABLE IF EXISTS repetition_types;

CREATE TABLE IF NOT EXISTS repetition_types (
  id     SERIAL      NOT NULL,
  title  VARCHAR(45) NOT NULL,
  active BOOLEAN     NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_repetition_types_id 
    PRIMARY KEY (id)
);

INSERT INTO repetition_types (title)
  VALUES ('Não se repete'),
         ('Todo dia'),
         ('Toda semana'),
         ('Todo mês'),
         ('Todo ano');

-- -----------------------------------------------------
-- Table schedules
-- -----------------------------------------------------
DROP TABLE IF EXISTS schedules;

CREATE TABLE IF NOT EXISTS schedules (
  id              SERIAL        NOT NULL,
  user_id         INT           NOT NULL,
  title           VARCHAR(255)  NOT NULL,
  type            CHAR          NOT NULL DEFAULT 'P' COMMENT 'P - Pay / R - Receive',
  value           DECIMAL(15,2) NOT NULL,
  repetition_type INT           NOT NULL,
  initial_date    DATE          NOT NULL,
  active          BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_schedules_id PRIMARY KEY (id, user_id),
  CONSTRAINT fk_schedules_users
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_schedules_repetition_types
    FOREIGN KEY (repetition_type) REFERENCES repetition_types (id)
);


-- -----------------------------------------------------
-- Table schedule_repetitions
-- -----------------------------------------------------
DROP TABLE IF EXISTS schedule_repetitions;

CREATE TABLE IF NOT EXISTS schedule_repetitions (
  id            SERIAL        NOT NULL,
  schedule_id   INT           NOT NULL,
  schedule_date DATE          NOT NULL,
  value         DECIMAL(15,2) NOT NULL,
  status        BOOLEAN       NOT NULL DEFAULT FALSE COMMENT 'Indicates if the schedule were already finished',
  active        BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_schedule_repetitions_id 
    PRIMARY KEY (id, schedule_id),
  CONSTRAINT fk_schedule_repetitions_schedules
    FOREIGN KEY (schedule_id) REFERENCES schedules (id)
);


-- -----------------------------------------------------
-- Table articles
-- -----------------------------------------------------
DROP TABLE IF EXISTS articles;

CREATE TABLE IF NOT EXISTS articles (
	id          SERIAL       NOT NULL,
	title       VARCHAR(100) NOT NULL,
	description VARCHAR(255) NOT NULL,
	url         VARCHAR(255) NOT NULL,
	img         VARCHAR(255) NOT NULL,
	date        DATE         NOT NULL DEFAULT now(),
	partner     VARCHAR(100) NOT NULL,
	CONSTRAINT 
		pk_articles_id PRIMARY KEY(id)
);
