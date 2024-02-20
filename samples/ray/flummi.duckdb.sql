SELECT E'P3\n' || width :: text || ' ' || height :: text || E'\n255\n' ||
       (SELECT string_agg(
                lpad(((cast_ray.color).r * 255) :: text, 3, ' ') || ' ' ||
                lpad(((cast_ray.color).g * 255) :: text, 3, ' ') || ' ' ||
                lpad(((cast_ray.color).b * 255) :: text, 3, ' '),
                E'\n'
                ORDER BY (pixel_y, pixel_x)
               )
        FROM   (
            SELECT  (x) :: int AS "pixel_x",
                    (y) :: int AS "pixel_y",
                    (0.0) :: double AS "origin_x",
                    (0.0) :: double AS "origin_y",
                    (-4.5) :: double AS "origin_z",
                    (direction.x) :: double AS "direction_x",
                    (direction.y) :: double AS "direction_y",
                    (direction.z) :: double AS "direction_z",
                    (true) :: bool AS "shadows",
                    (10) :: int AS "max_rec_depth",
                    (0.000001) :: double AS "epsilon",
                    greatest(
                      (((2*abs(width/2 - x))^2)*100/(width^2)),
                      (((2*abs(height/2 - y))^2)*100/(height^2))
                    ) :: numeric AS "proportion"
            FROM    (SELECT 512         AS width,
                            512         AS height,
                            radians(50) AS fov
                    ) AS "constants"(width,height,fov),
            LATERAL (SELECT vec.sub(
                              vec.make(0.0, 0.0,  0.0), -- looking at
                              vec.make(0.0, 0.0, -4.5)  -- camera position
                            ) AS rot_z,
                            vec.cross(
                              vec.make(0.0, 1.0,  0.0), -- up vector
                              rot_z
                            ) AS rot_x,
                            vec.cross(rot_z, rot_x)  AS rot_y
                    ) AS "camera rotation"(rot_z, rot_x, rot_y),
            LATERAL (SELECT unnest(range(width ))) AS "xs"("x"),
            LATERAL (SELECT unnest(range(height))) AS "ys"("y"),
            LATERAL (SELECT sin((((x + 0.5) / width ) - 0.5) * fov * (width / height))) AS "_x"("offset_x"),
            LATERAL (SELECT sin((((y + 0.5) / height) - 0.5) * fov                   )) AS "_y"("offset_y"),
            LATERAL (SELECT vec.add(
                              vec.add(
                                vec.mul(
                                  vec.norm(rot_x),
                                  offset_x
                                ),
                                vec.mul(
                                  vec.norm(rot_y),
                                  offset_y
                                )
                              ),
                              vec.norm(rot_z)
                            ) AS "direction"
                    ) AS "transient"
        ) AS ray_inputs,
        LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS real) AS "color_b",
            CAST(NULL AS real) AS "color_g",
            CAST(NULL AS real) AS "color_r",
            CAST((ray_inputs.direction_x) AS real) AS "direction_x",
            CAST((ray_inputs.direction_y) AS real) AS "direction_y",
            CAST((ray_inputs.direction_z) AS real) AS "direction_z",
            CAST((ray_inputs.epsilon) AS real) AS "epsilon",
            CAST(NULL AS int) AS "id",
            CAST(NULL AS real) AS "light_x",
            CAST(NULL AS real) AS "light_y",
            CAST(NULL AS real) AS "light_z",
            CAST(NULL AS material) AS "material",
            CAST((ray_inputs.max_rec_depth) AS int) AS "max_rec_depth",
            CAST(NULL AS real) AS "min_dist",
            CAST(NULL AS real) AS "normal_x",
            CAST(NULL AS real) AS "normal_y",
            CAST(NULL AS real) AS "normal_z",
            CAST((ray_inputs.origin_x) AS real) AS "origin_x",
            CAST((ray_inputs.origin_y) AS real) AS "origin_y",
            CAST((ray_inputs.origin_z) AS real) AS "origin_z",
            CAST(NULL AS real) AS "pixel_b",
            CAST(NULL AS real) AS "pixel_g",
            CAST(NULL AS real) AS "pixel_r",
            CAST(NULL AS bool) AS "shadow_ray",
            CAST((ray_inputs.shadows) AS bool) AS "shadows",
            CAST(NULL AS int) AS "step",
            CAST(NULL AS struct(r real, g real, b real)) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((SELECT s FROM spheres AS s WHERE material = 'l') AS sphere) AS "light",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((0) AS real) AS "pixel_b",
                   CAST((0) AS real) AS "pixel_g",
                   CAST((0) AS real) AS "pixel_r",
                   CAST((false) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((0) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey0"("%kind%", "%label%", "P_x", "P_y", "P_z", "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter29"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("P_x", "P_y", "P_z", "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."P_x")) AS real) AS "P_x",
                   CAST((("%inputs%"."P_y")) AS real) AS "P_y",
                   CAST((("%inputs%"."P_z")) AS real) AS "P_z",
                   CAST((("%inputs%"."origin_x") - ("%inputs%"."triangle").p1_x) AS real) AS "T1_x",
                   CAST((("%inputs%"."origin_y") - ("%inputs%"."triangle").p1_y) AS real) AS "T1_y",
                   CAST((("%inputs%"."origin_z") - ("%inputs%"."triangle").p1_z) AS real) AS "T1_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."det")) AS real) AS "det",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter30', "P_x", "P_y", "P_z", "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey1"("%kind%", "%label%", "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "%result%") AS (
        WITH
          "%inputs%"("T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u") AS (
            SELECT "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u"
            FROM   "inter32"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
          ),
          "%assign%"("Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u") AS (
            SELECT CAST((("%inputs%"."T1_y") * ("%inputs%"."e1_z") - ("%inputs%"."T1_z") * ("%inputs%"."e1_y")) AS real) AS "Q_x",
                   CAST((("%inputs%"."T1_z") * ("%inputs%"."e1_x") - ("%inputs%"."T1_x") * ("%inputs%"."e1_z")) AS real) AS "Q_y",
                   CAST((("%inputs%"."T1_x") * ("%inputs%"."e1_y") - ("%inputs%"."T1_y") * ("%inputs%"."e1_x")) AS real) AS "Q_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."det")) AS real) AS "det",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST((("%inputs%"."u")) AS real) AS "u"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter34', "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey10"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter64"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey10'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter66"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey10'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "truthy9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey10'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter61"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey10'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id") - 1) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'jump', 'sphere_loop_head', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey2"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter36"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey2'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST(((("%inputs%"."e2_x") * ("%inputs%"."Q_x") + ("%inputs%"."e2_y") * ("%inputs%"."Q_y") + ("%inputs%"."e2_z") * ("%inputs%"."Q_z")) / ("%inputs%"."det")) AS real) AS "dist",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter38', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey3"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "max_rec_depth", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "max_rec_depth", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter38"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey3'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."triangle").material) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."e2_y") * ("%inputs%"."e1_z") - ("%inputs%"."e2_z") * ("%inputs%"."e1_y")) AS real) AS "normal_x",
                   CAST((("%inputs%"."e2_z") * ("%inputs%"."e1_x") - ("%inputs%"."e2_x") * ("%inputs%"."e1_z")) AS real) AS "normal_y",
                   CAST((("%inputs%"."e2_x") * ("%inputs%"."e1_y") - ("%inputs%"."e2_y") * ("%inputs%"."e1_x")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter39', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey6"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "truthy5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "truthy4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter36"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter29"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter32"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter44"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter38"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey6'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id") - 1) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'jump', 'triangle_loop_head', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey7"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "thc", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca") AS (
            SELECT "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca"
            FROM   "inter61"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey7'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "thc") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."tca")) AS real) AS "tca",
                   CAST((sqrt(("%inputs%"."sphere").radius ** 2 - ("%inputs%"."d2"))) AS real) AS "thc"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter63', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "thc", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey8"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "max_rec_depth", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "max_rec_depth", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step"
            FROM   "inter64"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey8'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."sphere").material) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."direction_x") * ("%inputs%"."dist") - ("%inputs%"."sphere").center_x + ("%inputs%"."origin_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."direction_y") * ("%inputs%"."dist") - ("%inputs%"."sphere").center_y + ("%inputs%"."origin_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."direction_z") * ("%inputs%"."dist") - ("%inputs%"."sphere").center_z + ("%inputs%"."origin_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter65', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light").center_x) AS real) AS "light_x",
                   CAST((("%inputs%"."light").center_y) AS real) AS "light_y",
                   CAST((("%inputs%"."light").center_z) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'ray_loop_head', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter103"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "u") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "u"
            FROM   "truthy16"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter103'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "condition%0") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x") - ("%inputs%"."normal_x") * ("%inputs%"."u")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y") - ("%inputs%"."normal_y") * ("%inputs%"."u")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z") - ("%inputs%"."normal_z") * ("%inputs%"."u")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."step") < ("%inputs%"."max_rec_depth")) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy17', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "inter19"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "triangle_loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter19'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."triangle").p2_x - ("%inputs%"."triangle").p1_x) AS real) AS "e1_x",
                   CAST((("%inputs%"."triangle").p2_y - ("%inputs%"."triangle").p1_y) AS real) AS "e1_y",
                   CAST((("%inputs%"."triangle").p2_z - ("%inputs%"."triangle").p1_z) AS real) AS "e1_z",
                   CAST((("%inputs%"."triangle").p3_x - ("%inputs%"."triangle").p1_x) AS real) AS "e2_x",
                   CAST((("%inputs%"."triangle").p3_y - ("%inputs%"."triangle").p1_y) AS real) AS "e2_y",
                   CAST((("%inputs%"."triangle").p3_z - ("%inputs%"."triangle").p1_z) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter20', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter20"("%kind%", "%label%", "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter19"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter20'
          ),
          "%assign%"("P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."direction_y") * ("%inputs%"."e2_z") - ("%inputs%"."direction_z") * ("%inputs%"."e2_y")) AS real) AS "P_x",
                   CAST((("%inputs%"."direction_z") * ("%inputs%"."e2_x") - ("%inputs%"."direction_x") * ("%inputs%"."e2_z")) AS real) AS "P_y",
                   CAST((("%inputs%"."direction_x") * ("%inputs%"."e2_y") - ("%inputs%"."direction_y") * ("%inputs%"."e2_x")) AS real) AS "P_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter21', "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter21"("%kind%", "%label%", "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter20"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter21'
          ),
          "%assign%"("P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."P_x")) AS real) AS "P_x",
                   CAST((("%inputs%"."P_y")) AS real) AS "P_y",
                   CAST((("%inputs%"."P_z")) AS real) AS "P_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."e1_x") * ("%inputs%"."P_x") + ("%inputs%"."e1_y") * ("%inputs%"."P_y") + ("%inputs%"."e1_z") * ("%inputs%"."P_z")) AS real) AS "det",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter29', "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter29"("%kind%", "%label%", "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter21"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter29'
          ),
          "%assign%"("P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "condition%1", "condition%2") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."P_x")) AS real) AS "P_x",
                   CAST((("%inputs%"."P_y")) AS real) AS "P_y",
                   CAST((("%inputs%"."P_z")) AS real) AS "P_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."det")) AS real) AS "det",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST((abs(("%inputs%"."det")) <= ("%inputs%"."epsilon")) AS bool) AS "condition%1",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
          UNION ALL
        SELECT 'goto', 'falsey6', "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1" AND NOT "condition%2"
          UNION ALL
        SELECT 'goto', 'truthy6', "P_x", "P_y", "P_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1" AND "condition%2"
      ),
      "inter30"("%kind%", "%label%", "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "%result%") AS (
        WITH
          "%inputs%"("P_x", "P_y", "P_z", "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "P_x", "P_y", "P_z", "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter30'
          ),
          "%assign%"("T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u") AS (
            SELECT CAST((("%inputs%"."T1_x")) AS real) AS "T1_x",
                   CAST((("%inputs%"."T1_y")) AS real) AS "T1_y",
                   CAST((("%inputs%"."T1_z")) AS real) AS "T1_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."det")) AS real) AS "det",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST(((("%inputs%"."T1_x") * ("%inputs%"."P_x") + ("%inputs%"."T1_y") * ("%inputs%"."P_y") + ("%inputs%"."T1_z") * ("%inputs%"."P_z")) / ("%inputs%"."det")) AS real) AS "u"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter32', "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter32"("%kind%", "%label%", "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u") AS (
            SELECT "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u"
            FROM   "inter30"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter32'
          ),
          "%assign%"("T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "condition%3", "condition%4") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."T1_x")) AS real) AS "T1_x",
                   CAST((("%inputs%"."T1_y")) AS real) AS "T1_y",
                   CAST((("%inputs%"."T1_z")) AS real) AS "T1_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."det")) AS real) AS "det",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST((("%inputs%"."u")) AS real) AS "u",
                   CAST((("%inputs%"."u") NOT BETWEEN 0 AND 1) AS bool) AS "condition%3",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%4"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%3"
          UNION ALL
        SELECT 'goto', 'falsey6', "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%3" AND NOT "condition%4"
          UNION ALL
        SELECT 'goto', 'truthy6', "T1_x", "T1_y", "T1_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%3" AND "condition%4"
      ),
      "inter34"("%kind%", "%label%", "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "v", "%result%") AS (
        WITH
          "%inputs%"("Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u") AS (
            SELECT "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u"
            FROM   "falsey1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter34'
          ),
          "%assign%"("Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "v") AS (
            SELECT CAST((("%inputs%"."Q_x")) AS real) AS "Q_x",
                   CAST((("%inputs%"."Q_y")) AS real) AS "Q_y",
                   CAST((("%inputs%"."Q_z")) AS real) AS "Q_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."det")) AS real) AS "det",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST((("%inputs%"."u")) AS real) AS "u",
                   CAST(((("%inputs%"."direction_x") * ("%inputs%"."Q_x") + ("%inputs%"."direction_y") * ("%inputs%"."Q_y") + ("%inputs%"."direction_z") * ("%inputs%"."Q_z")) / ("%inputs%"."det")) AS real) AS "v"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter36', "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "v", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter36"("%kind%", "%label%", "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "v") AS (
            SELECT "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "u", "v"
            FROM   "inter34"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter36'
          ),
          "%assign%"("Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "condition%5", "condition%6") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."Q_x")) AS real) AS "Q_x",
                   CAST((("%inputs%"."Q_y")) AS real) AS "Q_y",
                   CAST((("%inputs%"."Q_z")) AS real) AS "Q_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."det")) AS real) AS "det",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST((0 > ("%inputs%"."v") OR ("%inputs%"."v") + ("%inputs%"."u") > 1) AS bool) AS "condition%5",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%6"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey2', "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%5"
          UNION ALL
        SELECT 'goto', 'falsey6', "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%5" AND NOT "condition%6"
          UNION ALL
        SELECT 'goto', 'truthy6', "Q_x", "Q_y", "Q_z", "color_b", "color_g", "color_r", "det", "direction_x", "direction_y", "direction_z", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%5" AND "condition%6"
      ),
      "inter38"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "falsey2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter38'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "condition%7", "condition%8") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."dist")) AS real) AS "dist",
                   CAST((("%inputs%"."e1_x")) AS real) AS "e1_x",
                   CAST((("%inputs%"."e1_y")) AS real) AS "e1_y",
                   CAST((("%inputs%"."e1_z")) AS real) AS "e1_z",
                   CAST((("%inputs%"."e2_x")) AS real) AS "e2_x",
                   CAST((("%inputs%"."e2_y")) AS real) AS "e2_y",
                   CAST((("%inputs%"."e2_z")) AS real) AS "e2_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST((("%inputs%"."dist") <= ("%inputs%"."epsilon") OR ("%inputs%"."dist") >= ("%inputs%"."min_dist")) AS bool) AS "condition%7",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%8"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey3', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%7"
          UNION ALL
        SELECT 'goto', 'falsey6', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%7" AND NOT "condition%8"
          UNION ALL
        SELECT 'goto', 'truthy6', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "e1_x", "e1_y", "e1_z", "e2_x", "e2_y", "e2_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%7" AND "condition%8"
      ),
      "inter39"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "falsey3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter39'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((sqrt(("%inputs%"."normal_x") ** 2 + ("%inputs%"."normal_y") ** 2 + ("%inputs%"."normal_z") ** 2)) AS real) AS "length",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter40', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter40"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter39"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter40'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x") / ("%inputs%"."length")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y") / ("%inputs%"."length")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z") / ("%inputs%"."length")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter44', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter44"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter40"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter44'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "condition%9", "condition%10", "condition%11") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST((("%inputs%"."normal_x") * ("%inputs%"."direction_x") + ("%inputs%"."normal_y") * ("%inputs%"."direction_y") + ("%inputs%"."normal_z") * ("%inputs%"."direction_z") > 0) AS bool) AS "condition%9",
                   CAST((("%inputs%"."material") = 'm') AS bool) AS "condition%10",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%11"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey6', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11"
          UNION ALL
        SELECT 'goto', 'truthy4', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%9"
          UNION ALL
        SELECT 'goto', 'truthy5', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%9" AND "condition%10"
          UNION ALL
        SELECT 'goto', 'truthy6', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%9" AND NOT "condition%10" AND "condition%11"
      ),
      "inter57"("%kind%", "%label%", "L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step"
            FROM   "sphere_loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter57'
          ),
          "%assign%"("L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT CAST((("%inputs%"."sphere").center_x - ("%inputs%"."origin_x")) AS real) AS "L_x",
                   CAST((("%inputs%"."sphere").center_y - ("%inputs%"."origin_y")) AS real) AS "L_y",
                   CAST((("%inputs%"."sphere").center_z - ("%inputs%"."origin_z")) AS real) AS "L_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter58', "L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter58"("%kind%", "%label%", "L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "%result%") AS (
        WITH
          "%inputs%"("L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT "L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step"
            FROM   "inter57"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter58'
          ),
          "%assign%"("L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca") AS (
            SELECT CAST((("%inputs%"."L_x")) AS real) AS "L_x",
                   CAST((("%inputs%"."L_y")) AS real) AS "L_y",
                   CAST((("%inputs%"."L_z")) AS real) AS "L_z",
                   CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."L_x") * ("%inputs%"."direction_x") + ("%inputs%"."L_y") * ("%inputs%"."direction_y") + ("%inputs%"."L_z") * ("%inputs%"."direction_z")) AS real) AS "tca"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter59', "L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter59"("%kind%", "%label%", "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "%result%") AS (
        WITH
          "%inputs%"("L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca") AS (
            SELECT "L_x", "L_y", "L_z", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca"
            FROM   "inter58"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter59'
          ),
          "%assign%"("color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."L_x") ** 2 + ("%inputs%"."L_y") ** 2 + ("%inputs%"."L_z") ** 2 - ("%inputs%"."tca") ** 2) AS real) AS "d2",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."tca")) AS real) AS "tca"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter61', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter61"("%kind%", "%label%", "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca") AS (
            SELECT "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca"
            FROM   "inter59"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter61'
          ),
          "%assign%"("color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "condition%12", "condition%13", "condition%14", "condition%15", "condition%16", "condition%17", "condition%18") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."d2")) AS real) AS "d2",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."tca")) AS real) AS "tca",
                   CAST((("%inputs%"."d2") > ("%inputs%"."sphere").radius ** 2) AS bool) AS "condition%12",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%13",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "condition%14",
                   CAST((("%inputs%"."material") <> 'l') AS bool) AS "condition%15",
                   CAST((("%inputs%"."material") = 'l') AS bool) AS "condition%16",
                   CAST((("%inputs%"."material") = 'm') AS bool) AS "condition%17",
                   CAST((("%inputs%"."material") = 'r') AS bool) AS "condition%18"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey10', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%12" AND NOT "condition%13"
          UNION ALL
        SELECT 'goto', 'falsey7', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%12"
          UNION ALL
        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%12" AND "condition%13" AND "condition%14" AND NOT "condition%15"
          UNION ALL
        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%12" AND "condition%13" AND NOT "condition%14" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18"
          UNION ALL
        SELECT 'goto', 'truthy12', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%12" AND "condition%13" AND "condition%14" AND "condition%15"
          UNION ALL
        SELECT 'goto', 'truthy13', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%12" AND "condition%13" AND NOT "condition%14" AND "condition%16"
          UNION ALL
        SELECT 'goto', 'truthy14', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%12" AND "condition%13" AND NOT "condition%14" AND NOT "condition%16" AND "condition%17"
          UNION ALL
        SELECT 'goto', 'truthy16', "color_b", "color_g", "color_r", "d2", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%12" AND "condition%13" AND NOT "condition%14" AND NOT "condition%16" AND NOT "condition%17" AND "condition%18"
      ),
      "inter63"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "thc") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "tca", "thc"
            FROM   "falsey7"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter63'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((least(("%inputs%"."tca") + ("%inputs%"."thc"), greatest(("%inputs%"."tca") - ("%inputs%"."thc"), 0))) AS real) AS "dist",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter64', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter64"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step"
            FROM   "inter63"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter64'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "condition%19", "condition%20", "condition%21", "condition%22", "condition%23", "condition%24", "condition%25") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."dist")) AS real) AS "dist",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."dist") NOT BETWEEN ("%inputs%"."epsilon") AND ("%inputs%"."min_dist")) AS bool) AS "condition%19",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%20",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "condition%21",
                   CAST((("%inputs%"."material") <> 'l') AS bool) AS "condition%22",
                   CAST((("%inputs%"."material") = 'l') AS bool) AS "condition%23",
                   CAST((("%inputs%"."material") = 'm') AS bool) AS "condition%24",
                   CAST((("%inputs%"."material") = 'r') AS bool) AS "condition%25"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey10', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%19" AND NOT "condition%20"
          UNION ALL
        SELECT 'goto', 'falsey8', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%19"
          UNION ALL
        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%19" AND "condition%20" AND "condition%21" AND NOT "condition%22"
          UNION ALL
        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%19" AND "condition%20" AND NOT "condition%21" AND NOT "condition%23" AND NOT "condition%24" AND NOT "condition%25"
          UNION ALL
        SELECT 'goto', 'truthy12', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%19" AND "condition%20" AND "condition%21" AND "condition%22"
          UNION ALL
        SELECT 'goto', 'truthy13', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%19" AND "condition%20" AND NOT "condition%21" AND "condition%23"
          UNION ALL
        SELECT 'goto', 'truthy14', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%19" AND "condition%20" AND NOT "condition%21" AND NOT "condition%23" AND "condition%24"
          UNION ALL
        SELECT 'goto', 'truthy16', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "dist", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%19" AND "condition%20" AND NOT "condition%21" AND NOT "condition%23" AND NOT "condition%24" AND "condition%25"
      ),
      "inter65"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step"
            FROM   "falsey8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter65'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((sqrt(("%inputs%"."normal_x") ** 2 + ("%inputs%"."normal_y") ** 2 + ("%inputs%"."normal_z") ** 2)) AS real) AS "length",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter66', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter66"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step"
            FROM   "inter65"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter66'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "condition%26", "condition%27", "condition%28", "condition%29", "condition%30", "condition%31", "condition%32") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x") / ("%inputs%"."length")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y") / ("%inputs%"."length")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z") / ("%inputs%"."length")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."sphere")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."material") = 'm') AS bool) AS "condition%26",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%27",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "condition%28",
                   CAST((("%inputs%"."material") <> 'l') AS bool) AS "condition%29",
                   CAST((("%inputs%"."material") = 'l') AS bool) AS "condition%30",
                   CAST((("%inputs%"."material") = 'm') AS bool) AS "condition%31",
                   CAST((("%inputs%"."material") = 'r') AS bool) AS "condition%32"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey10', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%26" AND NOT "condition%27"
          UNION ALL
        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%26" AND "condition%27" AND "condition%28" AND NOT "condition%29"
          UNION ALL
        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%26" AND "condition%27" AND NOT "condition%28" AND NOT "condition%30" AND NOT "condition%31" AND NOT "condition%32"
          UNION ALL
        SELECT 'goto', 'truthy12', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%26" AND "condition%27" AND "condition%28" AND "condition%29"
          UNION ALL
        SELECT 'goto', 'truthy13', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%26" AND "condition%27" AND NOT "condition%28" AND "condition%30"
          UNION ALL
        SELECT 'goto', 'truthy14', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%26" AND "condition%27" AND NOT "condition%28" AND NOT "condition%30" AND "condition%31"
          UNION ALL
        SELECT 'goto', 'truthy16', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%26" AND "condition%27" AND NOT "condition%28" AND NOT "condition%30" AND NOT "condition%31" AND "condition%32"
          UNION ALL
        SELECT 'goto', 'truthy9', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%26"
      ),
      "inter86"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step"
            FROM   "truthy14"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter86'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."light_x") - ("%inputs%"."origin_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."light_y") - ("%inputs%"."origin_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."light_z") - ("%inputs%"."origin_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter87', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter87"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step"
            FROM   "inter86"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter87'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((sqrt(("%inputs%"."direction_x") ** 2 + ("%inputs%"."direction_y") ** 2 + ("%inputs%"."direction_z") ** 2)) AS real) AS "length",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter88', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter88"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step"
            FROM   "inter87"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter88'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x") / ("%inputs%"."length")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y") / ("%inputs%"."length")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z") / ("%inputs%"."length")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter89', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter89"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "u", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step"
            FROM   "inter88"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter89'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "u") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((greatest(0, ("%inputs%"."direction_x") * ("%inputs%"."normal_x") + ("%inputs%"."direction_y") * ("%inputs%"."normal_y") + ("%inputs%"."direction_z") * ("%inputs%"."normal_z"))) AS real) AS "u"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter90', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "u", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter9"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "ray_loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter9'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x") / ("%inputs%"."length")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y") / ("%inputs%"."length")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z") / ("%inputs%"."length")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'triangle_loop_head', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter90"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadows", "step", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "u") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "u"
            FROM   "inter89"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter90'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadows", "step", "condition%33") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."color_b") * ("%inputs%"."u")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."color_g") * ("%inputs%"."u")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."color_r") * ("%inputs%"."u")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."shadows")) AS bool) AS "condition%33"
            FROM "%inputs%"
          )

        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%33"
          UNION ALL
        SELECT 'goto', 'truthy15', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%33"
      ),
      "ray_loop_exit"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("pixel_b", "pixel_g", "pixel_r") AS (
            SELECT "pixel_b", "pixel_g", "pixel_r"
            FROM   "truthy9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_exit'
              UNION ALL
            SELECT "pixel_b", "pixel_g", "pixel_r"
            FROM   "inter61"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_exit'
              UNION ALL
            SELECT "pixel_b", "pixel_g", "pixel_r"
            FROM   "inter64"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_exit'
              UNION ALL
            SELECT "pixel_b", "pixel_g", "pixel_r"
            FROM   "truthy12"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_exit'
              UNION ALL
            SELECT "pixel_b", "pixel_g", "pixel_r"
            FROM   "inter66"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_exit'
              UNION ALL
            SELECT "pixel_b", "pixel_g", "pixel_r"
            FROM   "inter90"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_exit'
              UNION ALL
            SELECT "pixel_b", "pixel_g", "pixel_r"
            FROM   "truthy13"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_exit'
              UNION ALL
            SELECT "pixel_b", "pixel_g", "pixel_r"
            FROM   "inter103"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_exit'
          )
        SELECT 'emit', NULL,
               CAST(({r: ("%inputs%"."pixel_r"), g: ("%inputs%"."pixel_g"), b: ("%inputs%"."pixel_b")}) AS struct(r real, g real, b real))
        FROM   "%inputs%"
      ),
      "ray_loop_head"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='ray_loop_head'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='ray_loop_head'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((SELECT MAX(t.id) FROM triangles AS t) AS int) AS "id",
                   CAST((sqrt(("%inputs%"."direction_x") ** 2 + ("%inputs%"."direction_y") ** 2 + ("%inputs%"."direction_z") ** 2)) AS real) AS "length",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST(('n') AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST(('Infinity' :: real) AS real) AS "min_dist",
                   CAST((0) AS real) AS "normal_x",
                   CAST((0) AS real) AS "normal_y",
                   CAST((0) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter9', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "length", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "sphere_loop_head"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='sphere_loop_head'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "truthy6"
            WHERE  "%kind%"='goto'
            AND    "%label%"='sphere_loop_head'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((SELECT t FROM spheres AS t WHERE t.id = ("%inputs%"."id")) AS sphere) AS "sphere",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter57', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "triangle_loop_head"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='triangle_loop_head'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='triangle_loop_head'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((SELECT t FROM triangles AS t WHERE t.id = ("%inputs%"."id")) AS triangle) AS "triangle"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter19', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy12"("%kind%", "%label%", "pixel_b", "pixel_g", "pixel_r", "%result%") AS (
        WITH
          "%inputs%"("%") AS (
            SELECT NULL
            FROM   "inter64"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy12'
              UNION ALL
            SELECT NULL
            FROM   "inter66"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy12'
              UNION ALL
            SELECT NULL
            FROM   "truthy9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy12'
              UNION ALL
            SELECT NULL
            FROM   "inter61"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy12'
          ),
          "%assign%"("pixel_b", "pixel_g", "pixel_r") AS (
            SELECT CAST((0) AS real) AS "pixel_b",
                   CAST((0) AS real) AS "pixel_g",
                   CAST((0) AS real) AS "pixel_r"
            FROM "%inputs%"
          )

        SELECT 'goto', 'ray_loop_exit', "pixel_b", "pixel_g", "pixel_r", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy13"("%kind%", "%label%", "pixel_b", "pixel_g", "pixel_r", "%result%") AS (
        WITH
          "%inputs%"("%") AS (
            SELECT NULL
            FROM   "inter64"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy13'
              UNION ALL
            SELECT NULL
            FROM   "inter66"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy13'
              UNION ALL
            SELECT NULL
            FROM   "truthy9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy13'
              UNION ALL
            SELECT NULL
            FROM   "inter61"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy13'
          ),
          "%assign%"("pixel_b", "pixel_g", "pixel_r") AS (
            SELECT CAST((1) AS real) AS "pixel_b",
                   CAST((1) AS real) AS "pixel_g",
                   CAST((1) AS real) AS "pixel_r"
            FROM "%inputs%"
          )

        SELECT 'goto', 'ray_loop_exit', "pixel_b", "pixel_g", "pixel_r", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy14"("%kind%", "%label%", "color_b", "color_g", "color_r", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step"
            FROM   "inter64"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy14'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step"
            FROM   "inter66"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy14'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step"
            FROM   "truthy9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy14'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step"
            FROM   "inter61"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy14'
          ),
          "%assign%"("color_b", "color_g", "color_r", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x") + ("%inputs%"."direction_x") * ("%inputs%"."min_dist") + ("%inputs%"."normal_x") * ("%inputs%"."epsilon")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y") + ("%inputs%"."direction_y") * ("%inputs%"."min_dist") + ("%inputs%"."normal_y") * ("%inputs%"."epsilon")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z") + ("%inputs%"."direction_z") * ("%inputs%"."min_dist") + ("%inputs%"."normal_z") * ("%inputs%"."epsilon")) AS real) AS "origin_z",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter86', "color_b", "color_g", "color_r", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy15"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadows", "step"
            FROM   "inter90"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy15'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((true) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'jump', 'ray_loop_head', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy16"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "u", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter64"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy16'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter66"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy16'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "truthy9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy16'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter61"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy16'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "u") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x") + ("%inputs%"."direction_x") * ("%inputs%"."min_dist") + ("%inputs%"."normal_x") * ("%inputs%"."epsilon")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y") + ("%inputs%"."direction_y") * ("%inputs%"."min_dist") + ("%inputs%"."normal_y") * ("%inputs%"."epsilon")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z") + ("%inputs%"."direction_z") * ("%inputs%"."min_dist") + ("%inputs%"."normal_z") * ("%inputs%"."epsilon")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((2 * (("%inputs%"."direction_x") * ("%inputs%"."normal_x") + ("%inputs%"."direction_y") * ("%inputs%"."normal_y") + ("%inputs%"."direction_z") * ("%inputs%"."normal_z"))) AS real) AS "u"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter103', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "u", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy17"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter103"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy17'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step") + 1) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'jump', 'ray_loop_head', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy4"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter44"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy4'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", "condition%34", "condition%35") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x") * -1) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y") * -1) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z") * -1) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."triangle")) AS triangle) AS "triangle",
                   CAST((("%inputs%"."material") = 'm') AS bool) AS "condition%34",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%35"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey6', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%34" AND NOT "condition%35"
          UNION ALL
        SELECT 'goto', 'truthy5', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%34"
          UNION ALL
        SELECT 'goto', 'truthy6', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%34" AND "condition%35"
      ),
      "truthy5"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle") AS (
            SELECT "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "inter44"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy5'
              UNION ALL
            SELECT "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "triangle"
            FROM   "truthy4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy5'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "condition%36") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."triangle").b) AS real) AS "color_b",
                   CAST((("%inputs%"."triangle").g) AS real) AS "color_g",
                   CAST((("%inputs%"."triangle").r) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%36"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey6', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%36"
          UNION ALL
        SELECT 'goto', 'truthy6', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%36"
      ),
      "truthy6"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS (
        WITH
          "%inputs%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "truthy5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "truthy4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter36"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter29"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter32"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter44"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy6'
              UNION ALL
            SELECT "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step"
            FROM   "inter38"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy6'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step") AS (
            SELECT CAST((("%inputs%"."color_b")) AS real) AS "color_b",
                   CAST((("%inputs%"."color_g")) AS real) AS "color_g",
                   CAST((("%inputs%"."color_r")) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((SELECT MAX(s.id) FROM spheres AS s) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step"
            FROM "%inputs%"
          )

        SELECT 'goto', 'sphere_loop_head', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy9"("%kind%", "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step") AS (
            SELECT "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "sphere", "step"
            FROM   "inter66"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy9'
          ),
          "%assign%"("color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", "condition%37", "condition%38", "condition%39", "condition%40", "condition%41", "condition%42") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."sphere").b) AS real) AS "color_b",
                   CAST((("%inputs%"."sphere").g) AS real) AS "color_g",
                   CAST((("%inputs%"."sphere").r) AS real) AS "color_r",
                   CAST((("%inputs%"."direction_x")) AS real) AS "direction_x",
                   CAST((("%inputs%"."direction_y")) AS real) AS "direction_y",
                   CAST((("%inputs%"."direction_z")) AS real) AS "direction_z",
                   CAST((("%inputs%"."epsilon")) AS real) AS "epsilon",
                   CAST((("%inputs%"."id")) AS int) AS "id",
                   CAST((("%inputs%"."light_x")) AS real) AS "light_x",
                   CAST((("%inputs%"."light_y")) AS real) AS "light_y",
                   CAST((("%inputs%"."light_z")) AS real) AS "light_z",
                   CAST((("%inputs%"."material")) AS material) AS "material",
                   CAST((("%inputs%"."max_rec_depth")) AS int) AS "max_rec_depth",
                   CAST((("%inputs%"."min_dist")) AS real) AS "min_dist",
                   CAST((("%inputs%"."normal_x")) AS real) AS "normal_x",
                   CAST((("%inputs%"."normal_y")) AS real) AS "normal_y",
                   CAST((("%inputs%"."normal_z")) AS real) AS "normal_z",
                   CAST((("%inputs%"."origin_x")) AS real) AS "origin_x",
                   CAST((("%inputs%"."origin_y")) AS real) AS "origin_y",
                   CAST((("%inputs%"."origin_z")) AS real) AS "origin_z",
                   CAST((("%inputs%"."pixel_b")) AS real) AS "pixel_b",
                   CAST((("%inputs%"."pixel_g")) AS real) AS "pixel_g",
                   CAST((("%inputs%"."pixel_r")) AS real) AS "pixel_r",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "shadow_ray",
                   CAST((("%inputs%"."shadows")) AS bool) AS "shadows",
                   CAST((("%inputs%"."step")) AS int) AS "step",
                   CAST((("%inputs%"."id") = 0) AS bool) AS "condition%37",
                   CAST((("%inputs%"."shadow_ray")) AS bool) AS "condition%38",
                   CAST((("%inputs%"."material") <> 'l') AS bool) AS "condition%39",
                   CAST((("%inputs%"."material") = 'l') AS bool) AS "condition%40",
                   CAST((("%inputs%"."material") = 'm') AS bool) AS "condition%41",
                   CAST((("%inputs%"."material") = 'r') AS bool) AS "condition%42"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey10', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%37"
          UNION ALL
        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%37" AND "condition%38" AND NOT "condition%39"
          UNION ALL
        SELECT 'goto', 'ray_loop_exit', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%37" AND NOT "condition%38" AND NOT "condition%40" AND NOT "condition%41" AND NOT "condition%42"
          UNION ALL
        SELECT 'goto', 'truthy12', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%37" AND "condition%38" AND "condition%39"
          UNION ALL
        SELECT 'goto', 'truthy13', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%37" AND NOT "condition%38" AND "condition%40"
          UNION ALL
        SELECT 'goto', 'truthy14', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%37" AND NOT "condition%38" AND NOT "condition%40" AND "condition%41"
          UNION ALL
        SELECT 'goto', 'truthy16', "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%37" AND NOT "condition%38" AND NOT "condition%40" AND NOT "condition%41" AND "condition%42"
      )

     SELECT 'jump', "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
     FROM   "falsey6"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
     FROM   "falsey10"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
     FROM   "truthy15"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "color_b", "color_g", "color_r", "direction_x", "direction_y", "direction_z", "epsilon", "id", "light_x", "light_y", "light_z", "material", "max_rec_depth", "min_dist", "normal_x", "normal_y", "normal_z", "origin_x", "origin_y", "origin_z", "pixel_b", "pixel_g", "pixel_r", "shadow_ray", "shadows", "step", CAST(NULL AS struct(r real, g real, b real))
     FROM   "truthy17"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS int), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS material), CAST(NULL AS int), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS real), CAST(NULL AS bool), CAST(NULL AS bool), CAST(NULL AS int), "%result%"
     FROM   "ray_loop_exit"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
        ) AS cast_ray(color)
       ) || E'\n' AS ppm
FROM   (SELECT
          512 AS width,
          512 AS height
       );
