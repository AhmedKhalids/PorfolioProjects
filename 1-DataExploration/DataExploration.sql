
-- Selecting all of the rows of the tables
Select * 
From PortfolioProjects..CovidDeaths
-- i add it because there's some null data
where continent  is not null
order by 3,4

--Select * 
--From PortfolioProjects..CovidVaccination
--order by 3,4

-- Select Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProjects..CovidDeaths
where continent  is not null
order by 1,2

-- See the TotalCases vs Total Deaths
Select location,date,total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as PercentOfDeath
From PortfolioProjects..CovidDeaths
where location = 'Saudi Arabia' AND continent  is not null
order by 1,2

-- See the date total cases vs Population ' percent of population got covid'
Select location,date,total_cases,population, (total_cases/population)*100 as PercentOfPeopleGotCovid
From PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

-- countries with the highest infection Rate compared to population
Select location,population, Max(total_cases) as NumberOfHighestInfection, Max((total_cases/population))*100 as PercentOfPeopleGotCovid
From PortfolioProjects..CovidDeaths
where continent is not null
	Group by location,population
order by PercentOfPeopleGotCovid desc

-- who are the countries with highest death count per population
-- i change the type total_death because it's a nvchar
Select Location, Max(cast(total_deaths as int )) as TotalDeathCount
From  PortfolioProjects..CovidDeaths
where continent is  null
and location not in ('World', 'European Union' , 'International')
group by location
order by TotalDeathCount desc

-- let's do it with continent that with the highest death count per population
Select continent, Max(cast(total_deaths as int )) as TotalDeathCount
From  PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers of cases in each day

Select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int )) as Total_death_cases, (SUM(cast(new_deaths as int )) / sum(new_cases))*100 as PercentageOfDeath
From PortfolioProjects..CovidDeaths
where continent  is not null
group by date
order by 1,2

-- sum of all casess for all days
Select  sum(new_cases) as total_cases, SUM(cast(new_deaths as int )) as Total_death_cases, (SUM(cast(new_deaths as int )) / sum(new_cases))*100 as PercentageOfDeath
From PortfolioProjects..CovidDeaths
where continent  is not null
order by 1,2

-- looking to total population vs vaccine ' u will know what time did every country start giving vaccine ' 
Select  cD.continent , cD.location , cD.date , cD.population, cV.new_vaccinations
,  SUM(CONVERT(bigint,cV.new_vaccinations)) OVER (partition by cD.location order by cD.location , cD.date ) as AddingPeopleVaccinated
-- i use bigint because exceed the int " can't handle the number "
from PortfolioProjects..CovidVaccination as cV
join PortfolioProjects..CovidDeaths as cD
	on	cV.location = cD.location 
	And cV.date = cD.date
where cD.continent is not null	
order by 2,3


-- Using # , Temp Table to perform Calculation on Partition By in previous query
-- the drop to avoid the creation of 2 table with the same name
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AddingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select  cD.continent , cD.location , cD.date , cD.population, cV.new_vaccinations
,  SUM(CONVERT(bigint,cV.new_vaccinations)) OVER (partition by cD.location order by cD.location , cD.date ) as AddingPeopleVaccinated
-- i use bigint because exceed the int " can't handle the number "
from PortfolioProjects..CovidVaccination as cV
join PortfolioProjects..CovidDeaths as cD
	on	cV.location = cD.location 
	And cV.date = cD.date

Select *, (AddingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- perpose of This part for other project  ' visualation  '
Create View PercentPopulationVaccinated as
Select cD.continent , cD.location , cD.date , cD.population, cV.new_vaccinations
,  SUM(CONVERT(bigint,cV.new_vaccinations)) OVER (partition by cD.location order by cD.location , cD.date ) as AddingPeopleVaccinated
-- i use bigint because exceed the int " can't handle the number "
from PortfolioProjects..CovidVaccination as cV
join PortfolioProjects..CovidDeaths as cD
	on	cV.location = cD.location 
	And cV.date = cD.date



	-- tables that i use them in tabluea:
	--table 1:
	Select  sum(new_cases) as total_cases, SUM(cast(new_deaths as int )) as Total_death_cases, (SUM(cast(new_deaths as int )) / sum(new_cases))*100 as PercentageOfDeath
	From PortfolioProjects..CovidDeaths
	where continent  is not null
	order by 1,2

	--table2:
	--Select Location, Max(cast(total_deaths as int )) as TotalDeathCount
	--From  PortfolioProjects..CovidDeaths
	--where continent is  null
	--and location not in ('World', 'European Union' , 'International')
	--group by location
	--order by TotalDeathCount desc

	--table3:
	Select location,population, Max(total_cases) as NumberOfHighestInfection, Max((total_cases/population))*100 as PercentOfPeopleGotCovid
	From PortfolioProjects..CovidDeaths
	where continent is not null
	Group by location,population
	order by PercentOfPeopleGotCovid desc

	--table4:

	Select Location, population,date, max(total_cases) as highestGetCovidCount ,Max((total_cases / population ))*100 as PercentPopulationGetCovid
	From  PortfolioProjects..CovidDeaths
	--where continent is  not null
	group by location,population,date
	order by PercentPopulationGetCovid desc

	--table5:
	-- See the TotalCases vs Total Deaths in saudi
	Select location,date,total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as PercentOfDeath
	From PortfolioProjects..CovidDeaths
	where location = 'Saudi Arabia' AND continent  is not null
	order by 1,2