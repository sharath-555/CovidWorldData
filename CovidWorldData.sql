select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

select location, date,  total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total-cases vs total deaths
select location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

--looking at Total_cases vs population
select location, date,  total_cases, population, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location like '%states'
order by 1,2

Select location, population, max(total_cases) as HighestInfectedCount, max((total_cases/population))*100 as 
PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc

--showing countries with highest death count
select location, max(cast (total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

--showing the continents with highest total deaths
select location, max(cast (total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeaths desc

--Global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))
/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Rolling data of people vaccinated in different locations
with PopvsVac (continent, location, date, population, new_vaccations, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
order by 2,3

--creating a view for later data visulization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
