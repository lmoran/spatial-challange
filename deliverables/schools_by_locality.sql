SELECT ssc.ssc_code16, ssc.ssc_name16, COUNT(*) AS Schools
    FROM ssc_2016_aust ssc INNER JOIN schools_vic s ON ST_Within(s.geom, ssc.geom)
    GROUP BY ssc.ssc_name16, ssc.ssc_code16
    ORDER BY ssc.ssc_name16, ssc.ssc_code16;