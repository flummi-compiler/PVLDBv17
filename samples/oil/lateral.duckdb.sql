SELECT oil_inputs.x, oil_inputs.y, oil.well
FROM   endpoints AS oil_inputs,
LATERAL (
WITH RECURSIVE run("rec?",
                    "res",
                    "pivot_x",
                    "pivot_y",
                    "slope",
                    "cost",
                    "yield",
                    "current",
                    "well") AS
(
     (SELECT True,
               NULL :: struct(x int, y int, yield int),
               oil_inputs.x,
               oil_inputs.y,
               '-infinity' :: float AS "slope_1",
               '-infinity' :: float AS "cost_1",
               (SELECT abs("p"."c") AS "abs"
               FROM endpoints AS "p"
               WHERE ("p"."x" = oil_inputs.x AND "p"."y" = oil_inputs.y)) AS "yield_1",
               NULL :: struct(x int, y int, cost int, slope float) AS "current_4",
               NULL :: struct(x int, y int, yield int) AS "well")
     UNION ALL
     (SELECT "result".*
     FROM run AS "run"("rec?",
                         "res",
                         "pivot_x",
                         "pivot_y",
                         "slope",
                         "cost",
                         "yield",
                         "current",
                         "well"),
          LATERAL
          (SELECT "ifresult2".*
          FROM LATERAL
               (SELECT (SELECT  {x: e.x, y: e.y, cost: actual_cost, slope: rot}
                         FROM    endpoints AS e,
                         LATERAL (SELECT (e.x - "run"."pivot_x") :: float / (e.y - "run"."pivot_y"),
                                        CASE WHEN pivot_y > e.y THEN -e.c ELSE e.c END) AS _(rot, actual_cost)
                         WHERE   e.y <> "run"."pivot_y"
                         AND     (rot > "run"."slope" OR
                                   rot = "run"."slope" AND actual_cost < "run"."cost")
                         ORDER BY rot, actual_cost DESC
                         LIMIT 1)) AS "let0"("current_2"),
               LATERAL (SELECT "current_2" IS NULL AS "q3_2") AS "let1"("q3_2"),
               LATERAL
               ((SELECT False,
                         "well" AS "result",
                         "run"."pivot_x",
                         "run"."pivot_y",
                         "run"."slope",
                         "run"."cost",
                         "run"."yield",
                         "run"."current",
                         "run"."well"
                    WHERE NOT "q3_2" IS DISTINCT FROM True)
                    UNION ALL
                    (SELECT "ifresult8".*
                    FROM LATERAL
                         (SELECT "yield" + "current_2".cost AS "yield_4") AS "let6"("yield_4"),
                         LATERAL
                         (SELECT ("well" IS NULL OR "yield_4" > "well".yield) AS "q7_3") AS "let7"("q7_3"),
                         LATERAL
                         ((SELECT True,
                                   NULL :: struct(x int, y int, yield int),
                                   "pivot_x",
                                   "pivot_y",
                                   "current_2".slope,
                                   "current_2".cost,
                                   "yield_4",
                                   "current_2",
                                   ("current_2".x,
                                   "current_2".y,
                                   "yield_4") :: struct(x int, y int, yield int) AS "well_4"
                         WHERE NOT "q7_3" IS DISTINCT FROM True)
                         UNION ALL
                         (SELECT True,
                                   NULL :: struct(x int, y int, yield int),
                                   "pivot_x",
                                   "pivot_y",
                                   "current_2".slope,
                                   "current_2".cost,
                                   "yield_4",
                                   "current_2",
                                   "well"
                         WHERE "q7_3" IS DISTINCT FROM True)
                         ) AS "ifresult8"
                    WHERE "q3_2" IS DISTINCT FROM True)
               ) AS "ifresult2"
          ) AS "result"
     WHERE "run"."rec?")
)
SELECT "run"."res" AS "res"
FROM run AS "run"
WHERE NOT "run"."rec?";
) AS oil(well);
