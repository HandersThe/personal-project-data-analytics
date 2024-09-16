SELECT *
FROM public.covid_death
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid-19 in Indonesia
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/NULLIF(CAST(total_cases AS real) , 0))*100 AS death_percentage
FROM public.covid_death
WHERE location = 'Indonesia'
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid-19
SELECT 
	location, 
	date, 
	total_cases, 
	population, 
	(total_cases/NULLIF(CAST(population AS real) , 0))*100 AS infected_percentage
FROM public.covid_death
WHERE location = 'Indonesia'
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT
	location, 
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/NULLIF(CAST(population AS real) , 0)))*100 AS infected_percentage
FROM public.covid_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_infection_count DESC


-- Showing Countries with Highest Death Count
SELECT 
	location,
	MAX(total_deaths) AS total_death_count
FROM public.covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


-- Showing Continent with Highest Death Count
SELECT 
	location,
	MAX(total_deaths) AS total_death_count
FROM public.covid_death
WHERE 
	continent IS NULL AND
	location <> 'High-income countries' AND
	location <> 'Upper-middle-income countries' AND
	location <> 'Lower-middle-income countries' AND
	location <> 'Low-income countries'
GROUP BY location
ORDER BY total_death_count DESC


--Looking at Total Population vs Vaccinations
--CTE
WITH PopvsVac (
	continent,
	location,
	date,
	population,
	new_vaccinations,
	rolling_people_vaccinated)
AS 
(
SELECT
	covd.continent,
	covd.location,
	covd.date,
	covd.population,
	covv.new_vaccinations,
	SUM(covv.new_vaccinations) OVER (
		PARTITION BY covd.location 
		ORDER BY covd.location, covd.date) AS rolling_people_vaccinated
FROM public.covid_death AS covd
JOIN public.covid_vaccinated as covv
	ON covd.location = covv.location AND
	covd.date = covv.date
WHERE covd.continent IS NOT NULL
)
-- SELECT *
-- FROM PopvsVac
SELECT
	*,
	(rolling_people_vaccinated/CAST(population AS real))*100 AS vaccinated_percentage_
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
	continent character varying(50),
	location character varying(50),
	date date,
	population bigint,
	new_vaccinations bigint,
	rolling_people_vaccinations numeric
)

INSERT INTO #percent_population_vaccinated
SELECT
	covd.continent,
	covd.location,
	covd.date,
	covd.population,
	covv.new_vaccinations,
	SUM(covv.new_vaccinations) OVER (
		PARTITION BY covd.location 
		ORDER BY covd.location, covd.date) AS rolling_people_vaccinated
FROM public.covid_death AS covd
JOIN public.covid_vaccinated as covv
	ON covd.location = covv.location AND
	covd.date = covv.date
WHERE covd.continent IS NOT NULL

SELECT
	*,
	(rolling_people_vaccinated/CAST(population AS real))*100 AS vaccinated_percentage_
FROM #percent_population_vaccinated

-- Create View to store data for later visualisations
CREATE VIEW percent_population_vaccinated AS
SELECT
	covd.continent,
	covd.location,
	covd.date,
	covd.population,
	covv.new_vaccinations,
	SUM(covv.new_vaccinations) OVER (
		PARTITION BY covd.location 
		ORDER BY covd.location, covd.date) AS rolling_people_vaccinated
FROM public.covid_death AS covd
JOIN public.covid_vaccinated as covv
	ON covd.location = covv.location AND
	covd.date = covv.date
WHERE covd.continent IS NOT NULL
-- SELECT *
-- FROM percent_population_vaccinated