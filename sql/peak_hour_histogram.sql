-- Prepare a histogram of the distribution of peak generation by hour
WITH hourly_sums AS (
  SELECT sum(watt_hours) as wh, date_trunc('hour', time) AS time_hour
  FROM series s
  JOIN registers r ON s.register_id = r.id
  WHERE r.name = 'gen'
  GROUP BY date_trunc('hour', time)
  -- for some reason using < is not filtering results, but using abs does
  HAVING abs(sum(watt_hours)) > 100
)
SELECT count(*), date_part('hour', hs.time_hour)
FROM (
  SELECT min(wh) AS wh, date(time_hour) AS date
  FROM hourly_sums
  GROUP BY date(time_hour)
  ORDER BY wh
) mins
JOIN hourly_sums hs
  ON mins.wh = hs.wh
  AND date(hs.time_hour) = date
GROUP BY date_part('hour', hs.time_hour)
ORDER BY date_part('hour', hs.time_hour)

-- avg hourly output for this month
SELECT abs(avg(sum_wh)) as avg_watt, date_part('hour', time_hour) as hour
FROM (
    SELECT sum(watt_hours) as sum_wh, date_trunc('hour', time) as time_hour
    FROM series s
    JOIN registers r
      ON r.id = s.register_id
    WHERE r.name = 'gen'
      AND date_part('month', time) = date_part('month', now())
      AND date_part('hour', time) BETWEEN 5 AND 22
    GROUP BY date_trunc('hour', time)
    ORDER BY date_trunc('hour', time)
    ) a
GROUP BY date_part('hour', time_hour)
ORDER BY date_part('hour', time_hour)

