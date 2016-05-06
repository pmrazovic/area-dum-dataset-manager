module StatisticQueries
	module Sections
		# time_slot_size needs to be less than hour and divisor of 60, e.g. 5 min, 10 min, 15 min, 20 min, 30 min...
		# days is array of their orders in week, e.g. [0,1,2,3] = [Sun, Mon, Tue, Wed]
		def self.total_check_ins_per_time_slot(section, start_datetime, end_datetime, time_slot_size, days)
	    sql = "SELECT time_slots.time_slot_start,
     							  time_slots.time_slot_end,
       							time_slots.time_slot_hour,
       							time_slots.time_slot_hour_part,
       							count(section_check_ins.check_in_id) AS total
						FROM (SELECT to_char(range1,'HH24:MI') AS time_slot_start,
	     									 to_char(range1 + (#{time_slot_size} * interval '1 minute'),'HH24:MI') AS time_slot_end,
	     									 (extract(hour FROM range1)) AS time_slot_hour,
	     									 (extract(minute FROM range1)::int / #{time_slot_size}) AS time_slot_hour_part
	     						FROM generate_series('1970-01-01 00:00','1970-01-01 23:#{time_slot_size*((60/time_slot_size)-1)}', '#{time_slot_size} min'::interval) AS range1) AS time_slots
						LEFT OUTER JOIN
								 (SELECT (extract(hour FROM timestamp)) AS time_slot_hour,
        								 (extract(minute FROM timestamp)::int / #{time_slot_size}) AS  time_slot_hour_part,
        								 check_ins.id AS check_in_id
           			 FROM check_ins
           			 WHERE section_id = #{section.id} AND extract(dow from timestamp) IN (#{days.join(', ')}) AND
                     	 timestamp >= TO_TIMESTAMP('#{start_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD') AND
                 			 timestamp <= TO_TIMESTAMP('#{end_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD')) AS section_check_ins
						ON time_slots.time_slot_hour = section_check_ins. time_slot_hour AND
							 time_slots.time_slot_hour_part = section_check_ins. time_slot_hour_part
						GROUP BY 1,2,3,4
						ORDER BY 3,4"
			return ActiveRecord::Base.connection.execute(sql)
		end

		def self.total_check_ins_per_day_of_week(section, start_datetime, end_datetime)
			sql = "SELECT days.day_order AS day_order,
						        CASE WHEN days.day_order=0 THEN 'Sunday'
			            			 WHEN days.day_order=1 THEN 'Monday'
			            			 WHEN days.day_order=2 THEN 'Tuesday'
						             WHEN days.day_order=3 THEN 'Wednesday'
						             WHEN days.day_order=4 THEN 'Thursday'
						             WHEN days.day_order=5 THEN 'Friday'
						             WHEN days.day_order=6 THEN 'Saturday'
			              END AS day_name,
									  count(section_check_ins.check_in_id) as total
						 FROM (SELECT range1 AS day_order 
									 FROM generate_series(0,6) AS range1) AS days
						 LEFT OUTER JOIN 
     							(SELECT extract(dow from timestamp) AS day_order,
	     										check_ins.id AS check_in_id
      						 FROM check_ins
      			 			 WHERE section_id = #{section.id} AND
             			 			 timestamp >= TO_TIMESTAMP('#{start_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD') AND
             			 			 timestamp <= TO_TIMESTAMP('#{end_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD')) as section_check_ins
									 ON days.day_order = section_check_ins.day_order
						 GROUP BY 1,2
						 ORDER BY 1"
      return ActiveRecord::Base.connection.execute(sql)
		end

		def self.avg_check_ins_per_time_slot(section, start_datetime, end_datetime, time_slot_size, days)
			sql = "SELECT  datetime_slots.time_slot_start,
										 datetime_slots.time_slot_end,
	                   datetime_slots.time_slot_hour,
        						 datetime_slots.time_slot_hour_part,
        						 AVG(COALESCE(group_checkin_counts.total,0.0)) AS mean,
        						 stddev_pop(COALESCE(group_checkin_counts.total,0.0)) AS stdev
						FROM (SELECT range1::date AS time_slot_date,
             						 (extract(hour FROM range1)) AS time_slot_hour,
             						 (extract(minute FROM range1)::int / #{time_slot_size}) AS time_slot_hour_part,
             						 to_char(range1,'HH24:MI') AS time_slot_start,
	     									 to_char(range1 + (#{time_slot_size} * interval '1 minute'),'HH24:MI') AS time_slot_end
      						FROM generate_series('#{start_datetime.strftime("%Y-%m-%d")} 00:00', '#{end_datetime.strftime("%Y-%m-%d")} 23:#{time_slot_size*((60/time_slot_size)-1)}', '#{time_slot_size} min'::interval) AS range1
      						WHERE extract(dow from range1) IN (#{days.join(', ')})) AS datetime_slots
						LEFT OUTER JOIN
      						(SELECT timestamp::timestamp::date AS date,
              						(extract(hour FROM timestamp)) AS hour,
              						(extract(minute FROM timestamp)::int / #{time_slot_size}) AS hour_slot,
              						count(*) AS total
       						FROM check_ins
       						WHERE section_id = #{section.id} AND 
             						extract(dow from timestamp) IN (#{days.join(', ')}) AND
             						timestamp >= TO_TIMESTAMP('#{start_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD') AND
             						timestamp <= TO_TIMESTAMP('#{end_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD')
									GROUP BY 1,2,3) AS group_checkin_counts
						ON datetime_slots.time_slot_date = group_checkin_counts.date AND 
   						 datetime_slots.time_slot_hour = group_checkin_counts.hour AND 
   						 datetime_slots.time_slot_hour_part = group_checkin_counts.hour_slot
						GROUP BY 1,2,3,4
						ORDER BY 1,2;"

			return ActiveRecord::Base.connection.execute(sql)
		end

		def self.avg_check_ins_per_day_of_week(section, start_datetime, end_datetime)
			sql = "SELECT day_slots.day_order AS day_order,
       							CASE WHEN day_slots.day_order=0 THEN 'Sunday'
            						 WHEN day_slots.day_order=1 THEN 'Monday'
            						 WHEN day_slots.day_order=2 THEN 'Tuesday'
	     									 WHEN day_slots.day_order=3 THEN 'Wednesday'
	     									 WHEN day_slots.day_order=4 THEN 'Thursday'
	     									 WHEN day_slots.day_order=5 THEN 'Friday'
	     									 WHEN day_slots.day_order=6 THEN 'Saturday'
										END AS day_name,
									  AVG(COALESCE(grouped_section_check_ins.total,0.0)) AS mean,
										STDDEV_POP(COALESCE(grouped_section_check_ins.total,0.0)) AS stdev
						FROM (SELECT range1::date AS day_slot_date,
	 											 extract(dow from range1) AS day_order
									FROM generate_series('#{start_datetime.strftime("%Y-%m-%d")}', '#{end_datetime.strftime("%Y-%m-%d")}', '1 day'::interval) AS range1) AS day_slots
						LEFT OUTER JOIN 
    						 (SELECT timestamp::date AS day_slot_date,
	     									 count(check_ins.id) AS total
      						FROM check_ins
    							WHERE section_id = #{section.id} AND
								 				timestamp >= TO_TIMESTAMP('#{start_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD') AND
								 				timestamp <= TO_TIMESTAMP('#{end_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD')
							    GROUP BY 1) as grouped_section_check_ins
						ON day_slots.day_slot_date = grouped_section_check_ins.day_slot_date
 						GROUP BY 1,2
 						ORDER BY 1;"

 			return ActiveRecord::Base.connection.execute(sql)
		end

		def self.check_ins_time_series(section, start_datetime, end_datetime, time_slot_size)
			sql = "SELECT datetime_slots.time_slot_date AS time_slot_date,
       							datetime_slots.time_slot_hour AS time_slot_hour,
       							datetime_slots.time_slot_hour_part AS time_slot_hour_part,
       							datetime_slots.time_slot_start AS time_slot_start,
       							datetime_slots.time_slot_end AS time_slot_end,
      							COALESCE(group_checkin_counts.total, 0) AS total
						FROM (SELECT range1::date AS time_slot_date,
				       					 (extract(hour FROM range1)) AS time_slot_hour,
				       					 (extract(minute FROM range1)::int / #{time_slot_size}) AS time_slot_hour_part,
				      					 to_char(range1,'HH24:MI') AS time_slot_start,
				      				   to_char(range1 + (#{time_slot_size} * interval '1 minute'),'HH24:MI') AS time_slot_end
    							FROM generate_series('#{start_datetime.strftime("%Y-%m-%d")} 00:00', '#{end_datetime.strftime("%Y-%m-%d")} 23:#{time_slot_size*((60/time_slot_size)-1)}', '#{time_slot_size} min'::interval) AS range1) AS datetime_slots
						LEFT OUTER JOIN 
   							 (SELECT timestamp::timestamp::date AS date,
												 (extract(hour FROM timestamp)) AS hour,
        								 (extract(minute FROM timestamp)::int / #{time_slot_size}) AS hour_slot,
        								  count(*) AS total
    							FROM check_ins
							    WHERE section_id = #{section.id} AND 
             						timestamp >= TO_TIMESTAMP('#{start_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD') AND
             						timestamp <= TO_TIMESTAMP('#{end_datetime.strftime("%Y-%m-%d")}', 'YYYY-MM-DD')
    							GROUP BY 1,2,3) AS group_checkin_counts
						ON datetime_slots.time_slot_date = group_checkin_counts.date AND 
						   datetime_slots.time_slot_hour = group_checkin_counts.hour AND 
						   datetime_slots.time_slot_hour_part = group_checkin_counts.hour_slot
						ORDER BY 1,2,3;"
			return ActiveRecord::Base.connection.execute(sql)
		end









	end
end