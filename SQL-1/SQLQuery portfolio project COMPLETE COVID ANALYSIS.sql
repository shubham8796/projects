SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null


--SELECT *
--FROM PortfolioProject.dbo.CovidVaccination

--SELECT THE DATA THAT  WE ARE USING


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER  BY 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--IT HELP TO UNDERSTAND COUNTRY DEATH PERCENTAGE

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases*100) AS DEATHRATIO
FROM PortfolioProject..CovidDeaths
ORDER  BY 1,2

--LOOKING AT TOTALDEATH VS POPULATION (IN INDIA)

SELECT Location, DATE, Population, total_deaths,(total_deaths/population*100) AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE Location Like '%IND%'
ORDER  BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE VS TOTAL POPULATION

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location Like '%INDIA%'
GROUP BY Location, population
ORDER BY PercentageOfPopulationInfected DESC

--LOOKING AT HIGHEST DEATH VS POPULATION

SELECT Location, MAX(CAST(total_deaths AS int)) AS TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TOTALDEATHCOUNT DESC

--CHECKING AS PER CONTINENT

SELECT continent, MAX(CAST(total_deaths AS int)) AS TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TOTALDEATHCOUNT DESC

--CHECKING GOLBAL NUMBER

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2

--JOINING COVID DEATH AND VACCINATION TABLE 

SELECT *
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination vacc
	ON Dea.location = vacc.location
	AND Dea.date = vacc.date

-- LOOKING AT TOTAL POPULATON VS VACCINATION

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vacc.new_vaccinations
,SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
----,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination vacc
	ON Dea.location = vacc.location
	AND Dea.date = vacc.date
WHERE Dea.continent IS NOT NULL
ORDER BY 1,2

--USE CTE

WITH POPVSVACC (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vacc.new_vaccinations
,SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
----,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination vacc
	ON Dea.location = vacc.location
	AND Dea.date = vacc.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 1,2
)
SELECT* , (RollingPeopleVaccinated/population)*100 AS PercentageOfPeopleVaccinated
FROM POPVSVACC


--TEMP TABLE

Drop Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPeopleVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
----,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination vacc
	ON Dea.location = vacc.location
	AND Dea.date = vacc.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 1,2

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageOfPeopleVaccinated
FROM #PercentPeopleVaccinated

--CREATING VIEW STORE DATA FOR LATER VISUALISATION

Create View PercentPeopleVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
----,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination vacc
	ON Dea.location = vacc.location
	AND Dea.date = vacc.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 1,2


SELECT *
FROM PercentPeopleVaccinated