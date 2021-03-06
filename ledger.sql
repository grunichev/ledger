--
-- File generated with SQLiteStudio v3.2.1 on Tue Jan 28 22:42:15 2020
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: account_types
DROP TABLE IF EXISTS account_types;

CREATE TABLE account_types (
    id   INTEGER   PRIMARY KEY
                   UNIQUE
                   NOT NULL,
    name TEXT (32) NOT NULL
);


-- Table: accounts
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    id              INTEGER   PRIMARY KEY
                              UNIQUE
                              NOT NULL,
    type_id         INTEGER   REFERENCES account_types (id) ON DELETE RESTRICT
                                                            ON UPDATE CASCADE
                              NOT NULL,
    name            TEXT (64) NOT NULL
                              UNIQUE,
    currency_id     INTEGER   REFERENCES assets (id) ON DELETE RESTRICT
                                                      ON UPDATE CASCADE
                              NOT NULL,
    active          INTEGER,
    number          TEXT (32),
    reconciled_on   INTEGER   DEFAULT (0),
    organization_id INTEGER   REFERENCES agents (id) ON DELETE SET NULL
                                                     ON UPDATE CASCADE
);


-- Table: action_details
DROP TABLE IF EXISTS action_details;

CREATE TABLE action_details (
    id          INTEGER    PRIMARY KEY
                           NOT NULL
                           UNIQUE,
    pid         INTEGER    REFERENCES actions (id) ON DELETE CASCADE
                                                   ON UPDATE CASCADE
                           NOT NULL,
    category_id INTEGER    REFERENCES categories (id) ON DELETE SET DEFAULT
                                                      ON UPDATE CASCADE
                           NOT NULL
                           DEFAULT (0),
    tag_id      INTEGER    REFERENCES tags (id) ON DELETE SET NULL
                                                ON UPDATE CASCADE,
    sum         REAL       NOT NULL,
    alt_sum     REAL       DEFAULT (0),
    note        TEXT (256) 
);


-- Table: actions
DROP TABLE IF EXISTS actions;

CREATE TABLE actions (
    id              INTEGER PRIMARY KEY
                            UNIQUE
                            NOT NULL,
    timestamp       INTEGER NOT NULL,
    account_id      INTEGER REFERENCES accounts (id) ON DELETE CASCADE
                                                     ON UPDATE CASCADE
                            NOT NULL,
    peer_id         INTEGER REFERENCES agents (id) ON DELETE RESTRICT
                                                   ON UPDATE CASCADE
                            NOT NULL,
    alt_currency_id INTEGER REFERENCES assets (id) ON DELETE RESTRICT
                                                    ON UPDATE CASCADE
);


-- Table: asset_types
DROP TABLE IF EXISTS asset_types;

CREATE TABLE asset_types (
    id   INTEGER   PRIMARY KEY
                   UNIQUE
                   NOT NULL,
    name TEXT (32) NOT NULL
);


-- Table: assets
DROP TABLE IF EXISTS assets;

CREATE TABLE assets (
    id        INTEGER    PRIMARY KEY
                         UNIQUE
                         NOT NULL,
    name      TEXT (32)  UNIQUE
                         NOT NULL,
    type_id   INTEGER    REFERENCES asset_types (id) ON DELETE RESTRICT
                                                      ON UPDATE CASCADE
                         NOT NULL,
    full_name TEXT (128) NOT NULL,
    isin      TEXT (12),
    web_id    TEXT (32),
    src_id    INTEGER    REFERENCES data_sources (id) ON DELETE SET NULL
                                                      ON UPDATE CASCADE
                         NOT NULL
                         DEFAULT ( -1)
);


-- Table: agents
DROP TABLE IF EXISTS agents;

CREATE TABLE agents (
    id       INTEGER    PRIMARY KEY
                        UNIQUE
                        NOT NULL,
    pid      INTEGER    NOT NULL
                        DEFAULT (0),
    name     TEXT (64)  UNIQUE
                        NOT NULL,
    location TEXT (128) 
);


-- Table: balances
DROP TABLE IF EXISTS balances;

CREATE TABLE balances (
    level1            INTEGER,
    level2            INTEGER,
    account_name      TEXT    NOT NULL,
    balance           REAL,
    currency_name     TEXT,
    balance_adj       REAL,
    days_unreconciled INTEGER,
    active            INTEGER
);


-- Table: balances_aux
DROP TABLE IF EXISTS balances_aux;

CREATE TABLE balances_aux (
    account_type      INTEGER NOT NULL,
    account           INTEGER NOT NULL,
    currency          INTEGER NOT NULL,
    balance           REAL,
    balance_adj       REAL,
    unreconciled_days INTEGER,
    active            INTEGER
);


-- Table: books
DROP TABLE IF EXISTS books;

CREATE TABLE books (
    id   INTEGER   PRIMARY KEY
                   NOT NULL
                   UNIQUE,
    name TEXT (32) NOT NULL
);


-- Table: categories
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    id      INTEGER   PRIMARY KEY
                      UNIQUE
                      NOT NULL,
    pid     INTEGER   NOT NULL
                      DEFAULT (0),
    name    TEXT (64) UNIQUE
                      NOT NULL,
    often   INTEGER,
    special INTEGER
);


-- Table: data_sources
DROP TABLE IF EXISTS data_sources;

CREATE TABLE data_sources (
    id   INTEGER   PRIMARY KEY
                   UNIQUE
                   NOT NULL,
    name TEXT (32) NOT NULL
);


-- Table: dividends
DROP TABLE IF EXISTS dividends;

CREATE TABLE dividends (
    id         INTEGER     PRIMARY KEY
                           UNIQUE
                           NOT NULL,
    timestamp  INTEGER     NOT NULL,
    number     TEXT (32)   DEFAULT (''),
    account_id INTEGER     REFERENCES accounts (id) ON DELETE CASCADE
                                                    ON UPDATE CASCADE
                           NOT NULL,
    asset_id   INTEGER     REFERENCES assets (id) ON DELETE RESTRICT
                                                    ON UPDATE CASCADE
                           NOT NULL,
    sum        REAL        NOT NULL
                           DEFAULT (0),
    sum_tax    REAL        DEFAULT (0),
    note       TEXT (1014),
    note_tax   TEXT (64) 
);


-- Table: holdings
DROP TABLE IF EXISTS holdings;

CREATE TABLE holdings (
    level1     INTEGER,
    level2     INTEGER,
    currency   TEXT,
    account    TEXT,
    asset      TEXT,
    asset_name TEXT,
    qty        REAL,
    open       REAL,
    quote      REAL,
    share      REAL,
    profit_rel REAL,
    profit     REAL,
    value      REAL,
    value_adj  REAL
);


-- Table: holdings_aux
DROP TABLE IF EXISTS holdings_aux;

CREATE TABLE holdings_aux (
    currency  INTEGER,
    account   INTEGER,
    asset     INTEGER,
    qty       REAL,
    value     REAL,
    quote     REAL,
    quote_adj REAL,
    total     REAL,
    total_adj REAL
);


-- Table: languages
DROP TABLE IF EXISTS languages;

CREATE TABLE languages (
    id       INTEGER  PRIMARY KEY AUTOINCREMENT
                      UNIQUE
                      NOT NULL,
    language CHAR (2) UNIQUE
                      NOT NULL
);

-- Table: ledger
DROP TABLE IF EXISTS ledger;

CREATE TABLE ledger (
    id           INTEGER PRIMARY KEY
                         NOT NULL
                         UNIQUE,
    timestamp    INTEGER NOT NULL,
    sid          INTEGER NOT NULL,
    book_account INTEGER NOT NULL
                         REFERENCES books (id) ON DELETE NO ACTION
                                               ON UPDATE NO ACTION,
    asset_id    INTEGER REFERENCES assets (id) ON DELETE SET NULL
                                               ON UPDATE SET NULL,
    account_id   INTEGER NOT NULL
                         REFERENCES accounts (id) ON DELETE NO ACTION
                                                  ON UPDATE NO ACTION,
    amount       REAL,
    value        REAL,
    peer_id      INTEGER REFERENCES agents (id) ON DELETE NO ACTION
                                                ON UPDATE NO ACTION,
    category_id  INTEGER REFERENCES categories (id) ON DELETE NO ACTION
                                                    ON UPDATE NO ACTION,
    tag_id       INTEGER REFERENCES tags (id) ON DELETE NO ACTION
                                              ON UPDATE NO ACTION
);


-- Table: ledger_sums
DROP TABLE IF EXISTS ledger_sums;

CREATE TABLE ledger_sums (
    sid          INTEGER NOT NULL,
    timestamp    INTEGER NOT NULL,
    book_account INTEGER NOT NULL
                         REFERENCES books (id) ON DELETE NO ACTION
                                               ON UPDATE NO ACTION,
    asset_id    INTEGER REFERENCES assets (id) ON DELETE SET NULL
                                               ON UPDATE SET NULL,
    account_id   INTEGER NOT NULL
                         REFERENCES accounts (id) ON DELETE NO ACTION
                                                  ON UPDATE NO ACTION,
    sum_amount   REAL,
    sum_value    REAL
);


-- Table: map_category
DROP TABLE IF EXISTS map_category;

CREATE TABLE map_category (
    id        INTEGER        PRIMARY KEY
                             UNIQUE
                             NOT NULL,
    value     VARCHAR (1024) NOT NULL,
    mapped_to INTEGER        NOT NULL
                             REFERENCES categories (id) ON DELETE SET DEFAULT
                                                        ON UPDATE CASCADE
                             DEFAULT (0)
);


-- Table: map_peer
DROP TABLE IF EXISTS map_peer;

CREATE TABLE map_peer (
    id        INTEGER        PRIMARY KEY
                             UNIQUE
                             NOT NULL,
    value     VARCHAR (1024) NOT NULL,
    mapped_to INTEGER        REFERENCES agents (id) ON DELETE SET DEFAULT
                                                    ON UPDATE CASCADE
                             NOT NULL
                             DEFAULT (0)
);


-- Table: quotes
DROP TABLE IF EXISTS quotes;

CREATE TABLE quotes (
    id        INTEGER PRIMARY KEY
                      UNIQUE
                      NOT NULL,
    timestamp INTEGER NOT NULL,
    asset_id INTEGER REFERENCES assets (id) ON DELETE CASCADE
                                              ON UPDATE CASCADE
                      NOT NULL,
    quote     REAL
);


-- Table: sequence
DROP TABLE IF EXISTS sequence;

CREATE TABLE sequence (
    id           INTEGER PRIMARY KEY
                         NOT NULL
                         UNIQUE,
    timestamp    INTEGER NOT NULL,
    type         INTEGER NOT NULL,
    operation_id INTEGER NOT NULL
);


-- Table: settings
DROP TABLE IF EXISTS settings;

CREATE TABLE settings (
    id    INTEGER   PRIMARY KEY
                    NOT NULL
                    UNIQUE,
    name  TEXT (32) NOT NULL
                    UNIQUE,
    value INTEGER
);


-- Table: t_last_assets
DROP TABLE IF EXISTS t_last_assets;

CREATE TABLE t_last_assets (
    id          INTEGER   PRIMARY KEY
                          UNIQUE
                          NOT NULL,
    name        TEXT (64) UNIQUE
                          NOT NULL,
    total_value REAL
);


-- Table: t_last_dates
DROP TABLE IF EXISTS t_last_dates;

CREATE TABLE t_last_dates (
    ref_id INTEGER NOT NULL,
    timestamp  INTEGER NOT NULL
);


-- Table: t_last_quotes
DROP TABLE IF EXISTS t_last_quotes;

CREATE TABLE t_last_quotes (
    timestamp INTEGER NOT NULL,
    asset_id INTEGER NOT NULL,
    quote     REAL
);


-- Table: t_months
DROP TABLE IF EXISTS t_months;

CREATE TABLE t_months (
    month          INTEGER,
    asset_id       INTEGER,
    last_timestamp INTEGER
);


-- Table: t_pivot
DROP TABLE IF EXISTS t_pivot;

CREATE TABLE t_pivot (
    row_key INTEGER NOT NULL,
    col_key INTEGER NOT NULL,
    value   REAL
);


-- Table: tags
DROP TABLE IF EXISTS tags;

CREATE TABLE tags (
    id  INTEGER   PRIMARY KEY
                  UNIQUE
                  NOT NULL,
    tag TEXT (64) NOT NULL
);


-- Table: corp_actions
DROP TABLE IF EXISTS corp_actions;

CREATE TABLE corp_actions (
    id   INTEGER     PRIMARY KEY
                     UNIQUE
                     NOT NULL,
    type INTEGER,
    note TEXT (1024)
);


-- Table: trades
DROP TABLE IF EXISTS trades;

CREATE TABLE trades (
    id           INTEGER   PRIMARY KEY
                           UNIQUE
                           NOT NULL,
    timestamp    INTEGER   NOT NULL,
    settlement   INTEGER   DEFAULT (0),
    corp_action_id INTEGER   DEFAULT (0),
    number       TEXT (32) DEFAULT (''),
    account_id   INTEGER   REFERENCES accounts (id) ON DELETE CASCADE
                                                    ON UPDATE CASCADE
                           NOT NULL,
    asset_id     INTEGER   REFERENCES assets (id) ON DELETE RESTRICT
                                                  ON UPDATE CASCADE
                           NOT NULL,
    qty          REAL      NOT NULL
                           DEFAULT (0),
    price        REAL      NOT NULL
                           DEFAULT (0),
    coupon       REAL      DEFAULT (0),
    fee          REAL      DEFAULT (0)
);


-- Table: deals
DROP TABLE IF EXISTS deals;

CREATE TABLE deals (
    id             INTEGER PRIMARY KEY
                           UNIQUE
                           NOT NULL,
    account_id     INTEGER NOT NULL,
    asset_id       INTEGER NOT NULL,
    open_sid  INTEGER NOT NULL,
    close_sid INTEGER NOT NULL,
    qty            REAL    NOT NULL
);


-- Table: transfer_notes
DROP TABLE IF EXISTS transfer_notes;

CREATE TABLE transfer_notes (
    id   INTEGER     PRIMARY KEY
                     UNIQUE
                     NOT NULL,
    tid  INTEGER     NOT NULL
                     UNIQUE,
    note TEXT (1024) NOT NULL
);


-- Table: transfers
DROP TABLE IF EXISTS transfers;

CREATE TABLE transfers (
    id         INTEGER PRIMARY KEY
                       UNIQUE
                       NOT NULL,
    tid        INTEGER NOT NULL,
    timestamp  INTEGER NOT NULL,
    type       INTEGER NOT NULL,
    account_id INTEGER NOT NULL
                       REFERENCES accounts (id) ON DELETE CASCADE
                                                ON UPDATE CASCADE,
    amount     REAL,
    rate       REAL
);


-- Index: agents_by_name_idx
DROP INDEX IF EXISTS agents_by_name_idx;
CREATE INDEX agents_by_name_idx ON agents (name);


-- Index: by_sid
DROP INDEX IF EXISTS by_sid;
CREATE INDEX by_sid ON ledger_sums (sid);


-- Index: tid_type_unique
DROP INDEX IF EXISTS tid_type_unique;
CREATE UNIQUE INDEX tid_type_unique ON transfers (tid, type);


    -- View: agents_ext
DROP VIEW IF EXISTS agents_ext;
CREATE VIEW agents_ext AS
    SELECT a1.*,
           count(a2.id) AS children_count,
           count(a3.id) AS actions_count
      FROM agents AS a1
           LEFT JOIN
           agents AS a2 ON a1.id = a2.pid
           LEFT JOIN
           actions AS a3 ON a1.id = a3.peer_id
     GROUP BY a1.id;


-- View: all_operations
DROP VIEW IF EXISTS all_operations;
CREATE VIEW all_operations AS
    SELECT m.type,
           m.id,
           m.timestamp,
           m.account_id,
           a.name AS account,
           m.num_peer,
           m.asset_id,
           s.name AS asset,
           s.full_name AS asset_name,
           m.note,
           m.note2,
           m.amount,
           m.qty_trid,
           m.price,
           m.fee_tax,
           l.sum_amount AS t_amount,
           m.t_qty,
           c.name AS currency,
           CASE WHEN m.timestamp <= a.reconciled_on THEN 1 ELSE 0 END AS reconciled
      FROM (
               SELECT 1 AS type,
                      o.id,
                      timestamp,
                      p.name AS num_peer,
                      account_id,
                      sum(d.sum) AS amount,
                      o.alt_currency_id AS asset_id,
                      NULL AS qty_trid,
                      sum(d.alt_sum) AS price,
                      NULL AS fee_tax,
                      NULL AS t_qty,
                      NULL AS note,
                      NULL AS note2,
                      o.id AS operation_id
                 FROM actions AS o
                      LEFT JOIN
                      agents AS p ON o.peer_id = p.id
                      LEFT JOIN
                      action_details AS d ON o.id = d.pid
                GROUP BY o.id
               UNION ALL
               SELECT 2 AS type,
                      d.id,
                      d.timestamp,
                      d.number AS num_peer,
                      d.account_id,
                      d.sum AS amount,
                      d.asset_id,
                      SUM(coalesce(l.amount, 0) ) AS qty_trid,
                      NULL AS price,
                      d.sum_tax AS fee_tax,
                      NULL AS t_qty,
                      d.note AS note,
                      d.note_tax AS note2,
                      d.id AS operation_id
                 FROM dividends AS d
                      LEFT JOIN
                      ledger AS l ON d.asset_id = l.asset_id AND
                                     d.account_id = l.account_id AND 
                                     l.book_account = 4 AND 
                                     l.timestamp <= d.timestamp
                GROUP BY d.id
               UNION ALL
               SELECT 3 AS type,
                      t.id,
                      t.timestamp,
                      t.number AS num_peer,
                      t.account_id,
                      -(t.price*t.qty) AS amount,
                      t.asset_id,
                      t.qty AS qty_trid,
                      t.price AS price,
                      t.fee AS fee_tax,
                      l.sum_amount AS t_qty,
                      ca.note AS note,
                      NULL AS note2,
                      t.id AS operation_id
                 FROM trades AS t
                      LEFT JOIN
                      sequence AS q ON q.type = 3 AND 
                                       t.id = q.operation_id
                      LEFT JOIN
                      ledger_sums AS l ON l.sid = q.id AND 
                                          l.book_account = 4
                      LEFT JOIN corp_actions AS ca ON t.corp_action_id=ca.id
               UNION ALL
               SELECT 4 AS type,
                      r.tid,
                      r.timestamp,
                      c.name AS num_peer,
                      r.account_id,
                      r.amount,
                      NULL AS asset_id,
                      r.type AS qty_trid,
                      r.rate AS price,
                      NULL AS fee_tax,
                      NULL AS t_qty,
                      n.note,
                      a.name AS note2,
                      r.id AS operation_id
                 FROM transfers AS r
                      LEFT JOIN
                      transfer_notes AS n ON r.tid = n.tid
                      LEFT JOIN
                      transfers AS tr ON r.tid = tr.tid AND
                                        r.type = -tr.type
                      LEFT JOIN
                      accounts AS a ON a.id = tr.account_id
                      LEFT JOIN
                      assets AS c ON c.id = a.currency_id
               ORDER BY timestamp
           )
           AS m
           LEFT JOIN
           accounts AS a ON m.account_id = a.id
           LEFT JOIN
           assets AS s ON m.asset_id = s.id
           LEFT JOIN
           assets AS c ON a.currency_id = c.id
           LEFT JOIN
           sequence AS q ON m.type = q.type AND 
                            m.operation_id = q.operation_id
           LEFT JOIN
           ledger_sums AS l ON l.sid = q.id AND 
                               (l.book_account = 3 OR 
                                l.book_account = 5);


-- View: all_transactions
DROP VIEW IF EXISTS all_transactions;
CREATE VIEW all_transactions AS
    SELECT at.*,
           a.currency_id AS currency
      FROM (
               SELECT 1 AS type,
                      a.id,
                      a.timestamp,
                      CASE WHEN SUM(d.sum) < 0 THEN COUNT(d.sum) ELSE -COUNT(d.sum) END AS subtype,
                      a.account_id AS account,
                      NULL AS asset,
                      SUM(d.sum) AS amount,
                      d.category_id AS price_category,
                      a.peer_id AS coupon_peer,
                      d.tag_id AS fee_tax_tag
                 FROM actions AS a
                      LEFT JOIN
                      action_details AS d ON a.id = d.pid
                GROUP BY a.id
               UNION ALL
               SELECT 2 AS type,
                      id,
                      timestamp,
                      0 AS subtype,
                      account_id AS account,
                      asset_id AS asset,
                      sum AS amount,
                      NULL AS price_category,
                      NULL AS coupon_peer,
                      sum_tax AS fee_tax_tag
                 FROM dividends
               UNION ALL
               SELECT 4 AS type,
                      id,
                      timestamp,
                      type AS subtype,
                      account_id AS account,
                      NULL AS asset,
                      amount,
                      NULL AS price_category,
                      NULL AS coupon_peer,
                      NULL AS fee_tax_tag
                 FROM transfers
               UNION ALL
               SELECT 3 AS type,
                      t.id,
                      t.timestamp,
                      coalesce(ca.type, 0) AS subtype,
                      t.account_id AS account,
                      t.asset_id AS asset,
                      t.qty AS amount,
                      t.price AS price_category,
                      t.coupon AS coupon_peer,
                      t.fee AS fee_tax_tag
                 FROM trades AS t
                      LEFT JOIN
                      corp_actions AS ca ON t.corp_action_id = ca.id
                ORDER BY timestamp,
                         type,
                         subtype
           )
           AS at
           LEFT JOIN
           accounts AS a ON at.account = a.id;


-- View: categories_ext
DROP VIEW IF EXISTS categories_ext;
CREATE VIEW categories_ext AS
    SELECT c1.*,
           count(c2.id) AS children_count
      FROM categories AS c1
           LEFT JOIN
           categories c2 ON c1.id = c2.pid
     GROUP BY c1.id;


-- View: categories_tree
DROP VIEW IF EXISTS categories_tree;
CREATE VIEW categories_tree AS
WITH RECURSIVE tree (
        id,
        level,
        path
    )
    AS (
        SELECT id,
               0,
               name
          FROM categories
         WHERE pid = 0
        UNION
        SELECT categories.id,
               tree.level + 1 AS level,
               tree.path || CHAR(127) || categories.name AS path
          FROM categories
               JOIN
               tree
         WHERE categories.pid = tree.id
    )
    SELECT id,
           level,
           path
      FROM tree
     ORDER BY path;



-- View: currencies
DROP VIEW IF EXISTS currencies;
CREATE VIEW currencies AS
    SELECT id,
           name
      FROM assets
     WHERE type_id = 1;


-- View: frontier
DROP VIEW IF EXISTS frontier;
CREATE VIEW frontier AS
    SELECT MAX(sequence.timestamp) AS ledger_frontier
      FROM sequence;


-- View: transfers_combined
DROP VIEW IF EXISTS transfers_combined;
CREATE VIEW transfers_combined AS
    SELECT f.tid AS id,
           f.id AS from_id,
           f.timestamp AS from_timestamp,
           f.account_id AS from_acc_id,
           t.id AS to_id,
           t.timestamp AS to_timestamp,
           t.account_id AS to_acc_id,
           fee.id AS fee_id,
           fee.timestamp AS fee_timestamp,
           fee.account_id AS fee_acc_id,
           f.amount AS from_amount,
           t.amount AS to_amount,
           fee.amount AS fee_amount,
           n.note
      FROM transfers AS f
           INNER JOIN
           transfers AS t ON f.tid = t.tid AND 
                             t.type = 1
           LEFT JOIN
           transfers AS fee ON f.tid = fee.tid AND 
                               fee.type = 0
           LEFT JOIN
           transfer_notes AS n ON f.tid = n.tid
     WHERE f.type = -1;

-- View: deals_ext
DROP VIEW IF EXISTS deals_ext;
CREATE VIEW deals_ext AS
    SELECT d.account_id,
           ac.name AS account,
           d.asset_id,
           at.name AS asset,
           ot.timestamp AS open_timestamp,
           ct.timestamp AS close_timestamp,
           ot.price AS open_price,
           ct.price AS close_price,
           d.qty AS qty,
           ot.fee + ct.fee AS fee,
           d.qty * (ct.price - ot.price) - (ot.fee + ct.fee) AS profit,
           coalesce(100 * (d.qty * (ct.price - ot.price) - (ot.fee + ct.fee) ) / (d.qty * ot.price), 0) AS rel_profit
      FROM deals AS d
           LEFT JOIN
           sequence AS os ON d.open_sid = os.id
           LEFT JOIN
           trades AS ot ON ot.id = os.operation_id
           LEFT JOIN
           sequence AS cs ON d.close_sid = cs.id
           LEFT JOIN
           trades AS ct ON ct.id = cs.operation_id
           LEFT JOIN
           accounts AS ac ON d.account_id = ac.id
           LEFT JOIN
           assets AS at ON d.asset_id = at.id
     ORDER BY ct.timestamp,
              ot.timestamp;


-- Trigger: action_details_after_delete
DROP TRIGGER IF EXISTS action_details_after_delete;
CREATE TRIGGER action_details_after_delete
         AFTER DELETE
            ON action_details
      FOR EACH ROW
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = OLD.pid
                             );
    DELETE FROM sequence
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = OLD.pid
                             );
    DELETE FROM ledger_sums
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = OLD.pid
                             );
END;


-- Trigger: action_details_after_insert
DROP TRIGGER IF EXISTS action_details_after_insert;
CREATE TRIGGER action_details_after_insert
         AFTER INSERT
            ON action_details
      FOR EACH ROW
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = NEW.pid
                             );
    DELETE FROM sequence
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = NEW.pid
                             );
    DELETE FROM ledger_sums
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = NEW.pid
                             );
END;

-- Trigger: action_details_after_update
DROP TRIGGER IF EXISTS action_details_after_update;
CREATE TRIGGER action_details_after_update
         AFTER UPDATE
            ON action_details
      FOR EACH ROW
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = OLD.pid
                             );
    DELETE FROM sequence
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = OLD.pid
                             );
    DELETE FROM ledger_sums
          WHERE timestamp >= (
                                 SELECT timestamp
                                   FROM actions
                                  WHERE id = OLD.pid
                             );
END;

-- Trigger: actions_after_delete
DROP TRIGGER IF EXISTS actions_after_delete;
CREATE TRIGGER actions_after_delete
         AFTER DELETE
            ON actions
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM action_details
          WHERE pid = OLD.id;
    DELETE FROM ledger
          WHERE timestamp >= OLD.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= OLD.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= OLD.timestamp;
END;

-- Trigger: actions_after_insert
DROP TRIGGER IF EXISTS actions_after_insert;
CREATE TRIGGER actions_after_insert
         AFTER INSERT
            ON actions
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= NEW.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= NEW.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= NEW.timestamp;
END;

-- Trigger: actions_after_update
DROP TRIGGER IF EXISTS actions_after_update;
CREATE TRIGGER actions_after_update
         AFTER UPDATE OF timestamp,
                         account_id,
                         peer_id
            ON actions
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
END;

-- Trigger: delete_agent
DROP TRIGGER IF EXISTS delete_agent;
CREATE TRIGGER delete_agent
    INSTEAD OF DELETE
            ON agents_ext
      FOR EACH ROW
BEGIN
    DELETE FROM agents
          WHERE id = OLD.id;
END;

-- Trigger: delete_category
DROP TRIGGER IF EXISTS delete_category;
CREATE TRIGGER delete_category
    INSTEAD OF DELETE
            ON categories_ext
      FOR EACH ROW
BEGIN
    DELETE FROM categories
          WHERE id = OLD.id;
END;

-- Trigger: delete_transfers
DROP TRIGGER IF EXISTS delete_transfers;
CREATE TRIGGER delete_transfers INSTEAD OF DELETE ON transfers_combined FOR EACH ROW BEGIN DELETE FROM transfer_notes
          WHERE tid = OLD.id;
DELETE FROM transfers
          WHERE tid = OLD.id; END;

-- Trigger: dividends_after_delete
DROP TRIGGER IF EXISTS dividends_after_delete;
CREATE TRIGGER dividends_after_delete
         AFTER DELETE
            ON dividends
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= OLD.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= OLD.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= OLD.timestamp;
END;

-- Trigger: dividends_after_insert
DROP TRIGGER IF EXISTS dividends_after_insert;
CREATE TRIGGER dividends_after_insert
         AFTER INSERT
            ON dividends
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= NEW.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= NEW.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= NEW.timestamp;
END;

-- Trigger: dividends_after_update
DROP TRIGGER IF EXISTS dividends_after_update;
CREATE TRIGGER dividends_after_update
         AFTER UPDATE OF timestamp,
                         account_id,
                         asset_id,
                         sum,
                         sum_tax
            ON dividends
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
END;

-- Trigger: insert_agent
DROP TRIGGER IF EXISTS insert_agent;
CREATE TRIGGER insert_agent
    INSTEAD OF INSERT
            ON agents_ext
      FOR EACH ROW
BEGIN
    INSERT INTO agents (
                           id,
                           pid,
                           name,
                           location
                       )
                       VALUES (
                           NEW.id,
                           NEW.pid,
                           NEW.name,
                           NEW.location
                       );
END;

-- Trigger: insert_category
DROP TRIGGER IF EXISTS insert_category;
CREATE TRIGGER insert_category
    INSTEAD OF INSERT
            ON categories_ext
      FOR EACH ROW
BEGIN
    INSERT INTO categories (
                               id,
                               pid,
                               name,
                               often,
                               special
                           )
                           VALUES (
                               NEW.id,
                               NEW.pid,
                               NEW.name,
                               NEW.often,
                               NEW.special
                           );
END;

-- Trigger: insert_transfers_w_none_w_fee
DROP TRIGGER IF EXISTS insert_transfers_w_none_w_fee;
CREATE TRIGGER insert_transfers_w_none_w_fee INSTEAD OF INSERT ON transfers_combined FOR EACH ROW WHEN NEW.fee_acc_id IS NOT NULL AND NEW.note IS NOT NULL   BEGIN INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT COALESCE(MAX(tid), 0) + 1
                                    FROM transfers
                              ),
-                             1,
                              NEW.from_timestamp,
                              NEW.from_acc_id,
                              NEW.from_amount,
                              NEW.to_amount / NEW.from_amount
                          );
INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT MAX(tid)
                                    FROM transfers
                              ),
                              1,
                              NEW.to_timestamp,
                              NEW.to_acc_id,
                              NEW.to_amount,
                              NEW.from_amount / NEW.to_amount
                          );
INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT MAX(tid)
                                    FROM transfers
                              ),
                              0,
                              NEW.fee_timestamp,
                              NEW.fee_acc_id,
                              NEW.fee_amount,
                              0
                          );
INSERT INTO transfer_notes (
                                   tid,
                                   note
                               )
                               VALUES (
                                   (
                                       SELECT MAX(tid)
                                         FROM transfers
                                   ),
                                   NEW.note
                               ); END;

-- Trigger: insert_transfers_w_note_wo_fee
DROP TRIGGER IF EXISTS insert_transfers_w_note_wo_fee;
CREATE TRIGGER insert_transfers_w_note_wo_fee INSTEAD OF INSERT ON transfers_combined FOR EACH ROW WHEN NEW.fee_acc_id IS NULL AND NEW.note IS NOT NULL
    BEGIN INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT COALESCE(MAX(tid), 0) + 1
                                    FROM transfers
                              ),
-                             1,
                              NEW.from_timestamp,
                              NEW.from_acc_id,
                              NEW.from_amount,
                              NEW.to_amount / NEW.from_amount
                          );
INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT MAX(tid)
                                    FROM transfers
                              ),
                              1,
                              NEW.to_timestamp,
                              NEW.to_acc_id,
                              NEW.to_amount,
                              NEW.from_amount / NEW.to_amount
                          );
INSERT INTO transfer_notes (
                                   tid,
                                   note
                               )
                               VALUES (
                                   (
                                       SELECT MAX(tid)
                                         FROM transfers
                                   ),
                                   NEW.note
                               ); END;

-- Trigger: insert_transfers_wo_note_w_fee
DROP TRIGGER IF EXISTS insert_transfers_wo_note_w_fee;
CREATE TRIGGER insert_transfers_wo_note_w_fee INSTEAD OF INSERT ON transfers_combined FOR EACH ROW WHEN NEW.fee_acc_id IS NOT NULL AND NEW.note IS NULL BEGIN INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT COALESCE(MAX(tid), 0) + 1
                                    FROM transfers
                              ),
-                             1,
                              NEW.from_timestamp,
                              NEW.from_acc_id,
                              NEW.from_amount,
                              NEW.to_amount / NEW.from_amount
                          );
INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT MAX(tid)
                                    FROM transfers
                              ),
                              1,
                              NEW.to_timestamp,
                              NEW.to_acc_id,
                              NEW.to_amount,
                              NEW.from_amount / NEW.to_amount
                          );
INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT MAX(tid)
                                    FROM transfers
                              ),
                              0,
                              NEW.fee_timestamp,
                              NEW.fee_acc_id,
                              NEW.fee_amount,
                              0
                          ); END;

-- Trigger: insert_transfers_wo_note_wo_fee
DROP TRIGGER IF EXISTS insert_transfers_wo_note_wo_fee;
CREATE TRIGGER insert_transfers_wo_note_wo_fee INSTEAD OF INSERT ON transfers_combined FOR EACH ROW WHEN NEW.fee_acc_id IS NULL AND NEW.note IS NULL BEGIN INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT COALESCE(MAX(tid), 0) + 1
                                    FROM transfers
                              ),
-                             1,
                              NEW.from_timestamp,
                              NEW.from_acc_id,
                              NEW.from_amount,
                              NEW.to_amount / NEW.from_amount
                          );
INSERT INTO transfers (
                              tid,
                              type,
                              timestamp,
                              account_id,
                              amount,
                              rate
                          )
                          VALUES (
                              (
                                  SELECT MAX(tid)
                                    FROM transfers
                              ),
                              1,
                              NEW.to_timestamp,
                              NEW.to_acc_id,
                              NEW.to_amount,
                              NEW.from_amount / NEW.to_amount
                          ); END;

-- Trigger: trades_after_delete
DROP TRIGGER IF EXISTS trades_after_delete;
CREATE TRIGGER trades_after_delete
         AFTER DELETE
            ON trades
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= OLD.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= OLD.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= OLD.timestamp;
END;

-- Trigger: trades_after_insert
DROP TRIGGER IF EXISTS trades_after_insert;
CREATE TRIGGER trades_after_insert
         AFTER INSERT
            ON trades
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= NEW.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= NEW.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= NEW.timestamp;
END;

-- Trigger: trades_after_update
DROP TRIGGER IF EXISTS trades_after_update;
CREATE TRIGGER trades_after_update
         AFTER UPDATE OF timestamp,
                         corp_action_id,
                         account_id,
                         asset_id,
                         qty,
                         price,
                         coupon,
                         fee
            ON trades
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
END;

-- Trigger: transfers_after_delete
DROP TRIGGER IF EXISTS transfers_after_delete;
CREATE TRIGGER transfers_after_delete
         AFTER DELETE
            ON transfers
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= OLD.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= OLD.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= OLD.timestamp;
END;

-- Trigger: transfers_after_insert
DROP TRIGGER IF EXISTS transfers_after_insert;
CREATE TRIGGER transfers_after_insert
         AFTER INSERT
            ON transfers
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= NEW.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= NEW.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= NEW.timestamp;
END;

-- Trigger: transfers_after_update
DROP TRIGGER IF EXISTS transfers_after_update;
CREATE TRIGGER transfers_after_update
         AFTER UPDATE OF timestamp,
                         type,
                         account_id,
                         amount
            ON transfers
      FOR EACH ROW
          WHEN (
    SELECT value
      FROM settings
     WHERE id = 1
)
BEGIN
    DELETE FROM ledger
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
    DELETE FROM sequence
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
    DELETE FROM ledger_sums
          WHERE timestamp >= OLD.timestamp OR
                timestamp >= NEW.timestamp;
END;

-- Trigger: update_agent
DROP TRIGGER IF EXISTS update_agent;
CREATE TRIGGER update_agent
    INSTEAD OF UPDATE
            ON agents_ext
      FOR EACH ROW
BEGIN
    UPDATE agents
       SET id = NEW.id,
           pid = NEW.pid,
           name = NEW.name,
           location = NEW.location
     WHERE id = OLD.id;
END;

-- Trigger: update_category
DROP TRIGGER IF EXISTS update_category;
CREATE TRIGGER update_category
    INSTEAD OF UPDATE
            ON categories_ext
      FOR EACH ROW
BEGIN
    UPDATE categories
       SET id = NEW.id,
           pid = NEW.pid,
           name = NEW.name,
           often = NEW.often,
           special = NEW.special
     WHERE id = OLD.id;
END;

-- Trigger: update_fee
DROP TRIGGER IF EXISTS update_fee;
CREATE TRIGGER update_fee INSTEAD OF UPDATE OF fee_timestamp, fee_acc_id, fee_amount ON transfers_combined FOR EACH ROW WHEN NEW.fee_acc_id IS NOT NULL AND NEW.fee_acc_id!=0   BEGIN INSERT OR IGNORE INTO transfers(tid, type, timestamp, account_id, timestamp) VALUES (OLD.id, 0, NEW.fee_timestamp, NEW.fee_acc_id, NEW.fee_amount);
UPDATE transfers SET account_id = NEW.fee_acc_id, timestamp = NEW.fee_timestamp, amount = NEW.fee_amount WHERE tid = OLD.id AND type = 0; END;

-- Trigger: update_fee_empty
DROP TRIGGER IF EXISTS update_fee_empty;
CREATE TRIGGER update_fee_empty INSTEAD OF UPDATE OF fee_timestamp, fee_acc_id, fee_amount ON transfers_combined FOR EACH ROW WHEN NEW.fee_acc_id IS NULL OR NEW.fee_acc_id=0      BEGIN DELETE FROM transfers WHERE tid = OLD.id AND type = 0; END;

-- Trigger: update_from
DROP TRIGGER IF EXISTS update_from;
CREATE TRIGGER update_from INSTEAD OF UPDATE OF from_timestamp, from_acc_id, from_amount ON transfers_combined FOR EACH ROW BEGIN UPDATE transfers
       SET account_id = NEW.from_acc_id, timestamp = NEW.from_timestamp, amount = NEW.from_amount
     WHERE tid = OLD.id AND
           type = -1; END;

-- Trigger: update_note
DROP TRIGGER IF EXISTS update_note;
CREATE TRIGGER update_note INSTEAD OF UPDATE OF note ON transfers_combined FOR EACH ROW WHEN NEW.note IS NOT NULL  BEGIN INSERT OR IGNORE INTO transfer_notes(tid, note) VALUES (OLD.id, NEW.note);
UPDATE transfer_notes SET note = NEW.note WHERE tid = OLD.id; END;

-- Trigger: update_note_empty
DROP TRIGGER IF EXISTS update_note_empty;
CREATE TRIGGER update_note_empty INSTEAD OF UPDATE OF note ON transfers_combined FOR EACH ROW WHEN NEW.note IS NULL BEGIN DELETE FROM transfer_notes WHERE tid = OLD.id; END;

-- Trigger: update_to
DROP TRIGGER IF EXISTS update_to;
CREATE TRIGGER update_to INSTEAD OF UPDATE OF to_timestamp, to_acc_id, to_amount ON transfers_combined FOR EACH ROW BEGIN UPDATE transfers
       SET account_id = NEW.to_acc_id, timestamp = NEW.to_timestamp, amount = NEW.to_amount
     WHERE tid = OLD.id AND
           type = 1; END;

-- Trigger to keep predefinded categories from deletion
CREATE TRIGGER keep_predefined_categories BEFORE DELETE ON categories FOR EACH ROW WHEN OLD.special = 1 AND (SELECT value FROM settings WHERE id=1)
BEGIN
    SELECT RAISE(ABORT, "Can't delete predefinded category");
END;


-- Initialize default values for settings
INSERT INTO settings(id, name, value) VALUES (0, 'SchemaVersion', 9);
INSERT INTO settings(id, name, value) VALUES (1, 'TriggersEnabled', 1);
INSERT INTO settings(id, name, value) VALUES (2, 'BaseCurrency', 1);
INSERT INTO settings(id, name, value) VALUES (3, 'Language', 1);
INSERT INTO settings(id, name, value) VALUES (4, 'RuTaxClientSecret', 'IyvrAbKt9h/8p6a7QPh8gpkXYQ4=');
INSERT INTO settings(id, name, value) VALUES (5, 'RuTaxSessionId', '');
INSERT INTO settings(id, name, value) VALUES (6, 'RuTaxRefreshToken', '');

-- Initialize available languages
INSERT INTO languages (id, language) VALUES (1, 'en');
INSERT INTO languages (id, language) VALUES (2, 'ru');

-- Initialize default values for books
INSERT INTO books (id, name) VALUES (1, 'Costs');
INSERT INTO books (id, name) VALUES (2, 'Incomes');
INSERT INTO books (id, name) VALUES (3, 'Money');
INSERT INTO books (id, name) VALUES (4, 'Assets');
INSERT INTO books (id, name) VALUES (5, 'Liabilities');
INSERT INTO books (id, name) VALUES (6, 'Transfers');

-- Initialize asset types values
INSERT INTO asset_types (id, name) VALUES (1, 'Money');
INSERT INTO asset_types (id, name) VALUES (2, 'Shares');
INSERT INTO asset_types (id, name) VALUES (3, 'Bonds');
INSERT INTO asset_types (id, name) VALUES (4, 'Funds');
INSERT INTO asset_types (id, name) VALUES (5, 'Commodities');
INSERT INTO asset_types (id, name) VALUES (6, 'Derivatives');

-- Initialize some account types
INSERT INTO account_types (id, name) VALUES (1, 'Cash');
INSERT INTO account_types (id, name) VALUES (2, 'Bank accounts');
INSERT INTO account_types (id, name) VALUES (3, 'Cards');
INSERT INTO account_types (id, name) VALUES (4, 'Investment');
INSERT INTO account_types (id, name) VALUES (5, 'Deposits');
INSERT INTO account_types (id, name) VALUES (6, 'Debts');
INSERT INTO account_types (id, name) VALUES (7, 'e-Wallets');

-- Initialize sources of quotation data
INSERT INTO data_sources (id, name) VALUES (-1, 'None');
INSERT INTO data_sources (id, name) VALUES (0, 'Bank of Russia');
INSERT INTO data_sources (id, name) VALUES (1, 'MOEX');
INSERT INTO data_sources (id, name) VALUES (2, 'NYSE/Nasdaq');
INSERT INTO data_sources (id, name) VALUES (3, 'Euronext');

-- Initialize predefinded categories
INSERT INTO categories (id, pid, name, often, special) VALUES (1, 0, 'Income', 0, 1);
INSERT INTO categories (id, pid, name, often, special) VALUES (2, 0, 'Spending', 0, 1);
INSERT INTO categories (id, pid, name, often, special) VALUES (3, 0, 'Profits', 0, 1);
INSERT INTO categories (id, pid, name, often, special) VALUES (4, 1, 'Starting balance', 0, 1);
INSERT INTO categories (id, pid, name, often, special) VALUES (5, 2, 'Fees', 0, 1);
INSERT INTO categories (id, pid, name, often, special) VALUES (6, 2, 'Taxes', 0, 1);
INSERT INTO categories (id, pid, name, often, special) VALUES (7, 3, 'Dividends', 0, 1);
INSERT INTO categories (id, pid, name, often, special) VALUES (8, 3, 'Interest', 0, 1);
INSERT INTO categories (id, pid, name, often, special) VALUES (9, 3, 'Results of investments', 0, 1);

-- Initialize common currencies
INSERT INTO assets (id, name, type_id, full_name, web_id, src_id) VALUES (1, 'RUB', 1, 'Российский Рубль', NULL, -1);
INSERT INTO assets (id, name, type_id, full_name, web_id, src_id) VALUES (2, 'USD', 1, 'Доллар США', 'R01235', 0);
INSERT INTO assets (id, name, type_id, full_name, web_id, src_id) VALUES (3, 'EUR', 1, 'Евро', 'R01239', 0);

-- Initialize rate for base currency
INSERT INTO quotes (id, timestamp, asset_id, quote) VALUES (1, 946684800, 1, 1.0);

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
