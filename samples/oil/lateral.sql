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
            NULL :: well,
            oil_inputs.x,
            oil_inputs.y,
            '-infinity' :: float AS "slope_1",
            '-infinity' :: float AS "cost_1",
            (SELECT abs("p"."c") AS "abs"
              FROM endpoints AS "p"
              WHERE ("p"."x" = oil_inputs.x AND "p"."y" = oil_inputs.y)) AS "yield_1",
            NULL :: bore AS "current_4",
            NULL :: well AS "well")
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
                (WITH "let0"("current_2") AS MATERIALIZED (
                  SELECT (SELECT ("e"."x",
                                  "e"."y",
                                  "_"."actual_cost",
                                  "_"."rot") :: bore AS "row"
                          FROM endpoints AS "e",
                                LATERAL
                                (SELECT ("e"."x" - "pivot_x") :: float8
                                        /
                                        ("e"."y" - "pivot_y") AS "?column?",
                                        CASE WHEN "pivot_y" > "e"."y" THEN - "e"."c"
                                            ELSE "e"."c"
                                        END AS "c"
                                ) AS "_"("rot", "actual_cost")
                          WHERE ("e"."y" <> "pivot_y"
                                  AND
                                  ("_"."rot" > "slope"
                                  OR
                                  ("_"."rot" = "slope" AND ("_"."actual_cost") < "cost")))
                          ORDER BY ("_"."rot") ASC, ("_"."actual_cost") DESC
                          LIMIT 1)
                  ) SELECT * FROM "let0") AS "let0"("current_2"),
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
                        (SELECT ("current_2" :: bore).slope AS "slope_4"
                        ) AS "let4"("slope_4"),
                        LATERAL
                        (SELECT ("current_2" :: bore).cost AS "cost_4") AS "let5"("cost_4"),
                        LATERAL
                        (SELECT ("yield") + "cost_4" AS "yield_4") AS "let6"("yield_4"),
                        LATERAL
                        (SELECT ("well" IS NULL
                                OR
                                "yield_4" > (("well" :: well).yield)) AS "q7_3"
                        ) AS "let7"("q7_3"),
                        LATERAL
                        ((SELECT True,
                                NULL :: well,
                                "pivot_x",
                                "pivot_y",
                                "slope_4",
                                "cost_4",
                                "yield_4",
                                "current_2",
                                (("current_2" :: bore).x,
                                  ("current_2" :: bore).y,
                                  "yield_4") :: well AS "well_4"
                          WHERE NOT "q7_3" IS DISTINCT FROM True)
                          UNION ALL
                        (SELECT True,
                                NULL :: well,
                                "pivot_x",
                                "pivot_y",
                                "slope_4",
                                "cost_4",
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
WHERE NOT "run"."rec?"
) AS oil(well);
