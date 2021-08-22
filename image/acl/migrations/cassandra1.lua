-- return {
--   postgres =  {
--     -- name = "2015-08-25-841841_init_acl",
--     up = [[
--       CREATE TABLE IF NOT EXISTS acls(
--         id uuid,
--         consumer_id uuid REFERENCES consumers (id) ON DELETE CASCADE,
--         "group" text,
--         created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
--         PRIMARY KEY (id)
--       );

--       DO $$
--       BEGIN
--         IF (SELECT to_regclass('acls_group')) IS NULL THEN
--           CREATE INDEX acls_group ON acls("group");
--         END IF;
--         IF (SELECT to_regclass('acls_consumer_id')) IS NULL THEN
--           CREATE INDEX acls_consumer_id ON acls(consumer_id);
--         END IF;
--       END$$;
--     ]],
--     -- down = [[
--     --   DROP TABLE acls;
--     -- ]],
--   },


--   cassandra = 
--     {
--         name = "2015-08-25-841841_init_acl",
--         up = [[
--       CREATE TABLE IF NOT EXISTS acls(
--         id uuid,
--         consumer_id uuid,
--         group text,
--         created_at timestamp,
--         PRIMARY KEY (id)
--       );

--       CREATE INDEX IF NOT EXISTS ON acls(group);
--       CREATE INDEX IF NOT EXISTS acls_consumer_id ON acls(consumer_id);


      -- CREATE TABLE IF NOT EXISTS acls_no_routes(
      --   id uuid,
      --   route_id uuid,
      --   created_at timestamp,
      --   PRIMARY KEY (id)
      -- );
      -- CREATE INDEX IF NOT EXISTS  ON acls_no_routes(route_id);
--     ]],
--     --     down = [[
--     --   DROP TABLE acls;
--     --   DROP TABLE  acls_no_routes;
--     -- ]],
--     },
-- }


return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "acls" (
        "id"           UUID                         PRIMARY KEY,
        "created_at"   TIMESTAMP WITH TIME ZONE     DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
        "consumer_id"  UUID                         REFERENCES "consumers" ("id") ON DELETE CASCADE,
        "group"        TEXT,
        "cache_key"    TEXT                         UNIQUE
      );

      DO $$
      BEGIN
        CREATE INDEX IF NOT EXISTS "acls_consumer_id_idx" ON "acls" ("consumer_id");
      EXCEPTION WHEN UNDEFINED_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;

      DO $$
      BEGIN
        CREATE INDEX IF NOT EXISTS "acls_group_idx" ON "acls" ("group");
      EXCEPTION WHEN UNDEFINED_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;
    ]],
  },

  cassandra = {
    up = [[
      CREATE TABLE IF NOT EXISTS acls(
        id          uuid PRIMARY KEY,
        created_at  timestamp,
        consumer_id uuid,
        group       text,
        cache_key   text
      );
      CREATE INDEX IF NOT EXISTS ON acls(group);
      CREATE INDEX IF NOT EXISTS ON acls(consumer_id);
      CREATE INDEX IF NOT EXISTS ON acls(cache_key);
      
      CREATE TABLE IF NOT EXISTS acls_no_routes(
        id   uuid PRIMARY KEY,
        route_id uuid,
        created_at timestamp
      );
      CREATE INDEX IF NOT EXISTS  ON acls_no_routes(route_id);

      CREATE TABLE IF NOT EXISTS acls_no_routes(
        id uuid,
        route_id uuid,
        created_at timestamp,
        PRIMARY KEY (id)
      );
      CREATE INDEX IF NOT EXISTS  ON acls_no_routes(route_id);
    ]],
  },
}
