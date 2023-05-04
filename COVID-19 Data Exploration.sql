Select * 
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

Select * 
From PortfolioProject.dbo.CovidVaccinations
order by 3,4

-- Select data that we will be using.

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%United States%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid.

Select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
-- Where location like '%United States%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
-- Where location like '%United States%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest death count

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
-- Where location like '%United States%'
Group by Location
order by TotalDeathCount desc

-- Showing continents with highest death count

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
-- Where location like '%United States%'
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
-- Where location like '%United States%'
Where continent is not null
--and total_cases is not null
--and total_deaths is not null
Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


-- Querying off of new View

Select * 
From PercentPopulationVaccinated



-- SQL Queries for Tableau Visualizations

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%United States%'
where continent is not null 
--Group By date
order by 1,2


-- 2. 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%United States%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%United States%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%United States%'
Group by Location, Population, date
order by PercentPopulationInfected desc