SELECT
  "saref:Sensor"."id", "saref:Sensor"."status", floor, "datasheet"."minTemp", "datasheet"."maxTemp"
FROM
  "saref:Sensor", "assets", datasheet
WHERE
  id = assets."ID" AND datasheet."ID" = datasheet
ORDER BY
  floor
