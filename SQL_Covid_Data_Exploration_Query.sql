Select *
From DataPortfolioProject.dbo.CovidDeaths$
order by 3,4


--Select *
--From DataPortfolioProject.dbo.CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population	
From DataPortfolioProject..CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DataPortfolioProject..CovidDeaths$
where location like'%states%'
order by 1,2


--Total Cases vs Population
Select Location, date, total_cases, Population, (total_deaths/Population)*100 as DeathPercentage
From DataPortfolioProject..CovidDeaths$
where location like'%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From DataPortfolioProject..CovidDeaths$
--where location like'%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per population
Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From DataPortfolioProject..CovidDeaths$
--where location like'%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Breakdown by Continent

--Continents with highest death count per population
Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From DataPortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
--Death rate by date across the world
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From DataPortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2



--Total Population vs Vaccicnations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
From DataPortfolioProject..CovidDeaths$ dea
Join DataPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From DataPortfolioProject..CovidDeaths$ dea
Join DataPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE (temp table) to perform calculation on new column
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From DataPortfolioProject..CovidDeaths$ dea
Join DataPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, ((RollingPeopleVaccinated/Population)*100) as RollingPeopleVaccinatedPercentage
From PopVsVac

--TEMP Table
Create Table #PercentpopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)

Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From DataPortfolioProject..CovidDeaths$ dea
Join DataPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, ((RollingPeopleVaccinated/Population)*100) as RollingPeopleVaccinatedPercentage
From #PercentpopulationVaccinated


--TEMP Table Edited
DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)

Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From DataPortfolioProject..CovidDeaths$ dea
Join DataPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, ((RollingPeopleVaccinated/Population)*100) as RollingPeopleVaccinatedPercentage
From #PercentpopulationVaccinated


--View to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From DataPortfolioProject..CovidDeaths$ dea
Join DataPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
