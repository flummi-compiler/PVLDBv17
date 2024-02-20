SELECT o.o_orderkey, optimize.savings
FROM   orders AS o,
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "current_item", "orderkey", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS int) AS "current_item",
            CAST((o.o_orderkey) AS int) AS "orderkey",
            CAST(NULL AS supplier_change) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "%loop%"("%kind%", "%label%", "current_item", "orderkey", "%result%") AS (
        SELECT * FROM "%loop%"
      ),
      "entry"("%kind%", "%label%", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey") AS (
            SELECT "current_item", "orderkey"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("orderkey", "condition%0") AS (
            SELECT CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((SELECT NOT EXISTS(SELECT 1 FROM orders AS o WHERE o.o_orderkey = ("%inputs%"."orderkey"))) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("%") AS (
            SELECT NULL
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((NULL :: supplier_change) AS supplier_change)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "current_item", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("orderkey") AS (
            SELECT "orderkey"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("current_item", "orderkey") AS (
            SELECT CAST((SELECT MAX(l.l_linenumber) FROM lineitem AS l WHERE l.l_orderkey = ("%inputs%"."orderkey")) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "current_item", "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "current_item", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey") AS (
            SELECT "current_item", "orderkey"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "current_item", "orderkey"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("current_item", "orderkey", "condition%1") AS (
            SELECT CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."current_item") < 1) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "current_item", "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
      ),
      "falsey1"("%kind%", "%label%", "current_item", "lineitem", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey") AS (
            SELECT "current_item", "orderkey"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
          ),
          "%assign%"("current_item", "lineitem", "orderkey") AS (
            SELECT CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((SELECT l
                         FROM   lineitem AS l
                         WHERE  l.l_orderkey = ("%inputs%"."orderkey")
                         AND    l.l_linenumber = ("%inputs%"."current_item")) AS lineitem) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter2', "current_item", "lineitem", "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter2"("%kind%", "%label%", "cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("current_item", "lineitem", "orderkey") AS (
            SELECT "current_item", "lineitem", "orderkey"
            FROM   "falsey1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter2'
          ),
          "%assign%"("cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey") AS (
            SELECT CAST((SELECT ps
                         FROM   partsupp AS ps
                         WHERE  ps.ps_partkey = (("%inputs%"."lineitem")).l_partkey
                         AND    ps.ps_suppkey = (("%inputs%"."lineitem")).l_suppkey) AS partsupp) AS "cur_supplier",
                   CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."lineitem")) AS lineitem) AS "lineitem",
                   CAST((SELECT ps
                         FROM   partsupp AS ps
                         WHERE  ps.ps_partkey = (("%inputs%"."lineitem")).l_partkey
                         AND    ps.ps_availqty >= (("%inputs%"."lineitem")).l_quantity
                         ORDER BY ps.ps_supplycost, ps.ps_suppkey
                         LIMIT 1) AS partsupp) AS "min_supplier",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter4', "cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter4"("%kind%", "%label%", "cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey") AS (
            SELECT "cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter4'
          ),
          "%assign%"("cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey", "condition%2") AS (
            SELECT CAST((("%inputs%"."cur_supplier")) AS partsupp) AS "cur_supplier",
                   CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."lineitem")) AS lineitem) AS "lineitem",
                   CAST((("%inputs%"."min_supplier")) AS partsupp) AS "min_supplier",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST(((("%inputs%"."cur_supplier")).ps_suppkey <> (("%inputs%"."min_supplier")).ps_suppkey) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge2', "cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2"
          UNION ALL
        SELECT 'goto', 'truthy2', "cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%2"
      ),
      "truthy2"("%kind%", "%label%", "current_item", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey") AS (
            SELECT "cur_supplier", "current_item", "lineitem", "min_supplier", "orderkey"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy2'
          ),
          "%assign%"("current_item", "orderkey") AS (
            SELECT CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge2', "current_item", "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int),
               CAST(((
                        (("%inputs%"."lineitem")).l_partkey,
                        (1 - (("%inputs%"."min_supplier")).ps_supplycost / (("%inputs%"."cur_supplier")).ps_supplycost) * 100,
                        (("%inputs%"."cur_supplier")).ps_suppkey,
                        (("%inputs%"."min_supplier")).ps_suppkey
                      ) :: supplier_change) AS supplier_change)
        FROM   "%inputs%"
      ),
      "merge2"("%kind%", "%label%", "current_item", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey") AS (
            SELECT "current_item", "orderkey"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge2'
              UNION ALL
            SELECT "current_item", "orderkey"
            FROM   "truthy2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge2'
          ),
          "%assign%"("current_item", "orderkey") AS (
            SELECT CAST((("%inputs%"."current_item") - 1) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "current_item", "orderkey", CAST(NULL AS supplier_change)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "current_item", "orderkey", CAST(NULL AS supplier_change)
     FROM   "merge2"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int), "%result%"
     FROM   "truthy2"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS optimize(savings)
WHERE o.o_oderstatus = 'O';
