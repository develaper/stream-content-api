# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'json'

# Load JSON data from the file
json_file_path = Rails.root.join('..', 'titan-test-docs', 'streams_data.json')
if !File.exist?(json_file_path)
  puts "Error: JSON file not found at #{json_file_path}"
  exit
end

json_data = JSON.parse(File.read(json_file_path))

# Clear existing data
puts "Clearing existing data..."
ContentAvailability.destroy_all
App.destroy_all
Market.destroy_all
Movie.destroy_all
TvShow.destroy_all
Season.destroy_all
Episode.destroy_all
Channel.destroy_all
ChannelProgram.destroy_all
CatalogEntry.destroy_all
ProgramSchedule.destroy_all

# Create markets
puts "Creating markets..."
markets = {}
[ 'gb', 'es' ].each do |code|
  markets[code] = Market.create!(code: code.upcase)
end

# Create apps
puts "Creating apps..."
apps = {}
json_data['movies'].flat_map { |m| m['availabilities'] }.map { |a| a['app'] }.uniq.each do |app_name|
  # Convert snake_case to normal name (e.g., prime_video -> Prime Video)
  display_name = app_name.gsub('_', ' ').split.map(&:capitalize).join(' ')
  apps[app_name] = App.create!(name: display_name)
end

json_data['channels'].flat_map { |m| m['availabilities'] }.map { |a| a['app'] }.uniq.each do |app_name|
  # Convert snake_case to normal name (e.g., prime_video -> Prime Video)
  display_name = app_name.gsub('_', ' ').split.map(&:capitalize).join(' ')
  apps[app_name] = App.create!(name: display_name)
end

# Create movies
puts "Creating movies..."
json_data['movies'].each do |movie_data|
  movie = Movie.create!(
    title: movie_data['original_title'],
    year: movie_data['year'],
    duration_in_seconds: movie_data['duration_in_seconds']
  )

  # Create content availabilities
  movie_data['availabilities'].each do |availability|
    app = apps[availability['app']]
    market = markets[availability['market']]

    if app && market
      ContentAvailability.create!(
        content: movie,
        app: app,
        market: market
      )
    end
  end
end

# Create TV shows, seasons, and episodes
puts "Creating TV shows, seasons, and episodes..."
if json_data['tv_shows'].present?
  json_data['tv_shows'].each do |tv_show_data|
    tv_show = TvShow.create!(
      title: tv_show_data['original_title'],
      year: tv_show_data['year']
    )

    # Create content availabilities for TV show
    tv_show_data['availabilities'].each do |availability|
      app = apps[availability['app']]
      market = markets[availability['market']]

      if app && market
        ContentAvailability.create!(
          content: tv_show,
          app: app,
          market: market
        )
      end
    end

    # Create seasons
    if tv_show_data['seasons'].present?
      tv_show_data['seasons'].each do |season_data|
        season = Season.create!(
          title: season_data['original_title'],
          number: season_data['number'],
          year: season_data['year'],
          duration_in_seconds: season_data['duration_in_seconds'],
          tv_show: tv_show
        )

        # Create content availabilities for season
        if season_data['availabilities'].present?
          season_data['availabilities'].each do |availability|
            app = apps[availability['app']]
            market = markets[availability['market']]

            if app && market
              ContentAvailability.create!(
                content: season,
                app: app,
                market: market
              )
            end
          end
        end
      end
    end

    # Create episodes
    if tv_show_data['episodes'].present?
      tv_show_data['episodes'].each do |episode_data|
        # Find the season by number
        season = tv_show.seasons.find_by(number: episode_data['season_number'])

        if season
          Episode.create!(
            title: episode_data['original_title'],
            number: episode_data['number'],
            season_number: episode_data['season_number'],
            duration_in_seconds: episode_data['duration_in_seconds'],
            year: episode_data['year'],
            season: season
          )
        end
      end
    end
  end
end

# Create channels and programs
puts "Creating channels and channel programs..."
if json_data['channels'].present?
  json_data['channels'].each do |channel_data|
    channel = Channel.create!(
      title: channel_data['original_title']
    )

    # Create content availabilities for channel
    channel_data['availabilities'].each do |availability|
      app = apps[availability['app']]
      market = markets[availability['market']]

      if app && market
        ContentAvailability.create!(
          content: channel,
          app: app,
          market: market
        )
      end
    end

    # Create channel programs
    channel_data['channel_programs'].each do |program_data|
      # Parse start and end times
      schedules = program_data['schedule']
      channel_program = ChannelProgram.create!(
        channel: channel,
        title: program_data['original_title']
      )
      schedules.each do |schedule|
        ProgramSchedule.create!(
          channel_program: channel_program,
          start_time: Time.parse(schedule['start_time']),
          end_time: Time.parse(schedule['end_time'])
        )
      end
    end
  end
end

puts "Seed completed successfully!"
puts "Created:"
puts "- #{Market.count} markets"
puts "- #{App.count} apps"
puts "- #{Movie.count} movies"
puts "- #{TvShow.count} TV shows"
puts "- #{Season.count} seasons"
puts "- #{Episode.count} episodes"
puts "- #{Channel.count} channels"
puts "- #{ChannelProgram.count} channel programs"
puts "- #{ContentAvailability.count} content availabilities"
