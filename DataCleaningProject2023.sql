
/*

CLEANING DATA IN SQL USING NASHVILLE HOUSING DATASET

*/


Select *
from Nashville

--Standardize Date Format

Select SaleDate, convert(date, saledate)
from Nashville

update Nashville --does not work completely
set SaleDate = convert(date, saledate)

Select SaleDateConverted 
from Nashville

alter table nashville --add another column insted and insert the converted SaleDate
add SaleDateConverted date;

update Nashville --inserting converted SaleDate to the new column
set SaleDateConverted = convert(date, saledate)

--Populate Property Address data

Select PropertyAddress
from Nashville
where PropertyAddress is null

Select *
from Nashville
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
from Nashville as a
join Nashville as b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from Nashville as a
join Nashville as b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select PropertyAddress
from Nashville
--where PropertyAddress is null

--------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from Nashville
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+2, len(propertyaddress)) as address
from Nashville

select PropertyAddress ,len(propertyaddress)
from Nashville

alter table nashville 
add PropertySplitAddress nvarchar(255);

update Nashville
set PropertySplitAddress = SUBSTRING(
propertyaddress, 1, CHARINDEX(',',propertyaddress)-1
)

alter table nashville 
add PropertySplitCity nvarchar(255);

update Nashville 
set PropertySplitCity = SUBSTRING(
propertyaddress, CHARINDEX(',',propertyaddress)+2, len(propertyaddress)
)

Select PropertyAddress ,PropertySplitAddress, PropertySplitCity
from Nashville

select OwnerAddress
from Nashville

select
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from Nashville

alter table nashville
add OwnerSplitAddress nvarchar(255);

update Nashville
set OwnerSplitAddress =
parsename(replace(owneraddress,',','.'),3)

alter table nashville
add OwnerSplitCity nvarchar(255);

update Nashville
set OwnerSplitCity =
parsename(replace(owneraddress,',','.'),2)

alter table nashville
add OwnerSplitState nvarchar(255);

update Nashville
set OwnerSplitState =
parsename(replace(owneraddress,',','.'),1)

select *
from Nashville

select ParcelID, PropertyAddress, OwnerAddress
from Nashville

select ParcelID, [UniqueID ],PropertySplitAddress, PropertySplitCity, 
OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from Nashville

--THIS SHOULD BE DONE BEFORE REMOVING COLUMNS TO AVOID LENGTHY QUERY
Select a.ParcelID, a.ownerSplitAddress, b.ParcelID, b.propertySplitAddress, isnull(a.ownersplitaddress, b.propertysplitAddress)
from Nashville as a
join Nashville as b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
where a.ownerSplitAddress is null

update a
set OwnerSplitAddress = isnull(a.ownersplitaddress, b.PropertySplitAddress)
from Nashville as a
join Nashville as b
	on a.parcelid = b.parcelid
	--and a.[UniqueID ] <> b.[UniqueID ]
where a.ownersplitaddress is null

update a
set OwnerSplitCity = isnull(a.ownersplitCity, b.PropertySplitCity)
from Nashville as a
join Nashville as b
	on a.parcelid = b.parcelid
	--and a.[UniqueID ] <> b.[UniqueID ]
where a.ownersplitCity is null

--------------------------------------------------------------------------------

--Change Y and N, to Yes and No in "Solid as Vacant" field

Select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville
group by SoldAsVacant
order by 2

Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From Nashville

update Nashville
set SoldAsVacant =
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

--------------------------------------------------------------------------------

--Remove Duplicates
with rownumCTE as (
select *,
	Row_Number() Over(
	partition by parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
			order by uniqueid
			) row_num
from Nashville
--order by ParcelID
)
DELETE
from rownumCTE
where row_num > 1
--order by PropertyAddress

--------------------------------------------------------------------------------

--Delete Unused Columns

select *
from Nashville

alter table nashville
drop column owneraddress, taxdistrict, propertyaddress

alter table nashville
drop column saledate