# == Schema Information
#
# Table name: albums
#
#  asin        :string       not null, primary key
#  title       :string
#  artist      :string
#  price       :float
#  rdate       :date
#  label       :string
#  rank        :integer
#
# Table name: styles
#
# album        :string       not null
# style        :string       not null
#
# Table name: tracks
# album        :string       not null
# disk         :integer      not null
# posn         :integer      not null
# song         :string

require_relative './sqlzoo.rb'

def alison_artist
  # Select the name of the artist who recorded the song 'Alison'.
  execute(<<-SQL)
    SELECT
      albums.artist
    FROM
      albums
    INNER JOIN
      tracks ON albums.asin = tracks.album
    WHERE 
      tracks.song = 'Alison'
  SQL
end

def exodus_artist
  # Select the name of the artist who recorded the song 'Exodus'.
  execute(<<-SQL)
    SELECT
      albums.artist
    FROM
      albums
    INNER JOIN
      tracks ON albums.asin = tracks.album
    WHERE
      tracks.song = 'Exodus'
  SQL
end

def blur_songs
  # Select the `song` for each `track` on the album `Blur`.
  execute(<<-SQL)
    SELECT
      song
    FROM
      tracks
    INNER JOIN
      albums ON albums.asin = tracks.album
    WHERE
      albums.title = 'Blur'
  SQL
end

def heart_tracks
  # For each album show the title and the total number of tracks containing
  # the word 'Heart' (albums with no such tracks need not be shown). Order first by
  # the number of such tracks, then by album title.
  execute(<<-SQL)
    SELECT
      albums.title, COUNT(*) AS heart_count
    FROM
      albums
    INNER JOIN
      tracks ON albums.asin = tracks.album
    WHERE
      tracks.song LIKE '%Heart%'
    GROUP BY
      albums.title
    HAVING
      COUNT(*) > 0
    ORDER BY
      heart_count DESC, albums.title ASC
  SQL
end

def title_tracks
  # A 'title track' has a `song` that is the same as its album's `title`. Select
  # the names of all the title tracks.
  execute(<<-SQL)
    SELECT
      tracks.song
    FROM
      tracks
    INNER JOIN
      albums ON tracks.album = albums.asin
    WHERE
      tracks.song = albums.title
  SQL
end

def eponymous_albums
  # An 'eponymous album' has a `title` that is the same as its recording
  # artist's name. Select the titles of all the eponymous albums.
  execute(<<-SQL)
    SELECT
      title
    FROM
      albums
    WHERE
      title = artist
  SQL
end

def song_title_counts
  # Select the song names that appear on more than two albums. Also select the
  # COUNT of times they show up.
  execute(<<-SQL)
    SELECT
      song, COUNT(*)
    FROM (
      SELECT DISTINCT
        album, song
      FROM
        tracks
    ) AS distinct_tracks
    GROUP BY
      song
    HAVING
      COUNT(*) > 2
  SQL
end

def best_value
  # A "good value" album is one where the price per track is less than 50
  # pence. Find the good value albums - show the title, the price and the number
  # of tracks.
  execute(<<-SQL)
    SELECT
      albums.title, albums.price, track_counts.num_tracks
    FROM
      albums
    INNER JOIN (
      SELECT
        album, COUNT(*) AS num_tracks
      FROM
        tracks
      GROUP BY
        album
    ) AS track_counts ON albums.asin = track_counts.album
    WHERE
      albums.price / track_counts.num_tracks < 0.5
  SQL
end

def top_track_counts
  # Wagner's Ring cycle has an imposing 173 tracks, Bing Crosby clocks up 101
  # tracks. List the top 10 albums. Select both the album title and the track
  # count, and order by both track count and title (descending).
  execute(<<-SQL)
    SELECT
      albums.title, track_counts.num_tracks
    FROM
      albums
    INNER JOIN (
      SELECT
        album, COUNT(*) AS num_tracks
      FROM
        tracks
      GROUP BY
        album
    ) AS track_counts ON albums.asin = track_counts.album
    ORDER BY
      track_counts.num_tracks DESC, albums.title DESC
    LIMIT
      10;
  SQL
end

def rock_superstars
  # Select the artist who has recorded the most rock albums, as well as the
  # number of albums. HINT: use LIKE '%Rock%' in your query.
  execute(<<-SQL)
    SELECT
      artist, COUNT(*)
    FROM (
      SELECT DISTINCT
        asin, artist
      FROM
        albums
      INNER JOIN
        styles ON albums.asin = styles.album
      WHERE
        style LIKE '%Rock%'
    ) AS rock_albums
    GROUP BY
      artist
    ORDER BY
      COUNT(*) DESC
    LIMIT
      1;
  SQL
end

def expensive_tastes
  # Select the five styles of music with the highest average price per track,
  # along with the price per track. One or more of each aggregate functions,
  # subqueries, and joins will be required.
  #
  # HINT: Start by getting the number of tracks per album. You can do this in a
  # subquery. Next, JOIN the styles table to this result and use aggregates to
  # determine the average price per track.
  execute(<<-SQL)
    SELECT
      styles.style, (SUM(per_album_info.price) / SUM(per_album_info.album_num_tracks)) AS avg_style_track_price
    FROM
      styles
    INNER JOIN(
      SELECT
        asin, price, track_counts.num_tracks AS album_num_tracks
      FROM
        albums
      INNER JOIN(
        SELECT
          album, COUNT(*) AS num_tracks
        FROM
          tracks
        GROUP BY
          album
      ) AS track_counts ON albums.asin = track_counts.album
      WHERE
        price IS NOT NULL
    ) AS per_album_info ON styles.album = per_album_info.asin
    GROUP BY
      styles.style
    ORDER BY
      avg_style_track_price DESC, styles.style ASC
    LIMIT
      5
  SQL
end
