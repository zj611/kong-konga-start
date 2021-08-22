return {
  cassandra = {
    up = [[
      CREATE TABLE IF NOT EXISTS record_request(
        id          uuid PRIMARY KEY,
        created_at  timestamp,
        key         text,
        server_name text,
        ws_id       uuid
      );
      CREATE INDEX IF NOT EXISTS ON record_request(key);
    ]],
  },
  postgres = {
    up = [[]]
  },
}
