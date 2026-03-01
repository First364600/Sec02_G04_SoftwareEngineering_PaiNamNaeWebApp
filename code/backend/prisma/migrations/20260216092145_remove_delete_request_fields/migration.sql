/*
  Warnings:

  - You are about to drop the column `approvedAt` on the `DeleteAccountRequest` table. All the data in the column will be lost.
  - You are about to drop the column `approvedBy` on the `DeleteAccountRequest` table. All the data in the column will be lost.
  - You are about to drop the column `createdAt` on the `DeleteAccountRequest` table. All the data in the column will be lost.
  - You are about to drop the column `notes` on the `DeleteAccountRequest` table. All the data in the column will be lost.
  - You are about to drop the column `reason` on the `DeleteAccountRequest` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "DeleteAccountRequest" DROP COLUMN "approvedAt",
DROP COLUMN "approvedBy",
DROP COLUMN "createdAt",
DROP COLUMN "notes",
DROP COLUMN "reason";
