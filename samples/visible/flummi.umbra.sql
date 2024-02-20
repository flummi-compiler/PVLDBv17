SELECT x, visible."?"
FROM   range(100) AS _(x),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS float) AS "angle",
            CAST((x) AS float) AS "herex",
            CAST((0) AS float) AS "herey",
            CAST(NULL AS float) AS "hhere",
            CAST(NULL AS int) AS "i",
            CAST(NULL AS float) AS "locx",
            CAST(NULL AS float) AS "locy",
            CAST(NULL AS float) AS "max_angle",
            CAST((256) AS int) AS "resolution",
            CAST(NULL AS float) AS "stepx",
            CAST(NULL AS float) AS "stepy",
            CAST((x) AS float) AS "therex",
            CAST((99) AS float) AS "therey",
            CAST(NULL AS bool) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "%result%") AS (
        WITH
          "%inputs%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."herex")) AS float) AS "herex",
                   CAST((("%inputs%"."herey")) AS float) AS "herey",
                   CAST((SELECT SUM(s.z * (2-dist)^2) / SUM((2-dist)^2) AS hhere
                         FROM   surface AS s, LATERAL (SELECT (sqrt((s.x-("%inputs%"."herex"))^2 + (s.y-("%inputs%"."herey"))^2))) AS _(dist)
                         WHERE  dist < 2) AS float) AS "hhere",
                   CAST((1) AS int) AS "i",
                   CAST((("%inputs%"."herex")) AS float) AS "locx",
                   CAST((("%inputs%"."herey")) AS float) AS "locy",
                   CAST((NULL :: float) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST(((("%inputs%"."therex") - ("%inputs%"."herex")) / ("%inputs%"."resolution")) AS float) AS "stepx",
                   CAST(((("%inputs%"."therey") - ("%inputs%"."herey")) / ("%inputs%"."resolution")) AS float) AS "stepy",
                   CAST((("%inputs%"."therex")) AS float) AS "therex",
                   CAST((("%inputs%"."therey")) AS float) AS "therey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "%result%") AS (
        WITH
          "%inputs%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "condition%0") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."herex")) AS float) AS "herex",
                   CAST((("%inputs%"."herey")) AS float) AS "herey",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."locx")) AS float) AS "locx",
                   CAST((("%inputs%"."locy")) AS float) AS "locy",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."stepx")) AS float) AS "stepx",
                   CAST((("%inputs%"."stepy")) AS float) AS "stepy",
                   CAST((("%inputs%"."therex")) AS float) AS "therex",
                   CAST((("%inputs%"."therey")) AS float) AS "therey",
                   CAST((("%inputs%"."i") > ("%inputs%"."resolution")) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("angle", "max_angle") AS (
            SELECT "angle", "max_angle"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."angle") = ("%inputs%"."max_angle")) AS bool)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "%result%") AS (
        WITH
          "%inputs%"("herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT CAST((("%inputs%"."herex")) AS float) AS "herex",
                   CAST((("%inputs%"."herey")) AS float) AS "herey",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i") + 1) AS int) AS "i",
                   CAST((("%inputs%"."locx") + ("%inputs%"."stepx")) AS float) AS "locx",
                   CAST((("%inputs%"."locy") + ("%inputs%"."stepy")) AS float) AS "locy",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."stepx")) AS float) AS "stepx",
                   CAST((("%inputs%"."stepy")) AS float) AS "stepy",
                   CAST((("%inputs%"."therex")) AS float) AS "therex",
                   CAST((("%inputs%"."therey")) AS float) AS "therey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter8', "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter8"("%kind%", "%label%", "herex", "herey", "hhere", "hloc", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "%result%") AS (
        WITH
          "%inputs%"("herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter8'
          ),
          "%assign%"("herex", "herey", "hhere", "hloc", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT CAST((("%inputs%"."herex")) AS float) AS "herex",
                   CAST((("%inputs%"."herey")) AS float) AS "herey",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((SELECT SUM(s.z * (2-dist)^2) / SUM((2-dist)^2) AS hhere
                         FROM   surface AS s, LATERAL (SELECT (sqrt((s.x-("%inputs%"."locx"))^2 + (s.y-("%inputs%"."locy"))^2))) AS _(dist)
                         WHERE  dist < 2) AS float) AS "hloc",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."locx")) AS float) AS "locx",
                   CAST((("%inputs%"."locy")) AS float) AS "locy",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."stepx")) AS float) AS "stepx",
                   CAST((("%inputs%"."stepy")) AS float) AS "stepy",
                   CAST((("%inputs%"."therex")) AS float) AS "therex",
                   CAST((("%inputs%"."therey")) AS float) AS "therey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter9', "herex", "herey", "hhere", "hloc", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter9"("%kind%", "%label%", "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "%result%") AS (
        WITH
          "%inputs%"("herex", "herey", "hhere", "hloc", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT "herex", "herey", "hhere", "hloc", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey"
            FROM   "inter8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter9'
          ),
          "%assign%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT CAST((degrees(atan((("%inputs%"."hloc") - ("%inputs%"."hhere")) / sqrt((("%inputs%"."locx") - ("%inputs%"."herex")) ^ 2 + (("%inputs%"."locy") - ("%inputs%"."herey")) ^ 2)))) AS float) AS "angle",
                   CAST((("%inputs%"."herex")) AS float) AS "herex",
                   CAST((("%inputs%"."herey")) AS float) AS "herey",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."locx")) AS float) AS "locx",
                   CAST((("%inputs%"."locy")) AS float) AS "locy",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."stepx")) AS float) AS "stepx",
                   CAST((("%inputs%"."stepy")) AS float) AS "stepy",
                   CAST((("%inputs%"."therex")) AS float) AS "therex",
                   CAST((("%inputs%"."therey")) AS float) AS "therey"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter11', "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter11"("%kind%", "%label%", "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "%result%") AS (
        WITH
          "%inputs%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey"
            FROM   "inter9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter11'
          ),
          "%assign%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "condition%1") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."herex")) AS float) AS "herex",
                   CAST((("%inputs%"."herey")) AS float) AS "herey",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."locx")) AS float) AS "locx",
                   CAST((("%inputs%"."locy")) AS float) AS "locy",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."stepx")) AS float) AS "stepx",
                   CAST((("%inputs%"."stepy")) AS float) AS "stepy",
                   CAST((("%inputs%"."therex")) AS float) AS "therex",
                   CAST((("%inputs%"."therey")) AS float) AS "therey",
                   CAST((("%inputs%"."max_angle") IS NULL OR ("%inputs%"."angle") > ("%inputs%"."max_angle")) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'truthy1', "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1"
          UNION ALL
        SELECT 'jump', 'loop_head', "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
      ),
      "truthy1"("%kind%", "%label%", "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", "%result%") AS (
        WITH
          "%inputs%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT "angle", "herex", "herey", "hhere", "i", "locx", "locy", "resolution", "stepx", "stepy", "therex", "therey"
            FROM   "inter11"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          ),
          "%assign%"("angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."herex")) AS float) AS "herex",
                   CAST((("%inputs%"."herey")) AS float) AS "herey",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."locx")) AS float) AS "locx",
                   CAST((("%inputs%"."locy")) AS float) AS "locy",
                   CAST((("%inputs%"."angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."stepx")) AS float) AS "stepx",
                   CAST((("%inputs%"."stepy")) AS float) AS "stepy",
                   CAST((("%inputs%"."therex")) AS float) AS "therex",
                   CAST((("%inputs%"."therey")) AS float) AS "therey"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
     FROM   "inter11"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "angle", "herex", "herey", "hhere", "i", "locx", "locy", "max_angle", "resolution", "stepx", "stepy", "therex", "therey", CAST(NULL AS bool)
     FROM   "truthy1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS float), CAST(NULL AS float), CAST(NULL AS float), CAST(NULL AS float), CAST(NULL AS int), CAST(NULL AS float), CAST(NULL AS float), CAST(NULL AS float), CAST(NULL AS int), CAST(NULL AS float), CAST(NULL AS float), CAST(NULL AS float), CAST(NULL AS float), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS visible("?");
