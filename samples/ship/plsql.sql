CREATE OR REPLACE FUNCTION preferred_shipmode(custkey int) RETURNS TEXT AS
$$
  DECLARE
    ground int;
    air    int;
    mail   int;
  BEGIN
    -- collect shipping mode statistics
    ground := (SELECT COUNT(*)
               FROM   lineitem AS l, orders AS o
               WHERE  l.l_orderkey = o.o_orderkey AND o.o_custkey = custkey
               AND    l.l_shipmode IN ('RAIL', 'TRUCK'));
    air :=    (SELECT COUNT(*)
               FROM   lineitem AS l, orders AS o
               WHERE  l.l_orderkey = o.o_orderkey AND o.o_custkey = custkey
               AND    l.l_shipmode IN ('AIR', 'REG AIR'));
    mail :=   (SELECT COUNT(*)
               FROM   lineitem AS l, orders AS o
               WHERE  l.l_orderkey = o.o_orderkey AND o.o_custkey = custkey
               AND    l.l_shipmode = 'MAIL');
    -- determine preferred shipping mode
    IF ground >= air AND ground >= mail THEN
      RETURN 'ground';
    ELSIF air >= ground AND air >= mail THEN
      RETURN 'air';
    ELSIF mail >= ground AND mail >= air THEN
      RETURN 'mail';
    END IF;
    -- not reached
    RETURN 'nothing';
  END;
$$
LANGUAGE PLPGSQL;
