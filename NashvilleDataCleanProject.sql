SELECT *
FROM PortfolioProject.dbo.[Nashville Housing]


-- Standardize Date Format, "change sale date", its a date/time, need to convert to date only

SELECT SaleDate, CONVERT(date, SaleDate)
From PortfolioProject.dbo.[Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD SaleDateConverted Date;
--This added a new column to the data

Update [Nashville Housing]
SET SaleDateConverted = Convert(date,saledate)


SELECT SaleDateConverted, convert(date,SaleDate)
from [Nashville Housing]


--Populate Property Address

SELECT PropertyAddress
from [Nashville Housing]
where PropertyAddress is null 


--POPULATING NULL VALUES FOR DATA CLEANING 

SELECT *
FROM [Nashville Housing]
where PropertyAddress is null

SELECT *
from [Nashville Housing]
--where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [Nashville Housing] a
JOIN [Nashville Housing] b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ] <>b.[UniqueID ]
 where a.PropertyAddress is null 

--TIME TO POPULATE THE NULLS
 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from [Nashville Housing] a
JOIN [Nashville Housing] b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ] <>b.[UniqueID ]
 where a.PropertyAddress is null 

Update a 
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing] a
JOIN [Nashville Housing] b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ] <>b.[UniqueID ]
 Where a.PropertyAddress is null


 --BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS 

SELECT PropertyAddress
from [Nashville Housing]

SELECT 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address

From [Nashville Housing]

SELECT
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
From [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress nvarchar(255);


Update [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)


ALTER TABLE [Nashville Housing]
ADD PropertySplitCity nvarchar(255);

Update [Nashville Housing]
SET PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--split the property addresses up (eg state,city,etc are in their own columns)

SELECT OwnerAddress
FROM [Nashville Housing]

SELECT
PARSENAME(OwnerAddress,1)
FROM [Nashville Housing]

SELECT
PARSENAME(Replace(OwnerAddress, ',' , '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',' , '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',' , '.'), 1)
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress nvarchar(255);


Update [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',' , '.'), 3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity nvarchar(255);


Update [Nashville Housing]
SET OwnerSplitCity =PARSENAME(Replace(OwnerAddress, ',' , '.'), 2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState nvarchar(255);


Update [Nashville Housing]
SET OwnerSplitState =PARSENAME(Replace(OwnerAddress, ',' , '.'), 1)


--CHANGE Y AN N TO YES AND NO IN "SOLD AS VACANT" FIELD

Select Distinct(SoldAsVacant), count(soldasvacant)
FROM [Nashville Housing]
group by SoldAsVacant
order by 2

Select SoldAsVacant
, case when SoldAsVacant= 'Y' THEN 'Yes'
		when SoldAsVacant= 'N' then 'No'
		else SoldAsVacant
		end
FROM [Nashville Housing]

update [Nashville Housing]
set SoldAsVacant = case when SoldAsVacant= 'Y' THEN 'Yes'
		when SoldAsVacant= 'N' then 'No'
		else SoldAsVacant
		end


--REMOVING DUPLICATES
--Shouldn't delete raw data here, usually removing duplicates after creating a temp table

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by 
					UniqueID
					) row_num

FROM [Nashville Housing]
--order by ParcelID
)

SELECT *
FROM RowNumCTE 
Where row_num > 1 
order by PropertyAddress


DELETE 
FROM RowNumCTE 
Where row_num > 1 



--DELETE UNUSED COLUMNS
--do not do this to raw data!! ask for advice beforehand


SELECT *
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
drop column OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE [Nashville Housing]
drop column SaleDate