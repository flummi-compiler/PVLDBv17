SELECT starting_position, border.point
FROM   (VALUES (0,0), (0,1), (1,0), (1,1)) AS starting_position(x, y),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "current", "goal", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((starting_position.x, starting_position.y) AS vec2) AS "current",
            CAST(NULL AS vec2) AS "goal",
            CAST(NULL AS vec2) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "%loop%"("%kind%", "%label%", "current", "goal", "%result%") AS (
        SELECT * FROM "%loop%"
      ),
      "entry"("%kind%", "%label%", "current", "goal", "%result%") AS (
        WITH
          "%inputs%"("current", "goal") AS (
            SELECT "current", "goal"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("current", "goal") AS (
            SELECT CAST((("%inputs%"."current")) AS vec2) AS "current",
                   CAST((("%inputs%"."current")) AS vec2) AS "goal"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "current", "goal", CAST(NULL AS vec2)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "current", "direction", "goal", "%result%") AS (
        WITH
          "%inputs%"("current", "goal") AS (
            SELECT "current", "goal"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "current", "goal"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("current", "direction", "goal") AS (
            SELECT CAST((("%inputs%"."current")) AS vec2) AS "current",
                   CAST((SELECT d.dir
                         FROM   squares AS s NATURAL JOIN directions AS d
                         WHERE  s.xy = ("%inputs%"."current")) AS vec2) AS "direction",
                   CAST((("%inputs%"."goal")) AS vec2) AS "goal"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter1', "current", "direction", "goal", CAST(NULL AS vec2)
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS vec2), CAST(NULL AS vec2), CAST(NULL AS vec2),
               CAST((("%inputs%"."current")) AS vec2)
        FROM   "%inputs%"
      ),
      "inter1"("%kind%", "%label%", "current", "direction", "goal", "%result%") AS (
        WITH
          "%inputs%"("current", "direction", "goal") AS (
            SELECT "current", "direction", "goal"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter1'
          ),
          "%assign%"("current", "direction", "goal") AS (
            SELECT CAST((((("%inputs%"."current")).x + (("%inputs%"."direction")).x, (("%inputs%"."current")).y + (("%inputs%"."direction")).y) :: vec2) AS vec2) AS "current",
                   CAST((("%inputs%"."direction")) AS vec2) AS "direction",
                   CAST((("%inputs%"."goal")) AS vec2) AS "goal"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter3', "current", "direction", "goal", CAST(NULL AS vec2)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter3"("%kind%", "%label%", "current", "goal", "%result%") AS (
        WITH
          "%inputs%"("current", "direction", "goal") AS (
            SELECT "current", "direction", "goal"
            FROM   "inter1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter3'
          ),
          "%assign%"("current", "goal", "condition%0") AS (
            SELECT CAST((("%inputs%"."current")) AS vec2) AS "current",
                   CAST((("%inputs%"."goal")) AS vec2) AS "goal",
                   CAST((("%inputs%"."current") = ("%inputs%"."goal") OR ("%inputs%"."direction") IS NULL) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "current", "goal", CAST(NULL AS vec2)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
      )

     SELECT 'jump', "%label%", "current", "goal", CAST(NULL AS vec2)
     FROM   "inter3"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS vec2), CAST(NULL AS vec2), "%result%"
     FROM   "loop_head"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS border(point);
