
--DATA CLEANING IN SQL

SELECT *
FROM [Portfolio Project].dbo.Nashville



-- STANDARDIZE AND FORMAT THE SALE DATE

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [Portfolio Project].dbo.Nashville

UPDATE Nashville
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE Nashville
ADD SaleDateNew Date

UPDATE Nashville
SET SaleDateNew = CONVERT(Date, SaleDate)

SELECT SaleDateNew, CONVERT(Date,SaleDate)
FROM [Portfolio Project].dbo.Nashville

--POPULATE PROPERTY ADDRESS COLUMN

SELECT *
FROM [Portfolio Project].dbo.Nashville
WHERE PropertyAddress is NULL
ORDER BY ParcelID

--Looking through the data, we will find that properties with the same parcel IDs have the same Property Address.
--Populating the missing property Addresses with Addresses that have corresponding Parcel IDs.


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.Nashville a
JOIN [Portfolio Project].dbo.Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL 

--Doing a self join of the Nashville data to match properties with the same Parcel ID and different Unique ID.

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.Nashville a
JOIN [Portfolio Project].dbo.Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL 


SELECT PropertyAddress
FROM [Portfolio Project].dbo.Nashville

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].dbo.Nashville

ALTER TABLE [Portfolio Project].dbo.Nashville
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE [Portfolio Project].dbo.Nashville
ADD PropertySplitCity Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT*
FROM [Portfolio Project].dbo.Nashville

SELECT OwnerAddress
FROM [Portfolio Project].dbo.Nashville

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM [Portfolio Project].dbo.Nashville

ALTER TABLE [Portfolio Project].dbo.Nashville
Add OwnerSplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Portfolio Project].dbo.Nashville
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Portfolio Project].dbo.Nashville
ADD OwnerSplitState Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT *
FROM [Portfolio Project].dbo.Nashville




-- CHANGE Y AND N to YES AND NO IN "SOLD AS VACANT" FIELD


SELECT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.Nashville
GROUP BY SoldAsVacant
ORDER BY 2




Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Portfolio Project].dbo.Nashville


UPDATE [Portfolio Project].dbo.Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END







--REMOVING DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Portfolio Project].dbo.Nashville
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT *
FROM [Portfolio Project].dbo.Nashville






-- DELETING UNNECESSARY COLUMNS


SELECT *
FROM [Portfolio Project].dbo.Nashville


ALTER TABLE [Portfolio Project].dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


SELECT *
FROM [Portfolio Project].dbo.Nashville
ORDER BY [UniqueID ]
