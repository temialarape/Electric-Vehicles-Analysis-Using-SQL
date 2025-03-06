CREATE TABLE electric_vehicle_population (
	vin VARCHAR(10),
	County VARCHAR(50),
	City VARCHAR(100),
	State CHAR(2),
	Postal_Code VARCHAR(10),
	Model_Year INT,
	Make VARCHAR(50),
	Model VARCHAR(100),
	Electric_Vehicle_Type VARCHAR(100),
	Cafv_Eligibility VARCHAR(250),
	Electric_Range FLOAT,
	Base_Msrp FLOAT,
	Electric_Utility VARCHAR(255)
	);
	
	Copy electric_vehicle_population 
	from 'C:\Program Files\PostgreSQL\16\data\Data Copy\Electric_Vehicle_Population_Data.csv' delimiter ',' csv header;
	
	SELECT * FROM electric_vehicle_population;
	
	--1. A list of the total number of electric vehicles for each state
	
	Select state, COUNT(state) AS Count_Of_State
	FROM electric_vehicle_population
	GROUP BY state
	ORDER BY count_of_state desc;
	
	--2. List of the total number of electric vehicles for each city
	
	Select city, count(city) AS count_of_city
	FROM electric_vehicle_population
	GROUP BY city
	ORDER BY count_of_city desc;
	
	--3. Electric vehicles located in the city of Seattle
	
	Select * FROM electric_vehicle_population
	WHERE city = 'Seattle';
	
	--4. Total number of electric vehicles for each county
	
	Select county, count(*) AS count_of_county
	FROM electric_vehicle_population
	GROUP BY county
	ORDER BY count_of_county desc;
	
	--5. All electric vehicles with a BASE MSRP greater than the average MSRP of all vehicles 
	
	Select *
	FROM electric_vehicle_population
	WHERE base_msrp > (Select AVG(base_msrp) FROM electric_vehicle_population );
	
	--6. All Plug-in-Hybrid Electric Vehicles(PHEV) from King County with an electric range greater than 50 miles
	
	Select * FROM electric_vehicle_population
	WHERE county = 'King'
	AND electric_vehicle_type = 'Plug-in Hybrid Electric Vehicle (PHEV)'
	AND electric_range > 50;
	
	--7. Count of number of electric vehicles in each city, but only cities with more than 100 vehicles
	
	Select city, count(*) AS vehicle_count
	FROM electric_vehicle_population
	Group BY city
	HAVING COUNT(*) > 100
	ORDER BY vehicle_count desc;
	
	--8. List of the Make and Model of electric vehicles located in counties where the average electric range exceeds 150 miles
	
	Select make, model
	FROM electric_vehicle_population
	WHERE county IN (Select county FROM electric_vehicle_population GROUP BY county HAVING AVG(electric_range) > 150);
	
	--9. Categorization of vehicles according to their affordability
	
	Select CASE WHEN base_msrp > 40000 THEN 'Expensive'
	ELSE 'Affordable'
	END AS vehicle_category,
	COUNT(*) AS total_vehicle
	FROM electric_vehicle_population
	GROUP BY vehicle_category;
	
	--10. List of the make, model and electric range of vehicles along with the rank based on the electric range within its county
	
	Select make, model, electric_range,county,
	RANK()OVER(PARTITION BY county ORDER BY electric_range desc) AS range_rank
	FROM electric_vehicle_population;
	
	--11. Percentage of CAFV eligible vehicles 
	
	WITH vehicles_counts AS(
	Select state, COUNT(*) AS total_vehicles, SUM(CASE
												WHEN Cafv_Eligibilty = 'Clean Alternative Fuel Vehicle Eligible'
												THEN 1 ELSE 0 END) AS cafv_eligible_vehicles
	FROM electric_vehicle_population
	GROUP BY state
	)
	Select state, total_vehicles, cafv_eligible_vehicles,
	(cafv_eligible_vehicles::FLOAT/total_vehicles * 100) AS cafv_eligible_percentage
	FROM vehicles_counts;

	