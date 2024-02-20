SELECT clouds.c, giftwrap.hull
FROM   (VALUES (1), (2), (3)) AS clouds(c),
LATERAL (
WITH RECURSIVE run("rec?", "res", "cloud", "poh0_label", "poh_label", "poh_x", "poh_y") AS
(
     (SELECT True, NULL :: int, "poh0_1".cloud, "poh0_1".label, "poh0_1".label, "poh0_1".x, "poh0_1".y
     FROM (SELECT "p" AS "p"
                    FROM points AS "p"
                    WHERE "p"."cloud" = clouds.c
                    ORDER BY p.x
                    LIMIT 1
          ) AS "let1"("poh0_1"))
     UNION ALL
     (SELECT "result".*
     FROM run AS "run"("rec?", "res", "cloud", "poh0_label", "poh_label", "poh_x", "poh_y"),
          LATERAL
          (SELECT "yield5".*
          FROM LATERAL
               ((SELECT False,
                         "run"."poh_label" AS "result",
                         "run"."cloud",
                         "run"."poh0_label",
                         "run"."poh_label",
                         "run"."poh_x",
                         "run"."poh_y")
                    UNION ALL
                    (SELECT True, NULL :: int, "cloud", "poh0_label", "poh_3".label, "poh_3".x, "poh_3".y
                    FROM (SELECT p1
                                  FROM   points AS p1
                                  WHERE  p1.cloud = "run"."cloud"
                                  AND    p1.label <> "run"."poh_label"
                                  AND    NOT EXISTS (SELECT 1
                                                      FROM   points AS p2
                                                      WHERE  left_of(p2.x, p2.y, "run"."poh_x", "run"."poh_y", p1.x, p1.y)
                                                      AND    p2.cloud = "run"."cloud")
                         ) AS "let6"("poh_3")
                    WHERE ("poh_3".label = "poh0_label") IS DISTINCT FROM True)
               ) AS "yield5"
          ) AS "result"
     WHERE "run"."rec?")
)
SELECT "run"."res" AS "res"
FROM run AS "run"
WHERE NOT "run"."rec?"
) AS giftwrap(hull);
