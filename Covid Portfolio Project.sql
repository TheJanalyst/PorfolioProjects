Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--looking at Total Cases vs total Deaths

Select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2 desc

--looking at total cases vs population

Select Location, date, total_cases,total_deaths, population, (total_cases/population)*100 as populationPercentage, (total_deaths/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%poland%'
order by 1,2 desc


--looking at Countires with highset infection rate compared to population

Select continent, Location, population, MAX(cast(total_deaths as int)) as Highestdeaths, max((total_deaths/population))*100 as populationPercentageDeathhs
From PortfolioProject..CovidDeaths$
--where location like '%poland%'
where continent like '%america%'
Group by continent, Location, population
order by Highestdeaths desc


--by continent

Select continent, max(cast(population as int)) as MaxPopulation, MAX(cast(total_deaths as int)) as Maxdeaths, max(total_deaths/population)*100  as populationPercentageDeathhs
From PortfolioProject..CovidDeaths$
--where location like '%poland%'
where continent is not null
Group by continent
order by MaxPopulation desc


-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by  dea.Location 
Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVacc/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 desc



--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by  dea.Location 
Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVacc/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc
)
Select *,(RollingPeopleVaccinated/Population)*100 as PercentRollingVaccinated
From PopvsVac



--temp table

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by  dea.Location 
Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVacc/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc

Select *,(RollingPeopleVaccinated/Population)*100 as PercentRollingVaccinated
From #PercentPopulationVaccinated



--PercentPopulationVaccinated (View)
USE PortfolioProject;
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by  dea.Location 
Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVacc/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc

Select *
From PercentPopulationVaccinated



--Total deaths By location without split to Europen Union, World and International (View)

USE PortfolioProject;
GO
Create View NumberByLocation as
Select location, sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
and location not in('World','European Union','International')
Group by location
--order by TotalDeathCount desc
GO
Select*
From NumberByLocation



--GLOBAL NUMBERS (View)
USE PortfolioProject;
GO
Create View GlobalNumbers as
Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
--order by 1,2
GO
Select *
From GlobalNumbers




--looking at countires with highset infection rate compared to population (View)

USE PortfolioProject;
GO
Create View PercentPopulationInfected as
Select Location, Population, MAX(total_cases) as HighestInfection, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--where location like '%poland%'
where continent is not null
Group by Location, population
--order by populationPercentageInfectes desc
GO
Select *
From PercentPopulationInfected