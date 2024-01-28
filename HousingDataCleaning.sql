SELECT * 
FROM Portofolioproject..HousingData

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Portofolioproject..HousingData

UPDATE HousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE HousingData
ADD SaleDateConverted Date;

UPDATE HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portofolioproject..HousingData

------------------------------------------------------------------------------------
-- Populated Property Address data

SELECT PropertyAddress
FROM Portofolioproject..HousingData
WHERE PropertyAddress IS NULL
---- 
--handling null values of propertyaddress

SELECT h1.ParcelID,h1.PropertyAddress, h2.ParcelID,h2.PropertyAddress, ISNULL(h1.PropertyAddress,h2.PropertyAddress)
FROM Portofolioproject..HousingData h1
JOIN Portofolioproject..HousingData h2
ON h1.ParcelID = h2.ParcelID AND h1.[UniqueID ] <> h2.[UniqueID ]
WHERE h1.PropertyAddress IS NULL

UPDATE h1
SET PropertyAddress =  ISNULL(h1.PropertyAddress,h2.PropertyAddress)
FROM Portofolioproject..HousingData h1
JOIN Portofolioproject..HousingData h2
ON h1.ParcelID = h2.ParcelID AND h1.[UniqueID ] <> h2.[UniqueID ]
WHERE h1.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------

-- Breaking out PropertyAddress into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portofolioproject..HousingData

SELECT 
SUBSTRING ( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING ( PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Portofolioproject..HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress NVARCHAR(255);

UPDATE HousingData
SET PropertySplitAddress = 
SUBSTRING ( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 
FROM Portofolioproject..HousingData

ALTER TABLE HousingData
ADD PropertySplitCity NVARCHAR(255);

UPDATE HousingData
SET PropertySplitCity = 
SUBSTRING ( PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM Portofolioproject..HousingData

SELECT * 
FROM Portofolioproject..HousingData


--- Handling Owner Address

SELECT OwnerAddress 
FROM Portofolioproject..HousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portofolioproject..HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE HousingData
SET OwnerSplitAddress= 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM Portofolioproject..HousingData

ALTER TABLE HousingData
ADD OwnerSplitCity NVARCHAR(255);

UPDATE HousingData
SET OwnerSplitCity = 
PARSENAME(REPLACE(OwnerAddress,',','.'),2)
FROM Portofolioproject..HousingData

ALTER TABLE HousingData
ADD OwnerSplitState NVARCHAR(255);

UPDATE HousingData
SET OwnerSplitState = 
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portofolioproject..HousingData


------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portofolioproject..HousingData
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END AS SoldAsVacantCorrected
FROM Portofolioproject..HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END 
FROM Portofolioproject..HousingData;

-------------------------------------------------------------------------------------------
--- Remove duplicates

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM Portofolioproject..HousingData
)
DELETE
FROM RowNumCTE
WHERE row_num>1

---------------------------------------------------------------------------------------------
-- DELETE unused columns

ALTER TABLE Portofolioproject..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portofolioproject..HousingData
DROP COLUMN SaleDate

SELECT * 
FROM Portofolioproject..HousingData