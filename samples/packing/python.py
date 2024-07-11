#!/bin/python3
import os, duckdb, functools


DUCKDB_DB_FILE = os.environ["DUCKDB_DB_FILE"]
DB = duckdb.connect(DUCKDB_DB_FILE, read_only=True)


@functools.lru_cache(maxsize=None)
def pack_order(orderkey: int, capacity: int = 60) -> tuple[int, list[str]]:
  n, largest_part = DB.execute(
    """
    SELECT COUNT(DISTINCT l_linenumber), MAX(p.p_size)
    FROM   lineitem AS l, part AS p
    WHERE  l.l_orderkey = $1
    AND    l.l_partkey = p.p_partkey
    """,
    [orderkey]
  ).fetchone()

  # orderkey not found or container capacity sufficient to hold the largest part?
  if n == 0 or capacity < largest_part:
    return orderkey, []

  items  = (1 << n) - 1
  packed = 0
  packs  = []

  # iterate through all non-empty subsets of items
  subset = items & -items
  subsets = []

  while True:
    subsets.append(subset)
    subset = items & (subset - items)
    if items == subset: break

  # as long as there are still lineitems to pack...
  while packed != items:
    pack = DB.execute(
      """
      SELECT argmax(subset, size)
      FROM   (SELECT subset, SUM(p_size)
              FROM   UNNEST($2) AS _(subset),
                     lineitem AS l, part AS p
              WHERE  l_orderkey = $1
              AND    subset & $4 = 0
              AND    subset & (1 << l_linenumber - 1) <> 0
              AND    l_partkey = p_partkey
              GROUP BY subset) AS _(subset, size)
      WHERE   size <= $3
      """,
      [orderkey, subsets, capacity, packed]
    ).fetchone()[0]
    packs.append(f"{pack:0>{n}b}")
    packed |= pack

  return orderkey, packs


if __name__ == "__main__":
  from multiprocessing import Pool

  with Pool() as p:
    results = p.starmap(
      pack_order,
      DB.execute(
        """
        SELECT o.o_orderkey
        FROM   orders AS o
        """,
      ).fetchall()
    )

    for orderkey, packs in results:
      print(orderkey, packs)
