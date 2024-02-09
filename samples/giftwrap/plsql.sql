CREATE OR REPLACE FUNCTION giftwrap(cloud_id int) RETURNS SETOF text AS
$$
  DECLARE
    poh0 points; -- initial point on hull
    poh  points;
    pout text;
  BEGIN
    -- poh0 is leftmost point in S (and is on the hull)
    poh0 := (SELECT p
             FROM   points AS p
             WHERE  p.cloud = cloud_id
             ORDER BY p.loc[0]
             LIMIT 1);
    poh := poh0;
    LOOP
      -- emit point on hull
      pout := poh.label;
      RETURN NEXT pout;
      -- find point p1 in S such that no point p2 in S is to the left of line poh—p1
      poh := (SELECT p1
              FROM   points AS p1
              WHERE  p1.label <> poh.label
              AND    p1.cloud = poh.cloud
              AND    NOT EXISTS (SELECT 1
                                 FROM   points AS p2
                                 WHERE  p2.cloud = poh.cloud
                                 AND    left_of(p2.loc, poh.loc, p1.loc)));
      EXIT WHEN poh = poh0;
    END LOOP;
    RETURN;
  END;
$$
LANGUAGE PLPGSQL;
