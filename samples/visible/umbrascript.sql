CREATE FUNCTION visible(herex  float, herey float,
                        therex float, therey float,
                        resolution int) RETURNS bool
AS
$$
  let mut stepx     : float;
  let mut stepy     : float;
  let mut locx      : float;
  let mut locy      : float;
  let mut angle     : float;
  let mut max_angle : float;

  SELECT SUM(s.z * (2-dist)^2) / SUM((2-dist)^2) AS hhere
  FROM   surface AS s, LATERAL (SELECT (sqrt((s.x-herex)^2 + (s.y-herey)^2))) AS _(dist)
  WHERE  dist < 2
  {
    stepx = (therex - herex) / resolution;
    stepy = (therey - herey) / resolution;
    locx = herex;
    locy = herey;

    max_angle = NULL :: float;

    SELECT i
    FROM   generate_series(1, resolution) AS _(i)
    {
      locx = locx + stepx;
      locy = locy + stepy;

      SELECT SUM(s.z * (2-dist)^2) / SUM((2-dist)^2) AS hloc
      FROM   surface AS s, LATERAL (SELECT (sqrt((s.x-locx)^2 + (s.y-locy)^2))) AS _(dist)
      WHERE  dist < 2
      {
        angle = degrees(atan(hloc - hhere) / sqrt((locx - herex)^2 + (locy - herey)^2));

        IF (max_angle IS NULL OR angle > max_angle)
        {
          max_angle = angle;
        }
      }
    }
  }

  RETURN angle = max_angle;
$$ LANGUAGE umbrascript;
