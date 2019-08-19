# == Schema Information
#
# Table name: countries
#
#  name        :string       not null, primary key
#  continent   :string
#  area        :integer
#  population  :integer
#  gdp         :integer

require_relative './sqlzoo.rb'

# BONUS QUESTIONS: These problems require knowledge of aggregate
# functions. Attempt them after completing section 05.

def highest_gdp
  # Which countries have a GDP greater than every country in Europe? (Give the
  # name only. Some countries may have NULL gdp values)
  execute(<<-SQL)
    SELECT
      name
    FROM
      countries
    WHERE
      gdp > (
        SELECT
          MAX(gdp)
        FROM
          countries
        WHERE
          continent = 'Europe'
        GROUP BY
          continent
      );
  SQL
end

def largest_in_continent
  # Find the largest country (by area) in each continent. Show the continent,
  # name, and area.
  execute(<<-SQL)
    SELECT
      largest.continent, 
      largest.name, 
      largest.area
    FROM
      countries AS largest
    INNER JOIN (
      SELECT
        continent, MAX(area) AS max_area
      FROM
        countries
      GROUP BY
        continent
    ) AS largest_by_continent ON (largest.area = largest_by_continent.max_area
    AND largest.continent = largest_by_continent.continent)
  SQL
end

def large_neighbors
  # Some countries have populations more than three times that of any of their
  # neighbors (in the same continent). Give the countries and continents.
  execute(<<-SQL)
    SELECT
      large_neighbor.name, large_neighbor.continent
    FROM
      countries AS large_neighbor
    INNER JOIN (
      SELECT
        continent, MAX(population) AS second_largest_pop
      FROM
        countries
      WHERE
        name NOT IN (
          SELECT
            largest_countries.name
          FROM
            countries AS largest_countries
          INNER JOIN (
            SELECT
              continent, MAX(population) AS largest_pop
            FROM
              countries
            GROUP BY
              continent
          ) AS largest_by_continent ON largest_countries.continent = largest_by_continent.continent
          AND largest_countries.population = largest_by_continent.largest_pop
        )
      GROUP BY
        continent
    ) AS second_largest_neighbor ON large_neighbor.continent = second_largest_neighbor.continent
    WHERE
      large_neighbor.population > 3 * second_largest_neighbor.second_largest_pop
  SQL
end