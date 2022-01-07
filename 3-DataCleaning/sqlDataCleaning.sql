/*
Cleaning data

issues that we have in that table:

1-Date format
2-Property address
3-Address has more than 1 data (Address, City, State)
4-Duplicate in some rows
5-unused columns
6-rename some row in Sold as Vacant



*/

-- see all of the table and check for other issues

Select* 
From PortfolioProjects..HousingCleaning


------------------------------------------------------------------------------------------
---------- 1:
---------- Standardize Date Format

-- Code:

Select SaleDate, CONVERT(Date,SaleDate) 
From PortfolioProjects..HousingCleaning
-- there's unnecessary ' extra ' numbers that we don't want 
-- make sure if we change to another format it will be fixed


-- now change
Update HousingCleaning
Set SaleDate = CONVERT(Date,SaleDate)

--other way
Alter table	HousingCleaning
add SaleDateNew date;

update HousingCleaning
Set SaleDateNew = CONVERT(Date,SaleDate)


-- Check:

Select SaleDate 
From PortfolioProjects..HousingCleaning

-- second way check:
Select SaleDateNew
From PortfolioProjects..HousingCleaning


------------------------------------------------------------------------------------------
---------- 2:
---------- Populate Property Address data

Select *
From PortfolioProjects..HousingCleaning
-- where propertyAddress is null
order by ParcelID
-- property address usually it's the same for all users with same unice ParceID 

-- Code:

-- join table on it self so i can compare each row with each other
Select  t1.ParcelID , t1.PropertyAddress ,t2.ParcelID, t2.PropertyAddress
From PortfolioProjects..HousingCleaning t1
JOIN PortfolioProjects..HousingCleaning t2
	on t1.ParcelID = t2.ParcelID AND t1.UniqueID <> t2.UniqueID
where t1.PropertyAddress is null


-- we use ISNULL because its raplce if the first value is null  with second value
-- row that have the same uniqueid 
update t1
Set PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
From PortfolioProjects..HousingCleaning t1
JOIN PortfolioProjects..HousingCleaning t2
	on t1.ParcelID = t2.ParcelID 
	AND t1.UniqueID <> t2.UniqueID
where t1.PropertyAddress is null

-- Check:

Select  t1.ParcelID , t1.PropertyAddress ,t2.ParcelID, t2.PropertyAddress
From PortfolioProjects..HousingCleaning t1
JOIN PortfolioProjects..HousingCleaning t2
	on t1.ParcelID = t2.ParcelID AND t1.UniqueID <> t2.UniqueID
where t1.PropertyAddress is null

-- another check for making sure ... 

select * 
From PortfolioProjects..HousingCleaning 
where PropertyAddress is null



------------------------------------------------------------------------------------------
---------- 3:
---------- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjects..HousingCleaning
-- we can see there's a 2 value in row so we have to split it 

-- Code:
-- substring is to start from a spesific letter on a word EX: ' from letter 5 to 9 '
-- CHARINDEX is a number for the place of the letter

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress ) -1) as Address1
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress) )as Address2
From PortfolioProjects..HousingCleaning 
-- this query it's like take before the " , " and after the " , "


Alter table	HousingCleaning
add  PropertyCityNew nvarchar(255);

update HousingCleaning
Set PropertyCityNew = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress ) -1)


Alter table	HousingCleaning
add  PropertyAddressNew nvarchar(255);

update HousingCleaning
Set PropertyAddressNew = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress) )

-- Check:

select PropertyCityNew,PropertyAddressNew
from PortfolioProjects..HousingCleaning




-- other easier way we will do it on OwnerAddress to fix it 

-- Code:
-- it's do the same perpose of substring but in back ward " start split from the end "
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from PortfolioProjects..HousingCleaning


Alter table	HousingCleaning
add  OwnerAddressNew nvarchar(255);

update HousingCleaning
Set OwnerAddressNew = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter table	HousingCleaning
add  OwnerCityNew nvarchar(255);

update HousingCleaning
Set OwnerCityNew = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter table	HousingCleaning
add  OwnerStateNew nvarchar(255);

update HousingCleaning
Set OwnerStateNew = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Check:
select OwnerAddressNew,OwnerCityNew,OwnerStateNew
from PortfolioProjects..HousingCleaning
where OwnerStateNew is not null


------------------------------------------------------------------------------------------
---------- 4:

------------ Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProjects..HousingCleaning
group by SoldAsVacant
-- as you can see the problem there's a 2 way to describe 1 value ' y , yes ' , ' n , no'

-- Code:

select SoldAsVacant,
	CASE
		when SoldAsVacant = 'Y' THEN 'YES'
		when SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	 End

from PortfolioProjects..HousingCleaning

update HousingCleaning
SET SoldAsVacant = CASE
		when SoldAsVacant = 'Y' THEN 'YES'
		when SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	 End


-- Check:

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProjects..HousingCleaning
group by SoldAsVacant

------------------------------------------------------------------------------------------
---------- 5:
---------- Remove Duplicates

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY 
	ParcelID, PropertyAddress, SalesPrice, SaleDate,LegalRefrence
	Order BY
	UniqueID
	) row_n
from PortfolioProjects..HousingCleaning
order by ParcelID


-- Code:
-- RowNumCTE it's a temp table so that we can use the row_Num(local var) to compare and delete after
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjects.dbo.HousingCleaning
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
--DELETE
--From RowNumCTE
--Where row_num > 1





------------------------------------------------------------------------------------------
---------- 6:
---------- Delete Unused Columns
--delete the column that we fix it in previous steps:
-- Code:
alter table PortfolioProjects.dbo.HousingCleaning
DROP COLUMN OwnerAddress,PropertyAddress,SaleDate
-- Check:
Select OwnerAddress,PropertyAddress,SaleDate
from PortfolioProjects.dbo.HousingCleaning