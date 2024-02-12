CREATE OR REPLACE FUNCTION oil(pivot_x int, pivot_y int) RETURNS well AS
$$
  DECLARE
    slope      float := '-infinity';
    cost       float := '-infinity';
    yield      int;    -- running sum of deposit capacities
    current    bore;
    well       well;
  BEGIN
    -- we will always hit the deposit for the pivot
    yield := (SELECT abs(p.c)
              FROM   endpoints AS p
              WHERE  (p.x, p.y) = (pivot_x, pivot_y));

    LOOP
      -- find next endpoint in clock-wise rotation centered around pivot
      current := (SELECT  (e.x, e.y, actual_cost, rot) :: bore
                  FROM    endpoints AS e,
                  LATERAL (SELECT (e.x - pivot_x) :: float / (e.y - pivot_y),
                                  CASE WHEN pivot_y > e.y THEN -e.c ELSE e.c END) AS _(rot, actual_cost)
                  WHERE   e.y <> pivot_y
                  AND     (rot > slope OR rot = slope AND actual_cost < cost) -- rotate farther than last slope
                  ORDER BY rot, actual_cost DESC                              -- identify next endpoint
                  LIMIT 1);                                                   --   in clock-wise rotation

      -- if we cannot find another endpoint in this
      -- rotation, we have gone full circle: exit
      EXIT WHEN current IS NULL;

      slope := current.slope;
      cost  := current.cost;
      yield := yield + cost;

      -- did we find a new maximum yield?
      IF well IS NULL OR yield > well.yield THEN
        well := (current.x, current.y, yield) :: well;
      END IF;
    END LOOP;
    -- best endpoint and overall yield for this pivot
    RETURN well;
  END;
$$
LANGUAGE PLPGSQL;
