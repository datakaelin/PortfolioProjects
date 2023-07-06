/* 

Cleaning Data in SQL Queries

*/

Select *
From AdventureWorksDW2022.dbo.[NashvilleHousing ]


------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


Select *
From AdventureWorksDW2022.dbo.[NashvilleHousing ]
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From AdventureWorksDW2022.dbo.[NashvilleHousing ] a
JOIN AdventureWorksDW2022.dbo.[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From AdventureWorksDW2022.dbo.[NashvilleHousing ] a
JOIN AdventureWorksDW2022.dbo.[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From AdventureWorksDW2022.dbo.[NashvilleHousing ]
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))as Address

From AdventureWorksDW2022.dbo.[NashvilleHousing ]


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVarchar(255);

Update [NashvilleHousing ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVarchar(255);

Update [NashvilleHousing ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From AdventureWorksDW2022.dbo.[NashvilleHousing ]




Select OwnerAddress
From AdventureWorksDW2022.dbo.[NashvilleHousing ]




Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
From AdventureWorksDW2022.dbo.[NashvilleHousing ]



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVarchar(255);

Update [NashvilleHousing ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVarchar(255);

Update [NashvilleHousing ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVarchar(255);

Update [NashvilleHousing ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)


---------------------------------------------------------------------------------------------------------------------------

-- Change 0 and 1 to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From AdventureWorksDW2022.dbo.[NashvilleHousing ]
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = '1' THEN 'Yes'
	 When SoldAsVacant = '0' THEN 'No'
	 Else SoldAsVacant
	 END
From AdventureWorksDW2022.dbo.[NashvilleHousing ]

Update [NashvilleHousing ]
SET SoldAsVacant = CASE When SoldAsVacant = '1' THEN 'Yes'
	 When SoldAsVacant = '0' THEN 'No'
	 Else SoldAsVacant
	 END

------------------------------------------------------------------------------------------------------

-- Remove Duplicates
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
			

From AdventureWorksDW2022.dbo.[NashvilleHousing ]
--ORDER BY ParcelID
)
Select *
From RowNumCTE
Where row_num > 1


-------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From AdventureWorksDW2022.dbo.[NashvilleHousing ]

ALTER TABLE AdventureWorksDW2022.dbo.[NashvilleHousing ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
