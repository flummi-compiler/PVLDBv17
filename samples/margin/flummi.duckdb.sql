SELECT o.o_orderkey, margin.margin
FROM   orders AS o,
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS float) AS "cheapest",
            CAST(NULL AS int) AS "items",
            CAST(NULL AS float) AS "margin",
            CAST((o.o_orderkey) AS int) AS "orderkey",
            CAST(NULL AS int) AS "p1",
            CAST(NULL AS int) AS "p2",
            CAST(NULL AS struct(partkey int, price float)) AS "part1",
            CAST(NULL AS float) AS "pmargin",
            CAST(NULL AS float) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "outer_head"("%kind%", "%label%", "items", "margin", "orderkey", "p1", "%result%") AS (
        WITH
          "%inputs%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='outer_head'
          ),
          "%assign%"("items", "margin", "orderkey", "p1", "condition%0") AS (
            SELECT CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."p1") < 1) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "items", "margin", "orderkey", "p1", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "items", "margin", "orderkey", "p1", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "inner_head"("%kind%", "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "%result%") AS (
        WITH
          "%inputs%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='inner_head'
          ),
          "%assign%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "condition%1") AS (
            SELECT CAST((("%inputs%"."cheapest")) AS float) AS "cheapest",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."p2")) AS int) AS "p2",
                   CAST((("%inputs%"."part1")) AS struct(partkey int, price float)) AS "part1",
                   CAST((("%inputs%"."pmargin")) AS float) AS "pmargin",
                   CAST((("%inputs%"."p2") < 1) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
          UNION ALL
        SELECT 'goto', 'truthy1', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1"
      ),
      "entry"("%kind%", "%label%", "items", "margin", "orderkey", "%result%") AS (
        WITH
          "%inputs%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("items", "margin", "orderkey") AS (
            SELECT CAST((SELECT COUNT(*)
                         FROM   lineitem AS l
                         WHERE  l.l_orderkey = ("%inputs%"."orderkey")) AS int) AS "items",
                   CAST((0) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "items", "margin", "orderkey", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "items", "margin", "orderkey", "p1", "%result%") AS (
        WITH
          "%inputs%"("items", "margin", "orderkey") AS (
            SELECT "items", "margin", "orderkey"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("items", "margin", "orderkey", "p1") AS (
            SELECT CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."items")) AS int) AS "p1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter2', "items", "margin", "orderkey", "p1", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter2"("%kind%", "%label%", "items", "margin", "orderkey", "p1", "%result%") AS (
        WITH
          "%inputs%"("items", "margin", "orderkey", "p1") AS (
            SELECT "items", "margin", "orderkey", "p1"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter2'
          ),
          "%assign%"("items", "margin", "orderkey", "p1", "condition%2") AS (
            SELECT CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."p1") < 1) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "items", "margin", "orderkey", "p1", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2"
          UNION ALL
        SELECT 'goto', 'truthy0', "items", "margin", "orderkey", "p1", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%2"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("margin") AS (
            SELECT "margin"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
              UNION ALL
            SELECT "margin"
            FROM   "outer_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."margin")) AS float)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "%result%") AS (
        WITH
          "%inputs%"("items", "margin", "orderkey", "p1") AS (
            SELECT "items", "margin", "orderkey", "p1"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
              UNION ALL
            SELECT "items", "margin", "orderkey", "p1"
            FROM   "outer_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."items")) AS int) AS "p2",
                   CAST((SELECT struct_pack(partkey := l.l_partkey, price := l.l_extendedprice * (1 - l.l_discount) * (1 + l.l_tax))
                         FROM   lineitem AS l
                         WHERE  l.l_orderkey = ("%inputs%"."orderkey")
                         AND    l.l_linenumber = ("%inputs%"."p1")) AS struct(partkey int, price float)) AS "part1",
                   CAST((0) AS float) AS "pmargin"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter4', "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter4"("%kind%", "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "%result%") AS (
        WITH
          "%inputs%"("items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter4'
          ),
          "%assign%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "condition%3") AS (
            SELECT CAST((("%inputs%"."part1").price) AS float) AS "cheapest",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."p2")) AS int) AS "p2",
                   CAST((("%inputs%"."part1")) AS struct(partkey int, price float)) AS "part1",
                   CAST((("%inputs%"."pmargin")) AS float) AS "pmargin",
                   CAST((("%inputs%"."p2") < 1) AS bool) AS "condition%3"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%3"
          UNION ALL
        SELECT 'goto', 'truthy1', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%3"
      ),
      "truthy1"("%kind%", "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "%result%") AS (
        WITH
          "%inputs%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
              UNION ALL
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "inner_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          ),
          "%assign%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT CAST((("%inputs%"."cheapest")) AS float) AS "cheapest",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin") + ("%inputs%"."pmargin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1") - 1) AS int) AS "p1",
                   CAST((("%inputs%"."p2")) AS int) AS "p2",
                   CAST((("%inputs%"."part1")) AS struct(partkey int, price float)) AS "part1",
                   CAST((("%inputs%"."pmargin")) AS float) AS "pmargin"
            FROM "%inputs%"
          )

        SELECT 'jump', 'outer_head', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey1"("%kind%", "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin", "%result%") AS (
        WITH
          "%inputs%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
              UNION ALL
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "inner_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
          ),
          "%assign%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin") AS (
            SELECT CAST((("%inputs%"."cheapest")) AS float) AS "cheapest",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."p2")) AS int) AS "p2",
                   CAST((("%inputs%"."part1")) AS struct(partkey int, price float)) AS "part1",
                   CAST((SELECT struct_pack(partkey := l.l_partkey, price := l.l_extendedprice * (1 - l.l_discount) * (1 + l.l_tax))
                         FROM   lineitem AS l
                         WHERE  l.l_orderkey = ("%inputs%"."orderkey")
                         AND    l.l_linenumber = ("%inputs%"."p2")) AS struct(partkey int, price float)) AS "part2",
                   CAST((("%inputs%"."pmargin")) AS float) AS "pmargin"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter9', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter9"("%kind%", "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin", "%result%") AS (
        WITH
          "%inputs%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin") AS (
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin"
            FROM   "falsey1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter9'
          ),
          "%assign%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin", "condition%4", "condition%5") AS (
            SELECT CAST((("%inputs%"."cheapest")) AS float) AS "cheapest",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."p2")) AS int) AS "p2",
                   CAST((("%inputs%"."part1")) AS struct(partkey int, price float)) AS "part1",
                   CAST((("%inputs%"."part2")) AS struct(partkey int, price float)) AS "part2",
                   CAST((("%inputs%"."pmargin")) AS float) AS "pmargin",
                   CAST((("%inputs%"."part1").partkey = ("%inputs%"."part2").partkey) AS bool) AS "condition%4",
                   CAST((("%inputs%"."part2").price < ("%inputs%"."cheapest")) AS bool) AS "condition%5"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge2', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%4" AND NOT "condition%5"
          UNION ALL
        SELECT 'goto', 'merge2', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%4"
          UNION ALL
        SELECT 'goto', 'truthy3', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "part2", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%4" AND "condition%5"
      ),
      "truthy3"("%kind%", "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "%result%") AS (
        WITH
          "%inputs%"("items", "margin", "orderkey", "p1", "p2", "part1", "part2") AS (
            SELECT "items", "margin", "orderkey", "p1", "p2", "part1", "part2"
            FROM   "inter9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy3'
          ),
          "%assign%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT CAST((("%inputs%"."part2").price) AS float) AS "cheapest",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."p2")) AS int) AS "p2",
                   CAST((("%inputs%"."part1")) AS struct(partkey int, price float)) AS "part1",
                   CAST((("%inputs%"."part1").price - ("%inputs%"."part2").price) AS float) AS "pmargin"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge2', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "merge2"("%kind%", "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", "%result%") AS (
        WITH
          "%inputs%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "inter9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge2'
              UNION ALL
            SELECT "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin"
            FROM   "truthy3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge2'
          ),
          "%assign%"("cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin") AS (
            SELECT CAST((("%inputs%"."cheapest")) AS float) AS "cheapest",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."margin")) AS float) AS "margin",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."p1")) AS int) AS "p1",
                   CAST((("%inputs%"."p2") - 1) AS int) AS "p2",
                   CAST((("%inputs%"."part1")) AS struct(partkey int, price float)) AS "part1",
                   CAST((("%inputs%"."pmargin")) AS float) AS "pmargin"
            FROM "%inputs%"
          )

        SELECT 'jump', 'inner_head', "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
     FROM   "truthy1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "cheapest", "items", "margin", "orderkey", "p1", "p2", "part1", "pmargin", CAST(NULL AS float)
     FROM   "merge2"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS float), CAST(NULL AS int), CAST(NULL AS float), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS struct(partkey int, price float)), CAST(NULL AS float), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS margin(margin);
