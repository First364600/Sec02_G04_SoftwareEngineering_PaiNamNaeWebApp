/*
  Warnings:

  - Added the required column `selfiePhotoUrl` to the `DriverVerification` table without a default value. This is not possible if the table is not empty.
  - Added the required column `typeOnLicense` to the `DriverVerification` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "LicenseType" AS ENUM ('PRIVATE_CAR_TEMPORARY', 'PRIVATE_CAR', 'PUBLIC_CAR', 'LIFETIME');

-- AlterTable
ALTER TABLE "DriverVerification" ADD COLUMN     "selfiePhotoUrl" TEXT NOT NULL,
ADD COLUMN     "typeOnLicense" "LicenseType" NOT NULL;
