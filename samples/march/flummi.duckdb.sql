SELECT starting_position, border.point
FROM   (VALUES (0,0), (0,1), (1,0), (1,1)) AS starting_position(x, y),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "current_x", "current_y", "goal_x", "goal_y", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((starting_position.x) AS int) AS "current_x",
            CAST((starting_position.y) AS int) AS "current_y",
            CAST(NULL AS int) AS "goal_x",
            CAST(NULL AS int) AS "goal_y",
            CAST(NULL AS struct(x int, y int)) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "current_x", "current_y", "goal_x", "goal_y", "%result%") AS (
        WITH
          "%inputs%"("current_x", "current_y", "goal_x", "goal_y") AS (
            SELECT "current_x", "current_y", "goal_x", "goal_y"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("current_x", "current_y", "goal_x", "goal_y") AS (
            SELECT CAST((("%inputs%"."current_x")) AS int) AS "current_x",
                   CAST((("%inputs%"."current_y")) AS int) AS "current_y",
                   CAST((("%inputs%"."current_x")) AS int) AS "goal_x",
                   CAST((("%inputs%"."current_y")) AS int) AS "goal_y"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "current_x", "current_y", "goal_x", "goal_y", CAST(NULL AS struct(x int, y int))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter2"("%kind%", "%label%", "current_x", "current_y", "direction", "goal_x", "goal_y", "%result%") AS (
        WITH
          "%inputs%"("current_x", "current_y", "direction", "goal_x", "goal_y") AS (
            SELECT "current_x", "current_y", "direction", "goal_x", "goal_y"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter2'
          ),
          "%assign%"("current_x", "current_y", "direction", "goal_x", "goal_y") AS (
            SELECT CAST((("%inputs%"."current_x") + ("%inputs%"."direction").x) AS int) AS "current_x",
                   CAST((("%inputs%"."current_y") + ("%inputs%"."direction").y) AS int) AS "current_y",
                   CAST((("%inputs%"."direction")) AS struct(x int, y int)) AS "direction",
                   CAST((("%inputs%"."goal_x")) AS int) AS "goal_x",
                   CAST((("%inputs%"."goal_y")) AS int) AS "goal_y"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter4', "current_x", "current_y", "direction", "goal_x", "goal_y", CAST(NULL AS struct(x int, y int))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter4"("%kind%", "%label%", "current_x", "current_y", "goal_x", "goal_y", "%result%") AS (
        WITH
          "%inputs%"("current_x", "current_y", "direction", "goal_x", "goal_y") AS (
            SELECT "current_x", "current_y", "direction", "goal_x", "goal_y"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter4'
          ),
          "%assign%"("current_x", "current_y", "goal_x", "goal_y", "condition%0") AS (
            SELECT CAST((("%inputs%"."current_x")) AS int) AS "current_x",
                   CAST((("%inputs%"."current_y")) AS int) AS "current_y",
                   CAST((("%inputs%"."goal_x")) AS int) AS "goal_x",
                   CAST((("%inputs%"."goal_y")) AS int) AS "goal_y",
                   CAST((("%inputs%"."current_x") = ("%inputs%"."goal_x") AND ("%inputs%"."current_y") = ("%inputs%"."goal_y") OR ("%inputs%"."direction") IS NULL) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "current_x", "current_y", "goal_x", "goal_y", CAST(NULL AS struct(x int, y int))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
      ),
      "loop_head"("%kind%", "%label%", "current_x", "current_y", "direction", "goal_x", "goal_y", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("current_x", "current_y", "goal_x", "goal_y") AS MATERIALIZED (
            SELECT "current_x", "current_y", "goal_x", "goal_y"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "current_x", "current_y", "goal_x", "goal_y"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("current_x", "current_y", "direction", "goal_x", "goal_y") AS (
            SELECT CAST((("%inputs%"."current_x")) AS int) AS "current_x",
                   CAST((("%inputs%"."current_y")) AS int) AS "current_y",
                   CAST((SELECT d.dir
                         FROM   squares AS s NATURAL JOIN directions AS d
                         WHERE  s.x = ("%inputs%"."current_x")
                         AND    s.y = ("%inputs%"."current_y")) AS struct(x int, y int)) AS "direction",
                   CAST((("%inputs%"."goal_x")) AS int) AS "goal_x",
                   CAST((("%inputs%"."goal_y")) AS int) AS "goal_y"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter2', "current_x", "current_y", "direction", "goal_x", "goal_y", CAST(NULL AS struct(x int, y int))
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS struct(x int, y int)), CAST(NULL AS int), CAST(NULL AS int),
               CAST(((("%inputs%"."current_x"), ("%inputs%"."current_y"))) AS struct(x int, y int))
        FROM   "%inputs%"
      )

     SELECT 'jump', "%label%", "current_x", "current_y", "goal_x", "goal_y", CAST(NULL AS struct(x int, y int))
     FROM   "inter4"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), "%result%"
     FROM   "loop_head"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS border(point);
