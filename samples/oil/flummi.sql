SELECT p.x, p.y, oil.well
FROM   endpoints AS oil_inputs,
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "cost", "pivot_x", "pivot_y", "slope", "well", "yield", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS float) AS "cost",
            CAST((oil_inputs.x) AS int) AS "pivot_x",
            CAST((oil_inputs.y) AS int) AS "pivot_y",
            CAST(NULL AS float) AS "slope",
            CAST(NULL AS struct(x int, y int, yield int)) AS "well",
            CAST(NULL AS int) AS "yield",
            CAST(NULL AS struct(x int, y int, yield int)) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "cost", "pivot_x", "pivot_y", "slope", "well", "yield", "%result%") AS (
        WITH
          "%inputs%"("cost", "pivot_x", "pivot_y", "slope", "well", "yield") AS (
            SELECT "cost", "pivot_x", "pivot_y", "slope", "well", "yield"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("cost", "pivot_x", "pivot_y", "slope", "well", "yield") AS (
            SELECT CAST(('-Infinity' :: float) AS float) AS "cost",
                   CAST((("%inputs%"."pivot_x")) AS int) AS "pivot_x",
                   CAST((("%inputs%"."pivot_y")) AS int) AS "pivot_y",
                   CAST(('-Infinity' :: float) AS float) AS "slope",
                   CAST((("%inputs%"."well")) AS struct(x int, y int, yield int)) AS "well",
                   CAST((SELECT abs(p.c)
                         FROM   endpoints AS p
                         WHERE  p.x = ("%inputs%"."pivot_x")
                         AND    p.y = ("%inputs%"."pivot_y")) AS int) AS "yield"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "cost", "pivot_x", "pivot_y", "slope", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "current", "pivot_x", "pivot_y", "well", "yield", "%result%") AS (
        WITH
          "%inputs%"("cost", "pivot_x", "pivot_y", "slope", "well", "yield") AS (
            SELECT "cost", "pivot_x", "pivot_y", "slope", "well", "yield"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "cost", "pivot_x", "pivot_y", "slope", "well", "yield"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("current", "pivot_x", "pivot_y", "well", "yield") AS (
            SELECT CAST((SELECT  {x: e.x, y: e.y, cost: actual_cost, slope: rot}
                         FROM    endpoints AS e,
                         LATERAL (SELECT (e.x - ("%inputs%"."pivot_x")) :: float / (e.y - ("%inputs%"."pivot_y")),
                                         CASE WHEN pivot_y > e.y THEN -e.c ELSE e.c END) AS _(rot, actual_cost)
                         WHERE   e.y <> ("%inputs%"."pivot_y")
                         AND     (rot > ("%inputs%"."slope") OR
                                  rot = ("%inputs%"."slope") AND actual_cost < ("%inputs%"."cost"))
                         ORDER BY rot, actual_cost DESC
                         LIMIT 1) AS struct(x int, y int, cost int, slope float)) AS "current",
                   CAST((("%inputs%"."pivot_x")) AS int) AS "pivot_x",
                   CAST((("%inputs%"."pivot_y")) AS int) AS "pivot_y",
                   CAST((("%inputs%"."well")) AS struct(x int, y int, yield int)) AS "well",
                   CAST((("%inputs%"."yield")) AS int) AS "yield"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter3', "current", "pivot_x", "pivot_y", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter3"("%kind%", "%label%", "current", "pivot_x", "pivot_y", "well", "yield", "%result%") AS (
        WITH
          "%inputs%"("current", "pivot_x", "pivot_y", "well", "yield") AS (
            SELECT "current", "pivot_x", "pivot_y", "well", "yield"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter3'
          ),
          "%assign%"("current", "pivot_x", "pivot_y", "well", "yield", "condition%0") AS (
            SELECT CAST((("%inputs%"."current")) AS struct(x int, y int, cost int, slope float)) AS "current",
                   CAST((("%inputs%"."pivot_x")) AS int) AS "pivot_x",
                   CAST((("%inputs%"."pivot_y")) AS int) AS "pivot_y",
                   CAST((("%inputs%"."well")) AS struct(x int, y int, yield int)) AS "well",
                   CAST((("%inputs%"."yield")) AS int) AS "yield",
                   CAST((("%inputs%"."current") IS NULL) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "current", "pivot_x", "pivot_y", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "current", "pivot_x", "pivot_y", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("well") AS (
            SELECT "well"
            FROM   "inter3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."well")) AS struct(x int, y int, yield int))
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield", "%result%") AS (
        WITH
          "%inputs%"("current", "pivot_x", "pivot_y", "well", "yield") AS (
            SELECT "current", "pivot_x", "pivot_y", "well", "yield"
            FROM   "inter3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield") AS (
            SELECT CAST((("%inputs%"."current").cost) AS float) AS "cost",
                   CAST((("%inputs%"."current")) AS struct(x int, y int, cost int, slope float)) AS "current",
                   CAST((("%inputs%"."pivot_x")) AS int) AS "pivot_x",
                   CAST((("%inputs%"."pivot_y")) AS int) AS "pivot_y",
                   CAST((("%inputs%"."current").slope) AS float) AS "slope",
                   CAST((("%inputs%"."well")) AS struct(x int, y int, yield int)) AS "well",
                   CAST((("%inputs%"."yield")) AS int) AS "yield"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge0', "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "merge0"("%kind%", "%label%", "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield", "%result%") AS (
        WITH
          "%inputs%"("cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield") AS (
            SELECT "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge0'
          ),
          "%assign%"("cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield") AS (
            SELECT CAST((("%inputs%"."cost")) AS float) AS "cost",
                   CAST((("%inputs%"."current")) AS struct(x int, y int, cost int, slope float)) AS "current",
                   CAST((("%inputs%"."pivot_x")) AS int) AS "pivot_x",
                   CAST((("%inputs%"."pivot_y")) AS int) AS "pivot_y",
                   CAST((("%inputs%"."slope")) AS float) AS "slope",
                   CAST((("%inputs%"."well")) AS struct(x int, y int, yield int)) AS "well",
                   CAST((("%inputs%"."yield") + ("%inputs%"."cost")) AS int) AS "yield"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter6', "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter6"("%kind%", "%label%", "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield", "%result%") AS (
        WITH
          "%inputs%"("cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield") AS (
            SELECT "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield"
            FROM   "merge0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter6'
          ),
          "%assign%"("cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield", "condition%1") AS (
            SELECT CAST((("%inputs%"."cost")) AS float) AS "cost",
                   CAST((("%inputs%"."current")) AS struct(x int, y int, cost int, slope float)) AS "current",
                   CAST((("%inputs%"."pivot_x")) AS int) AS "pivot_x",
                   CAST((("%inputs%"."pivot_y")) AS int) AS "pivot_y",
                   CAST((("%inputs%"."slope")) AS float) AS "slope",
                   CAST((("%inputs%"."well")) AS struct(x int, y int, yield int)) AS "well",
                   CAST((("%inputs%"."yield")) AS int) AS "yield",
                   CAST((("%inputs%"."well") IS NULL OR ("%inputs%"."yield") > ("%inputs%"."well").yield) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'truthy1', "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1"
          UNION ALL
        SELECT 'jump', 'loop_head', "cost", "current", "pivot_x", "pivot_y", "slope", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
      ),
      "truthy1"("%kind%", "%label%", "cost", "pivot_x", "pivot_y", "slope", "well", "yield", "%result%") AS (
        WITH
          "%inputs%"("cost", "current", "pivot_x", "pivot_y", "slope", "yield") AS (
            SELECT "cost", "current", "pivot_x", "pivot_y", "slope", "yield"
            FROM   "inter6"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          ),
          "%assign%"("cost", "pivot_x", "pivot_y", "slope", "well", "yield") AS (
            SELECT CAST((("%inputs%"."cost")) AS float) AS "cost",
                   CAST((("%inputs%"."pivot_x")) AS int) AS "pivot_x",
                   CAST((("%inputs%"."pivot_y")) AS int) AS "pivot_y",
                   CAST((("%inputs%"."slope")) AS float) AS "slope",
                   CAST(({x: ("%inputs%"."current").x, y: ("%inputs%"."current").y, yield: ("%inputs%"."yield")}) AS struct(x int, y int, yield int)) AS "well",
                   CAST((("%inputs%"."yield")) AS int) AS "yield"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "cost", "pivot_x", "pivot_y", "slope", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "cost", "pivot_x", "pivot_y", "slope", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
     FROM   "inter6"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "cost", "pivot_x", "pivot_y", "slope", "well", "yield", CAST(NULL AS struct(x int, y int, yield int))
     FROM   "truthy1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS float), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS float), CAST(NULL AS struct(x int, y int, yield int)), CAST(NULL AS int), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS oil(well);
