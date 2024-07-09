SELECT input.givenStore, result.dt, result.profit
FROM   (SELECT MIN(d.d_date) AS min_date,
               MAX(d.d_date) AS max_date,
               store.s_store_sk AS givenStore
        FROM   store AS store,
               store_sales AS sale,
               date_dim AS d
        WHERE  sale.ss_store_sk = store.s_store_sk
        AND    sale.ss_sold_date_sk = d.d_date_sk
        GROUP BY store.s_store_sk) AS inputs,
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "endDate", "givenStore", "startDate", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((inputs.max_date) AS DATE) AS "endDate",
            CAST((inputs.givenStore) AS INT) AS "givenStore",
            CAST((inputs.min_date) AS DATE) AS "startDate",
            CAST(NULL AS struct(dt DATE, profit DECIMAL(15,2))) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "loop_head"("%kind%", "%label%", "endDate", "givenStore", "startDate", "%result%") AS (
        WITH
          "%inputs%"("endDate", "givenStore", "startDate") AS (
            SELECT "endDate", "givenStore", "startDate"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("endDate", "givenStore", "startDate", "condition%0") AS (
            SELECT CAST((("%inputs%"."endDate")) AS DATE) AS "endDate",
                   CAST((("%inputs%"."givenStore")) AS INT) AS "givenStore",
                   CAST((("%inputs%"."startDate")) AS DATE) AS "startDate",
                   CAST((("%inputs%"."startDate") > ("%inputs%"."endDate")) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "endDate", "givenStore", "startDate", CAST(NULL AS struct(dt DATE, profit DECIMAL(15,2)))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
      ),
      "entry"("%kind%", "%label%", "endDate", "givenStore", "startDate", "%result%") AS (
        WITH
          "%inputs%"("endDate", "givenStore", "startDate") AS (
            SELECT "endDate", "givenStore", "startDate"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("endDate", "givenStore", "startDate", "condition%1") AS (
            SELECT CAST((("%inputs%"."endDate")) AS DATE) AS "endDate",
                   CAST((("%inputs%"."givenStore")) AS INT) AS "givenStore",
                   CAST((("%inputs%"."startDate")) AS DATE) AS "startDate",
                   CAST((("%inputs%"."startDate") > ("%inputs%"."endDate")) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "endDate", "givenStore", "startDate", CAST(NULL AS struct(dt DATE, profit DECIMAL(15,2)))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
      ),
      "falsey0"("%kind%", "%label%", "dateSk", "endDate", "givenStore", "startDate", "%result%") AS (
        WITH
          "%inputs%"("endDate", "givenStore", "startDate") AS (
            SELECT "endDate", "givenStore", "startDate"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
              UNION ALL
            SELECT "endDate", "givenStore", "startDate"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("dateSk", "endDate", "givenStore", "startDate") AS (
            SELECT CAST((SELECT d_data_sk
                         FROM   date_dim
                         WHERE  d_date = ("%inputs%"."startDate")) AS INT) AS "dateSk",
                   CAST((("%inputs%"."endDate")) AS DATE) AS "endDate",
                   CAST((("%inputs%"."givenStore")) AS INT) AS "givenStore",
                   CAST((("%inputs%"."startDate")) AS DATE) AS "startDate"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge0', "dateSk", "endDate", "givenStore", "startDate", CAST(NULL AS struct(dt DATE, profit DECIMAL(15,2)))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "merge0"("%kind%", "%label%", "dayProfit", "endDate", "givenStore", "startDate", "%result%") AS (
        WITH
          "%inputs%"("dateSk", "endDate", "givenStore", "startDate") AS (
            SELECT "dateSk", "endDate", "givenStore", "startDate"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge0'
          ),
          "%assign%"("dayProfit", "endDate", "givenStore", "startDate") AS (
            SELECT CAST((SELECT SUM(ss_net_profit)
                         FROM   store_sales
                         WHERE  ss_sold_date_sk = ("%inputs%"."dateSk")
                         AND    ss_store_sk = ("%inputs%"."givenStore")) AS DECIMAL(15,2)) AS "dayProfit",
                   CAST((("%inputs%"."endDate")) AS DATE) AS "endDate",
                   CAST((("%inputs%"."givenStore")) AS INT) AS "givenStore",
                   CAST((("%inputs%"."startDate")) AS DATE) AS "startDate"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "dayProfit", "endDate", "givenStore", "startDate", CAST(NULL AS struct(dt DATE, profit DECIMAL(15,2)))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "endDate", "givenStore", "startDate", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("dayProfit", "endDate", "givenStore", "startDate") AS MATERIALIZED (
            SELECT "dayProfit", "endDate", "givenStore", "startDate"
            FROM   "merge0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("endDate", "givenStore", "startDate") AS (
            SELECT CAST((("%inputs%"."endDate")) AS DATE) AS "endDate",
                   CAST((("%inputs%"."givenStore")) AS INT) AS "givenStore",
                   CAST((("%inputs%"."startDate")) AS DATE) AS "startDate"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter1', "endDate", "givenStore", "startDate", CAST(NULL AS struct(dt DATE, profit DECIMAL(15,2)))
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS DATE), CAST(NULL AS INT), CAST(NULL AS DATE),
               CAST(({ dt: ("%inputs%"."startDate"), profit: ("%inputs%"."dayProfit") }) AS struct(dt DATE, profit DECIMAL(15,2)))
        FROM   "%inputs%"
      ),
      "inter1"("%kind%", "%label%", "endDate", "givenStore", "startDate", "%result%") AS (
        WITH
          "%inputs%"("endDate", "givenStore", "startDate") AS (
            SELECT "endDate", "givenStore", "startDate"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter1'
          ),
          "%assign%"("endDate", "givenStore", "startDate") AS (
            SELECT CAST((("%inputs%"."endDate")) AS DATE) AS "endDate",
                   CAST((("%inputs%"."givenStore")) AS INT) AS "givenStore",
                   CAST((("%inputs%"."startDate") + INTERVAL 1 DAY) AS DATE) AS "startDate"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "endDate", "givenStore", "startDate", CAST(NULL AS struct(dt DATE, profit DECIMAL(15,2)))
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "endDate", "givenStore", "startDate", CAST(NULL AS struct(dt DATE, profit DECIMAL(15,2)))
     FROM   "inter1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS DATE), CAST(NULL AS INT), CAST(NULL AS DATE), "%result%"
     FROM   "inter0"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS _(result);
