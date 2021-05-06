
--VIEWING AND INSPECTING THE DATA SET
select * 
from [Portfolio Project]..covidvaccinations
order by 3,4

select * 
from [Portfolio Project]..coviddeaths
order by 3,4

--SELECTING THE DATA WE ARE INTERESTED IN

select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..coviddeaths
where continent is not null --The data set also includes the continents as locations and put null in the continent fields for those entries
order by 1,2

--INSPECTING TOTAL OF CASES VS TOTAL DEATHS
--THIS SHOWS THE PROBABILITY OF A PERSON DYING FROM COVID IN EACH COUNTRY

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..coviddeaths
where location like '%Nigeria%'
order by 1,2

--INSPECTING THE TOTAL CASES VS POPULATION TO SHOW THE PERCENTAGE OF THE POPULATION THAT HAVE BEEN INFECTED

select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from [Portfolio Project]..coviddeaths
where continent is not null
order by 1,2

--For Nigeria
select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from [Portfolio Project]..coviddeaths
where location like '%Nigeria%'
order by 1,2

--COUNTRIES WITH THE HIGHEST INFECTION RATE RELATIVE TO THEIR POPULATION

select Location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as InfectionPercentage
from [Portfolio Project]..coviddeaths
where continent is not null
group by Location, population
order by InfectionPercentage desc

--SHOWING THE COUNTRIES WITHT THE HIGHEST DEATH COUNT PER POPULATION

select Location, max(cast(total_deaths as int)) as DeathCount
from [Portfolio Project]..coviddeaths
where continent is not null
group by Location
order by DeathCount desc

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT
select location, max(cast(total_deaths as int)) as DeathCount
from [Portfolio Project]..coviddeaths
where continent is null
group by location
order by DeathCount desc

select continent, max(cast(total_deaths as int)) as DeathCount
from [Portfolio Project]..coviddeaths
where continent is not null
group by continent
order by DeathCount desc

--GLOBAL NUMBERS 

--TOTAL DAILY NUMBERS GLOBALLY
select  date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [Portfolio Project]..coviddeaths
where continent is not null
group by date
order by 1,2

--TOTAL NUMBER GLOBALLY
select  sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [Portfolio Project]..coviddeaths
where continent is not null
--group by date
order by 1,2

--COMBINING BOTH DATA SETS IN OUR DATABASE- COVID DEATHS AND COVID VACCINATION TABLES

select *
from [Portfolio Project]..coviddeaths dea --giving the table name an alias 'dea'
join [Portfolio Project]..covidvaccinations vac--giving the table name an alias 'vac'
    on dea.location = vac.location
	and dea.date = vac.date

--INSPECTING THE TOTAL POPULATION  VS VACCINATION POPULATION

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from [Portfolio Project]..coviddeaths dea --giving the table name an alias 'dea'
join [Portfolio Project]..covidvaccinations vac--giving the table name an alias 'vac'
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--INSPECTING THE NUMBER OF PEOPLE VACINATED IN EACH COUNTRY AS A ROLLING COUNT SHOWING DAILY INCREMENTS TO THE TOTAL

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingCountVaccinated 
from [Portfolio Project]..coviddeaths dea --giving the table name an alias 'dea'
join [Portfolio Project]..covidvaccinations vac--giving the table name an alias 'vac'
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--CREATING A TEMP TABLE

drop table if exists #Percentofpopvac --to delete the table from the database to avoid errors when running below query again.

create Table #Percentofpopvac
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountVaccinated numeric
)

insert into #Percentofpopvac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingCountVaccinated 

from [Portfolio Project]..coviddeaths dea --giving the table name an alias 'dea'
join [Portfolio Project]..covidvaccinations vac--giving the table name an alias 'vac'
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingCountVaccinated/Population)*100
from #Percentofpopvac

--ALTERNATIVELY--CREATING A COMMON TABLE EXPRESSION

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingCountVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingCountVaccinated 

from [Portfolio Project]..coviddeaths dea --giving the table name an alias 'dea'
join [Portfolio Project]..covidvaccinations vac--giving the table name an alias 'vac'
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingCountVaccinated/Population)*100
from PopvsVac

--CREATING VIEW TO STORE DATA FOR VISUALIZATION

create view Percentofpopvac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingCountVaccinated 

from [Portfolio Project]..coviddeaths dea --giving the table name an alias 'dea'
join [Portfolio Project]..covidvaccinations vac--giving the table name an alias 'vac'
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

create view maxdeathcount as 
select location, max(cast(total_deaths as int)) as DeathCount
from [Portfolio Project]..coviddeaths
where continent is null
group by location
