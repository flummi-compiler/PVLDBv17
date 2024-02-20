SELECT o.o_orderkey, savings.maximum
FROM   orders AS o,
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "current_item", "orderkey", "savings", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS int) AS "current_item",
            CAST((o.o_orderkey) AS int) AS "orderkey",
            CAST(NULL AS float) AS "savings",
            CAST(NULL AS float) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "loop_head"("%kind%", "%label%", "current_item", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey", "savings") AS (
            SELECT "current_item", "orderkey", "savings"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("current_item", "orderkey", "savings", "condition%0") AS (
            SELECT CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings",
                   CAST((("%inputs%"."current_item") < 1) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "current_item", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "current_item", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "entry"("%kind%", "%label%", "current_item", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey", "savings") AS (
            SELECT "current_item", "orderkey", "savings"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("current_item", "orderkey", "savings") AS (
            SELECT CAST((SELECT MAX(l.l_linenumber) FROM lineitem AS l WHERE l.l_orderkey = ("%inputs%"."orderkey")) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((0) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter1', "current_item", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter1"("%kind%", "%label%", "current_item", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey", "savings") AS (
            SELECT "current_item", "orderkey", "savings"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter1'
          ),
          "%assign%"("current_item", "orderkey", "savings", "condition%1") AS (
            SELECT CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings",
                   CAST((("%inputs%"."current_item") < 1) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "current_item", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
          UNION ALL
        SELECT 'goto', 'truthy0', "current_item", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("savings") AS (
            SELECT "savings"
            FROM   "inter1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
              UNION ALL
            SELECT "savings"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."savings")) AS float)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "current_item", "lineitem", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey", "savings") AS (
            SELECT "current_item", "orderkey", "savings"
            FROM   "inter1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
              UNION ALL
            SELECT "current_item", "orderkey", "savings"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("current_item", "lineitem", "orderkey", "savings") AS (
            SELECT CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((SELECT (l.l_quantity :: bigint)      |
                                (l.l_suppkey  :: bigint << 7) |
                                (l.l_partkey  :: bigint << 21)
                         FROM   lineitem AS l
                         WHERE  l.l_orderkey = ("%inputs%"."orderkey")
                         AND    l.l_linenumber = ("%inputs%"."current_item")) AS bigint) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter3', "current_item", "lineitem", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter3"("%kind%", "%label%", "current_item", "orderkey", "partkey", "quantity", "savings", "suppkey", "%result%") AS (
        WITH
          "%inputs%"("current_item", "lineitem", "orderkey", "savings") AS (
            SELECT "current_item", "lineitem", "orderkey", "savings"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter3'
          ),
          "%assign%"("current_item", "orderkey", "partkey", "quantity", "savings", "suppkey") AS (
            SELECT CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."lineitem") >> 21) AS int) AS "partkey",
                   CAST((("%inputs%"."lineitem")      & ((1 <<  7) - 1)) AS int) AS "quantity",
                   CAST((("%inputs%"."savings")) AS float) AS "savings",
                   CAST((("%inputs%"."lineitem") >> 7 & ((1 << 14) - 1)) AS int) AS "suppkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter4', "current_item", "orderkey", "partkey", "quantity", "savings", "suppkey", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter4"("%kind%", "%label%", "cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey", "partkey", "quantity", "savings", "suppkey") AS (
            SELECT "current_item", "orderkey", "partkey", "quantity", "savings", "suppkey"
            FROM   "inter3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter4'
          ),
          "%assign%"("cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings") AS (
            SELECT CAST((SELECT ps.ps_supplycost
                         FROM   partsupp AS ps
                         WHERE  ps.ps_partkey = ("%inputs%"."partkey")
                         AND    ps.ps_suppkey = ("%inputs%"."suppkey")) AS float) AS "cur_supplycost",
                   CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((SELECT MIN(ps.ps_supplycost)
                         FROM   partsupp AS ps
                         WHERE  ps.ps_partkey = ("%inputs%"."partkey")
                         AND    ps.ps_availqty >= ("%inputs%"."quantity")) AS float) AS "min_supplycost",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."quantity")) AS int) AS "quantity",
                   CAST((("%inputs%"."savings")) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter8', "cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter8"("%kind%", "%label%", "cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings", "%result%") AS (
        WITH
          "%inputs%"("cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings") AS (
            SELECT "cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter8'
          ),
          "%assign%"("cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings", "condition%2") AS (
            SELECT CAST((("%inputs%"."cur_supplycost")) AS float) AS "cur_supplycost",
                   CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."min_supplycost")) AS float) AS "min_supplycost",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."quantity")) AS int) AS "quantity",
                   CAST((("%inputs%"."savings")) AS float) AS "savings",
                   CAST((("%inputs%"."cur_supplycost") > ("%inputs%"."min_supplycost")) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge1', "cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2"
          UNION ALL
        SELECT 'goto', 'truthy1', "cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%2"
      ),
      "truthy1"("%kind%", "%label%", "current_item", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings") AS (
            SELECT "cur_supplycost", "current_item", "min_supplycost", "orderkey", "quantity", "savings"
            FROM   "inter8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          ),
          "%assign%"("current_item", "orderkey", "savings") AS (
            SELECT CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings") + (("%inputs%"."cur_supplycost") - ("%inputs%"."min_supplycost")) * ("%inputs%"."quantity")) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge1', "current_item", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "merge1"("%kind%", "%label%", "current_item", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("current_item", "orderkey", "savings") AS (
            SELECT "current_item", "orderkey", "savings"
            FROM   "inter8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge1'
              UNION ALL
            SELECT "current_item", "orderkey", "savings"
            FROM   "truthy1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge1'
          ),
          "%assign%"("current_item", "orderkey", "savings") AS (
            SELECT CAST((("%inputs%"."current_item") - 1) AS int) AS "current_item",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "current_item", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "current_item", "orderkey", "savings", CAST(NULL AS float)
     FROM   "merge1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS float), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS savings(maximum);
