--Total cases and deaths, and death percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 1,2

--Death Count per Continent
Select location, SUM(new_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is NULL
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

--Population Infection Rate per location
Select location, population, max(total_cases) as HighestInfectionCount, max(CAST(total_cases as float)/CAST(population as float))*100 as PopulationInfectionRate
FROM PortfolioProject..CovidDeaths
group by location, population
order by PopulationInfectionRate desc

--Infection Rate recorded per date
Select location, population, date, max(total_cases) as HighestInfectionCount, max(CAST(total_cases as float)/CAST(population as float))*100 as PopulationInfectionRate
FROM PortfolioProject..CovidDeaths
group by location, population, date
order by PopulationInfectionRate desc

--Rolling count of vaccinated people
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3


SELECT location, date, population, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Use of CTE
With PopvsVac (continent, location, date, population, new_Vaccinations, NewVaccinationsRollingCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as NewVaccinationsRollingCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, CAST(NewVaccinationsRollingCount as float)/ CAST(population as float)*100 as PeopleVaccinatedPercentage
FROM PopvsVac

--Creating and inserting to Temp Table

Create Table #PercentPopulationVaccinated
(
    Continent nvarchar(50),
    Location nvarchar(50),
    date datetime,
    Population numeric,
    New_vaccinations numeric,
    NewVaccinationsRollingCount numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as NewVaccinationsRollingCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null


SELECT *, CAST(NewVaccinationsRollingCount as float)/ CAST(population as float)*100
FROM #PercentPopulationVaccinated


--Creating View for data viz
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as NewVaccinationsRollingCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null


Select *
FROM PercentPopulationVaccinated