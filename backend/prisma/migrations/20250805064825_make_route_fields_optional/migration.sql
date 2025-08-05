/*
  Warnings:

  - Added the required column `updatedAt` to the `Route` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Route" ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "waypoints" DROP NOT NULL,
ALTER COLUMN "landmarks" DROP NOT NULL,
ALTER COLUMN "steps" DROP NOT NULL;
