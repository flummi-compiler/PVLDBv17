SELECT o.o_orderkey, savings.maximum
FROM   orders AS o,
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "i", "lineitems", "orderkey", "savings", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS int) AS "i",
            CAST(NULL AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
            CAST((o.o_orderkey) AS int) AS "orderkey",
            CAST(NULL AS float) AS "savings",
            CAST(NULL AS float) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "loop_head"("%kind%", "%label%", "i", "lineitems", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("i", "lineitems", "orderkey", "savings") AS (
            SELECT "i", "lineitems", "orderkey", "savings"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("i", "lineitems", "orderkey", "savings", "condition%0") AS (
            SELECT CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."lineitems")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings",
                   CAST((("%inputs%"."i") < 1) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "i", "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "i", "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "entry"("%kind%", "%label%", "lineitems", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("i", "lineitems", "orderkey", "savings") AS (
            SELECT "i", "lineitems", "orderkey", "savings"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("lineitems", "orderkey", "savings") AS (
            SELECT CAST((SELECT ARRAY_AGG({
                           partkey: l.l_partkey,
                           suppkey: l.l_suppkey,
                           quantity: l.l_quantity :: int
                         })
                         FROM   lineitem AS l
                         WHERE  l.l_orderkey = ("%inputs%"."orderkey")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((0) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "i", "lineitems", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("lineitems", "orderkey", "savings") AS (
            SELECT "lineitems", "orderkey", "savings"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("i", "lineitems", "orderkey", "savings") AS (
            SELECT CAST((LEN(("%inputs%"."lineitems"))) AS int) AS "i",
                   CAST((("%inputs%"."lineitems")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter2', "i", "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter2"("%kind%", "%label%", "i", "lineitems", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("i", "lineitems", "orderkey", "savings") AS (
            SELECT "i", "lineitems", "orderkey", "savings"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter2'
          ),
          "%assign%"("i", "lineitems", "orderkey", "savings", "condition%1") AS (
            SELECT CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."lineitems")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings",
                   CAST((("%inputs%"."i") < 1) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "i", "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
          UNION ALL
        SELECT 'goto', 'truthy0', "i", "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("savings") AS (
            SELECT "savings"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
              UNION ALL
            SELECT "savings"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."savings")) AS float)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "i", "lineitem", "lineitems", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("i", "lineitems", "orderkey", "savings") AS (
            SELECT "i", "lineitems", "orderkey", "savings"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
              UNION ALL
            SELECT "i", "lineitems", "orderkey", "savings"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("i", "lineitem", "lineitems", "orderkey", "savings") AS (
            SELECT CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."lineitems")[("%inputs%"."i")]) AS struct(partkey int, suppkey int, quantity int)) AS "lineitem",
                   CAST((("%inputs%"."lineitems")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter4', "i", "lineitem", "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter4"("%kind%", "%label%", "cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("i", "lineitem", "lineitems", "orderkey", "savings") AS (
            SELECT "i", "lineitem", "lineitems", "orderkey", "savings"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter4'
          ),
          "%assign%"("cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings") AS (
            SELECT CAST((SELECT ps.ps_supplycost
                         FROM   partsupp AS ps
                         WHERE  ps.ps_partkey = ("%inputs%"."lineitem").partkey
                         AND    ps.ps_suppkey = ("%inputs%"."lineitem").suppkey) AS float) AS "cur_supplycost",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."lineitem")) AS struct(partkey int, suppkey int, quantity int)) AS "lineitem",
                   CAST((("%inputs%"."lineitems")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((SELECT MIN(ps.ps_supplycost)
                         FROM   partsupp AS ps
                         WHERE  ps.ps_partkey = ("%inputs%"."lineitem").partkey
                         AND    ps.ps_availqty >= ("%inputs%"."lineitem").quantity) AS float) AS "min_supplycost",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter6', "cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter6"("%kind%", "%label%", "cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings") AS (
            SELECT "cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter6'
          ),
          "%assign%"("cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings", "condition%2") AS (
            SELECT CAST((("%inputs%"."cur_supplycost")) AS float) AS "cur_supplycost",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."lineitem")) AS struct(partkey int, suppkey int, quantity int)) AS "lineitem",
                   CAST((("%inputs%"."lineitems")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((("%inputs%"."min_supplycost")) AS float) AS "min_supplycost",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings",
                   CAST((("%inputs%"."cur_supplycost") > ("%inputs%"."min_supplycost")) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge1', "cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2"
          UNION ALL
        SELECT 'goto', 'truthy1', "cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%2"
      ),
      "truthy1"("%kind%", "%label%", "i", "lineitems", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings") AS (
            SELECT "cur_supplycost", "i", "lineitem", "lineitems", "min_supplycost", "orderkey", "savings"
            FROM   "inter6"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          ),
          "%assign%"("i", "lineitems", "orderkey", "savings") AS (
            SELECT CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."lineitems")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings") + (("%inputs%"."cur_supplycost") - ("%inputs%"."min_supplycost")) * ("%inputs%"."lineitem").quantity) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge1', "i", "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "merge1"("%kind%", "%label%", "i", "lineitems", "orderkey", "savings", "%result%") AS (
        WITH
          "%inputs%"("i", "lineitems", "orderkey", "savings") AS (
            SELECT "i", "lineitems", "orderkey", "savings"
            FROM   "truthy1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge1'
              UNION ALL
            SELECT "i", "lineitems", "orderkey", "savings"
            FROM   "inter6"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge1'
          ),
          "%assign%"("i", "lineitems", "orderkey", "savings") AS (
            SELECT CAST((("%inputs%"."i") - 1) AS int) AS "i",
                   CAST((("%inputs%"."lineitems")) AS struct(partkey int, suppkey int, quantity int)[]) AS "lineitems",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."savings")) AS float) AS "savings"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "i", "lineitems", "orderkey", "savings", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "i", "lineitems", "orderkey", "savings", CAST(NULL AS float)
     FROM   "merge1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS struct(partkey int, suppkey int, quantity int)[]), CAST(NULL AS int), CAST(NULL AS float), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS savings(maximum);
