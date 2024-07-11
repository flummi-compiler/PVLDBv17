#!/bin/python3
import os, duckdb, functools


DUCKDB_DB_FILE = os.environ["DUCKDB_DB_FILE"]
DB = duckdb.connect(DUCKDB_DB_FILE, read_only=True)


@functools.lru_cache(maxsize=None)
def giftwrap(cloud_id: int) -> tuple[int, list[int]]:
  poh = DB.execute(
    """
    SELECT p
    FROM   points AS p
    WHERE  p.cloud = $1
    ORDER BY p.x
    LIMIT 1
    """,
    [cloud_id]
  ).fetchone()[0]

  poh0_label = poh["label"]
  hull = []

  while True:
    hull.append(poh["label"])

    poh = DB.execute(
      """
      SELECT p1
      FROM   points AS p1
      WHERE  p1.cloud = $1
      AND    p1.label <> $2
      AND    NOT EXISTS (SELECT 1
                        FROM   points AS p2
                        WHERE  left_of(p2.x :: hugeint, p2.y :: hugeint,
                                       $3   :: hugeint, $4   :: hugeint,
                                       p1.x :: hugeint, p1.y :: hugeint)
                        AND    p2.cloud = $1)
      """,
      [cloud_id, poh["label"], poh["x"], poh["y"]]
    ).fetchone()[0]

    if poh["label"] == poh0_label:
      break

  return cloud_id, hull


if __name__ == "__main__":
  from multiprocessing import Pool

  with Pool() as p:
    results = p.map(
      giftwrap,
      range(1,4)
    )

    for cloud_id, hull in results:
      print(cloud_id, hull)
