select *
from CovidData..CovidDeaths
where continent is not null
--when continent is null the location is an entire contient instad of a country
order by 3,4


--select Location, date, population, total_cases, new_cases and total_deaths data

select location, date, total_cases, new_cases, total_deaths, population
from CovidData..CovidDeaths
where continent is not null
order by 1,2


--shows the likelihood of dying if you get covid in the UAE

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from CovidData..CovidDeaths
where location = 'united arab emirates'
and continent is not null
order by 1,2


--shows what percentage of population got covid


select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidData..CovidDeaths
where location  like '%emirates%'
order by 1,2

--Shows countries with highest infection rates compared with the population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidData..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totalDeathCount
from CovidData..CovidDeaths
where continent is not null
group by location, population
order by totalDeathCount desc


--showing the continents with  highest death conut per population

select location, max(cast(total_deaths as int)) as totalDeathCount
from CovidData..CovidDeaths
where continent is null
group by location, population
order by totalDeathCount desc

select continent, max(cast(total_deaths as int)) as totalDeathCount
from CovidData..CovidDeaths
where continent is not null
group by continent, population
order by totalDeathCount desc


--global numbers

select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from CovidData..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from CovidData..CovidDeaths
where continent is not null
order by 1,2

--using vaccinations table

select *
from CovidData..CovidDeaths death
join CovidData..CovidVaccinations vaccine
on death.location = vaccine.location
and death.date = vaccine.date

--total popuation vs vaccinations
--showing percentge of people getting at least one dose of the vaccine

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, sum(convert(bigint, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as people_vaccinated 
from CovidData..CovidDeaths death
join CovidData..CovidVaccinations vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
order by 2,3


--using CTE to perform calculation on Partition By in prevoius query

with PopvsVac (continent, location, date, population, new_vaccinations, people_vaccinated)
as
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, sum(convert(bigint, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as people_vaccinated 
from CovidData..CovidDeaths death
join CovidData..CovidVaccinations vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
)

select * , (people_vaccinated/population)*100 as total_vaccinated
from PopvsVac

--same effect but with a 
--temp table

drop table if exists #percentePopulationVaccinated 
create table #percentePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)
insert into #percentePopulationVaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, sum(convert(bigint, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as people_vaccinated 
from CovidData..CovidDeaths death
join CovidData..CovidVaccinations vaccine
on death.location = vaccine.location
and death.date = vaccine.date


select * , (people_vaccinated/population)*100 as total_vaccinated
from #percentePopulationVaccinated


--creating view 

create view percentePopulationVaccinated as
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, sum(convert(int, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as people_vaccinated 
from CovidData..CovidDeaths death
join CovidData..CovidVaccinations vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null

create view globalNumbers as
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from CovidData..CovidDeaths
where continent is not null


select * 
from globalNumbers


