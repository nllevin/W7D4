# == Schema Information
#
# Table name: stops
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: routes
#
#  num         :string       not null, primary key
#  company     :string       not null, primary key
#  pos         :integer      not null, primary key
#  stop_id     :integer

require_relative './sqlzoo.rb'

def num_stops
  # How many stops are in the database?
  execute(<<-SQL)
    SELECT
      COUNT(*)
    FROM
      stops;
  SQL
end

def craiglockhart_id
  # Find the id value for the stop 'Craiglockhart'.
  execute(<<-SQL)
    SELECT
      stops.id
    FROM
      stops
    WHERE
      stops.name = 'Craiglockhart';
  SQL
end

def lrt_stops
  # Give the id and the name for the stops on the '4' 'LRT' service.
  execute(<<-SQL)
    SELECT
      stops.id, stops.name
    FROM
      stops
    INNER JOIN
      routes ON routes.stop_id = stops.id
    WHERE
      routes.num = '4' AND routes.company = 'LRT';
  SQL
end

def connecting_routes
  # Consider the following query:
  #
  # SELECT
  #   company,
  #   num,
  #   COUNT(*)
  # FROM
  #   routes
  # WHERE
  #   stop_id = 149 OR stop_id = 53
  # GROUP BY
  #   company, num
  #
  # The query gives the number of routes that visit either London Road
  # (149) or Craiglockhart (53). Run the query and notice the two services
  # that link these stops have a count of 2. Add a HAVING clause to restrict
  # the output to these two routes.
  execute(<<-SQL)
    SELECT
      company,
      num,
      COUNT(*)
    FROM
      routes
    WHERE
      stop_id = 149 OR stop_id = 53
    GROUP BY
      company, num
    HAVING
      COUNT(*) = 2;
  SQL
end

def cl_to_lr
  # Consider the query:
  #
  # SELECT
  #   a.company,
  #   a.num,
  #   a.stop_id,
  #   b.stop_id
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # WHERE
  #   a.stop_id = 53
  #
  # Observe that b.stop_id gives all the places you can get to from
  # Craiglockhart, without changing routes. Change the query so that it
  # shows the services from Craiglockhart to London Road.
  execute(<<-SQL)
    SELECT
      a.company,
      a.num,
      a.stop_id,
      b.stop_id
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    WHERE
      a.stop_id = 53 AND b.stop_id = 149;
  SQL
end

def cl_to_lr_by_name
  # Consider the query:
  #
  # SELECT
  #   a.company,
  #   a.num,
  #   stopa.name,
  #   stopb.name
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # JOIN
  #   stops stopa ON (a.stop_id = stopa.id)
  # JOIN
  #   stops stopb ON (b.stop_id = stopb.id)
  # WHERE
  #   stopa.name = 'Craiglockhart'
  #
  # The query shown is similar to the previous one, however by joining two
  # copies of the stops table we can refer to stops by name rather than by
  # number. Change the query so that the services between 'Craiglockhart' and
  # 'London Road' are shown.
  execute(<<-SQL)
    SELECT
      a.company,
      a.num,
      stopa.name,
      stopb.name
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    JOIN
      stops stopa ON (a.stop_id = stopa.id)
    JOIN
      stops stopb ON (b.stop_id = stopb.id)
    WHERE
      stopa.name = 'Craiglockhart' AND stopb.name = 'London Road';
  SQL
end

def haymarket_and_leith
  # Give the company and num of the services that connect stops
  # 115 and 137 ('Haymarket' and 'Leith')
  execute(<<-SQL)
    SELECT DISTINCT
      a.company, a.num
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    WHERE
      a.stop_id = 115 AND b.stop_id = 137;
  SQL
end

def craiglockhart_and_tollcross
  # Give the company and num of the services that connect stops
  # 'Craiglockhart' and 'Tollcross'
  execute(<<-SQL)
    SELECT
      routes_a.company, routes_a.num
    FROM
      routes AS routes_a
    INNER JOIN
      routes AS routes_b ON (routes_a.company = routes_b.company AND routes_a.num = routes_b.num)
    INNER JOIN
      stops AS stops_a ON stops_a.id = routes_a.stop_id
    INNER JOIN
      stops AS stops_b ON stops_b.id = routes_b.stop_id
    WHERE
      stops_a.name = 'Craiglockhart' AND stops_b.name = 'Tollcross';
  SQL
end

def start_at_craiglockhart
  # Give a distinct list of the stops that can be reached from 'Craiglockhart'
  # by taking one bus, including 'Craiglockhart' itself. Include the stop name,
  # as well as the company and bus no. of the relevant service.
  execute(<<-SQL)
    SELECT
      stops_b.name, routes_b.company, routes_b.num
    FROM
      routes AS routes_a
    INNER JOIN
      routes AS routes_b ON (routes_a.company = routes_b.company AND routes_a.num = routes_b.num)
    INNER JOIN
      stops AS stops_a ON routes_a.stop_id = stops_a.id
    INNER JOIN
      stops AS stops_b ON routes_b.stop_id = stops_b.id
    WHERE
      stops_a.name = 'Craiglockhart';
  SQL
end

def craiglockhart_to_sighthill
  # Find the routes involving two buses that can go from Craiglockhart to
  # Sighthill. Show the bus no. and company for the first bus, the name of the
  # stop for the transfer, and the bus no. and company for the second bus.
  execute(<<-SQL)
    SELECT DISTINCT
      routes_1.num, routes_1.company, 
      trans_stops.name,
      routes_2.num, routes_2.company
    FROM
      routes AS routes_1
    INNER JOIN
      routes AS trans_routes ON 
        (routes_1.company = trans_routes.company AND routes_1.num = trans_routes.num)
    INNER JOIN
      stops AS trans_stops ON trans_stops.id = trans_routes.stop_id
    INNER JOIN
      stops AS stops_1 ON stops_1.id = routes_1.stop_id
    INNER JOIN
      SELECT
    
  SQL
end

      # WHERE
      # stops_1.name = 'Craiglockhart' AND trans_stops.name IN (
      #   SELECT
      #     stops_3.name
      #   FROM
      #     stops AS stops_3
      #   INNER JOIN
      #     routes AS routes_3 ON routes_3.stop_id = stops_3.id
      #   INNER JOIN
      #     routes AS routes_4 ON 
      #       (routes_3.company = routes_4.company AND routes_3.num = routes_4.num)
      #   INNER JOIN
      #     stops AS stops_4 ON stops_4.id = routes_4.stop_id
      #   WHERE
      #     stops_4.name = 'Sighthill'
      # );


    #     INNER JOIN
    #   stops AS stops_2 ON stops_2.id = routes_2.stop_id
    # WHERE
    #   stops_1.name = 'Craiglockhart' AND 
    #   stops_2.name = 'Sighthill' AND
    #   trans_stops_1.name = trans_stops_2.name;