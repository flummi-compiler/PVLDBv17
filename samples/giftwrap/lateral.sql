SELECT clouds.c, giftwrap.hull
FROM   (VALUES (1), (2), (3)) AS clouds(c),
LATERAL (
WITH RECURSIVE run("rec?", "res", "poh0", "poh") AS
(
     (SELECT True, NULL :: text, "poh0_1", "poh0_1"
     FROM (SELECT (SELECT "p" AS "p"
                    FROM points AS "p"
                    WHERE "p"."cloud" = clouds.c
                    ORDER BY (("p"."loc")[0]) ASC
                    LIMIT 1)
          ) AS "let1"("poh0_1"))
     UNION ALL
     (SELECT "result".*
     FROM run AS "run"("rec?", "res", "poh0", "poh"),
          LATERAL
          (SELECT "yield5".*
          FROM LATERAL
               ((SELECT False,
                         ("run"."poh").label AS "result",
                         "run"."poh0",
                         "run"."poh")
                    UNION ALL
                    (SELECT True, NULL :: text, "poh0", "poh_3"
                    FROM (SELECT (SELECT "p1" AS "p1"
                                   FROM points AS "p1"
                                   WHERE ("p1"."label" <> (("poh" :: points).label)
                                        AND
                                        "p1"."cloud" = (("poh" :: points).cloud)
                                        AND
                                        NOT EXISTS (SELECT 1 AS "?column?"
                                                  FROM points AS "p2"
                                                  WHERE ("p2"."cloud"
                                                            =
                                                            (("poh" :: points).cloud)
                                                            AND
                                                            left_of("p2"."loc",
                                                                 ("poh" :: points).loc,
                                                                 "p1"."loc"))))) AS "poh_3"
                         ) AS "let6"("poh_3")
                    WHERE ("poh_3" = "poh0") IS DISTINCT FROM True)
               ) AS "yield5"
          ) AS "result"
     WHERE "run"."rec?")
)
SELECT "run"."res" AS "res"
FROM run AS "run"
WHERE NOT "run"."rec?"
) AS giftwrap(hull);
