CREATE FUNCTION giftwrap(cloud_id int) RETURNS text AS
$$
  let mut poh_label : int;
  let mut poh_x     : int;
  let mut poh_y     : int;
  let mut hull      : text;

  -- size of point cloud
  SELECT COUNT(*) :: int AS n
  FROM   points AS p
  WHERE  p.cloud = cloud_id;

  -- poh0 is leftmost point in S (and is on the hull)
  SELECT p.label AS poh0_label, p.x AS poh0_x, p.y AS poh0_y
  FROM   points AS p
  WHERE  p.cloud = cloud_id
  ORDER BY p.x
  LIMIT 1;

  poh_label = poh0_label;
  poh_x     = poh0_x;
  poh_y     = poh0_y;

  hull = 'p' || poh_label :: text;

  SELECT i FROM generate_series(1,n) AS _(i) {
    -- find point p1 in S such that no point p2 in S is to the left of line poh—p1
    SELECT p1.label AS poh1_label, p1.x AS poh1_x, p1.y AS poh1_y
    FROM   points AS p1
    WHERE  p1.label <> poh_label
    AND    p1.cloud = cloud_id
    AND    NOT EXISTS (SELECT 1
                       FROM   points AS p2
                       WHERE  (poh_x - p2.x) * (p1.y - p2.y) -
                              (poh_y - p2.y) * (p1.x - p2.x) > 0
                       AND    p2.cloud = cloud_id);

    poh_label = poh1_label;
    poh_x     = poh1_x;
    poh_y     = poh1_y;

    -- completed the tour around the cloud?
    if (poh_label = poh0_label) {
      break;
    }

    -- emit point on hull
    hull = hull || '|' || 'p' || poh_label :: text;
  }

  return hull;
$$ LANGUAGE umbrascript;
