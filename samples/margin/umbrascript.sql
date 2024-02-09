CREATE FUNCTION margin(orderkey int) RETURNS float
AS
$$
  let mut margin   : float;
  let mut cheapest : float;
  let mut pmargin  : float;

  margin = 0;

  SELECT l.l_extendedprice * (1 - l.l_discount) * (1 + l.l_tax) AS part1_price, l.l_partkey AS part1_partkey
  FROM   lineitem AS l
  WHERE  l.l_orderkey = orderkey
  {
    cheapest = part1_price;
    pmargin  = 0;

    SELECT l.l_extendedprice * (1 - l.l_discount) * (1 + l.l_tax) AS part2_price, l.l_partkey AS part2_partkey
    FROM   lineitem AS l
    WHERE  l.l_orderkey = orderkey
    {
      IF (part1_partkey = part2_partkey)
      {
        IF (part2_price < cheapest)
        {
          pmargin  = part1_price - part2_price;
          cheapest = part2_price;
        }
      }
    }

    margin = margin + pmargin;
  }

  RETURN margin;
$$ LANGUAGE umbrascript;
