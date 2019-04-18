#!/usr/bin/ruby

require 'rubygems'
require 'faker'
require 'zlib'

dir=ARGV[0]
puts("Writing the data to #{dir}")

file_count=ENV['FILE_COUNT'] || 1000
inserts_per_file=ENV['INSERTS_PER_FILE'] || 1000
total_inserts=file_count * inserts_per_file
notice_period=ENV['NOTICE_PERIOD'] || 1000

file_count.times do |fileIdx|
	Zlib::GzipWriter.open("#{dir}/#{fileIdx}.inserts.sql.gz", Zlib::BEST_COMPRESSION) do |file|
		inserts_per_file.times do |i|
			cnt = fileIdx * inserts_per_file + i
			puts("Completed #{cnt} of #{total_inserts} insert statements. (#{(100 * cnt.to_f / total_inserts.to_f).round}%)") if i % notice_period == 0
			fn = Faker::Name.first_name
			ln = Faker::Name.last_name
			bd = Faker::Date.birthday(18, 65)
			fb = Faker::Music.band
			file.puts("INSERT INTO tbl_main (first_name, last_name, birthdate, favorite_band) VALUES ( $q$#{fn}$q$ , $q$#{ln}$q$ , $q$#{bd}$q$ , $q$#{fb}$q$ );")
		end
	end
end

puts("Completed #{total_inserts} of #{total_inserts} insert statements. (100%)")
