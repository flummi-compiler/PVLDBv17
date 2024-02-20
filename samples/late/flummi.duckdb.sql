SELECT s.s_name, COUNT(*) AS numwait
FROM   supplier AS s, nation AS n, orders AS o
WHERE  s.s_nationkey = n.n_nationkey
WHERE  o.o_orderstatus = 'F'
AND    n.n_name = 'GERMANY'
AND    (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "blame", "current_item", "multi", "orderkey", "suppkey", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS bool) AS "blame",
            CAST(NULL AS int) AS "current_item",
            CAST(NULL AS bool) AS "multi",
            CAST((o.o_orderkey) AS int) AS "orderkey",
            CAST((s.s_suppkey) AS int) AS "suppkey",
            CAST(NULL AS bool) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "blame", "current_item", "multi", "orderkey", "suppkey", "%result%") AS (
        WITH
          "%inputs%"("blame", "current_item", "multi", "orderkey", "suppkey") AS (
            SELECT "blame", "current_item", "multi", "orderkey", "suppkey"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("blame", "current_item", "multi", "orderkey", "suppkey") AS (
            SELECT CAST((false) AS bool) AS "blame",
                   CAST((SELECT MAX(l.l_linenumber) FROM lineitem AS l WHERE l.l_orderkey = ("%inputs%"."orderkey")) AS int) AS "current_item",
                   CAST((false) AS bool) AS "multi",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."suppkey")) AS int) AS "suppkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "blame", "current_item", "multi", "orderkey", "suppkey", "%result%") AS (
        WITH
          "%inputs%"("blame", "current_item", "multi", "orderkey", "suppkey") AS (
            SELECT "blame", "current_item", "multi", "orderkey", "suppkey"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "blame", "current_item", "multi", "orderkey", "suppkey"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("blame", "current_item", "multi", "orderkey", "suppkey", "condition%0") AS (
            SELECT CAST((("%inputs%"."blame")) AS bool) AS "blame",
                   CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."multi")) AS bool) AS "multi",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."suppkey")) AS int) AS "suppkey",
                   CAST((("%inputs%"."current_item") < 1) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("blame", "multi") AS (
            SELECT "blame", "multi"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."multi") AND ("%inputs%"."blame")) AS bool)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "blame", "current_item", "lineitem", "multi", "orderkey", "suppkey", "%result%") AS (
        WITH
          "%inputs%"("blame", "current_item", "multi", "orderkey", "suppkey") AS (
            SELECT "blame", "current_item", "multi", "orderkey", "suppkey"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("blame", "current_item", "lineitem", "multi", "orderkey", "suppkey") AS (
            SELECT CAST((("%inputs%"."blame")) AS bool) AS "blame",
                   CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((SELECT (l.l_receiptdate, l.l_commitdate, l.l_suppkey)
                         FROM   lineitem AS l
                         WHERE  l.l_orderkey = ("%inputs%"."orderkey")
                         AND    l.l_linenumber = ("%inputs%"."current_item")) AS struct(l_receiptdate date, l_commitdate date, l_suppkey int)) AS "lineitem",
                   CAST((("%inputs%"."multi")) AS bool) AS "multi",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."suppkey")) AS int) AS "suppkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter4', "blame", "current_item", "lineitem", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter4"("%kind%", "%label%", "blame", "current_item", "multi", "orderkey", "suppkey", "%result%") AS (
        WITH
          "%inputs%"("blame", "current_item", "lineitem", "multi", "orderkey", "suppkey") AS (
            SELECT "blame", "current_item", "lineitem", "multi", "orderkey", "suppkey"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter4'
          ),
          "%assign%"("blame", "current_item", "multi", "orderkey", "suppkey", "condition%1", "condition%2") AS (
            SELECT CAST((("%inputs%"."blame")) AS bool) AS "blame",
                   CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."multi") OR ("%inputs%"."lineitem").l_suppkey <> ("%inputs%"."suppkey")) AS bool) AS "multi",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."suppkey")) AS int) AS "suppkey",
                   CAST((("%inputs%"."lineitem").l_receiptdate > ("%inputs%"."lineitem").l_commitdate) AS bool) AS "condition%1",
                   CAST((("%inputs%"."lineitem").l_suppkey <> ("%inputs%"."suppkey")) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey2', "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1" AND NOT "condition%2"
          UNION ALL
        SELECT 'goto', 'merge1', "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
          UNION ALL
        SELECT 'goto', 'truthy2', "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1" AND "condition%2"
      ),
      "truthy2"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("%") AS (
            SELECT NULL
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy2'
          )
        SELECT 'emit', NULL,
               CAST((false) AS bool)
        FROM   "%inputs%"
      ),
      "falsey2"("%kind%", "%label%", "blame", "current_item", "multi", "orderkey", "suppkey", "%result%") AS (
        WITH
          "%inputs%"("current_item", "multi", "orderkey", "suppkey") AS (
            SELECT "current_item", "multi", "orderkey", "suppkey"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey2'
          ),
          "%assign%"("blame", "current_item", "multi", "orderkey", "suppkey") AS (
            SELECT CAST((true) AS bool) AS "blame",
                   CAST((("%inputs%"."current_item")) AS int) AS "current_item",
                   CAST((("%inputs%"."multi")) AS bool) AS "multi",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."suppkey")) AS int) AS "suppkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge1', "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "merge1"("%kind%", "%label%", "blame", "current_item", "multi", "orderkey", "suppkey", "%result%") AS (
        WITH
          "%inputs%"("blame", "current_item", "multi", "orderkey", "suppkey") AS (
            SELECT "blame", "current_item", "multi", "orderkey", "suppkey"
            FROM   "falsey2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge1'
              UNION ALL
            SELECT "blame", "current_item", "multi", "orderkey", "suppkey"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge1'
          ),
          "%assign%"("blame", "current_item", "multi", "orderkey", "suppkey") AS (
            SELECT CAST((("%inputs%"."blame")) AS bool) AS "blame",
                   CAST((("%inputs%"."current_item") - 1) AS int) AS "current_item",
                   CAST((("%inputs%"."multi")) AS bool) AS "multi",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."suppkey")) AS int) AS "suppkey"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "blame", "current_item", "multi", "orderkey", "suppkey", CAST(NULL AS bool)
     FROM   "merge1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS bool), CAST(NULL AS int), CAST(NULL AS bool), CAST(NULL AS int), CAST(NULL AS int), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS bool), CAST(NULL AS int), CAST(NULL AS bool), CAST(NULL AS int), CAST(NULL AS int), "%result%"
     FROM   "truthy2"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
)
GROUP BY s.s_name
ORDER BY numwait DESC, s.s_name;
