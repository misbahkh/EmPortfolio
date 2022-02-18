
Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breakig out Address Individual Columns (Address, City, State)

Select PropertyAddress
from [Portfolio Project]..[Nashville Housing] 

select
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from [Portfolio Project]..[Nashville Housing] 
--+1 if you take it out you will see comma in front of address
-- -1 if you dont have it you will see comma after DR


--creating two new columns

alter table [Nashville Housing]
add PropertySplitAddress nvarchar(255);

update [Nashville Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table [Nashville Housing]
add PropertySplitCity nvarchar(255);

update [Nashville Housing]
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))


select OwnerAddress
from [Portfolio Project]..[Nashville Housing] 

--breaking up city, state, and address by not using substring
--parsename only looks for period. so what we can do is replace those commas with period)
select
PARSENAME(replace(OwnerAddress,',','.'), 3)
,PARSENAME(replace(OwnerAddress,',','.'), 2)
,PARSENAME(replace(OwnerAddress,',','.'), 1)
from [Portfolio Project]..[Nashville Housing] 

alter table [Nashville Housing]
add OwnerSplitAddress nvarchar(255);

update [Nashville Housing]
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3)

alter table [Nashville Housing]
add OwnerSplitCity nvarchar(255);

update [Nashville Housing]
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2)


alter table [Nashville Housing]
add OwnerSplitState nvarchar(255);

update [Nashville Housing]
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1)


select *
from [Portfolio Project]..[Nashville Housing]

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant), count(soldasvacant)
from [Portfolio Project]..[Nashville Housing]
group by soldasvacant
order by 2

select soldasvacant 
, case when soldasvacant = 'Y'then 'Yes'
when soldasvacant = 'N' then 'No' 
else soldasvacant 
end
from [Portfolio Project]..[Nashville Housing]

update [Nashville Housing]
set SoldAsVacant = case when soldasvacant = 'Y'then 'Yes'
when soldasvacant = 'N' then 'No' 
else soldasvacant 
end

--Remove Duplicates

with RowNumCTE AS(
Select *,
row_number() over(
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
order by UniqueID) row_num
from [Portfolio Project]..[Nashville Housing]
)
Delete
from RowNumCTE
where row_num > 1

--Delete Unused Columns 

select*
from [Portfolio Project]..[Nashville Housing]

alter table [Portfolio Project]..[Nashville Housing]
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table [Portfolio Project]..[Nashville Housing]
drop column SaleDate

