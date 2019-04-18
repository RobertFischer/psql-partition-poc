#!/usr/bin/ruby

dir=ARGV[0]
puts("Writing the SQL to #{dir}")

age_range=Range.new(17,66,false)

File.open("#{dir}/000_main.sql", "w") do |file|
	file.puts(<<HEREDIR
		CREATE TABLE public.tbl_main (
			first_name VARCHAR NOT NULL,
			last_name VARCHAR NOT NULL,
			birthdate DATE NOT NULL,
			favorite_band VARCHAR NOT NULL
		);

		CREATE SCHEMA birthday_parts;
HEREDIR
	)
end

File.open("#{dir}/001_partition.sql", "w") do |file|
	age_range.each do |age|
		birthyear = Time.now.year - age
		file.puts("CREATE TABLE birthday_parts.tbl_#{birthyear}_birthday ( CHECK ( #{birthyear} = EXTRACT( year FROM birthdate ) ) ) INHERITS ( public.tbl_main );")
	end
end

File.open("#{dir}/999_final.sql", "w") do |file|

	file.puts(<<HEREDIR
		CREATE OR REPLACE FUNCTION tbl_main_partition_function()
		RETURNS TRIGGER AS $$
			BEGIN
HEREDIR
	)

	age_range.each do |age|
		birthyear = Time.now.year - age
		file.puts(<<HEREDIR
				IF ( EXTRACT(year FROM NEW.birthdate) = #{birthyear} ) THEN
					INSERT INTO birthday_parts.tbl_#{birthyear}_birthday VALUES (NEW.*);
					RETURN NULL;
				END IF;
HEREDIR
		)
	end

	file.puts(<<HEREDIR
				RAISE EXCEPTION 'Birthdate out of range of partition: #{Time.now.year - age_range.max} to #{Time.now.year - age_range.min}';
			END;
		$$
		LANGUAGE plpgsql;

		CREATE TRIGGER tbl_main_partition_trigger
			BEFORE INSERT ON public.tbl_main
			FOR EACH ROW EXECUTE PROCEDURE tbl_main_partition_function();
HEREDIR
	 )

end

