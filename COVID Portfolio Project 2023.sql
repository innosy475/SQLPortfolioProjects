SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA THAT WILL BE USED


SELECT location,date, total_cases, new_cases, total_cases, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--total cases vs total deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
--where location like '%states%'
order by 1,2

--looking with countries with highest infection rate

Select location, population, max(total_cases) as HighestInfectionCount,
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc

----BY CONTINENT (CORRECT)
--Select location, max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..covidDeaths
----where location like '%states%'
--where continent is null
--GROUP BY location
--order by TotalDeathCount desc

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
GROUP BY location
order by TotalDeathCount desc


--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc



--global numbers
Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(nullif(new_cases,0))*100 as Deathpercentage
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--LOOKING TOTAL POPULATION VS VACCINATION

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(convert(int,vacc.new_vaccinations)) over (partition by death.location)
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3

SELECT *
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date


SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(convert(bigint,vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3

--USE CTE

WITH PopuVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(convert(bigint,vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopuVSVac



-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(convert(bigint,vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATER DATA VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(convert(bigint,vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated